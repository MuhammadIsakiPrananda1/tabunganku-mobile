import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MonthlyBudgetPage extends ConsumerStatefulWidget {
  const MonthlyBudgetPage({super.key});

  @override
  ConsumerState<MonthlyBudgetPage> createState() => _MonthlyBudgetPageState();
}

class _MonthlyBudgetPageState extends ConsumerState<MonthlyBudgetPage> {
  double _budgetLimit = 0.0;
  final _ctrl = TextEditingController();
  late int _month, _year;
  bool _hasError = false;

  static const _months = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _load();
  }

  void _step(int d) {
    setState(() {
      _month += d;
      if (_month > 12) { _month = 1; _year++; }
      else if (_month < 1) { _month = 12; _year--; }
    });
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _budgetLimit = prefs.getDouble('monthly_budget_${_year}_$_month') ?? 0.0;
      _ctrl.clear();
      _hasError = false;
    });
  }

  Future<void> _save() async {
    final raw = _ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final val = double.tryParse(raw) ?? 0.0;
    if (val <= 0.0) {
      setState(() {
        _hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nominal budget harus lebih besar dari Rp 0!',
              style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
        ));
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget_${_year}_$_month', val);
    final now = DateTime.now();
    if (_month == now.month && _year == now.year) {
      await prefs.setDouble('monthly_budget', val);
    }
    setState(() { 
      _budgetLimit = val; 
      _ctrl.clear(); 
      _hasError = false;
    });
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Budget berhasil disimpan!',
            style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsByGroupProvider(null));
    double spent = 0;
    for (final t in txs) {
      if (t.type == TransactionType.expense &&
          t.date.year == _year && t.date.month == _month) {
        spent += t.amount;
      }
    }

    final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final progress  = _budgetLimit > 0 ? (spent / _budgetLimit).clamp(0.0, 1.0) : 0.0;
    final isOver    = _budgetLimit > 0 && spent > _budgetLimit;
    final isWarn    = progress >= 0.8 && !isOver;
    final accent    = isOver  ? const Color(0xFFE53935)
                    : isWarn  ? Colors.orange.shade600
                    : AppColors.primary;
    final remaining = (_budgetLimit - spent).clamp(0.0, double.infinity);
    final fmt       = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateLabel = '${_months[_month]} $_year';

    final cardBg   = isDark ? AppColors.surfaceDark : Colors.white;
    final pageBg   = isDark ? AppColors.backgroundDark : const Color(0xFFF0F3F7);
    final divClr   = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.07);
    final subClr   = isDark ? Colors.white38 : Colors.black38;
    final txtClr   = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [

Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: isDark ? Colors.white70 : AppColors.primaryDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text('Budget Bulanan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                            fontSize: 15, fontWeight: FontWeight.w700, color: txtClr)),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: divClr),
                      ),
                      child: Row(
                        children: [
                          _navBtn(Icons.chevron_left_rounded, () => _step(-1)),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month_rounded,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 7),
                                Text(dateLabel,
                                    style: GoogleFonts.quicksand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: txtClr)),
                              ],
                            ),
                          ),
                          _navBtn(Icons.chevron_right_rounded, () => _step(1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: divClr),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

Text(
                                  'PENGELUARAN BULAN INI',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: subClr,
                                  ),
                                ),
                                const SizedBox(height: 6),

Text(
                                  fmt.format(spent),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: txtClr,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),

Text(
                                  _budgetLimit > 0
                                      ? 'dari ${fmt.format(_budgetLimit)}'
                                      : 'Belum ada limit budget',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: subClr,
                                  ),
                                ),
                                const SizedBox(height: 14),

Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 7,
                                          backgroundColor: isDark
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.grey.shade100,
                                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Divider(height: 1, color: divClr),

IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _statCell(
                                    icon: Icons.trending_up_rounded,
                                    label: 'Terpakai',
                                    value: '${(progress * 100).toStringAsFixed(1)}%',
                                    color: accent,
                                    subClr: subClr,
                                    txtClr: txtClr,
                                  ),
                                ),
                                VerticalDivider(width: 1, color: divClr),
                                Expanded(
                                  child: _statCell(
                                    icon: Icons.savings_rounded,
                                    label: 'Sisa Budget',
                                    value: _budgetLimit > 0
                                        ? fmt.format(remaining)
                                        : '–',
                                    color: AppColors.primary,
                                    subClr: subClr,
                                    txtClr: txtClr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

if (_budgetLimit > 0) ...[
                      _statusBanner(
                          isOver, isWarn, accent, progress, isDark, txtClr),
                      const SizedBox(height: 14),
                    ] else
                      const SizedBox(height: 4),

Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: divClr),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.tune_rounded,
                                    color: AppColors.primary, size: 15),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Atur Limit Budget',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: txtClr)),
                                  Text(dateLabel,
                                      style: GoogleFonts.quicksand(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: subClr)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

TextFormField(
                            controller: _ctrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: txtClr),
                            onChanged: (v) {
                              final n = v.replaceAll(RegExp(r'[^0-9]'), '');
                              if (n.isEmpty) { 
                                _ctrl.clear(); 
                                if (_hasError) {
                                  setState(() {
                                    _hasError = false;
                                  });
                                }
                                return; 
                              }
                              final f = NumberFormat.currency(
                                      locale: 'id_ID', symbol: '', decimalDigits: 0)
                                  .format(int.parse(n));
                              _ctrl.value = TextEditingValue(
                                  text: f,
                                  selection: TextSelection.collapsed(offset: f.length));

                              final val = double.tryParse(n) ?? 0.0;
                              if (val > 0.0 && _hasError) {
                                setState(() {
                                  _hasError = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Masukkan nominal budget',
                              hintStyle: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  color: isDark ? Colors.white24 : Colors.black26),
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(Icons.account_balance_wallet_rounded,
                                      color: AppColors.primary, size: 17),
                                  const SizedBox(width: 5),
                                  Text('Rp',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF0F3F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _hasError ? Colors.redAccent : divClr),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: _hasError ? Colors.redAccent : divClr),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _hasError ? Colors.redAccent : AppColors.primary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 13),
                              isDense: true,
                            ),
                          ),
                          if (_hasError) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'Nominal budget harus lebih besar dari Rp 0!',
                                style: GoogleFonts.quicksand(
                                  color: Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_rounded, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Simpan Budget',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
      );

  Widget _statCell({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color subClr,
    required Color txtClr,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 5),
              Text(label,
                  style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: subClr)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: txtClr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(bool isOver, bool isWarn, Color accent, double progress,
      bool isDark, Color txtClr) {
    final msg = isOver
        ? 'Budget terlampaui! Harap kurangi pengeluaran.'
        : isWarn
            ? 'Mendekati batas — sisa ${((1 - progress) * 100).toStringAsFixed(0)}% budget.'
            : 'Pengeluaran masih dalam batas aman.';
    final icon = isOver
        ? Icons.error_outline_rounded
        : isWarn
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: txtClr)),
          ),
        ],
      ),
    );
  }
}
