import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';
import 'package:tabunganku/models/transaction_model.dart';

/// Service untuk mengelola data transaksi
/// Timpa dengan Firebase/REST API nanti
abstract class TransactionService {
    /// Hapus semua transaksi user saat ini
    Future<void> clearAllTransactions();
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> getTransaction(String id);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchTransactions();
}

/// Mock implementation untuk testing
class MockTransactionService implements TransactionService {
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
    await _ensureUserLoaded(userId);
    _userTransactions[userId]!.add(transaction);
    await _saveUserTransactions(userId);
    await _emitTransactions(userId);
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
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final userId = await _getCurrentUserId();
    await _ensureUserLoaded(userId);
    _userTransactions[userId]!.removeWhere((t) => t.id == id);
    await _saveUserTransactions(userId);
    await _emitTransactions(userId);
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return Stream<List<TransactionModel>>.multi((controller) {
      Future<void>(() async {
        final userId = await _getCurrentUserId();
        await _ensureUserLoaded(userId);
        final ordered = _ordered(_userTransactions[userId] ?? const <TransactionModel>[]);
        controller.add(List.unmodifiable(ordered));
      });
      final subscription = _streamController.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }
}
