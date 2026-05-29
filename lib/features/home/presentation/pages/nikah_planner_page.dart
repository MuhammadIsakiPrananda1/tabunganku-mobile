import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class BiayaNikahPlannerPage extends ConsumerStatefulWidget {
  const BiayaNikahPlannerPage({super.key});

  @override
  ConsumerState<BiayaNikahPlannerPage> createState() => _BiayaNikahPlannerPageState();
}

class _BiayaNikahPlannerPageState extends ConsumerState<BiayaNikahPlannerPage> {
  final String _prefKeyNikah = 'nikah_planner_data_v1';

  // State fields
  double _savedAmount = 0.0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365)); // Default 1 year from now
  List<Map<String, dynamic>> _checklistItems = [];

  // Controllers
  final TextEditingController _savedAmountController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostController = TextEditingController();

  String _selectedCategory = 'Gedung & Katering';
  final List<String> _categories = [
    'Gedung & Katering',
    'Busana & MUA',
    'Dekorasi & Hiburan',
    'Undangan & Souvenir',
    'Foto & Video',
    'Mahar & Hantaran',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlannerData();
  }

  @override
  void dispose() {
    _savedAmountController.dispose();
    _itemNameController.dispose();
    _itemCostController.dispose();
    super.dispose();
  }

  Future<void> _loadPlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyNikah);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _savedAmount = (decoded['savedAmount'] as num).toDouble();
      _targetDate = DateTime.parse(decoded['targetDate'] as String);
      _checklistItems = (decoded['items'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _savedAmount = 0.0;
      _checklistItems = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'savedAmount': _savedAmount,
      'targetDate': _targetDate.toIso8601String(),
      'items': _checklistItems,
    };
    await prefs.setString(_prefKeyNikah, jsonEncode(data));
  }

  void _updateSavings() async {
    final text = _savedAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0.0;
    if (amount < 0) return;

    setState(() {
      _savedAmount = amount;
    });
    await _savePlannerData();
    _savedAmountController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _addChecklistItem() async {
    final title = _itemNameController.text.trim();
    final costText = _itemCostController.text.replaceAll('.', '');
    final cost = double.tryParse(costText) ?? 0.0;

    if (title.isEmpty || cost <= 0) return;

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': _selectedCategory,
      'title': title,
      'cost': cost,
      'checked': false,
    };

    setState(() {
      _checklistItems.add(newItem);
    });
    await _savePlannerData();

    _itemNameController.clear();
    _itemCostController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _toggleChecklistItem(String id) async {
    final index = _checklistItems.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    setState(() {
      _checklistItems[index]['checked'] = !(_checklistItems[index]['checked'] as bool);
    });
    await _savePlannerData();
  }

  void _deleteChecklistItem(String id) async {
    setState(() {
      _checklistItems.removeWhere((item) => item['id'] == id);
    });
    await _savePlannerData();
  }

  double get _totalEstimatedCost {
    return _checklistItems.fold(0.0, (sum, item) => sum + (item['cost'] as num).toDouble());
  }

  int get _monthsRemaining {
    final now = DateTime.now();
    int months = (_targetDate.year - now.year) * 12 + _targetDate.month - now.month;
    return months <= 0 ? 1 : months;
  }

  double get _recommendedMonthlySavings {
    final gap = _totalEstimatedCost - _savedAmount;
    if (gap <= 0) return 0.0;
    return gap / _monthsRemaining;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFFFF9FA);
    final accentColor = const Color(0xFFEC407A); // Romantic Pink Accent
    final progress = _totalEstimatedCost > 0 ? (_savedAmount / _totalEstimatedCost).clamp(0.0, 1.0) : 0.0;

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
          '💍 Biaya Nikah Planner',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          // Circular Progress Dashboard
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimasi Total Biaya',
                            style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalEstimatedCost),
                              style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold, color: contentColor),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Uang Terkumpul Saat Ini',
                            style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_savedAmount),
                              style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: contentColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade50),
                const SizedBox(height: 14),
                
                // Savings Advice Row
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target Waktu: ${DateFormat('MMMM yyyy', 'id_ID').format(_targetDate)} ($_monthsRemaining Bulan Lagi).\nNabung per Bulan: Rp ${NumberFormat.decimalPattern('id_ID').format(_recommendedMonthlySavings.round())}',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _selectTargetDate(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                          ),
                          child: Text(
                            'Atur Tanggal',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11.5, color: contentColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => _showUpdateSavedDialog(isDarkMode, accentColor),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Update Tabungan',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category checklist grids
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '📋 Rencana Anggaran Nikah',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(isDarkMode, accentColor),
                icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                label: Text('Tambah Item', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_checklistItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 48,
                    color: accentColor.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Rencana Anggaran',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tambahkan kebutuhan pernikahan Anda (MUA, Dekorasi, Catering, dll) menggunakan tombol di atas.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

          // Group by category and build lists
          ..._categories.map((cat) {
            final catItems = _checklistItems.where((i) => i['category'] == cat).toList();
            if (catItems.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
                  child: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                ...catItems.map((item) {
                  final id = item['id'] as String;
                  final checked = item['checked'] as bool;
                  final title = item['title'] as String;
                  final cost = (item['cost'] as num).toDouble();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: checked,
                        activeColor: accentColor,
                        onChanged: (_) => _toggleChecklistItem(id),
                        title: Text(
                          title,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: checked 
                                ? Colors.grey 
                                : contentColor,
                            decoration: checked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(cost),
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: checked ? Colors.grey : accentColor,
                          ),
                        ),
                        secondary: IconButton(
                          onPressed: () => _deleteChecklistItem(id),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC407A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
      await _savePlannerData();
    }
  }

  void _showUpdateSavedDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
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
                  'Update Jumlah Tabungan Nikah',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _savedAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_RibuanFormatter()],
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    hintText: 'Masukkan Jumlah Tabungan',
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateSavings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddItemDialog(bool isDarkMode, Color accentColor) {
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
              child: SingleChildScrollView(
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
                      'Tambah Anggaran Kebutuhan Nikah',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),
  
                    // Category Selector
                    Text(
                      'Kategori Kebutuhan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                          items: _categories.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              _selectedCategory = val ?? _categories.first;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
  
                    // Item Name
                    Text(
                      'Nama Kebutuhan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _itemNameController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Nama Kebutuhan',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 16),
  
                    // Item Cost
                    Text(
                      'Estimasi Biaya',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _itemCostController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanFormatter()],
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Estimasi Biaya',
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
  
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _addChecklistItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Daftarkan Anggaran',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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
