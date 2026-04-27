import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  String _amountStr = '0';
  bool _isNumpadVisible = false;
  
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
  }

  void _onNumberPress(String val) {
    setState(() {
      if (_amountStr == '0') {
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
    final amount = double.tryParse(_amountStr) ?? 0;
    return amount * _fromCurrency['rate'] / _toCurrency['rate'];
  }

  String _formatValue(dynamic val) {
    double value;
    if (val is String) {
      value = double.tryParse(val.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    } else {
      value = (val as num).toDouble();
    }
    
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: value < 1 && value > 0 ? (value < 0.0001 ? 6 : 4) : 0,
    );
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : AppColors.primaryDark, size: 18),
        ),
        title: Text(
          'Valas',
          style: GoogleFonts.comicNeue(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReferenceLabel('Jumlah', isDarkMode),
                    const SizedBox(height: 6),
                    _buildReferenceInput(context, _fromCurrency, _formatValue(_amountStr), true, isDarkMode),
                    
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        onTap: _swapCurrencies,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8DE969),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.green.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildReferenceLabel('Hasil Konversi', isDarkMode),
                    const SizedBox(height: 6),
                    _buildReferenceInput(context, _toCurrency, _formatValue(_convertedAmount), false, isDarkMode),
                  ],
                ),
              ),
            ),
          ),

          // Permanently Visible Numpad
          Container(
            height: (280 + MediaQuery.of(context).padding.bottom),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: _buildNumpad(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingCursor(bool isDarkMode) {
    return _BlinkingCursor(isDarkMode: isDarkMode);
  }

  Widget _buildReferenceLabel(String label, bool isDarkMode) {
    return Text(
      label,
      style: GoogleFonts.comicNeue(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildReferenceInput(BuildContext context, Map<String, dynamic> currency, String val, bool isFrom, bool isDarkMode) {
    final isActive = isFrom && _isNumpadVisible;
    return InkWell(
      onTap: isFrom 
        ? () => setState(() => _isNumpadVisible = !_isNumpadVisible)
        : () => _showCurrencyPicker(context, isFrom),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive 
              ? (isDarkMode ? Colors.cyanAccent : Colors.blue) 
              : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Amount on the left with Blinking Cursor (Beam)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currency['symbol']} ',
                    style: GoogleFonts.comicNeue(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (isFrom && val == '0') _buildBlinkingCursor(isDarkMode),
                  Flexible(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        val,
                        style: GoogleFonts.comicNeue(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: val == '0' || val == '0,00'
                            ? (isDarkMode ? Colors.white24 : Colors.grey.shade300)
                            : (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  if (isFrom && val != '0') _buildBlinkingCursor(isDarkMode),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Currency Picker on the right
            InkWell(
              onTap: () => _showCurrencyPicker(context, isFrom),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currency['flag'], style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    currency['code'],
                    style: GoogleFonts.comicNeue(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, color: isDarkMode ? Colors.white38 : Colors.grey, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSwapDivider(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Divider(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, height: 1),
        ),
        GestureDetector(
          onTap: _swapCurrencies,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(Icons.swap_vert_rounded, 
              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpad(bool isDarkMode) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 10) {
          setState(() => _isNumpadVisible = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minimalist Handle
            Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildNumpadRow(['1', '2', '3'], isDarkMode),
            _buildNumpadRow(['4', '5', '6'], isDarkMode),
            _buildNumpadRow(['7', '8', '9'], isDarkMode),
            _buildNumpadRow(['.', '0', 'back'], isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> values, bool isDarkMode) {
    return Row(
      children: values.map((val) => _numpadBtn(val, isDarkMode, isIcon: val == 'back')).toList(),
    );
  }

  Widget _numpadBtn(String val, bool isDarkMode, {bool isIcon = false}) {
    return Expanded(
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
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.blue.withValues(alpha: 0.1),
          highlightColor: Colors.blue.withValues(alpha: 0.05),
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: isIcon 
              ? Icon(Icons.backspace_outlined, color: isDarkMode ? Colors.white54 : Colors.grey.shade400, size: 20)
              : Text(
                  val,
                  style: GoogleFonts.comicNeue(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, bool isFrom) {
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Premium Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Mata Uang',
              style: GoogleFonts.comicNeue(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final curr = _currencies[index];
                  final isSelected = (isFrom ? _fromCurrency : _toCurrency) == curr;
                    
                    return InkWell(
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
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? (isDarkMode ? Colors.cyanAccent.withValues(alpha: 0.1) : Colors.blue.shade50)
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                              ? (isDarkMode ? Colors.cyanAccent : Colors.blue)
                              : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(curr['flag'], style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    curr['code'],
                                    style: GoogleFonts.comicNeue(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    curr['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.comicNeue(
                                      fontSize: 10,
                                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: isDarkMode ? Colors.cyanAccent : Colors.blue, size: 16),
                          ],
                        ),
                      ),
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
  const _BlinkingCursor({required this.isDarkMode});

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
        height: 24,
        margin: const EdgeInsets.only(left: 4),
        color: widget.isDarkMode ? Colors.cyanAccent : Colors.blue,
      ),
    );
  }
}
