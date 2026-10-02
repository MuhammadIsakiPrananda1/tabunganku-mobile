/// Service: CurrencyService
//
// Mengambil kurs mata uang dari API dan menyimpan cache lokal.
/// Menyimpan data lokal di [SharedPreferences] per user.
/// v1.5.3 — Optimalisasi: parallel fetch, cache TTL 5 menit, endpoint API terbaru.
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currencyServiceProvider = Provider((ref) => CurrencyService());

class CurrencyRatesData {
  final Map<String, double> rates;
  final DateTime lastUpdated;
  final bool isLive;

  const CurrencyRatesData({
    required this.rates,
    required this.lastUpdated,
    this.isLive = true,
  });
}

final currencyRatesProvider =
    AsyncNotifierProvider<CurrencyRatesNotifier, Map<String, double>>(() {
  return CurrencyRatesNotifier();
});

class CurrencyRatesNotifier extends AsyncNotifier<Map<String, double>> {
  DateTime? lastUpdated;

  @override
  FutureOr<Map<String, double>> build() async {
    final rates = await ref.read(currencyServiceProvider).fetchLatestRates();
    lastUpdated = DateTime.now();
    return rates;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    // Paksa bypass cache saat refresh manual
    final rates = await ref.read(currencyServiceProvider).fetchLatestRates(bypassCache: true);
    lastUpdated = DateTime.now();
    state = AsyncData(rates);
  }
}

class CurrencyService {
  static const String _cacheKey = 'currency_rates_cache_v2';
  static const String _cacheTimestampKey = 'currency_rates_timestamp_v2';
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// Daftar endpoint primer (real-time, diurutkan berdasarkan keandalan & kecepatan)
  static const List<String> _primaryEndpoints = [
    // Frankfurter (ECB-based, sangat stabil, free)
    'https://api.frankfurter.dev/v1/latest?base=USD',
    // Open Exchange Rates (fallback cepat)
    'https://open.er-api.com/v6/latest/USD',
    // ExchangeRate-API (terpercaya)
    'https://api.exchangerate-api.com/v4/latest/USD',
  ];

  /// Endpoint sekunder / CDN (biasanya lebih lambat tapi andal)
  static const List<String> _secondaryEndpoints = [
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
    'https://raw.githubusercontent.com/fawazahmed0/currency-api/1/latest/currencies/usd.json',
  ];

  /// Fetch kurs terbaru dengan strategi:
  /// 1. Baca dari cache lokal jika masih valid (< 5 menit)
  /// 2. Parallel race antara 3 endpoint primer (ambil yang paling cepat)
  /// 3. Fallback ke endpoint sekunder
  /// 4. Fallback ke kurs offline hardcoded
  Future<Map<String, double>> fetchLatestRates({bool bypassCache = false}) async {
    // 1. Baca cache lokal jika belum kedaluwarsa
    if (!bypassCache) {
      final cached = await _readCache();
      if (cached != null) {
        debugPrint('[CurrencyService] Menggunakan cache lokal (TTL ${_cacheTtl.inMinutes} menit)');
        return cached;
      }
    }

    // 2. Race parallel endpoint primer (ambil respons tercepat)
    final result = await _raceEndpoints(_primaryEndpoints, timeoutMs: 4000);
    if (result != null) {
      await _writeCache(result);
      return result;
    }

    // 3. Coba endpoint sekunder secara berurutan
    for (final url in _secondaryEndpoints) {
      final secondary = await _fetchFromUrl(url, timeoutMs: 5000);
      if (secondary != null) {
        await _writeCache(secondary);
        return secondary;
      }
    }

    // 4. Fallback ke kurs offline yang dikalibrasi ke pasar terkini
    debugPrint('[CurrencyService] Semua API gagal — menggunakan kurs offline');
    return _offlineFallbackRates;
  }

  /// Race parallel: kirim semua request bersamaan, ambil hasil pertama yang valid
  Future<Map<String, double>?> _raceEndpoints(
    List<String> urls, {
    required int timeoutMs,
  }) async {
    final completer = Completer<Map<String, double>?>();
    int pendingCount = urls.length;

    for (final url in urls) {
      _fetchFromUrl(url, timeoutMs: timeoutMs).then((result) {
        if (result != null && !completer.isCompleted) {
          completer.complete(result);
        } else {
          pendingCount--;
          if (pendingCount <= 0 && !completer.isCompleted) {
            completer.complete(null);
          }
        }
      }).catchError((_) {
        pendingCount--;
        if (pendingCount <= 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    return completer.future.timeout(
      Duration(milliseconds: timeoutMs + 500),
      onTimeout: () => null,
    );
  }

  /// Fetch dari satu URL dan parse hasilnya
  Future<Map<String, double>?> _fetchFromUrl(String url, {required int timeoutMs}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(Duration(milliseconds: timeoutMs));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return null;

      Map<String, dynamic>? rawRates;

      // Format: { rates: { IDR: ..., EUR: ... } }
      if (data.containsKey('rates') && data['rates'] is Map) {
        rawRates = Map<String, dynamic>.from(data['rates'] as Map);
      }
      // Format Fawazahmed0: { usd: { idr: ..., eur: ... } }
      else if (data.containsKey('usd') && data['usd'] is Map) {
        rawRates = Map<String, dynamic>.from(data['usd'] as Map);
      }

      if (rawRates == null) return null;

      double? usdToIdr;
      rawRates.forEach((key, value) {
        if (key.toUpperCase() == 'IDR') {
          usdToIdr = double.tryParse(value.toString());
        }
      });

      if (usdToIdr == null || usdToIdr! <= 0) return null;

      final Map<String, double> idrRates = {'IDR': 1.0, 'USD': usdToIdr!};
      rawRates.forEach((code, rateVal) {
        final upperCode = code.toUpperCase();
        final double? val = double.tryParse(rateVal.toString());
        if (val != null && val > 0) {
          idrRates[upperCode] = usdToIdr! / val;
        }
      });

      debugPrint('[CurrencyService] Berhasil fetch dari $url — IDR/USD: $usdToIdr');
      return idrRates;
    } catch (e) {
      debugPrint('[CurrencyService] Gagal fetch dari $url: $e');
      return null;
    }
  }

  // ─── Cache Management ──────────────────────────────────────────────────────

  Future<Map<String, double>?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampRaw = prefs.getString(_cacheTimestampKey);
      if (timestampRaw == null) return null;

      final timestamp = DateTime.tryParse(timestampRaw);
      if (timestamp == null) return null;

      final age = DateTime.now().difference(timestamp);
      if (age > _cacheTtl) return null; // cache kedaluwarsa

      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, double.parse(v.toString())));
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(Map<String, double> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rates));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // ─── Fallback Offline (dikalibrasi ke kurs pasar terkini) ─────────────────

  static const Map<String, double> _offlineFallbackRates = {
    'IDR': 1.0,
    'USD': 17865.0,
    'EUR': 20680.0,
    'SGD': 13976.0,
    'JPY': 111.95,
    'SAR': 4764.0,
    'MYR': 4401.0,
    'AUD': 12670.0,
    'GBP': 24175.0,
    'CNY': 2644.0,
    'HKD': 2277.0,
    'KRW': 12.65,
    'THB': 539.0,
    'VND': 0.684,
    'PHP': 289.0,
    'CAD': 12860.0,
    'CHF': 21980.0,
    'TWD': 560.0,
    'NZD': 10500.0,
    'BRL': 3430.0,
  };
}
