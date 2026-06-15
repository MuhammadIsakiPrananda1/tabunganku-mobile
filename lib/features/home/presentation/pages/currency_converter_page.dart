import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/services/currency_service.dart';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  String _amountStr = '1';
  bool _isNumpadVisible = true;
  bool _isLoading = true;
  DateTime? _lastUpdated;
  
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

  void _onNumberPress(String val) {
    setState(() {
      if (_amountStr == '0' && val != '.') {
        _amountStr = val;
      } else {
        _amountStr += val;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  double get _convertedAmount {
    final amount = double.tryParse(_amountStr.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
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

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        actions: [
          IconButton(
            onPressed: _fetchRates,
            icon: Icon(Icons.refresh_rounded, color: accentColor, size: 20),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReferenceLabel('Dari', isDarkMode),
                  const SizedBox(height: 4),
                  _buildCurrencyCard(_fromCurrency, _amountStr, true, isDarkMode, accentColor),
                  
                  const SizedBox(height: 12),
                  Center(
                    child: IconButton(
                      onPressed: _swapCurrencies, 
                      icon: Icon(Icons.swap_vert_rounded, color: accentColor, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: accentColor.withOpacity(0.08),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildReferenceLabel('Ke', isDarkMode),
                  const SizedBox(height: 4),
                  _buildCurrencyCard(_toCurrency, _formatValue(_convertedAmount), false, isDarkMode, accentColor),

                  if (_lastUpdated != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Pembaruan terakhir: ${DateFormat('HH:mm').format(_lastUpdated!)} WIB',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: contentColor.withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Custom Numpad
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isNumpadVisible ? (310 + MediaQuery.of(context).padding.bottom) : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: _buildNumpad(isDarkMode, accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceLabel(String label, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: contentColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(Map<String, dynamic> currency, String val, bool isFrom, bool isDarkMode, Color accentColor) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final isActive = isFrom && _isNumpadVisible;

    return InkWell(
      onTap: isFrom 
        ? () => setState(() => _isNumpadVisible = !_isNumpadVisible)
        : () => _showCurrencyPicker(context, isFrom, accentColor),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive 
              ? accentColor 
              : (isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency['symbol'],
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isActive && val == '0') ...[
                          _buildBlinkingCursor(isDarkMode, accentColor),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          val,
                          style: GoogleFonts.quicksand(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: val == '0' ? contentColor.withOpacity(0.3) : contentColor,
                          ),
                        ),
                        if (isActive && val != '0') ...[
                          const SizedBox(width: 2),
                          _buildBlinkingCursor(isDarkMode, accentColor),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency['name'],
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: contentColor.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _showCurrencyPicker(context, isFrom, accentColor),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currency['flag'], style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(
                      currency['code'],
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: accentColor, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlinkingCursor(bool isDarkMode, Color accentColor) {
    return _BlinkingCursor(isDarkMode: isDarkMode, accentColor: accentColor);
  }

  Widget _buildNumpad(bool isDarkMode, Color accentColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildNumpadRow(['1', '2', '3'], isDarkMode, accentColor),
          _buildNumpadRow(['4', '5', '6'], isDarkMode, accentColor),
          _buildNumpadRow(['7', '8', '9'], isDarkMode, accentColor),
          _buildNumpadRow(['.', '0', 'back'], isDarkMode, accentColor),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> values, bool isDarkMode, Color accentColor) {
    return Row(
      children: values.map((val) => _numpadBtn(val, isDarkMode, accentColor, isIcon: val == 'back')).toList(),
    );
  }

  Widget _numpadBtn(String val, bool isDarkMode, Color accentColor, {bool isIcon = false}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (val == 'back') {
                _onBackspace();
              } else {
                _onNumberPress(val);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
              ),
              child: isIcon 
                ? Icon(Icons.backspace_outlined, color: accentColor, size: 18)
                : Text(
                    val,
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
            ),
          ),
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
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, 
              height: 4, 
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300, 
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
                        color: isDarkMode ? Colors.white30 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle_rounded, color: accentColor, size: 20) : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) _fromCurrency = curr; else _toCurrency = curr;
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

class _BlinkingCursor extends StatefulWidget {
  final bool isDarkMode;
  final Color accentColor;
  const _BlinkingCursor({required this.isDarkMode, required this.accentColor});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 22,
        color: widget.accentColor,
      ),
    );
  }
}
