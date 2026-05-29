import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class TabunganWisataPage extends ConsumerStatefulWidget {
  const TabunganWisataPage({super.key});

  @override
  ConsumerState<TabunganWisataPage> createState() => _TabunganWisataPageState();
}

class _TabunganWisataPageState extends ConsumerState<TabunganWisataPage> {
  final String _prefKeyWisata = 'wisata_planner_data_v1';

  // Config variables
  String _destination = '';
  double _savedAmount = 0.0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  List<Map<String, dynamic>> _budgetItems = [];
  List<Map<String, dynamic>> _checklistItems = [];

  // Controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _savedAmountController = TextEditingController();
  
  final TextEditingController _budgetItemNameController = TextEditingController();
  final TextEditingController _budgetItemCostController = TextEditingController();
  
  final TextEditingController _todoNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlannerData();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _savedAmountController.dispose();
    _budgetItemNameController.dispose();
    _budgetItemCostController.dispose();
    _todoNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyWisata);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _destination = decoded['destination'] as String? ?? '';
      _savedAmount = (decoded['savedAmount'] as num?)?.toDouble() ?? 0.0;
      _targetDate = DateTime.parse(decoded['targetDate'] as String);
      _budgetItems = (decoded['budgetItems'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
      _checklistItems = (decoded['checklistItems'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _destination = '';
      _savedAmount = 0.0;
      _budgetItems = [];
      _checklistItems = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'destination': _destination,
      'savedAmount': _savedAmount,
      'targetDate': _targetDate.toIso8601String(),
      'budgetItems': _budgetItems,
      'checklistItems': _checklistItems,
    };
    await prefs.setString(_prefKeyWisata, jsonEncode(data));
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

  void _addBudgetItem() async {
    final title = _budgetItemNameController.text.trim();
    final costText = _budgetItemCostController.text.replaceAll('.', '');
    final cost = double.tryParse(costText) ?? 0.0;

    if (title.isEmpty || cost <= 0) return;

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'cost': cost,
    };

    setState(() {
      _budgetItems.add(newItem);
    });
    await _savePlannerData();
    _budgetItemNameController.clear();
    _budgetItemCostController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _deleteBudgetItem(String id) async {
    setState(() {
      _budgetItems.removeWhere((i) => i['id'] == id);
    });
    await _savePlannerData();
  }

  void _addChecklistItem() async {
    final title = _todoNameController.text.trim();
    if (title.isEmpty) return;

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'checked': false,
    };

    setState(() {
      _checklistItems.add(newItem);
    });
    await _savePlannerData();
    _todoNameController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _toggleChecklistItem(String id) async {
    final index = _checklistItems.indexWhere((i) => i['id'] == id);
    if (index == -1) return;

    setState(() {
      _checklistItems[index]['checked'] = !(_checklistItems[index]['checked'] as bool);
    });
    await _savePlannerData();
  }

  void _deleteChecklistItem(String id) async {
    setState(() {
      _checklistItems.removeWhere((i) => i['id'] == id);
    });
    await _savePlannerData();
  }

  double get _totalEstimatedCost {
    return _budgetItems.fold(0.0, (sum, item) => sum + (item['cost'] as num).toDouble());
  }

  int get _monthsRemaining {
    final now = DateTime.now();
    int months = (_targetDate.year - now.year) * 12 + _targetDate.month - now.month;
    return months <= 0 ? 1 : months;
  }

  double get _monthlySavingsTarget {
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
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFFFFBF7);
    final accentColor = const Color(0xFFFF9800); // Sunset Orange
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
          '🏖️ Tabungan Wisata',
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
          // Destination Progress Card
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destinasi Impian',
                            style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _destination.isEmpty ? 'Belum Diatur' : _destination,
                                  style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.bold, color: contentColor),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _showEditDestinationDialog(isDarkMode, accentColor),
                                borderRadius: BorderRadius.circular(100),
                                child: Icon(Icons.edit_rounded, size: 14, color: accentColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.beach_access_rounded, color: accentColor, size: 24),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimasi Total Biaya',
                          style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalEstimatedCost),
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: contentColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Dana Terkumpul',
                          style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_savedAmount),
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Linear progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Saving Target Advisory
                Row(
                  children: [
                    Icon(Icons.departure_board_rounded, color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rencana Berangkat: ${DateFormat('dd MMM yyyy', 'id_ID').format(_targetDate)} ($_monthsRemaining Bulan Lagi).\nTarget Nabung / Bulan: Rp ${NumberFormat.decimalPattern('id_ID').format(_monthlySavingsTarget.round())}',
                        style: GoogleFonts.quicksand(
                          fontSize: 10.5,
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
          const SizedBox(height: 28),

          // Budget items panel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '💰 Rincian Anggaran Wisata',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddBudgetItemDialog(isDarkMode, accentColor),
                icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                label: Text('Anggaran', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Budget cards list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
              ),
            ),
            child: _budgetItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada rincian anggaran.',
                        style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(_budgetItems.length, (index) {
                      final item = _budgetItems[index];
                      final id = item['id'] as String;
                      final title = item['title'] as String;
                      final cost = (item['cost'] as num).toDouble();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(cost),
                                      style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _deleteBudgetItem(id),
                                      borderRadius: BorderRadius.circular(100),
                                      child: Icon(Icons.close_rounded, size: 16, color: Colors.redAccent.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (index != _budgetItems.length - 1)
                            Divider(height: 1, color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade50),
                        ],
                      );
                    }),
                  ),
          ),

          const SizedBox(height: 28),

          // Itinerary checklist panel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '✈️ Persiapan Keberangkatan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddChecklistDialog(isDarkMode, accentColor),
                icon: const Icon(Icons.playlist_add_rounded, size: 14, color: Colors.white),
                label: Text('Checklist', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Todo list
          ..._checklistItems.map((item) {
            final id = item['id'] as String;
            final title = item['title'] as String;
            final checked = item['checked'] as bool;

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
                      color: checked ? Colors.grey : contentColor,
                      decoration: checked ? TextDecoration.lineThrough : null,
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
              primary: Color(0xFFFF9800),
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

  void _showEditDestinationDialog(bool isDarkMode, Color accentColor) {
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
                'Ubah Destinasi Liburan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _destinationController,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Masukkan Nama Destinasi',
                  hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_destinationController.text.trim().isNotEmpty) {
                      setState(() {
                        _destination = _destinationController.text.trim();
                      });
                      await _savePlannerData();
                    }
                    _destinationController.clear();
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Destinasi',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                'Update Tabungan Liburan',
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
                    'Simpan Tabungan',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddBudgetItemDialog(bool isDarkMode, Color accentColor) {
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
                'Tambah Kebutuhan Biaya Perjalanan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
              ),
              const SizedBox(height: 20),

              // Item Name
              Text(
                'Nama Kebutuhan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _budgetItemNameController,
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
                controller: _budgetItemCostController,
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
                  onPressed: _addBudgetItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Anggaran',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddChecklistDialog(bool isDarkMode, Color accentColor) {
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
                'Tambah Checklist Persiapan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
              ),
              const SizedBox(height: 20),

              // Todo Name
              Text(
                'Nama Persiapan / Kegiatan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _todoNameController,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Masukkan Nama Kegiatan',
                  hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
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
                    'Simpan Checklist',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
