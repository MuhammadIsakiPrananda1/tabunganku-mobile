import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_group_model.dart';
import '../models/transaction_model.dart';
import './transaction_provider.dart';

/// Provider that watches family transactions and automatically syncs the total balance to Firestore
final familyBalanceSyncProvider = Provider.autoDispose<void>((ref) {
  final groupId = ref.watch(userGroupIdProvider);
  if (groupId == null || groupId.isEmpty) return;

  ref.listen(transactionsByGroupProvider(groupId), (previous, next) {
    final totalBalance = next.fold(0.0, (sum, t) => 
      sum + (t.type == TransactionType.income ? t.amount : -t.amount));
    
    // Perform sync in background
    ref.read(familyGroupServiceProvider).syncLocalBalance(totalBalance);
  }, fireImmediately: true);
});


// User Profile Model
class UserProfile {
  final String name;
  final int avatarIndex;
  final int colorIndex;

  UserProfile({
    required this.name,
    this.avatarIndex = 0,
    this.colorIndex = 0,
  });

  UserProfile copyWith({
    String? name,
    int? avatarIndex,
    int? colorIndex,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}

// User Profile Provider (Locally Stored in SharedPreferences)
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

// For backward compatibility
final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProfileProvider).name;
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref ref;
  UserProfileNotifier(this.ref) : super(UserProfile(name: '')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('user_name') ?? '';
    int avatar = prefs.getInt('user_avatar') ?? 0;
    int color = prefs.getInt('user_color') ?? 0;
    
    // Cleanup old random names if they still exist
    final prefixes = ['Sultan', 'Jagoan', 'Pejuang', 'Juragan', 'Master', 'Pendekar', 'Bintang'];
    final suffixes = ['Hemat', 'Cuan', 'Tabung', 'MasaDepan', 'Bijak', 'Sukses'];
    
    bool isRandom = false;
    for (var p in prefixes) {
      for (var s in suffixes) {
        if (name == '$p $s') {
          isRandom = true;
          break;
        }
      }
    }

    if (isRandom) {
      await prefs.remove('user_name');
      name = '';
    }
    
    state = UserProfile(name: name, avatarIndex: avatar, colorIndex: color);
  }

  Future<void> updateProfile({String? name, int? avatarIndex, int? colorIndex}) async {
    final prefs = await SharedPreferences.getInstance();
    final oldName = state.name;
    final newName = name?.trim() ?? oldName;

    if (newName.isEmpty && oldName.isEmpty) return;

    // Save to Local
    if (name != null) await prefs.setString('user_name', newName);
    if (avatarIndex != null) await prefs.setInt('user_avatar', avatarIndex);
    if (colorIndex != null) await prefs.setInt('user_color', colorIndex);

    state = state.copyWith(
      name: newName,
      avatarIndex: avatarIndex,
      colorIndex: colorIndex,
    );

    // Sync to Firestore if in a group and name changed
    if (name != null && newName != oldName && oldName.isNotEmpty) {
      try {
        await ref.read(familyGroupServiceProvider).updateMemberName(oldName, newName);
      } catch (e) {
        print("Failed to sync name change: $e");
      }
    }
  }

  Future<void> setName(String name) => updateProfile(name: name);
}

// User Group ID Provider (Locally Stored in SharedPreferences)
final userGroupIdProvider = StateNotifierProvider<UserGroupIdNotifier, String?>((ref) {
  return UserGroupIdNotifier();
});

class UserGroupIdNotifier extends StateNotifier<String?> {
  UserGroupIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('group_id');
  }

  Future<void> setGroupId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('group_id');
    } else {
      await prefs.setString('group_id', id);
    }
    state = id;
  }
}

// Stream to listen to the specific group document from Firebase in real-time
final familyGroupStreamProvider = StreamProvider.autoDispose<FamilyGroupModel?>((ref) {
  final groupId = ref.watch(userGroupIdProvider);
  if (groupId == null || groupId.isEmpty) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('family_groups')
      .doc(groupId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return FamilyGroupModel.fromJson(snapshot.data()!);
  });
});

// A service to perform group actions
final familyGroupServiceProvider = Provider<FamilyGroupService>((ref) {
  return FamilyGroupService(ref);
});

class FamilyGroupService {
  final Ref ref;

