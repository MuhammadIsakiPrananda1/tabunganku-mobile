/// Page: MonthlyBudgetPage
///
/// Halaman penetapan dan pelacakan anggaran bulanan per kategori.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

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
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
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
    HapticFeedback.selectionClick();
    setState(() {
      _month += d;
      if (_month > 12) {
        _month = 1;
        _year++;
      } else if (_month < 1) {
        _month = 12;
        _year--;
      }
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

  Future<void> _resetBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Limit Budget?',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus limit budget untuk bulan ${_months[_month]} $_year?',
          style: GoogleFonts.quicksand(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('monthly_budget_${_year}_$_month');
      final now = DateTime.now();
      if (_month == now.month && _year == now.year) {
        await prefs.remove('monthly_budget');
      }
      setState(() {
        _budgetLimit = 0.0;
        _ctrl.clear();
        _hasError = false;
      });
      if (mounted) {
        showTopToast(context, 'Limit budget bulan ini telah dihapus.');
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsByGroupProvider(null));
    final monthlyExpenses = <TransactionModel>[];
    double spent = 0;

    for (final t in txs) {
      if (t.type == TransactionType.expense &&
          t.category != 'Tabungan' &&
          t.date.year == _year &&
          t.date.month == _month) {
        spent += t.amount;
        monthlyExpenses.add(t);
      }
    }

    final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final progress =
        _budgetLimit > 0 ? (spent / _budgetLimit).clamp(0.0, 1.0) : 0.0;
    final isOver = _budgetLimit > 0 && spent > _budgetLimit;
    final isWarn = progress >= 0.8 && !isOver;
    final accent = isOver
        ? const Color(0xFFEF4444)
        : isWarn
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    final remaining = (_budgetLimit - spent).clamp(0.0, double.infinity);
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateLabel = '${_months[_month]} $_year';

    final now = DateTime.now();
    final isCurrentMonth = _month == now.month && _year == now.year;

    // Remaining days calculation
    final lastDayOfMonth = DateTime(_year, _month + 1, 0).day;
    final remainingDays = isCurrentMonth
        ? (lastDayOfMonth - now.day + 1).clamp(1, lastDayOfMonth)
        : lastDayOfMonth;
    final dailyRecommendation = remaining > 0 ? remaining / remainingDays : 0.0;

    final cardBg = isDark ? const Color(0xFF151D24) : Colors.white;
    final pageBg = isDark ? const Color(0xFF0B0F15) : const Color(0xFFF8FAFC);
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    final txtClr = isDark ? Colors.white : const Color(0xFF0F172A);

    String statusLabel = 'Terkendali';
    Color statusColor = const Color(0xFF10B981);
    IconData statusIcon = Icons.check_circle_rounded;
    if (isOver) {
      statusLabel = 'Over Limit';
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel_rounded;
    } else if (isWarn) {
      statusLabel = 'Waspada (80%+)';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.warning_rounded;
    } else if (_budgetLimit == 0) {
      statusLabel = 'Belum Diatur';
      statusColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      statusIcon = Icons.info_outline_rounded;
    }

    // Category breakdown
    final categoryTotals = <String, double>{};
    for (var t in monthlyExpenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: txtClr,
                size: 14,
              ),
            ),
          ),
        ),
        title: Text(
          'Budget Bulanan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            letterSpacing: -0.2,
            color: txtClr,
          ),
        ),
        actions: [
          if (_budgetLimit > 0)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                tooltip: 'Hapus Limit',
                onPressed: _resetBudget,
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Modern Month Navigator ──
              _buildMonthNavigator(
                dateLabel: dateLabel,
                isDark: isDark,
                cardBg: cardBg,
                borderCol: borderCol,
                txtClr: txtClr,
              ),

              const SizedBox(height: 16),

              // ── 2. Fresh & Sleek Hero Budget Card ──
              _buildHeroBudgetCard(
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
                statusLabel: statusLabel,
                statusColor: statusColor,
                statusIcon: statusIcon,
                spent: spent,
                fmt: fmt,
                progress: progress,
                accent: accent,
                remaining: remaining,
                isCurrentMonth: isCurrentMonth,
                remainingDays: remainingDays,
                dailyRecommendation: dailyRecommendation,
              ),

              const SizedBox(height: 20),

              // ── 3. Fresh Limit Setup Form with Quick Presets ──
              _buildLimitForm(cardBg, borderCol, isDark, txtClr),

              const SizedBox(height: 20),

              // ── 4. Fresh Monthly Expense Breakdown by Category ──
              _buildExpenseBreakdown(
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
                txtClr: txtClr,
                sortedCategories: sortedCategories,
                totalSpent: spent,
                fmt: fmt,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FRESH & MINIMALIST WIDGET COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMonthNavigator({
    required String dateLabel,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required Color txtClr,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _step(-1),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2833) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: txtClr,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _step(1),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2833) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBudgetCard({
    required Color cardBg,
    required Color borderCol,
    required bool isDark,
    required String statusLabel,
    required Color statusColor,
    required IconData statusIcon,
    required double spent,
    required NumberFormat fmt,
    required double progress,
    required Color accent,
    required double remaining,
    required bool isCurrentMonth,
    required int remainingDays,
    required double dailyRecommendation,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF16212B),
                  const Color(0xFF0F172A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF2FBF7),
                ],
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.20)
              : const Color(0xFF10B981).withValues(alpha: 0.16),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Badge & Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pie_chart_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STATUS ANGGARAN',
                      style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12.5, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: GoogleFonts.quicksand(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Hero Main Focus: Sisa Budget / Pengeluaran
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _budgetLimit > 0 ? 'Sisa Anggaran Tersedia' : 'Total Pengeluaran',
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _budgetLimit > 0 ? fmt.format(remaining) : fmt.format(spent),
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: _budgetLimit > 0
                          ? (remaining > 0
                              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                              : const Color(0xFFEF4444))
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _budgetLimit > 0
                      ? 'Terpakai ${fmt.format(spent)} dari limit ${fmt.format(_budgetLimit)}'
                      : 'Belum menetapkan limit budget untuk bulan ini',
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sleek Fresh Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2833)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                ),
                if (_budgetLimit > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),

            // 3-Stat Metric Cards (Limit, Terpakai, Sisa)
            Row(
              children: [
                _buildStatBox(
                  label: 'LIMIT',
                  value: _budgetLimit > 0 ? fmt.format(_budgetLimit) : '–',
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildStatBox(
                  label: 'TERPAKAI',
                  value: fmt.format(spent),
                  color: accent,
                  icon: Icons.shopping_bag_outlined,
                  iconColor: accent,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildStatBox(
                  label: 'SISA',
                  value: _budgetLimit > 0 ? fmt.format(remaining) : '–',
                  color: _budgetLimit > 0 && remaining > 0
                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ],
            ),

            // Daily Recommendation Insight
            if (_budgetLimit > 0 && isCurrentMonth && remaining > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2833).withValues(alpha: 0.7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sisa $remainingDays hari lagi di bulan ini',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saran belanja: maks ${fmt.format(dailyRecommendation)} / hari',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2833).withValues(alpha: 0.5)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitForm(
    Color cardBg,
    Color borderCol,
    bool isDark,
    Color txtClr,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ATUR LIMIT BUDGET',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_months[_month]} $_year',
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Text Field
          TextFormField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: txtClr,
            ),
            onChanged: (v) {
              final n = v.replaceAll(RegExp(r'[^0-9]'), '');
              if (n.isEmpty) {
                _ctrl.clear();
                if (_hasError) setState(() => _hasError = false);
                return;
              }
              final f = NumberFormat.currency(
                locale: 'id_ID',
                symbol: '',
                decimalDigits: 0,
              ).format(int.parse(n));
              _ctrl.value = TextEditingValue(
                text: f,
                selection: TextSelection.collapsed(offset: f.length),
              );

              final val = double.tryParse(n) ?? 0.0;
              if (val > 0.0 && _hasError) {
                setState(() => _hasError = false);
              }
            },
            decoration: InputDecoration(
              hintText: 'Masukkan nominal budget',
              hintStyle: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rp',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _ctrl.clear();
                          _hasError = false;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1A232E)
                  : const Color(0xFFF8FAFC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _hasError ? const Color(0xFFEF4444) : borderCol,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _hasError ? const Color(0xFFEF4444) : AppColors.primary,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _hasError ? const Color(0xFFEF4444) : borderCol,
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          if (_hasError) ...[
            const SizedBox(height: 6),
            Text(
              'Nominal limit harus lebih dari Rp 0!',
              style: GoogleFonts.quicksand(
                color: const Color(0xFFEF4444),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                'Simpan Limit Budget',
                style: GoogleFonts.quicksand(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown({
    required Color cardBg,
    required Color borderCol,
    required bool isDark,
    required Color txtClr,
    required List<MapEntry<String, double>> sortedCategories,
    required double totalSpent,
    required NumberFormat fmt,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RINCIAN PENGELUARAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (sortedCategories.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${sortedCategories.length} Kategori',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2833)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 26,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada pengeluaran di bulan ini',
                      style: GoogleFonts.quicksand(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: sortedCategories.map((entry) {
                final pct = totalSpent > 0 ? entry.value / totalSpent : 0.0;
                final catIcon = _getExpenseCategoryIcon(entry.key);
                final catColor = _getExpenseCategoryColor(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(catIcon, size: 16, color: catColor),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: txtClr,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${(pct * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: catColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fmt.format(entry.value),
                                style: GoogleFonts.quicksand(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: txtClr,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2833)
                                : const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(catColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  IconData _getExpenseCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('makan') ||
        lower.contains('kuliner') ||
        lower.contains('minum') ||
        lower.contains('kopi') ||
        lower.contains('snack')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('belanja') ||
        lower.contains('pasar') ||
        lower.contains('mart') ||
        lower.contains('supermarket')) {
      return Icons.shopping_bag_rounded;
    } else if (lower.contains('transport') ||
        lower.contains('bensin') ||
        lower.contains('ojek') ||
        lower.contains('parkir') ||
        lower.contains('tol')) {
      return Icons.directions_car_rounded;
    } else if (lower.contains('tagihan') ||
        lower.contains('listrik') ||
        lower.contains('air') ||
        lower.contains('wifi') ||
        lower.contains('pulsa')) {
      return Icons.receipt_long_rounded;
    } else if (lower.contains('hiburan') ||
        lower.contains('game') ||
        lower.contains('nonton') ||
        lower.contains('bioskop') ||
        lower.contains('liburan')) {
      return Icons.sports_esports_rounded;
    } else if (lower.contains('sehat') ||
        lower.contains('obat') ||
        lower.contains('dokter') ||
        lower.contains('klinik')) {
      return Icons.medical_services_rounded;
    } else if (lower.contains('edukasi') ||
        lower.contains('pendidikan') ||
        lower.contains('kursus') ||
        lower.contains('buku')) {
      return Icons.school_rounded;
    } else if (lower.contains('keluarga') ||
        lower.contains('anak') ||
        lower.contains('orang tua')) {
      return Icons.favorite_rounded;
    }
    return Icons.local_offer_rounded;
  }

  Color _getExpenseCategoryColor(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('makan') ||
        lower.contains('kuliner') ||
        lower.contains('minum') ||
        lower.contains('kopi') ||
        lower.contains('snack')) {
      return const Color(0xFFF97316); // Orange
    } else if (lower.contains('belanja') ||
        lower.contains('pasar') ||
        lower.contains('mart') ||
        lower.contains('supermarket')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (lower.contains('transport') ||
        lower.contains('bensin') ||
        lower.contains('ojek') ||
        lower.contains('parkir') ||
        lower.contains('tol')) {
      return const Color(0xFF0EA5E9); // Sky Blue
    } else if (lower.contains('tagihan') ||
        lower.contains('listrik') ||
        lower.contains('air') ||
        lower.contains('wifi') ||
        lower.contains('pulsa')) {
      return const Color(0xFFF59E0B); // Amber
    } else if (lower.contains('hiburan') ||
        lower.contains('game') ||
        lower.contains('nonton') ||
        lower.contains('bioskop') ||
        lower.contains('liburan')) {
      return const Color(0xFFEC4899); // Pink
    } else if (lower.contains('sehat') ||
        lower.contains('obat') ||
        lower.contains('dokter') ||
        lower.contains('klinik')) {
      return const Color(0xFFEF4444); // Red
    } else if (lower.contains('edukasi') ||
        lower.contains('pendidikan') ||
        lower.contains('kursus') ||
        lower.contains('buku')) {
      return const Color(0xFF10B981); // Emerald
    } else if (lower.contains('keluarga') ||
        lower.contains('anak') ||
        lower.contains('orang tua')) {
      return const Color(0xFFE11D48); // Rose
    }
    return const Color(0xFF14B8A6); // Teal
  }
}

