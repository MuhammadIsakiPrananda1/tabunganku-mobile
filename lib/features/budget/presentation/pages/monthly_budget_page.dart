import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
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
      _budgetLimit = prefs.getDouble(monthKey) ?? prefs.getDouble('monthly_budget') ?? 0.0;
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
      if (t.type == TransactionType.expense && t.date.year == _selectedYear && t.date.month == _selectedMonth) {
        selectedMonthExpense += t.amount;
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Strict Color Rules per user request
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardBgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    
    double progress = _budgetLimit > 0 ? (selectedMonthExpense / _budgetLimit) : 0.0;
    if (progress > 1.0) progress = 1.0;

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final monthsIndo = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateDisplay = '${monthsIndo[_selectedMonth]} $_selectedYear';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Budget Bulanan', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Picker Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: Icon(Icons.chevron_left_rounded, color: textColor),
                  style: IconButton.styleFrom(backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
                Text(
                  dateDisplay,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: Icon(Icons.chevron_right_rounded, color: textColor),
                  style: IconButton.styleFrom(backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBgColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), 
                      blurRadius: 16, 
                      offset: const Offset(0, 8),
                    ),
                ]
              ),
              child: Column(
                children: [
                  Text(
                    'PENGELUARAN BULAN INI',
                    style: GoogleFonts.comicNeue(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatter.format(selectedMonthExpense),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.8 ? Colors.red.shade400 : (progress > 0.5 ? Colors.orange.shade400 : Colors.green.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toStringAsFixed(1)}% Terpakai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                      Text('Limit: ${formatter.format(_budgetLimit)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Atur Limit Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              onChanged: (value) {
                if (value.isEmpty) return;
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
                labelText: 'Target Maksimal Pengeluaran ($dateDisplay)',
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                hintText: 'Misal: 3.000.000',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: isDark ? Colors.white70 : Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2),
                ),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Simpan Target $dateDisplay', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