  FamilyGroupService(this.ref);

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    return code;
  }

  Future<void> createGroup(String groupName) async {
    final userName = ref.read(userNameProvider);
    if (userName.isEmpty) throw Exception("Nama belum diatur. Silakan atur nama kamu terlebih dahulu!");

    final code = _generateUniqueCode();
    final docRef = FirebaseFirestore.instance.collection('family_groups').doc();

    final group = FamilyGroupModel(
      id: docRef.id,
      code: code,
      name: groupName,
      adminName: userName,
      members: [userName],
      memberBalances: {userName: 0.0},
    );

    // Save to Firebase
    try {
      await docRef.set(group.toJson());
      // Save to Local
      await ref.read(userGroupIdProvider.notifier).setGroupId(docRef.id);
    } catch (e) {
      throw Exception("Gagal membuat grup: Izin ditolak. Pastikan aturan (Rules) di Firebase Console sudah diizinkan.");
    }
  }

  Future<void> joinGroup(String code) async {
    final userName = ref.read(userNameProvider);
    if (userName.isEmpty) throw Exception("Nama belum diatur. Silakan atur nama kamu terlebih dahulu!");

    final query = await FirebaseFirestore.instance
        .collection('family_groups')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception("Kode keluarga salah atau kadaluarsa.");

    final doc = query.docs.first;
    final groupData = doc.data();
    final List<String> members = List<String>.from(groupData['members'] ?? []);
    
    if (members.length >= 5) {
      throw Exception("Gagal bergabung: Anggota keluarga sudah maksimal (5 orang).");
    }

    final groupId = doc.id;

    // Fast update: and merge balance
    try {
      await doc.reference.update({
        'members': FieldValue.arrayUnion([userName]),
        'memberBalances.$userName': 0.0, // Initialize or keep as is if exists (Firestore merge notation)
      });

      // Save Local
      await ref.read(userGroupIdProvider.notifier).setGroupId(groupId);
    } catch (e) {
      throw Exception("Gagal bergabung: $e");
    }
  }

  Future<void> leaveGroup() async {
    final groupId = ref.read(userGroupIdProvider);
    final userName = ref.read(userNameProvider);

    if (groupId != null && groupId.isNotEmpty && userName.isNotEmpty) {
      final docRef = FirebaseFirestore.instance.collection('family_groups').doc(groupId);
      // Fast Leave: remove from members list but keep balance for history
      try {
        await docRef.update({
          'members': FieldValue.arrayRemove([userName])
        });
      } catch (_) {
        // If doc doesn't exist, ignore
      }
    }

    await ref.read(userGroupIdProvider.notifier).setGroupId(null);
  }

  /// Called whenever a transaction changes to sync local net worth to the cloud
  Future<void> syncLocalBalance(double localTotalBalance) async {
    final groupId = ref.read(userGroupIdProvider);
    final userName = ref.read(userNameProvider);

    if (groupId == null || groupId.isEmpty || userName.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('family_groups').doc(groupId);
    
    // We use SetOptions(merge: true) to only overwrite our specific user's balance
    await docRef.set({
      'memberBalances': {
        userName: localTotalBalance
      }
    }, SetOptions(merge: true));
  }

  /// Tries to find a random name in the group and replace it with the current user's name
  /// Useful if the user's name was cleared locally but still exists in the cloud as a random name.
  Future<void> trySyncMemberName(String currentUserName) async {
    final groupId = ref.read(userGroupIdProvider);
    if (groupId == null || groupId.isEmpty || currentUserName.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('family_groups').doc(groupId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final List<String> members = List<String>.from(data['members'] ?? []);
    
    if (members.contains(currentUserName)) return;

    // Check for any random names in the group
    final prefixes = ['Sultan', 'Jagoan', 'Pejuang', 'Juragan', 'Master', 'Pendekar', 'Bintang'];
    final suffixes = ['Hemat', 'Cuan', 'Tabung', 'MasaDepan', 'Bijak', 'Sukses'];

    String? foundRandomName;
    for (var member in members) {
      for (var p in prefixes) {
        for (var s in suffixes) {
          if (member == '$p $s') {
            foundRandomName = member;
            break;
          }
        }
        if (foundRandomName != null) break;
      }
      if (foundRandomName != null) break;
    }

    if (foundRandomName != null) {
      // If we found a random name and the current user is NOT in the group,
      // it's VERY likely this random name IS the current user.
      await updateMemberName(foundRandomName, currentUserName);
    }
  }

  /// Renames a member in Firestore (updates list, map keys, and admin name)
  Future<void> updateMemberName(String oldName, String newName) async {
    final groupId = ref.read(userGroupIdProvider);
    if (groupId == null || groupId.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('family_groups').doc(groupId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final members = List<String>.from(data['members'] ?? []);
      final balances = Map<String, dynamic>.from(data['memberBalances'] ?? {});
      String adminName = data['adminName'] ?? '';

      // Update members list
      members.remove(oldName);
      if (!members.contains(newName)) {
        members.add(newName);
      }

      // Update balances map (re-key)
      if (balances.containsKey(oldName)) {
        final balanceValue = balances[oldName];
        balances.remove(oldName);
        balances[newName] = balanceValue;
      } else {
        balances[newName] = 0.0;
      }

      // Update admin name if needed
      if (adminName == oldName) {
        adminName = newName;
      }

      transaction.update(docRef, {
        'members': members,
        'memberBalances': balances,
        'adminName': adminName,
      });
    });
  }
}
