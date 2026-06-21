import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/services/currency_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:ui';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  String _amountStr = '1';
  bool _isLoading = true;
  DateTime? _lastUpdated;
  
  late TextEditingController _amountController;
  late FocusNode _amountFocusNode;

  bool _isNoInternetDialogShowing = false;
  BuildContext? _dialogContext;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'flag': '🇮🇩', 'rate': 1.0, 'symbol': 'Rp'},
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸', 'rate': 16250.0, 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'rate': 17400.0, 'symbol': '€'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'flag': '🇸🇬', 'rate': 11950.0, 'symbol': 'S\$'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵', 'rate': 105.0, 'symbol': '¥'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'flag': '🇸🇦', 'rate': 4330.0, 'symbol': 'SR'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾', 'rate': 3400.0, 'symbol': 'RM'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺', 'rate': 10600.0, 'symbol': 'A\$'},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧', 'rate': 20200.0, 'symbol': '£'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'flag': '🇨🇳', 'rate': 2250.0, 'symbol': '¥'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'flag': '🇭🇰', 'rate': 2080.0, 'symbol': 'HK\$'},
    {'code': 'KRW', 'name': 'South Korean Won', 'flag': '🇰🇷', 'rate': 11.8, 'symbol': '₩'},
    {'code': 'THB', 'name': 'Thai Baht', 'flag': '🇹🇭', 'rate': 440.0, 'symbol': '฿'},
    {'code': 'VND', 'name': 'Vietnamese Dong', 'flag': '🇻🇳', 'rate': 0.64, 'symbol': '₫'},
    {'code': 'PHP', 'name': 'Philippine Peso', 'flag': '🇵🇭', 'rate': 282.0, 'symbol': '₱'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'flag': '🇨🇦', 'rate': 11900.0, 'symbol': 'C\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'flag': '🇨🇭', 'rate': 17800.0, 'symbol': 'CHF'},
    {'code': 'TWD', 'name': 'Taiwan Dollar', 'flag': '🇹🇼', 'rate': 500.0, 'symbol': 'NT\$'},
    {'code': 'NZD', 'name': 'New Zealand Dollar', 'flag': '🇳🇿', 'rate': 9600.0, 'symbol': 'NZ\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'flag': '🇧🇷', 'rate': 3100.0, 'symbol': 'R\$'},
  ];

  late Map<String, dynamic> _fromCurrency;
  late Map<String, dynamic> _toCurrency;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amountStr);
    _amountFocusNode = FocusNode();

    _fromCurrency = _currencies[1]; // USD
    _toCurrency = _currencies[0];   // IDR
    
    // Check if rates are already available to avoid showing loading spinner
    final initialRates = ref.read(currencyRatesProvider).value;
    if (initialRates != null) {
      _updateRatesFromMap(initialRates);
      _isLoading = false;
    } else {
      _isLoading = true;
      // If not available, we can trigger a fetch if it hasn't started
      _fetchRates();
    }

    _checkInternet();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        _showNoInternetPopup();
      } else {
        _dismissNoInternetPopup();
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogCtx) {
        _dialogContext = dialogCtx;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final accentColor = isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _dismissNoInternetPopup();
              Navigator.of(context).pop();
            },
            child: AlertDialog(
              backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Koneksi Terputus',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sambungkan ke internet untuk memperbarui kurs valas live dan memproses data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          _dismissNoInternetPopup();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    _lastUpdated = DateTime.now();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    await ref.read(currencyRatesProvider.notifier).refresh();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  double get _convertedAmount {
    final cleanStr = _amountStr.replaceAll(',', '.');
    final amount = double.tryParse(cleanStr) ?? 0.0;
    return amount * _fromCurrency['rate'] / _toCurrency['rate'];
  }

  String _formatValue(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: value < 1 && value > 0 ? (value < 0.0001 ? 6 : 4) : 0,
    );
    return format.format(value).trim();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currencyRatesProvider, (prev, next) {
      next.whenData((rates) {
        setState(() {
          _updateRatesFromMap(rates);
          _isLoading = false;
        });
      });
    });

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Electric Oceanic Blue & Pure Dark/Light backgrounds
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF3498DB) : const Color(0xFF2980B9);

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
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
          ),
          title: Text(
            'Konverter Valas',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: contentColor,
            ),
          ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReferenceLabel('Dari', isDarkMode),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            autofocus: false,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                            ],
                            cursorColor: accentColor,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                child: Text(
                                  _fromCurrency['symbol'],
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: '0',
                              hintStyle: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: contentColor.withValues(alpha: 0.3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _amountStr = value.isEmpty ? '0' : value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildCurrencyPickerButton(_fromCurrency, true, accentColor),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    Center(
                      child: IconButton(
                        onPressed: _swapCurrencies, 
                        icon: Icon(Icons.swap_vert_rounded, color: accentColor, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: accentColor.withValues(alpha: 0.08),
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
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
                                      fontSize: 14,
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
                        _buildCurrencyPickerButton(_toCurrency, false, accentColor),
                      ],
                    ),

                    if (_lastUpdated != null) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Pembaruan terakhir: ${DateFormat('HH:mm').format(_lastUpdated!)} WIB',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: contentColor.withValues(alpha: 0.3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
