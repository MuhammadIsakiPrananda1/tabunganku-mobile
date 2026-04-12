import 'package:flutter/material.dart';
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
  final TextEditingController _budgetController = TextEditingController();
  
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadBudget();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final monthKey = 'monthly_budget_${_selectedYear}_${_selectedMonth}';
    
    setState(() {
      // Hanya ambil budget spesifik bulan ini, jangan gunakan fallback global
      _budgetLimit = prefs.getDouble(monthKey) ?? 0.0;
      _budgetController.clear(); // Bersihkan form saat me-load
    });
  }

  Future<void> _saveBudget() async {
    final rawText = _budgetController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final val = double.tryParse(rawText) ?? 0.0;
    final prefs = await SharedPreferences.getInstance();
    final monthKey = 'monthly_budget_${_selectedYear}_${_selectedMonth}';
    
    await prefs.setDouble(monthKey, val);
    
    // Set fallback if they are setting the current month
    final now = DateTime.now();
    if (_selectedMonth == now.month && _selectedYear == now.year) {
      await prefs.setDouble('monthly_budget', val);
    }
    
    setState(() {
      _budgetLimit = val;
      _budgetController.clear(); // Kosongkan form setelah save
    });
    
    if (mounted) {
      FocusScope.of(context).unfocus(); // Tutup keyboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target Budget Disimpan!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txsMap = ref.watch(transactionsByGroupProvider(null));

    double selectedMonthExpense = 0.0;
    for (final t in txsMap) {
      if (t.type == TransactionType.expense &&
          t.date.year == _selectedYear &&
          t.date.month == _selectedMonth) {
        selectedMonthExpense += t.amount;
      }
    }

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final bgColor = isDarkMode ? AppColors.backgroundDark : AppColors.background;
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    double progress = _budgetLimit > 0 ? (selectedMonthExpense / _budgetLimit) : 0.0;
    const maxProgress = 1.0;
    final displayedProgress = progress > maxProgress ? maxProgress : progress;

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final monthsIndo = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateDisplay = '${monthsIndo[_selectedMonth]} $_selectedYear';

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar Area ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Budget Bulanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
            ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Month Selector ────────────────────────────────────
                        _buildMonthPicker(isDarkMode, dateDisplay),
                        
                        const SizedBox(height: 24),

                        // ── Premium Stats Card (Glassmorphism) ─────────────────
                        _buildPremiumStatsCard(isDarkMode, selectedMonthExpense, _budgetLimit, displayedProgress, formatter),

                        const SizedBox(height: 32),
                        
                        // ── Set Limit Section ──────────────────────────────────
                        _buildSetLimitSection(isDarkMode, dateDisplay),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthPicker(bool isDarkMode, String dateDisplay) {
    final pickerBg = isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.05);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: pickerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: contentColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(Icons.chevron_left_rounded, color: contentColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            dateDisplay,
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: contentColor,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(Icons.chevron_right_rounded, color: contentColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsCard(bool isDarkMode, double spent, double limit, double progress, NumberFormat formatter) {
    final statusColor = progress >= 0.9 ? Colors.redAccent : (progress >= 0.7 ? Colors.orangeAccent : AppColors.primaryLight);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: isDarkMode ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
      ),
      child: Column(
        children: [
          Text(
            'TOTAL PENGELUARAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatter.format(spent),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // ── Custom Premium Progress Bar ────────────────────────────────
          Stack(
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 14,
                width: MediaQuery.of(context).size.width * 0.7 * progress, // Approximation for simple animation
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terpakai', style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white38 : Colors.grey)),
                  Text('${(progress * 100).toStringAsFixed(1)}%', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sisa Limit', style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white38 : Colors.grey)),
                  Text(formatter.format((limit - spent).clamp(0, double.infinity)), 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetLimitSection(bool isDarkMode, String dateDisplay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Atur Limit Baru',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // ── Standardized Target Input ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'TARGET MAKSIMAL ($dateDisplay)',
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: (isDarkMode ? Colors.white : AppColors.primaryDark).withValues(alpha: 0.5),
                  letterSpacing: 1.2
                ),
              ),
            ),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
              onChanged: (value) {
                final number = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (number.isEmpty) {
                  _budgetController.clear();
                  return;
                }
                final formatted = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(int.parse(number));
                _budgetController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Rp',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // ── Save Button ──
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _saveBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Simpan Target $dateDisplay', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

