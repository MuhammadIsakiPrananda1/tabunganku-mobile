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

class _RamadanModePageState extends ConsumerState<RamadanModePage> {
  final String _prefKeyTarawih = 'ramadan_tarawih_v1';
  final String _prefKeyTarawihRakaat = 'ramadan_tarawih_rakaat_v2';
  final String _prefKeyWitirRakaat = 'ramadan_witir_rakaat_v2';
  final String _prefKeyPrayerNotes = 'ramadan_prayer_notes_v2';
  final String _prefKeySedekah = 'ramadan_sedekah_v1';
  final String _prefKeySedekahAmounts = 'ramadan_sedekah_amounts_v2';
  final String _prefKeyQuran = 'ramadan_quran_juz_v1';
  final String _prefKeyExpenses = 'ramadan_expenses_v1';

  List<int> _tarawihRakaat = List.generate(30, (_) => 0);
  List<int> _witirRakaat = List.generate(30, (_) => 0);
  List<String> _prayerNotes = List.generate(30, (_) => '');
  List<double> _sedekahAmounts = List.generate(30, (_) => 0.0);
  int _currentJuz = 0;
  List<Map<String, dynamic>> _expenses = [];

  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController =
      TextEditingController();
  bool _syncWithMainTransactions = true;
  String _selectedTab = 'Target Amal';
  final _ramadanFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

final tarawihRakaatRaw = prefs.getString(_prefKeyTarawihRakaat);
    if (tarawihRakaatRaw != null) {
      final decoded = jsonDecode(tarawihRakaatRaw) as List;
      _tarawihRakaat = decoded.map((e) => e as int).toList();
    } else {

      final tarawihRaw = prefs.getString(_prefKeyTarawih);
      if (tarawihRaw != null) {
        final decoded = jsonDecode(tarawihRaw) as List;
        final oldTarawihDays = decoded.map((e) => e as bool).toList();
        for (int i = 0; i < 30; i++) {
          if (i < oldTarawihDays.length && oldTarawihDays[i]) {
            _tarawihRakaat[i] = 8;
          }
        }
      }
    }

final witirRakaatRaw = prefs.getString(_prefKeyWitirRakaat);
    if (witirRakaatRaw != null) {
      final decoded = jsonDecode(witirRakaatRaw) as List;
      _witirRakaat = decoded.map((e) => e as int).toList();
    } else {

      final tarawihRaw = prefs.getString(_prefKeyTarawih);
      if (tarawihRaw != null) {
        final decoded = jsonDecode(tarawihRaw) as List;
        final oldTarawihDays = decoded.map((e) => e as bool).toList();
        for (int i = 0; i < 30; i++) {
          if (i < oldTarawihDays.length && oldTarawihDays[i]) {
            _witirRakaat[i] = 3;
          }
        }
      }
    }

final prayerNotesRaw = prefs.getString(_prefKeyPrayerNotes);
    if (prayerNotesRaw != null) {
      final decoded = jsonDecode(prayerNotesRaw) as List;
      _prayerNotes = decoded.map((e) => e as String).toList();
    }

final sedekahAmountsRaw = prefs.getString(_prefKeySedekahAmounts);
    if (sedekahAmountsRaw != null) {
      final decoded = jsonDecode(sedekahAmountsRaw) as List;
      _sedekahAmounts = decoded.map((e) => (e as num).toDouble()).toList();
    } else {

      final sedekahRaw = prefs.getString(_prefKeySedekah);
      if (sedekahRaw != null) {
        final decoded = jsonDecode(sedekahRaw) as List;
        final oldSedekahDays = decoded.map((e) => e as bool).toList();
        for (int i = 0; i < 30; i++) {
          if (i < oldSedekahDays.length && oldSedekahDays[i]) {
            _sedekahAmounts[i] = 10000.0;
          }
        }
      }
    }

_currentJuz = prefs.getInt(_prefKeyQuran) ?? 0;

final expensesRaw = prefs.getString(_prefKeyExpenses);
    if (expensesRaw != null) {
      final decoded = jsonDecode(expensesRaw) as List;
      _expenses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveTarawihRakaat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyTarawihRakaat, jsonEncode(_tarawihRakaat));
  }

  Future<void> _saveWitirRakaat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyWitirRakaat, jsonEncode(_witirRakaat));
  }

  Future<void> _savePrayerNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyPrayerNotes, jsonEncode(_prayerNotes));
  }

  Future<void> _saveSedekahAmounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySedekahAmounts, jsonEncode(_sedekahAmounts));
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
    if (!_ramadanFormKey.currentState!.validate()) return;
    final title = _expenseTitleController.text.trim();
    final amountText = _expenseAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;

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
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold, color: Colors.white),
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
    return _expenses.fold(
        0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  int get _tarawihCount => _tarawihRakaat.where((r) => r > 0).length;
  int get _sedekahCount => _sedekahAmounts.where((a) => a > 0).length;
  double get _totalSedekahAmount => _sedekahAmounts.fold(0.0, (sum, a) => sum + a);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF4F9F8);
    final accentColor = const Color(0xFF009688);
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
        ),
        title: Text(
          'Mode Ramadan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: Column(
        children: [

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
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent,
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
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.nightlight_round_rounded,
                      size: 50, color: isDarkMode ? goldColor : accentColor),
                ],
              ),
            ),
          ),

Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTab,
                  isExpanded: true,
                  dropdownColor:
                      isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: accentColor),
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                    fontSize: 13,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTab = newValue;
                      });
                    }
                  },
                  items: <String>['Target Amal', 'Tadarrus', 'Pengeluaran']
                      .map<DropdownMenuItem<String>>((String value) {
                    IconData iconData;
                    Color iconColor;
                    if (value == 'Target Amal') {
                      iconData = Icons.mosque_rounded;
                      iconColor = accentColor;
                    } else if (value == 'Tadarrus') {
                      iconData = Icons.menu_book_rounded;
                      iconColor = goldColor;
                    } else {
                      iconData = Icons.payments_rounded;
                      iconColor = Colors.redAccent;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(iconData, color: iconColor, size: 18),
                          const SizedBox(width: 12),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

Expanded(
            child: _selectedTab == 'Target Amal'
                ? _buildTargetAmalTab(
                    isDarkMode, accentColor, goldColor, contentColor)
                : _selectedTab == 'Tadarrus'
                    ? _buildTadarrusTab(
                        isDarkMode, accentColor, goldColor, contentColor)
                    : _buildExpensesTab(isDarkMode, accentColor, contentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAmalTab(
      bool isDarkMode, Color accentColor, Color goldColor, Color contentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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
                  NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0)
                      .format(_totalSedekahAmount),
                  Icons.volunteer_activism_rounded,
                  goldColor,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jurnal Amal Ramadan (30 Hari)',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: contentColor),
              ),
              TextButton(
                onPressed: () {
                  _showResetAmalDialog(accentColor, goldColor);
                },
                child: Text(
                  'Reset Semua',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUnifiedAmalGrid(isDarkMode, accentColor, goldColor),
        ],
      ),
    );
  }

  Widget _buildUnifiedAmalGrid(bool isDarkMode, Color accentColor, Color goldColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final tarawihRakaat = _tarawihRakaat[index];
        final witirRakaat = _witirRakaat[index];
        final hasTarawih = tarawihRakaat > 0;
        final hasWitir = witirRakaat > 0;
        final hasPrayer = hasTarawih || hasWitir;
        
        final sedekahAmt = _sedekahAmounts[index];
        final hasSedekah = sedekahAmt > 0;
        final hasNotes = _prayerNotes[index].isNotEmpty;

        return InkWell(
          onTap: () => _showDayAmalDialog(index, isDarkMode, accentColor, goldColor),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (hasPrayer || hasSedekah)
                    ? (hasPrayer && hasSedekah
                        ? accentColor.withOpacity(0.4)
                        : hasPrayer
                            ? accentColor.withOpacity(0.3)
                            : goldColor.withOpacity(0.3))
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.shade200),
                width: (hasPrayer || hasSedekah) ? 2.0 : 1.5,
              ),
              boxShadow: (hasPrayer || hasSedekah)
                  ? [
                      BoxShadow(
                        color: (hasPrayer ? accentColor : goldColor).withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: (hasPrayer || hasSedekah)
                          ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                          : (isDarkMode ? Colors.white24 : Colors.grey.shade400),
                    ),
                  ),
                ),
                if (hasNotes)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 13,
                      color: accentColor,
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mosque_rounded,
                        size: 15,
                        color: hasPrayer
                            ? accentColor
                            : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.volunteer_activism_rounded,
                        size: 15,
                        color: hasSedekah
                            ? goldColor
                            : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                      ),
                    ],
                  ),
                ),
                if (hasSedekah)
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Text(
                      sedekahAmt >= 1000000
                          ? '${(sedekahAmt / 1000000).toStringAsFixed(1)}M'
                          : sedekahAmt >= 1000
                              ? '${(sedekahAmt / 1000).toStringAsFixed(0)}k'
                              : sedekahAmt.toStringAsFixed(0),
                      style: GoogleFonts.quicksand(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: goldColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayAmalDialog(int index, bool isDarkMode, Color accentColor, Color goldColor) {
    final theme = Theme.of(context);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

int localTarawihRakaat = _tarawihRakaat[index];
    int localWitirRakaat = _witirRakaat[index];
    double localSedekahAmt = _sedekahAmounts[index];
    
    final notesController = TextEditingController(text: _prayerNotes[index]);
    final amountController = TextEditingController(
      text: localSedekahAmt > 0
          ? NumberFormat('#,###', 'id_ID').format(localSedekahAmt.toInt())
          : '',
    );
    bool shouldSync = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double currentSedekah = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0.0;
            final hasPrayer = localTarawihRakaat > 0 || localWitirRakaat > 0;
            
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Catatan Jurnal Hari Ke-${index + 1}',
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ramadan',
                            style: GoogleFonts.quicksand(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.mosque_rounded, color: accentColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sholat Tarawih & Witir',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: contentColor,
                                      ),
                                    ),
                                    Text(
                                      hasPrayer
                                          ? 'Tarawih: $localTarawihRakaat Rakaat, Witir: $localWitirRakaat Rakaat'
                                          : 'Belum shalat malam hari ini',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10,
                                        color: hasPrayer ? accentColor : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

Text(
                            'Sholat Tarawih',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: localTarawihRakaat,
                            dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                            items: List.generate(37, (i) => i).map((val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(val == 0 ? 'Tidak Shalat (0 Rakaat)' : '$val Rakaat'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                localTarawihRakaat = val ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

Text(
                            'Sholat Witir',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: localWitirRakaat,
                            dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                            items: List.generate(12, (i) => i).map((val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(val == 0 ? 'Tidak Shalat (0 Rakaat)' : '$val Rakaat'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                localWitirRakaat = val ?? 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: goldColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.volunteer_activism_rounded, color: goldColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sedekah Harian',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: contentColor,
                                      ),
                                    ),
                                    Text(
                                      currentSedekah > 0
                                          ? 'Sedekah: Rp ${NumberFormat('#,###', 'id_ID').format(currentSedekah.toInt())}'
                                          : 'Belum bersedekah hari ini',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10,
                                        color: currentSedekah > 0 ? goldColor : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [_RibuanFormatter()],
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nominal sedekah',
                              hintStyle: GoogleFonts.quicksand(color: Colors.grey, fontSize: 12),
                              prefixIcon: Container(
                                padding: const EdgeInsets.only(left: 12, right: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Rp',
                                      style: GoogleFonts.quicksand(
                                          fontWeight: FontWeight.bold,
                                          color: goldColor,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: goldColor, width: 1.5),
                              ),
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                          
                          if (currentSedekah > 0) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: shouldSync,
                                  activeColor: goldColor,
                                  onChanged: (val) {
                                    setModalState(() {
                                      shouldSync = val ?? true;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Catat otomatis sebagai pengeluaran Sosial & Zakat',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit_note_rounded, color: accentColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Catatan Ibadah',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: contentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: notesController,
                            maxLines: 2,
                            style: GoogleFonts.quicksand(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tulis detail sholat atau catatan amal lainnya...',
                              hintStyle: GoogleFonts.quicksand(color: Colors.grey, fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.quicksand(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () async {
                                final double finalSedekah = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0.0;
                                final String finalNotes = notesController.text.trim();
                                
                                setState(() {
                                  _tarawihRakaat[index] = localTarawihRakaat;
                                  _witirRakaat[index] = localWitirRakaat;
                                  _prayerNotes[index] = finalNotes;
                                  _sedekahAmounts[index] = finalSedekah;
                                });
                                
                                await _saveTarawihRakaat();
                                await _saveWitirRakaat();
                                await _savePrayerNotes();
                                await _saveSedekahAmounts();

                                if (finalSedekah > 0 && shouldSync && localSedekahAmt != finalSedekah) {
                                  final transaction = TransactionModel(
                                    id: 'ramadan_sedekah_${index + 1}_${DateTime.now().millisecondsSinceEpoch}',
                                    title: 'Sedekah Ramadan Hari Ke-${index + 1}',
                                    description: 'Sedekah harian tercatat dari Jurnal Ramadan',
                                    amount: finalSedekah,
                                    type: TransactionType.expense,
                                    date: DateTime.now(),
                                    category: 'Sosial & Zakat',
                                  );
                                  await ref.read(addTransactionProvider)(transaction);
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Jurnal Ramadan Hari ke-${index + 1} disimpan!',
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Simpan',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetAmalDialog(Color accentColor, Color goldColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Jurnal Ramadan?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text(
          'Semua catatan sholat Tarawih, Witir, Catatan Sholat, dan Sedekah yang telah dicatat akan dikosongkan kembali.',
          style: GoogleFonts.quicksand(fontSize: 12, height: 1.4, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _tarawihRakaat = List.generate(30, (_) => 0);
                _witirRakaat = List.generate(30, (_) => 0);
                _prayerNotes = List.generate(30, (_) => '');
                _sedekahAmounts = List.generate(30, (_) => 0.0);
              });
              await _saveTarawihRakaat();
              await _saveWitirRakaat();
              await _savePrayerNotes();
              await _saveSedekahAmounts();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Jurnal Ramadan berhasil di-reset!',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.grey.shade100,
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

  Widget _buildTadarrusTab(
      bool isDarkMode, Color accentColor, Color goldColor, Color contentColor) {
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
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, color: goldColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Progres Khatam Quran',
                  style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: contentColor),
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
                        backgroundColor: isDarkMode
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.shade100,
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
                            color: isDarkMode
                                ? Colors.white24
                                : Colors.grey.shade400,
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
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: contentColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentJuz > 0
                              ? () {
                                  setState(() {
                                    _currentJuz--;
                                  });
                                  _saveQuran();
                                }
                              : null,
                          icon: Icon(Icons.remove_circle_outline_rounded,
                              color:
                                  _currentJuz > 0 ? accentColor : Colors.grey),
                        ),
                        IconButton(
                          onPressed: _currentJuz < 30
                              ? () {
                                  setState(() {
                                    _currentJuz++;
                                  });
                                  _saveQuran();
                                }
                              : null,
                          icon: Icon(Icons.add_circle_outline_rounded,
                              color:
                                  _currentJuz < 30 ? accentColor : Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: accentColor,
                    inactiveTrackColor: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
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

  Widget _buildExpensesTab(
      bool isDarkMode, Color accentColor, Color contentColor) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
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
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0)
                              .format(_totalRamadanExpense),
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
                  onPressed: () =>
                      _showAddExpenseDialog(isDarkMode, accentColor),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Colors.white),
                  label: Text('Tambah',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),

Expanded(
          child: _expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 48,
                          color: isDarkMode
                              ? Colors.white12
                              : Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada pengeluaran Ramadan.',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                          color: isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.shade100,
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
                              child: const Icon(Icons.shopping_bag_rounded,
                                  color: Colors.redAccent, size: 18),
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
                                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                                        .format(date),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white30
                                          : Colors.grey.shade400,
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
                                  onTap: () =>
                                      _deleteExpense(item['id'] as String),
                                  borderRadius: BorderRadius.circular(100),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: isDarkMode
                                        ? Colors.white24
                                        : Colors.grey.shade400,
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg =
            isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: _ramadanFormKey,
                autovalidateMode: autoValidate,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tambah Pengeluaran Ramadan',
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: contentColor),
                  ),
                  const SizedBox(height: 16),

RichText(
                    text: TextSpan(
                      text: 'Nama Pengeluaran',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: contentColor.withOpacity(0.4)),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _expenseTitleController,
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: contentColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama pengeluaran tidak boleh kosong';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                      hintText: 'Masukkan Nama Pengeluaran',
                      hintStyle: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          fontSize: 12.5),
                      prefixIcon: Icon(
                        Icons.shopping_bag_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

RichText(
                    text: TextSpan(
                      text: 'Nominal Belanja',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: contentColor.withOpacity(0.4)),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _expenseAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_RibuanFormatter()],
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: contentColor),
                    validator: (value) {
                      final raw = (value ?? '').replaceAll('.', '');
                      final amount = double.tryParse(raw) ?? 0.0;
                      if (raw.isEmpty || amount <= 0) {
                        return 'Nominal harus lebih dari 0';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                      hintText: 'Masukkan Nominal Belanja',
                      hintStyle: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          fontSize: 12.5),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 12, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp',
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),

                  const SizedBox(height: 16),

CheckboxListTile(
                    value: _syncWithMainTransactions,
                    activeColor: accentColor,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Sinkronkan ke Transaksi Utama',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: contentColor),
                    ),
                    subtitle: Text(
                      'Pencatatan ini akan langsung didaftarkan ke pengeluaran bulanan dompet utama.',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          color: Colors.grey),
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
                      onPressed: () {
                        setModalState(() {
                          autoValidate = AutovalidateMode.onUserInteraction;
                        });
                        _addExpense();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Pengeluaran',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
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
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
