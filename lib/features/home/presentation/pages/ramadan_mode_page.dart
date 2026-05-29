import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class RamadanModePage extends ConsumerStatefulWidget {
  const RamadanModePage({super.key});

  @override
  ConsumerState<RamadanModePage> createState() => _RamadanModePageState();
}

class _RamadanModePageState extends ConsumerState<RamadanModePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _prefKeyTarawih = 'ramadan_tarawih_v1';
  final String _prefKeySedekah = 'ramadan_sedekah_v1';
  final String _prefKeyQuran = 'ramadan_quran_juz_v1';
  final String _prefKeyExpenses = 'ramadan_expenses_v1';

  List<bool> _tarawihDays = List.generate(30, (_) => false);
  List<bool> _sedekahDays = List.generate(30, (_) => false);
  int _currentJuz = 0;
  List<Map<String, dynamic>> _expenses = [];

  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  bool _syncWithMainTransactions = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Tarawih
    final tarawihRaw = prefs.getString(_prefKeyTarawih);
    if (tarawihRaw != null) {
      final decoded = jsonDecode(tarawihRaw) as List;
      _tarawihDays = decoded.map((e) => e as bool).toList();
    }

    // Load Sedekah
    final sedekahRaw = prefs.getString(_prefKeySedekah);
    if (sedekahRaw != null) {
      final decoded = jsonDecode(sedekahRaw) as List;
      _sedekahDays = decoded.map((e) => e as bool).toList();
    }

    // Load Quran Juz
    _currentJuz = prefs.getInt(_prefKeyQuran) ?? 0;

    // Load Expenses
    final expensesRaw = prefs.getString(_prefKeyExpenses);
    if (expensesRaw != null) {
      final decoded = jsonDecode(expensesRaw) as List;
      _expenses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveTarawih() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyTarawih, jsonEncode(_tarawihDays));
  }

  Future<void> _saveSedekah() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySedekah, jsonEncode(_sedekahDays));
  }

  Future<void> _saveQuran() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyQuran, _currentJuz);
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyExpenses, jsonEncode(_expenses));
  }

  void _addExpense() async {
    final title = _expenseTitleController.text.trim();
    final amountText = _expenseAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    final newExpense = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };

    setState(() {
      _expenses.insert(0, newExpense);
    });
    await _saveExpenses();

    if (_syncWithMainTransactions) {
      final transaction = TransactionModel(
        id: newExpense['id'] as String,
        title: '[Ramadan] $title',
        description: 'Catatan pengeluaran menu Mode Ramadan',
        amount: amount,
        type: TransactionType.expense,
        date: DateTime.now(),
        category: 'Sosial & Zakat',
      );
      await ref.read(addTransactionProvider)(transaction);
    }

    _expenseTitleController.clear();
    _expenseAmountController.clear();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengeluaran Ramadan berhasil ditambahkan!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF009688),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteExpense(String id) async {
    setState(() {
      _expenses.removeWhere((e) => e['id'] == id);
    });
    await _saveExpenses();
  }

  double get _totalRamadanExpense {
    return _expenses.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  int get _tarawihCount => _tarawihDays.where((d) => d).length;
  int get _sedekahCount => _sedekahDays.where((d) => d).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF4F9F8);
    final accentColor = const Color(0xFF009688); // Serene Emerald Green
    final goldColor = const Color(0xFFD4AF37); // Rich gold accent

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
          '🌙 Mode Ramadan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Elegant Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF0D5C54), const Color(0xFF083C37)]
                      : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marhaban ya Ramadan',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? goldColor : accentColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"Sucikan hati, bersihkan jiwa, dan atur finansialmu dengan penuh berkah dan manfaat."',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            color: isDarkMode ? Colors.white70 : Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.nightlight_round_rounded, size: 50, color: isDarkMode ? goldColor : accentColor),
                ],
              ),
            ),
          ),

          // Custom Premium Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: accentColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                labelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11.5),
                unselectedLabelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11.5),
                tabs: const [
                  Tab(text: 'Target Amal'),
                  Tab(text: 'Tadarrus'),
                  Tab(text: 'Pengeluaran'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tab content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTargetAmalTab(isDarkMode, accentColor, goldColor, contentColor),
                _buildTadarrusTab(isDarkMode, accentColor, goldColor, contentColor),
                _buildExpensesTab(isDarkMode, accentColor, contentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAmalTab(bool isDarkMode, Color accentColor, Color goldColor, Color contentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tarawih',
                  '$_tarawihCount / 30 Hari',
                  Icons.mosque_rounded,
                  accentColor,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Sedekah',
                  '$_sedekahCount / 30 Hari',
                  Icons.volunteer_activism_rounded,
                  goldColor,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tarawih Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📅 Checklist Sholat Tarawih',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tarawihDays = List.generate(30, (_) => true);
                  });
                  _saveTarawih();
                },
                child: Text(
                  'Check Semua',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _build30DaysGrid(_tarawihDays, accentColor, (index) {
            setState(() {
              _tarawihDays[index] = !_tarawihDays[index];
            });
            _saveTarawih();
          }, isDarkMode),

          const SizedBox(height: 28),

          // Sedekah Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🤲 Sedekah Harian Ramadan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sedekahDays = List.generate(30, (_) => true);
                  });
                  _saveSedekah();
                },
                child: Text(
                  'Check Semua',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: goldColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _build30DaysGrid(_sedekahDays, goldColor, (index) {
            setState(() {
              _sedekahDays[index] = !_sedekahDays[index];
            });
            _saveSedekah();
          }, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build30DaysGrid(List<bool> daysList, Color activeColor, Function(int) onTap, bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final active = daysList[index];
        return InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active 
                  ? activeColor 
                  : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active 
                    ? Colors.transparent 
                    : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
              ),
            ),
            child: Text(
              'H-${index + 1}',
              style: GoogleFonts.quicksand(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: active
                    ? Colors.white
                    : (isDarkMode ? Colors.white54 : Colors.grey.shade600),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTadarrusTab(bool isDarkMode, Color accentColor, Color goldColor, Color contentColor) {
    final progress = _currentJuz / 30.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, color: goldColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Progres Khatam Quran',
                  style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.bold, color: contentColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: 30 Juz di bulan Ramadan',
                  style: GoogleFonts.quicksand(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Selesai',
                          style: GoogleFonts.quicksand(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sudah Khatam: $_currentJuz Juz',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentJuz > 0 ? () {
                            setState(() {
                              _currentJuz--;
                            });
                            _saveQuran();
                          } : null,
                          icon: Icon(Icons.remove_circle_outline_rounded, color: _currentJuz > 0 ? accentColor : Colors.grey),
                        ),
                        IconButton(
                          onPressed: _currentJuz < 30 ? () {
                            setState(() {
                              _currentJuz++;
                            });
                            _saveQuran();
                          } : null,
                          icon: Icon(Icons.add_circle_outline_rounded, color: _currentJuz < 30 ? accentColor : Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    thumbColor: goldColor,
                    overlayColor: goldColor.withOpacity(0.12),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    min: 0,
                    max: 30,
                    divisions: 30,
                    value: _currentJuz.toDouble(),
                    onChanged: (val) {
                      setState(() {
                        _currentJuz = val.round();
                      });
                      _saveQuran();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(bool isDarkMode, Color accentColor, Color contentColor) {
    return Column(
      children: [
        // Total Ramadan spend
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pengeluaran Ramadan',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalRamadanExpense),
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddExpenseDialog(isDarkMode, accentColor),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: Text('Tambah', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expense List
        Expanded(
          child: _expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: 48, color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada pengeluaran Ramadan.',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final item = _expenses[index];
                    final amount = (item['amount'] as num).toDouble();
                    final date = DateTime.parse(item['date'] as String);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shopping_bag_rounded, color: Colors.redAccent, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: contentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '- ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount)}',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                InkWell(
                                  onTap: () => _deleteExpense(item['id'] as String),
                                  borderRadius: BorderRadius.circular(100),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tambah Pengeluaran Ramadan',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                  ),
                  const SizedBox(height: 16),
                  
                  // Label & input nama pengeluaran
                  Text(
                    'Nama Pengeluaran',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _expenseTitleController,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'Masukkan Nama Pengeluaran',
                      hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Label & input nominal
                  Text(
                    'Nominal Belanja',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _expenseAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_RibuanFormatter()],
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'Masukkan Nominal Belanja',
                      hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Sync with core transactions
                  CheckboxListTile(
                    value: _syncWithMainTransactions,
                    activeColor: accentColor,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Sinkronkan ke Transaksi Utama',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12, color: contentColor),
                    ),
                    subtitle: Text(
                      'Pencatatan ini akan langsung didaftarkan ke pengeluaran bulanan dompet utama.',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 9.5, color: Colors.grey),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        _syncWithMainTransactions = val ?? true;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Pengeluaran',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
