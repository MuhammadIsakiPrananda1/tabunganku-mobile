import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';

class SavingPlansPage extends ConsumerStatefulWidget {
  const SavingPlansPage({super.key});

  @override
  ConsumerState<SavingPlansPage> createState() => _SavingPlansPageState();
}

class _SavingPlansPageState extends ConsumerState<SavingPlansPage> {
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Semua',
      'category': 'Semua',
      'icon': Icons.grid_view_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Dana Darurat',
      'category': 'Darurat',
      'icon': Icons.health_and_safety_rounded,
      'color': Colors.redAccent,
      'desc': 'Dana cadangan untuk situasi tidak terduga.',
    },
    {
      'title': 'Dana Pendidikan',
      'category': 'Pendidikan',
      'icon': Icons.school_rounded,
      'color': Colors.blueAccent,
      'desc': 'Persiapan biaya pendidikan masa depan.',
    },
    {
      'title': 'Dana Pensiun',
      'category': 'Pensiun',
      'icon': Icons.elderly_rounded,
      'color': Colors.orangeAccent.shade700,
      'desc': 'Tabungan untuk masa tua yang sejahtera.',
    },
    {
      'title': 'Kurban',
      'category': 'Kurban',
      'icon': Icons.pets_rounded,
      'color': Colors.green,
      'desc': 'Tabungan khusus untuk ibadah kurban tahunan.',
    },
  ];

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Darurat':
        return Colors.redAccent;
      case 'Pendidikan':
        return Colors.blueAccent;
      case 'Pensiun':
        return Colors.orangeAccent.shade700;
      case 'Kurban':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Darurat':
        return Icons.health_and_safety_rounded;
      case 'Pendidikan':
        return Icons.school_rounded;
      case 'Pensiun':
        return Icons.elderly_rounded;
      case 'Kurban':
        return Icons.pets_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'Darurat':
        return 'Dana Darurat';
      case 'Pendidikan':
        return 'Dana Pendidikan';
      case 'Pensiun':
        return 'Dana Pensiun';
      case 'Kurban':
        return 'Kurban';
      default:
        return cat;
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  String _formatDigitsWithDots(String s) {
    if (s.isEmpty) return s;
    String digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  Future<void> _deleteTarget(String? targetId) async {
    if (targetId == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Hapus Rencana?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus rencana tabungan ini? Tindakan ini tidak dapat dikembalikan.',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(savingTargetServiceProvider).deleteTarget(targetId);
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Rencana berhasil dihapus.',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showAddSheet({SavingTargetModel? target}) {
    final isEdit = target != null;
    final nameController = TextEditingController(text: isEdit ? target.name : '');
    final amountController = TextEditingController(
      text: isEdit ? _formatDigitsWithDots(target.targetAmount.round().toString()) : '',
    );
    DateTime selectedDate = isEdit ? target.dueDate : DateTime.now().add(const Duration(days: 365));
    final dateController = TextEditingController(
      text: DateFormat('d MMM yyyy', 'id_ID').format(selectedDate),
    );
    String selectedCategory = isEdit ? target.category : 'Darurat';

    bool nameHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final inset = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            padding: EdgeInsets.only(bottom: inset),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isEdit ? 'Ubah Rencana Tabungan' : 'Tambah Rencana Tabungan',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Input
                  HighVisInput(
                    controller: nameController,
                    icon: Icons.edit_note_rounded,
                    label: 'Nama Rencana',
                    isDarkMode: isDark,
                    hintText: 'Masukkan Nama Rencana (cth: Beli Laptop)',
                    hasError: nameHasError,
                    onChanged: (val) {
                      if (nameHasError && val.trim().isNotEmpty) {
                        setSheetState(() => nameHasError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  HighVisInput(
                    controller: amountController,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Dana yang Dibutuhkan',
                    isDarkMode: isDark,
                    hintText: 'Masukkan Nominal Target',
                    prefixText: 'Rp',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _RibuanFormatter(),
                    ],
                    hasError: amountHasError,
                    onChanged: (val) {
                      if (amountHasError) {
                        final amt = double.tryParse(val.replaceAll('.', '')) ?? 0;
                        if (amt > 0) {
                          setSheetState(() => amountHasError = false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Due Date Picker (Using HighVisInput as readOnly button)
                  HighVisInput(
                    controller: dateController,
                    icon: Icons.calendar_today_rounded,
                    label: 'Target Terkumpul',
                    isDarkMode: isDark,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          selectedDate = picked;
                          dateController.text = DateFormat('d MMM yyyy', 'id_ID').format(picked);
                        });
                      }
                    },
                    suffix: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Chips Selector
                  Text(
                    'Kategori Rencana',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Darurat', 'Pendidikan', 'Pensiun', 'Kurban'].map((cat) {
                      final isSelected = selectedCategory == cat;
                      final catColor = _getCategoryColor(cat);
                      return ChoiceChip(
                        label: Text(
                          _getCategoryTitle(cat),
                          style: GoogleFonts.quicksand(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setSheetState(() => selectedCategory = cat),
                        selectedColor: catColor,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: () async {
                      final nameVal = nameController.text.trim();
                      final rawAmount = amountController.text.replaceAll('.', '');
                      final amountVal = double.tryParse(rawAmount) ?? 0.0;

                      setSheetState(() {
                        nameHasError = nameVal.isEmpty;
                        amountHasError = amountVal <= 0;
                      });

                      if (nameHasError || amountHasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nameHasError
                                        ? 'Nama rencana tidak boleh kosong!'
                                        : 'Nominal target harus lebih dari 0!',
                                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }

                      final navigator = Navigator.of(context);
                      if (isEdit) {
                        final updated = target.copyWith(
                          name: nameVal,
                          targetAmount: amountVal,
                          dueDate: selectedDate,
                          category: selectedCategory,
                        );
                        await ref.read(savingTargetServiceProvider).updateTarget(updated);
                      } else {
                        final newModel = SavingTargetModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameVal,
                          targetAmount: amountVal,
                          dueDate: selectedDate,
                          createdAt: DateTime.now(),
                          category: selectedCategory,
                        );
                        await ref.read(savingTargetServiceProvider).addTarget(newModel);
                      }

                      navigator.pop();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  isEdit ? 'Rencana diperbarui!' : 'Rencana berhasil dibuat!',
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Rencana Tabungan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final bgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final transactions = ref.watch(transactionsByGroupProvider(null));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Dana Rencana',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: targetsAsync.when(
        data: (targets) {
          // Filter only saving target categories to prevent conflict with Buying Targets (Pembelian/Umum)
          final planTargets = targets.where((t) => 
            t.category == 'Darurat' || 
            t.category == 'Pendidikan' || 
            t.category == 'Pensiun' || 
            t.category == 'Kurban'
          ).toList();

          return Column(
            children: [
              _buildMetricsDashboard(planTargets, transactions, isDarkMode),
              _buildDropdownFilter(isDarkMode),
              const SizedBox(height: 8),
              Expanded(
                child: _buildTargetsList(planTargets, transactions, isDarkMode),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Rencana',
          style: GoogleFonts.quicksand(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildMetricsDashboard(
      List<SavingTargetModel> targets, List<TransactionModel> transactions, bool isDark) {
    // Filter targets based on selected category filter
    final filteredTargets = _selectedFilter == 'Semua'
        ? targets
        : targets.where((t) => t.category == _selectedFilter).toList();

    double totalTarget = 0.0;
    double totalSaved = 0.0;

    for (var target in filteredTargets) {
      totalTarget += target.targetAmount;
      final targetBalance = transactions
          .where((t) => !t.date.isBefore(target.createdAt))
          .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : 0));
      totalSaved += targetBalance > target.targetAmount ? target.targetAmount : targetBalance;
    }

    final remaining = totalTarget - totalSaved;
    final globalProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    // Dynamically adjust title based on selected filter
    String dashboardTitle = 'TOTAL DANA DIRENCANAKAN';
    if (_selectedFilter != 'Semua') {
      dashboardTitle = 'TOTAL ${_getCategoryTitle(_selectedFilter).toUpperCase()}';
    }

    // Dynamic brand colors for gradient and indicator
    final activeColor = _selectedFilter == 'Semua' ? AppColors.primary : _getCategoryColor(_selectedFilter);
    final categoryLightColors = {
      'Darurat': Colors.redAccent.shade100,
      'Pendidikan': Colors.blueAccent.shade100,
      'Pensiun': Colors.orangeAccent.shade100,
      'Kurban': Colors.greenAccent.shade200,
    };
    final lightColor = _selectedFilter == 'Semua' 
        ? Colors.teal.shade300 
        : (categoryLightColors[_selectedFilter] ?? Colors.teal.shade300);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  activeColor.withOpacity(0.15),
                  Colors.teal.shade900.withOpacity(0.3)
                ]
              : [activeColor, activeColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: activeColor.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
        border: Border.all(
          color: isDark
              ? activeColor.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboardTitle,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? lightColor : Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(totalTarget),
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpenuhi',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? lightColor : Colors.white70,
                ),
              ),
              Text(
                '${(globalProgress * 100).toInt()}%',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: globalProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.15),
              color: isDark ? lightColor : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL TERKUMPUL',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalSaved),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEBUTUHAN SISA',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white30 : Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(remaining > 0 ? remaining : 0.0),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? lightColor : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(bool isDark) {
    final activeCat = _categories.firstWhere((cat) => cat['category'] == _selectedFilter);
    final activeColor = activeCat['color'] as Color;
    final activeIcon = activeCat['icon'] as IconData;
    final activeTitle = activeCat['title'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Theme(
          data: Theme.of(context).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            initialValue: _selectedFilter,
            onSelected: (String value) {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = value);
            },
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                width: 1,
              ),
            ),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activeIcon,
                      size: 14,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    activeTitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) {
              return _categories.map((cat) {
                final categoryKey = cat['category'] as String;
                final isSelected = _selectedFilter == categoryKey;
                final Color catColor = cat['color'] as Color;

                return PopupMenuItem<String>(
                  value: categoryKey,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          size: 14,
                          color: catColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['title'] as String,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                            color: isSelected 
                                ? catColor 
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: catColor,
                        ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTargetsList(
      List<SavingTargetModel> targets, List<TransactionModel> transactions, bool isDark) {
    final filtered = _selectedFilter == 'Semua'
        ? targets
        : targets.where((t) => t.category == _selectedFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_added_outlined,
              size: 80,
              color: isDark ? Colors.white10 : Colors.teal.shade50,
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada rencana',
              style: GoogleFonts.quicksand(
                color: isDark ? Colors.white38 : Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buat rencana dana impianmu sekarang!',
              style: GoogleFonts.quicksand(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final target = filtered[index];
        final catColor = _getCategoryColor(target.category);
        final catIcon = _getCategoryIcon(target.category);

        final targetBalance = transactions
            .where((t) => !t.date.isBefore(target.createdAt))
            .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : 0));
        final progress = (target.targetAmount > 0)
            ? (targetBalance / target.targetAmount).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: catColor.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      catIcon,
                      color: catColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Category badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: catColor.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getCategoryTitle(target.category),
                                style: GoogleFonts.quicksand(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: catColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 10,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM yyyy', 'id_ID').format(target.dueDate),
                              style: GoogleFonts.quicksand(
                                color: isDark ? Colors.white38 : Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _showAddSheet(target: target),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.blue.shade400,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteTarget(target.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade400,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: catColor.withOpacity(0.1),
                  color: catColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatRupiah(targetBalance)} / ${_formatRupiah(target.targetAmount)}',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: catColor,
                    ),
                  ),
                ],
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
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
