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
import 'package:tabunganku/core/widgets/top_toast.dart';

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
      showTopToast(context, 'Limit budget berhasil disimpan! ✨');
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
    final pageBg   = isDark ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;
    final subClr   = isDark ? Colors.white60 : Colors.black54;
    final txtClr   = isDark ? Colors.white : AppColors.primaryDark;

    String statusLabel = 'Aman';
    Color statusColor = Colors.teal;
    if (isOver) {
      statusLabel = 'Melebihi Limit';
      statusColor = Colors.redAccent;
    } else if (isWarn) {
      statusLabel = 'Hampir Limit';
      statusColor = Colors.orangeAccent;
    } else if (_budgetLimit == 0) {
      statusLabel = 'Belum Diatur';
      statusColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: txtClr, size: 20),
        ),
        title: Text(
          'Budget Bulanan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: txtClr,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Navigation Month (Minimalist style) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _step(-1),
                    icon: Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 28),
                  ),
                  Text(
                    dateLabel,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: txtClr,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _step(1),
                    icon: Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Main Progress Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PENGELUARAN BULAN INI',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fmt.format(spent),
                      style: GoogleFonts.quicksand(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _budgetLimit > 0
                          ? 'dari limit ${fmt.format(_budgetLimit)}'
                          : 'Belum menetapkan limit budget',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        if (_budgetLimit > 0) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: borderCol,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatCell(
                          label: 'TERPAKAI',
                          value: '${(progress * 100).toStringAsFixed(1)}%',
                          color: accent,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: borderCol,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _StatCell(
                          label: 'SISA BUDGET',
                          value: _budgetLimit > 0 ? fmt.format(remaining) : '–',
                          color: _budgetLimit > 0 && remaining > 0 ? AppColors.primary : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Setup Limit Form (Minimalist and clean) ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATUR LIMIT BUDGET *',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ctrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
                        hintText: 'Masukkan nominal limit',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white10 : Colors.black26,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _hasError ? Colors.redAccent : borderCol, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _hasError ? Colors.redAccent : AppColors.primary, width: 1.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _hasError ? Colors.redAccent : borderCol, width: 1.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Simpan Limit Budget',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
