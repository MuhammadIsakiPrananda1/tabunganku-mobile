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

  double _targetBudget = 0.0;

double _savedAmount = 0.0;
  DateTime? _targetDate;
  List<Map<String, dynamic>> _checklistItems = [];

final TextEditingController _savedAmountController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostController = TextEditingController();
  
  final _savingsFormKey = GlobalKey<FormState>();
  final _itemFormKey = GlobalKey<FormState>();

  String _selectedCategory = 'Gedung & Katering';
  final List<String> _categories = [
    'Gedung & Katering',
    'Busana & MUA',
    'Dekorasi & Hiburan',
    'Undangan & Souvenir',
    'Foto & Video',
    'Mahar & Hantaran',
    'Cincin & Perhiasan',
    'Dokumen & KUA',
    'Transportasi & Hotel',
    'Seragam Keluarga',
    'Bulan Madu',
    'Lain-lain',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Gedung & Katering': Icons.restaurant_rounded,
    'Busana & MUA': Icons.face_retouching_natural_rounded,
    'Dekorasi & Hiburan': Icons.celebration_rounded,
    'Undangan & Souvenir': Icons.mail_rounded,
    'Foto & Video': Icons.camera_alt_rounded,
    'Mahar & Hantaran': Icons.card_giftcard_rounded,
    'Cincin & Perhiasan': Icons.diamond_rounded,
    'Dokumen & KUA': Icons.assignment_rounded,
    'Transportasi & Hotel': Icons.directions_car_rounded,
    'Seragam Keluarga': Icons.people_alt_rounded,
    'Bulan Madu': Icons.flight_takeoff_rounded,
    'Lain-lain': Icons.more_horiz_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'Gedung & Katering': const Color(0xFFEC407A),
    'Busana & MUA': const Color(0xFFAB47BC),
    'Dekorasi & Hiburan': const Color(0xFFFF7043),
    'Undangan & Souvenir': const Color(0xFF42A5F5),
    'Foto & Video': const Color(0xFF26A69A),
    'Mahar & Hantaran': const Color(0xFFFFCA28),
    'Cincin & Perhiasan': const Color(0xFFE91E63),
    'Dokumen & KUA': const Color(0xFF4CAF50),
    'Transportasi & Hotel': const Color(0xFF00BCD4),
    'Seragam Keluarga': const Color(0xFF3F51B5),
    'Bulan Madu': const Color(0xFF9C27B0),
    'Lain-lain': const Color(0xFF78909C),
  };

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
      _targetBudget = (decoded['targetBudget'] as num?)?.toDouble() ?? 0.0;
      if (decoded['targetDate'] != null) {
        _targetDate = DateTime.parse(decoded['targetDate'] as String);
      } else {
        _targetDate = null;
      }
      _checklistItems = (decoded['items'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _savedAmount = 0.0;
      _targetBudget = 0.0;
      _targetDate = null;
      _checklistItems = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'savedAmount': _savedAmount,
      'targetBudget': _targetBudget,
      'targetDate': _targetDate?.toIso8601String(),
      'items': _checklistItems,
    };
    await prefs.setString(_prefKeyNikah, jsonEncode(data));
  }

  void _updateSavings() async {
    if (!_savingsFormKey.currentState!.validate()) return;
    final text = _savedAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0.0;

    setState(() {
      _savedAmount = amount;
    });
    await _savePlannerData();
    _savedAmountController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _addChecklistItem() async {
    if (!_itemFormKey.currentState!.validate()) return;
    final title = _itemNameController.text.trim();
    final costText = _itemCostController.text.replaceAll('.', '');
    final cost = double.tryParse(costText) ?? 0.0;

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

  void _editChecklistItem(String id) async {
    if (!_itemFormKey.currentState!.validate()) return;
    final title = _itemNameController.text.trim();
    final costText = _itemCostController.text.replaceAll('.', '');
    final cost = double.tryParse(costText) ?? 0.0;

    final index = _checklistItems.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    setState(() {
      _checklistItems[index]['title'] = title;
      _checklistItems[index]['cost'] = cost;
      _checklistItems[index]['category'] = _selectedCategory;
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

  double get _effectiveTargetBudget {
    if (_targetBudget > 0) return _targetBudget;
    return _totalEstimatedCost;
  }

  int get _monthsRemaining {
    if (_targetDate == null) return 0;
    final now = DateTime.now();
    int months = (_targetDate!.year - now.year) * 12 + _targetDate!.month - now.month;
    return months <= 0 ? 1 : months;
  }

  double get _recommendedMonthlySavings {
    if (_targetDate == null) return 0.0;
    final gap = _effectiveTargetBudget - _savedAmount;
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
    final accentColor = const Color(0xFFEC407A);
    final progress = _effectiveTargetBudget > 0 ? (_savedAmount / _effectiveTargetBudget).clamp(0.0, 1.0) : 0.0;

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
          'Perencana Biaya Nikah',
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
          _buildTipCard(isDarkMode, accentColor),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF2A1E24),
                        const Color(0xFF1F1F1F),
                      ]
                    : [
                        const Color(0xFFFFF0F3),
                        const Color(0xFFFFF9FA),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(isDarkMode ? 0.05 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDarkMode
                    ? accentColor.withOpacity(0.1)
                    : accentColor.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RENCANA NIKAH',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}% Terkumpul',
                        style: GoogleFonts.quicksand(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _targetBudget > 0 ? 'Target Anggaran' : 'Estimasi Total Biaya',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_effectiveTargetBudget),
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: contentColor,
                              ),
                            ),
                          ),
                          if (_targetBudget > 0 && _totalEstimatedCost > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Detail Kebutuhan: Rp ${NumberFormat.decimalPattern('id_ID').format(_totalEstimatedCost.round())}',
                              style: GoogleFonts.quicksand(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white30 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Uang Terkumpul',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_savedAmount),
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(height: 20),

Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: accentColor.withOpacity(0.8), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _targetDate != null
                                  ? 'Target: ${DateFormat('MMMM yyyy', 'id_ID').format(_targetDate!)} ($_monthsRemaining Bulan Lagi)'
                                  : 'Target: Belum Diatur',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.savings_rounded, color: accentColor.withOpacity(0.8), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _targetDate != null
                                  ? 'Nabung per Bulan: Rp ${NumberFormat.decimalPattern('id_ID').format(_recommendedMonthlySavings.round())}'
                                  : 'Nabung per Bulan: - (Sesuaikan Rencana)',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => _showAdjustPlanSheet(isDarkMode, accentColor),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : accentColor.withOpacity(0.2),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.tune_rounded, size: 14, color: contentColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sesuaikan Rencana',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                      color: contentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => _showUpdateSavedDialog(isDarkMode, accentColor),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_card_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Update Tabungan',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rencana Anggaran Pernikahan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: contentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(isDarkMode, accentColor),
                    icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    label: Text(
                      'Tambah',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),

if (_checklistItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.01) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.list_alt_rounded, size: 40, color: accentColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'Anggaran Masih Kosong',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Belum ada rincian anggaran. Silakan tambah kebutuhan pernikahan Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ..._categories.map((cat) {
            final catItems = _checklistItems.where((i) => i['category'] == cat).toList();
            if (catItems.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4, top: 16),
                  child: Text(
                    cat.toUpperCase(),
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...catItems.map((item) {
                  final id = item['id'] as String;
                  final checked = item['checked'] as bool;
                  final title = item['title'] as String;
                  final cost = (item['cost'] as num).toDouble();
                  final catColor = _categoryColors[item['category']] ?? accentColor;
                  final catIcon = _categoryIcons[item['category']] ?? Icons.circle_outlined;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode
                              ? (checked
                                  ? Colors.white.withOpacity(0.02)
                                  : Colors.white.withOpacity(0.04))
                              : (checked
                                  ? Colors.grey.shade50
                                  : Colors.grey.shade100),
                        ),
                        boxShadow: [
                          if (!checked)
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.02 : 0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showAddItemDialog(isDarkMode, accentColor, editingItem: item),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [

                              GestureDetector(
                                onTap: () => _toggleChecklistItem(id),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: checked
                                          ? accentColor
                                          : (isDarkMode
                                              ? Colors.white30
                                              : Colors.grey.shade400),
                                      width: 2,
                                    ),
                                    color: checked ? accentColor : Colors.transparent,
                                  ),
                                  child: checked
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 14),

Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: checked
                                      ? (isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade100)
                                      : catColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  catIcon,
                                  size: 18,
                                  color: checked
                                      ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                                      : catColor,
                                ),
                              ),
                              const SizedBox(width: 14),

Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: checked
                                            ? (isDarkMode ? Colors.white30 : Colors.grey.shade400)
                                            : contentColor,
                                        decoration: checked ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(cost),
                                      style: GoogleFonts.quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: checked
                                            ? (isDarkMode ? Colors.white24 : Colors.grey.shade400)
                                            : accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                              ),
                            ],
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

void _showUpdateSavedDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _savingsFormKey,
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
                      RichText(
                        text: TextSpan(
                          text: 'Jumlah Tabungan',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _savedAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_RibuanFormatter()],
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                        validator: (value) {
                          final raw = (value ?? '').replaceAll('.', '');
                          final amount = double.tryParse(raw) ?? 0.0;
                          if (raw.isEmpty || amount < 0) {
                            return 'Nominal tabungan tidak boleh kosong';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                          hintText: 'Masukkan Jumlah Tabungan',
                          hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(left: 12, right: 4),
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
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
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
                            _updateSavings();
                          },
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
              ),
            );
          }
        );
      },
    );
  }

  void _showAddItemDialog(bool isDarkMode, Color accentColor, {Map<String, dynamic>? editingItem}) {
    if (editingItem != null) {
      _itemNameController.text = editingItem['title'] as String;
      final cost = (editingItem['cost'] as num).round();
      _itemCostController.text = NumberFormat.decimalPattern('id_ID').format(cost);
      _selectedCategory = editingItem['category'] as String;
    } else {
      _itemNameController.clear();
      _itemCostController.clear();
      _selectedCategory = _categories.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _itemFormKey,
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
                            color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            editingItem == null
                                ? 'Tambah Anggaran Kebutuhan Nikah'
                                : 'Edit Anggaran Kebutuhan Nikah',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14.5, color: contentColor),
                          ),
                          if (editingItem != null)
                            IconButton(
                              onPressed: () {
                                _deleteChecklistItem(editingItem['id'] as String);
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

Text(
                        'Kategori Kebutuhan',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 8),

DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: contentColor.withOpacity(0.5)),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: contentColor,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 4, bottom: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        items: _categories.map((String cat) {
                          final icon = _categoryIcons[cat] ?? Icons.circle;
                          final catColor = _categoryColors[cat] ?? accentColor;
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, size: 14, color: catColor),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  cat,
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: contentColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

RichText(
                        text: TextSpan(
                          text: 'Nama Kebutuhan',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _itemNameController,
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama kebutuhan tidak boleh kosong';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                          hintText: 'Masukkan Nama Kebutuhan',
                          hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                          contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
                          prefixIcon: Icon(
                            Icons.label_outline_rounded,
                            color: accentColor.withOpacity(0.8),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

RichText(
                        text: TextSpan(
                          text: 'Estimasi Biaya',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _itemCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_RibuanFormatter()],
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                        validator: (value) {
                          final raw = (value ?? '').replaceAll('.', '');
                          final amount = double.tryParse(raw) ?? 0.0;
                          if (raw.isEmpty || amount <= 0) {
                            return 'Estimasi biaya harus lebih dari 0';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                          hintText: 'Masukkan Estimasi Biaya',
                          hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                          contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(left: 12, right: 4),
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
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
    
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              autoValidate = AutovalidateMode.onUserInteraction;
                            });
                            if (editingItem == null) {
                              _addChecklistItem();
                            } else {
                              _editChecklistItem(editingItem['id'] as String);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            editingItem == null ? 'Daftarkan Anggaran' : 'Simpan Perubahan',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

void _showAdjustPlanSheet(bool isDarkMode, Color accentColor) {
    final targetBudgetController = TextEditingController(
      text: _targetBudget > 0 ? NumberFormat.decimalPattern('id_ID').format(_targetBudget.round()) : ''
    );
    DateTime? tempTargetDate = _targetDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                      'Sesuaikan Rencana Nikah',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

Text(
                      'Target Anggaran Pernikahan (Rp)',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: targetBudgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_RibuanFormatter()],
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Target Anggaran',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13)),
                            ],
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 8),

Text(
                      'Tanggal Pernikahan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempTargetDate ?? DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: isDarkMode
                                    ? ColorScheme.dark(
                                        primary: accentColor,
                                        onPrimary: Colors.white,
                                        surface: AppColors.surfaceDark,
                                        onSurface: Colors.white,
                                      )
                                    : ColorScheme.light(
                                        primary: accentColor,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: AppColors.primaryDark,
                                      ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempTargetDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: accentColor, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              tempTargetDate != null
                                  ? DateFormat('MMMM yyyy', 'id_ID').format(tempTargetDate!)
                                  : 'Pilih Bulan & Tahun',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final budgetText = targetBudgetController.text.replaceAll('.', '');
                          final budget = double.tryParse(budgetText) ?? 0.0;

                          setState(() {
                            _targetBudget = budget;
                            _targetDate = tempTargetDate;
                          });

                          await _savePlannerData();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Rencana pernikahan berhasil disimpan!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                              backgroundColor: accentColor,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Simpan Rencana',
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

Widget _buildTipCard(bool isDarkMode, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : accentColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_rounded, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Planner Pernikahan',
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Gunakan tombol "Template" di kanan untuk memuat preset anggaran secara instan.\n'
                  '2. Klik "Sesuaikan Rencana" untuk mengatur target anggaran, sisa waktu, dan tabungan Anda.',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
