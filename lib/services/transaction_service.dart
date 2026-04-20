import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/services/challenge_service.dart';

/// Service untuk mengelola data transaksi
/// Menggabungkan data Lokal (Pribadi) dan Cloud (Grup Keluarga)
abstract class TransactionService {
  /// Hapus semua transaksi user saat ini
  Future<void> clearAllTransactions();
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> getTransaction(String id);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  
  /// Menonton transaksi secara real-time.
  /// Jika groupId diberikan, juga akan menggabungkan data dari Firestore.
  Stream<List<TransactionModel>> watchTransactions([String? groupId]);
}

/// Hybrid implementation: Local for Personal, Firestore for Group
class MockTransactionService implements TransactionService {
  final ChallengeService? challengeService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MockTransactionService({this.challengeService});

  @override
    Future<void> clearAllTransactions() async {
      final userId = await _getCurrentUserId();
      await _ensureUserLoaded(userId);
      _userTransactions[userId] = [];
      await _saveUserTransactions(userId);
      await _emitTransactions(userId);
    }
  static const String _storagePrefix = 'transactions_user_';
  static final SecureStorageService _secureStorage = SecureStorageService();
  static Future<SharedPreferences>? _prefsFuture;
  static final Map<String, List<TransactionModel>> _userTransactions = {};
  static final StreamController<List<TransactionModel>> _streamController =
      StreamController<List<TransactionModel>>.broadcast();

  Future<SharedPreferences> _getPrefs() {
    _prefsFuture ??= SharedPreferences.getInstance();
    return _prefsFuture!;
  }

  Future<String> _getCurrentUserId() async {
    final userId = await _secureStorage.getUserId();
    return (userId == null || userId.isEmpty) ? 'guest' : userId;
  }

  Future<void> _ensureUserLoaded(String userId) async {
    if (_userTransactions.containsKey(userId)) {
      return;
    }

    final prefs = await _getPrefs();
    final raw = prefs.getString('$_storagePrefix$userId');
    if (raw == null || raw.isEmpty) {
      _userTransactions[userId] = [];
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _userTransactions[userId] = decoded
            .whereType<Map>()
            .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _userTransactions[userId] = [];
      }
    } catch (_) {
      _userTransactions[userId] = [];
    }
  }

  Future<void> _saveUserTransactions(String userId) async {
    final prefs = await _getPrefs();
    final list = _userTransactions[userId] ?? const <TransactionModel>[];
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString('$_storagePrefix$userId', raw);
  }

  List<TransactionModel> _ordered(List<TransactionModel> items) {
    final ordered = List<TransactionModel>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return ordered;
  }

  Future<void> _emitTransactions(String userId) async {
    await _ensureUserLoaded(userId);
    final ordered = _ordered(_userTransactions[userId] ?? const <TransactionModel>[]);
    _streamController.add(List.unmodifiable(ordered));
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    final ordered = _ordered(_userTransactions[userId] ?? const <TransactionModel>[]);
    return List.unmodifiable(ordered);
  }

  @override
  Future<TransactionModel> getTransaction(String id) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    final transactions = _userTransactions[userId] ?? const <TransactionModel>[];
    return transactions.firstWhere((t) => t.id == id);
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final userId = await _getCurrentUserId();
    
    // 1. Save Locally (Optional for group, but keeps a local backup)
    await _ensureUserLoaded(userId);
    _userTransactions[userId]!.add(transaction);
    await _saveUserTransactions(userId);
    await _emitTransactions(userId);

    // 2. Sync to Firestore if it's a group transaction
    if (transaction.groupId != null && transaction.groupId!.isNotEmpty) {
      try {
        await _firestore
            .collection('family_groups')
            .doc(transaction.groupId)
            .collection('transactions')
            .doc(transaction.id)
            .set(transaction.toJson());
      } catch (e) {
        print("ERROR: Gagal sinkronisasi transaksi ke Cloud: $e");
      }
    }

    // Trigger challenge update
    if (challengeService != null) {
      await challengeService!.checkAndUpdateChallengeFromTransaction(transaction);
    }

    return transaction;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    final transactions = _userTransactions[userId]!;
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await _saveUserTransactions(userId);
      await _emitTransactions(userId);
    }

    // Firestore Sync
    if (transaction.groupId != null && transaction.groupId!.isNotEmpty) {
      try {
        await _firestore
            .collection('family_groups')
            .doc(transaction.groupId)
            .collection('transactions')
            .doc(transaction.id)
            .update(transaction.toJson());
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    
    // Find transaction to check for groupId before deletion
    final txToDelete = _userTransactions[userId]!.firstWhere((t) => t.id == id, orElse: () => throw Exception("Not found"));
    final groupId = txToDelete.groupId;

    _userTransactions[userId]!.removeWhere((t) => t.id == id);
    await _saveUserTransactions(userId);
    await _emitTransactions(userId);

    // Firestore Sync
    if (groupId != null && groupId.isNotEmpty) {
      try {
        await _firestore
            .collection('family_groups')
            .doc(groupId)
            .collection('transactions')
            .doc(id)
            .delete();
      } catch (_) {}
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions([String? groupId]) {
    // Controller to manage the merged stream
    final controller = StreamController<List<TransactionModel>>.broadcast();

    // 1. Subscription to local data changes via _streamController
    StreamSubscription<List<TransactionModel>>? localSub;
    
    // 2. Subscription to Firestore if groupId is present
    StreamSubscription<QuerySnapshot>? firestoreSub;

    // Buffer to hold latest data from both sources
    List<TransactionModel> latestLocal = [];
    List<TransactionModel> latestCloud = [];

    void emitMerged() {
      // Use a Map to deduplicate by ID, preferring Cloud data if it matches
      final Map<String, TransactionModel> mergedMap = {};
      
      // Load local first
      for (var tx in latestLocal) {
        mergedMap[tx.id] = tx;
      }
      
      // Overwrite/Add Cloud transactions
      // This ensures that even if local data is stale or missing (for new members),
      // the cloud data is present.
      for (var tx in latestCloud) {
        mergedMap[tx.id] = tx;
      }

      final mergedList = mergedMap.values.toList();
      if (!controller.isClosed) {
        controller.add(_ordered(mergedList));
      }
    }

    // Initialize local data
    Future<void> init() async {
      final userId = await _getCurrentUserId();
      await _ensureUserLoaded(userId);
      latestLocal = _userTransactions[userId] ?? [];
      
      // Listen to future local changes
      localSub = _streamController.stream.listen((newList) {
        latestLocal = newList;
        emitMerged();
      });

      // Start Firestore listener if groupId is provided
      if (groupId != null && groupId.isNotEmpty) {
        firestoreSub = _firestore
            .collection('family_groups')
            .doc(groupId)
            .collection('transactions')
            .snapshots()
            .listen((snapshot) {
          latestCloud = snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList();
          emitMerged();
        }, onError: (e) => print("Firestore Stream Error: $e"));
      }

      emitMerged();
    }

    init();

    controller.onCancel = () {
      localSub?.cancel();
      firestoreSub?.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
