import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class TabunganWisataPage extends ConsumerStatefulWidget {
  const TabunganWisataPage({super.key});

  @override
  ConsumerState<TabunganWisataPage> createState() => _TabunganWisataPageState();
}

class _TabunganWisataPageState extends ConsumerState<TabunganWisataPage> {
  // Config variables - Clean state, starting from 0, resets on exit
  String _destination = '';
  double _savedAmount = 0.0;
  DateTime? _targetDate; // Nullable target date
  List<Map<String, dynamic>> _budgetItems = [];
  List<Map<String, dynamic>> _checklistItems = [];

  // Controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _savedAmountController = TextEditingController();
  final TextEditingController _budgetItemNameController = TextEditingController();
  final TextEditingController _budgetItemCostController = TextEditingController();
  final TextEditingController _todoNameController = TextEditingController();

  final _destinationFormKey = GlobalKey<FormState>();
  final _savingsFormKey = GlobalKey<FormState>();
  final _budgetFormKey = GlobalKey<FormState>();
  final _todoFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _destinationController.dispose();
    _savedAmountController.dispose();
    _budgetItemNameController.dispose();
    _budgetItemCostController.dispose();
    _todoNameController.dispose();
    super.dispose();
  }

  double get _totalEstimatedCost {
    return _budgetItems.fold(0.0, (sum, item) => sum + (item['cost'] as num).toDouble());
  }

  int get _monthsRemaining {
    if (_targetDate == null) return 0;
    final now = DateTime.now();
    int months = (_targetDate!.year - now.year) * 12 + _targetDate!.month - now.month;
    return months <= 0 ? 1 : months;
  }

  double get _monthlySavingsTarget {
    if (_targetDate == null) return 0.0;
    final gap = _totalEstimatedCost - _savedAmount;
    if (gap <= 0) return 0.0;
    return gap / _monthsRemaining;
  }

  void _updateSavings() {
    if (!_savingsFormKey.currentState!.validate()) return;
    final text = _savedAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0.0;

    setState(() {
      _savedAmount = amount;
    });
    _savedAmountController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _addBudgetItem() {
    if (!_budgetFormKey.currentState!.validate()) return;
    final title = _budgetItemNameController.text.trim();
    final costText = _budgetItemCostController.text.replaceAll('.', '');
    final cost = double.tryParse(costText) ?? 0.0;

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'cost': cost,
    };

    setState(() {
      _budgetItems.add(newItem);
    });
    _budgetItemNameController.clear();
    _budgetItemCostController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _deleteBudgetItem(String id) {
    setState(() {
      _budgetItems.removeWhere((i) => i['id'] == id);
    });
  }

  void _addChecklistItem() {
    if (!_todoFormKey.currentState!.validate()) return;
    final title = _todoNameController.text.trim();

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'checked': false,
    };

    setState(() {
      _checklistItems.add(newItem);
    });
    _todoNameController.clear();
    if (mounted) Navigator.pop(context);
  }

  void _toggleChecklistItem(String id) {
    final index = _checklistItems.indexWhere((i) => i['id'] == id);
    if (index == -1) return;

    setState(() {
      _checklistItems[index]['checked'] = !(_checklistItems[index]['checked'] as bool);
    });
  }

  void _deleteChecklistItem(String id) {
    setState(() {
      _checklistItems.removeWhere((i) => i['id'] == id);
    });
  }

  // Dynamic travel category icon generator based on title matching
  IconData _getCategoryIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('pesawat') || lower.contains('tiket') || lower.contains('flight') || lower.contains('trans') || lower.contains('tiket')) {
      return Icons.flight_takeoff_rounded;
    }
    if (lower.contains('hotel') || lower.contains('penginapan') || lower.contains('villa') || lower.contains('stay') || lower.contains('kos')) {
      return Icons.hotel_rounded;
    }
    if (lower.contains('makan') || lower.contains('kuliner') || lower.contains('food') || lower.contains('restoran') || lower.contains('jajan')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('oleh') || lower.contains('souvenir') || lower.contains('hadiah') || lower.contains('gift') || lower.contains('belanja')) {
      return Icons.card_giftcard_rounded;
    }
    if (lower.contains('wisata') || lower.contains('rekreasi') || lower.contains('activity') || lower.contains('hiburan')) {
      return Icons.local_activity_rounded;
    }
    return Icons.beach_access_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFFFFDFB); // Cozy ultra-soft tint
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
          'Tabungan Wisata',
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
          // Destination Progress Card with Sunset gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF2E1A0F), // Warm sunset-tinted charcoal
                        const Color(0xFF1E1E1E),
                      ]
                    : [
                        const Color(0xFFFFF3E0), // Sunset pastel light orange gradient
                        const Color(0xFFFFFDFB),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RENCANA WISATA',
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _destination.isEmpty ? 'Destinasi Impian' : _destination,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: contentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${(progress * 100).toStringAsFixed(0)}% Terkumpul',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
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
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalEstimatedCost),
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Dana Terkumpul',
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_savedAmount),
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sleek, customized linear progress bar
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
                
                // Saving Target Advisory card inside dashboard
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
                                  ? 'Rencana Berangkat: ${DateFormat('MMMM yyyy', 'id_ID').format(_targetDate!)} ($_monthsRemaining Bulan Lagi)'
                                  : 'Rencana Berangkat: Belum Diatur',
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
                                  ? 'Nabung per Bulan: Rp ${NumberFormat.decimalPattern('id_ID').format(_monthlySavingsTarget.round())}'
                                  : 'Nabung per Bulan: - (Atur Tanggal Target)',
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
                          onPressed: () => _selectTargetDate(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : accentColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_calendar_rounded, size: 14, color: contentColor),
                              const SizedBox(width: 6),
                              Text(
                                'Atur Tanggal',
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
                  'Rincian Anggaran Perjalanan',
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
              ElevatedButton.icon(
                onPressed: () => _showAddBudgetItemDialog(isDarkMode, accentColor),
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
          const SizedBox(height: 12),

          // Budget cards list
          if (_budgetItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                ),
              ),
              child: Center(
                child: Text(
                  'Belum ada rincian anggaran. Silakan tambah kebutuhan wisata Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  ),
                ),
              ),
            )
          else
            ...List.generate(_budgetItems.length, (index) {
              final item = _budgetItems[index];
              final id = item['id'] as String;
              final title = item['title'] as String;
              final cost = (item['cost'] as num).toDouble();
              final catIcon = _getCategoryIcon(title);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.02 : 0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Colored Left indicator bar
                        Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Category Icon Badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            catIcon,
                            size: 18,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        
                        // Info Text Area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: contentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(cost),
                                style: GoogleFonts.quicksand(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Delete Button
                        IconButton(
                          onPressed: () => _deleteBudgetItem(id),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.redAccent.withOpacity(0.6),
                          ),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          splashRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 28),

          // Itinerary checklist panel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Persiapan Keberangkatan',
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
              ElevatedButton.icon(
                onPressed: () => _showAddChecklistDialog(isDarkMode, accentColor),
                icon: const Icon(Icons.playlist_add_rounded, size: 14, color: Colors.white),
                label: Text(
                  'Checklist',
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
          const SizedBox(height: 12),

          // Todo list
          if (_checklistItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                ),
              ),
              child: Center(
                child: Text(
                  'Belum ada checklist persiapan. Silakan tambah kegiatan Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  ),
                ),
              ),
            )
          else
            ..._checklistItems.map((item) {
              final id = item['id'] as String;
              final title = item['title'] as String;
              final checked = item['checked'] as bool;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                    onTap: () => _toggleChecklistItem(id),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Custom circle checkbox
                          Container(
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
                          const SizedBox(width: 14),
                          
                          // Checklist Title
                          Expanded(
                            child: Text(
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
                          ),
                          
                          // Delete Checklist Button
                          IconButton(
                            onPressed: () => _deleteChecklistItem(id),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Colors.redAccent.withOpacity(0.5),
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            splashRadius: 16,
                          ),
                        ],
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
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 180)),
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
    }
  }

  void _showEditDestinationDialog(bool isDarkMode, Color accentColor) {
    _destinationController.text = _destination;
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
              child: Form(
                key: _destinationFormKey,
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
                      'Ubah Destinasi Liburan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: 'Destinasi Liburan',
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
                      controller: _destinationController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama destinasi tidak boleh kosong';
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
                        hintText: 'Masukkan Nama Destinasi',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.place_rounded,
                          color: accentColor.withOpacity(0.8),
                          size: 18,
                        ),
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
                          if (_destinationFormKey.currentState!.validate()) {
                            setState(() {
                              _destination = _destinationController.text.trim();
                            });
                            _destinationController.clear();
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ),
            );
          }
        );
      },
    );
  }

  void _showUpdateSavedDialog(bool isDarkMode, Color accentColor) {
    _savedAmountController.text = _savedAmount > 0 ? NumberFormat.decimalPattern('id_ID').format(_savedAmount.round()) : '';
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
                      'Update Tabungan Liburan',
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
                      keyboardType: TextInputType.number,
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
                        onPressed: () {
                          setModalState(() {
                            autoValidate = AutovalidateMode.onUserInteraction;
                          });
                          _updateSavings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ),
            );
          }
        );
      },
    );
  }

  void _showAddBudgetItemDialog(bool isDarkMode, Color accentColor) {
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
              child: Form(
                key: _budgetFormKey,
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
                      'Tambah Kebutuhan Biaya Perjalanan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

                    // Item Name
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
                      controller: _budgetItemNameController,
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
                        hintText: 'Masukkan Nama Kebutuhan (misal: Tiket Pesawat)',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.label_important_rounded,
                          color: accentColor.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item Cost
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
                      controller: _budgetItemCostController,
                      keyboardType: TextInputType.number,
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
                        onPressed: () {
                          setModalState(() {
                            autoValidate = AutovalidateMode.onUserInteraction;
                          });
                          _addBudgetItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ),
            );
          }
        );
      },
    );
  }

  void _showAddChecklistDialog(bool isDarkMode, Color accentColor) {
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
              child: Form(
                key: _todoFormKey,
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
                      'Tambah Checklist Persiapan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

                    // Todo Name
                    RichText(
                      text: TextSpan(
                        text: 'Nama Persiapan / Kegiatan',
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
                      controller: _todoNameController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kegiatan tidak boleh kosong';
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
                        hintText: 'Masukkan Nama Kegiatan (misal: Beli Koper)',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.check_circle_rounded,
                          color: accentColor.withOpacity(0.8),
                          size: 18,
                        ),
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
                          _addChecklistItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ),
            );
          }
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
