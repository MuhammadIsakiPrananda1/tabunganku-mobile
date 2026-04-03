import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/shopping_item_model.dart';
import 'package:tabunganku/services/shopping_item_service.dart';

// Provider for ShoppingItemService
final shoppingItemServiceProvider = Provider<ShoppingItemService>((ref) {
  return MockShoppingItemService();
});

// Provider for watching all shopping items
final shoppingItemsStreamProvider =
    StreamProvider.autoDispose<List<ShoppingItem>>((ref) {
  final service = ref.watch(shoppingItemServiceProvider);
  return service.watchItems();
});
