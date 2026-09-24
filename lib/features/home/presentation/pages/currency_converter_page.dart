/// Page: CurrencyConverterPage
///
/// Konversi mata uang asing secara real-time / lokal.
library;

import 'package:tabunganku/core/widgets/offline_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/services/currency_service.dart';
import 'package:tabunganku/core/utils/currency_formatter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  String _amountStr = '1';
  bool _isLoading = true;
  
  late TextEditingController _amountController;
  late FocusNode _amountFocusNode;

  bool _isNoInternetDialogShowing = false;
  BuildContext? _dialogContext;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'flag': '🇮🇩', 'rate': 1.0, 'symbol': 'Rp'},
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸', 'rate': 17865.0, 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'rate': 20680.0, 'symbol': '€'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'flag': '🇸🇬', 'rate': 13976.0, 'symbol': 'S\$'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵', 'rate': 111.95, 'symbol': '¥'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'flag': '🇸🇦', 'rate': 4764.0, 'symbol': 'SR'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾', 'rate': 4401.0, 'symbol': 'RM'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺', 'rate': 12670.0, 'symbol': 'A\$'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧', 'rate': 24175.0, 'symbol': '£'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'flag': '🇨🇳', 'rate': 2644.0, 'symbol': '¥'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'flag': '🇭🇰', 'rate': 2277.0, 'symbol': 'HK\$'},
    {'code': 'KRW', 'name': 'South Korean Won', 'flag': '🇰🇷', 'rate': 12.65, 'symbol': '₩'},
    {'code': 'THB', 'name': 'Thai Baht', 'flag': '🇹🇭', 'rate': 539.0, 'symbol': '฿'},
    {'code': 'VND', 'name': 'Vietnamese Dong', 'flag': '🇻🇳', 'rate': 0.684, 'symbol': '₫'},
    {'code': 'PHP', 'name': 'Philippine Peso', 'flag': '🇵🇭', 'rate': 289.0, 'symbol': '₱'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦', 'rate': 12860.0, 'symbol': 'C\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭', 'rate': 21980.0, 'symbol': 'CHF'},
    {'code': 'TWD', 'name': 'Taiwan Dollar', 'flag': '🇹🇼', 'rate': 560.0, 'symbol': 'NT\$'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'flag': '🇳🇿', 'rate': 10500.0, 'symbol': 'NZ\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'flag': '🇧🇷', 'rate': 3430.0, 'symbol': 'R\$'},
  ];

  late Map<String, dynamic> _fromCurrency;
  late Map<String, dynamic> _toCurrency;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amountStr);
    _amountFocusNode = FocusNode();

    _fromCurrency = _currencies[1]; // USD
    _toCurrency = _currencies[0]; // IDR

    final initialRates = ref.read(currencyRatesProvider).value;
    if (initialRates != null) {
      _updateRatesFromMap(initialRates);
      _isLoading = false;
    } else {
      _isLoading = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRates();
      _checkInternet();
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetPopup();
      } else {
        _dismissNoInternetPopup();
        _fetchRates();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none) && mounted) {
      _showNoInternetPopup();
    }
  }

  void _showNoInternetPopup() {
    if (_isNoInternetDialogShowing) return;
    _isNoInternetDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogCtx) {
        _dialogContext = dialogCtx;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final accentColor = isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _dismissNoInternetPopup();
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: OfflineLoadingDialog(
            title: 'Koneksi Valas Terputus',
            message: 'Sambungkan ke internet untuk memperbarui kurs valas live dan memproses data.',
            accentColor: accentColor,
            onDismiss: () {
              _dismissNoInternetPopup();
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            onRetry: () {
              _fetchRates();
              _dismissNoInternetPopup();
            },
          ),
        );
      },
    ).then((_) {
      _isNoInternetDialogShowing = false;
      _dialogContext = null;
    });
  }

  void _dismissNoInternetPopup() {
    if (_isNoInternetDialogShowing && _dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _isNoInternetDialogShowing = false;
      _dialogContext = null;
    }
  }

  void _updateRatesFromMap(Map<String, double> rates) {
    for (var curr in _currencies) {
      if (rates.containsKey(curr['code'])) {
        curr['rate'] = rates[curr['code']];
      }
    }
    _fromCurrency = _currencies.firstWhere(
      (c) => c['code'] == _fromCurrency['code'],
      orElse: () => _currencies[1],
    );
    _toCurrency = _currencies.firstWhere(
      (c) => c['code'] == _toCurrency['code'],
      orElse: () => _currencies[0],
    );
  }

  Future<void> _fetchRates() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await ref.read(currencyRatesProvider.notifier).refresh();
  }

  void _swapCurrencies() {
    HapticFeedback.selectionClick();
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  double get _convertedAmount {
    final cleanStr = _amountStr.replaceAll('.', '');
    final amount = double.tryParse(cleanStr) ?? 0.0;
    final fromRate = (_fromCurrency['rate'] as num?)?.toDouble() ?? 1.0;
    final toRate = (_toCurrency['rate'] as num?)?.toDouble() ?? 1.0;
    if (toRate == 0) return 0.0;
    return amount * fromRate / toRate;
  }

  String _formatValue(double value) {
    final isTargetIdr = _toCurrency['code'] == 'IDR';
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: isTargetIdr ? 0 : (value < 1 && value > 0 ? 4 : 2),
    );
    return format.format(value).trim();
  }

  String _formatUnitRate(double rate) {
    if (rate >= 100) {
      return NumberFormat('#,##0.00', 'id_ID').format(rate);
    } else if (rate >= 1) {
      return NumberFormat('#,##0.0000', 'id_ID').format(rate);
    } else {
      return NumberFormat('0.000000', 'id_ID').format(rate);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currencyRatesProvider, (prev, next) {
      next.whenData((rates) {
        if (mounted) {
          setState(() {
            _updateRatesFromMap(rates);
            _isLoading = false;
          });
        }
      });
    });

    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor =
        isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9);

    final fromRate = (_fromCurrency['rate'] as num?)?.toDouble() ?? 1.0;
    final toRate = (_toCurrency['rate'] as num?)?.toDouble() ?? 1.0;
    final unitRate = toRate > 0 ? fromRate / toRate : 1.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: pageBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              _dismissNoInternetPopup();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: contentColor, size: 20),
          ),
          title: Text(
            'Konverter Valas',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: contentColor,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: accentColor, size: 20),
              tooltip: 'Perbarui Kurs',
              onPressed: _fetchRates,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 2,
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchRates();
                },
                color: accentColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Live Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kurs Real-Time Online',
                              style: GoogleFonts.quicksand(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildReferenceLabel('Dari', isDarkMode),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              autofocus: false,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                RibuanFormatter(),
                              ],
                              cursorColor: accentColor,
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade50,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 8),
                                  child: Text(
                                    _fromCurrency['symbol'],
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0, minHeight: 0),
                                hintText: '0',
                                hintStyle: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor.withValues(alpha: 0.3),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: accentColor,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _amountStr = value.isEmpty ? '0' : value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCurrencyPickerButton(
                              _fromCurrency, true, accentColor),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Center(
                        child: IconButton(
                          onPressed: _swapCurrencies,
                          icon: Icon(Icons.swap_vert_rounded,
                              color: accentColor, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                accentColor.withValues(alpha: 0.08),
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildReferenceLabel('Ke', isDarkMode),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade200,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _toCurrency['symbol'],
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatValue(_convertedAmount),
                                      style: GoogleFonts.quicksand(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: contentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildCurrencyPickerButton(
                              _toCurrency, false, accentColor),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Unit Rate Indicator Pill
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nilai Tukar Referensi:',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '1 ${_fromCurrency['code']} = ${_formatUnitRate(unitRate)} ${_toCurrency['code']}',
                              style: GoogleFonts.quicksand(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: contentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kurs Populer Hari Ini Section
                      Text(
                        'KURS POPULER TERHADAP IDR',
                        style: GoogleFonts.quicksand(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: isDarkMode
                              ? Colors.white38
                              : Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currencies
                            .where((c) => c['code'] != 'IDR')
                            .take(8)
                            .length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final popularList = _currencies
                              .where((c) => c['code'] != 'IDR')
                              .take(8)
                              .toList();
                          final curr = popularList[index];
                          final double rate =
                              (curr['rate'] as num?)?.toDouble() ?? 1.0;
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _fromCurrency = curr;
                                _toCurrency = _currencies[0]; // IDR
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(curr['flag'],
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          curr['code'],
                                          style: GoogleFonts.quicksand(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: contentColor,
                                          ),
                                        ),
                                        Text(
                                          curr['name'],
                                          style: GoogleFonts.quicksand(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? Colors.white38
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${NumberFormat('#,##0.##', 'id_ID').format(rate)}',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceLabel(String label, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white70 : AppColors.primaryDark;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: contentColor,
        ),
      ),
    );
  }

  Widget _buildCurrencyPickerButton(Map<String, dynamic> currency, bool isFrom, Color accentColor) {
    return InkWell(
      onTap: () => _showCurrencyPicker(context, isFrom, accentColor),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currency['flag'], style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              currency['code'],
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, bool isFrom, Color accentColor) {
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, 
              height: 4, 
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300, 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Mata Uang', 
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold, 
                fontSize: 14, 
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final curr = _currencies[index];
                  final isSelected = (isFrom ? _fromCurrency : _toCurrency) == curr;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Text(curr['flag'], style: const TextStyle(fontSize: 22)),
                    title: Text(
                      curr['code'], 
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold, 
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      curr['name'], 
                      style: GoogleFonts.quicksand(
                        fontSize: 11, 
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.3) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle_rounded, color: accentColor, size: 20) : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromCurrency = curr;
                        } else {
                          _toCurrency = curr;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



