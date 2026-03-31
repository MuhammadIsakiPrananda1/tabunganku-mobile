import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/friend_model.dart';
import 'package:tabunganku/services/friend_service.dart';

// Provider untuk FriendService
final friendServiceProvider = Provider<FriendService>((ref) {
  // Timpa dengan Firebase service nanti
  return MockFriendService();
});

// Provider untuk mendapatkan semua teman
final friendsProvider = FutureProvider<List<FriendModel>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriends();
});

// Provider untuk menonton teman secara real-time
final friendsStreamProvider = StreamProvider<List<FriendModel>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return service.watchFriends();
});

// Provider untuk teman tertentu
final friendProvider = FutureProvider.family<FriendModel, String>((ref, id) async {
  final service = ref.watch(friendServiceProvider);
  return service.getFriend(id);
});
