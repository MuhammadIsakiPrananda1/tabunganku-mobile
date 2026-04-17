import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
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
  int _activeTabIndex = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> _tabs = [
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
      'color': Colors.brown,
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

  // Logic from SpecializedSavingPage
  final _amountControllers = List.generate(4, (_) => TextEditingController());
  final _nameControllers = List.generate(4, (i) => TextEditingController());
  final List<DateTime> _selectedDates = List.generate(4, (_) => DateTime.now().add(const Duration(days: 365)));

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    for (int i = 0; i < _tabs.length; i++) {
        _nameControllers[i].text = '${_tabs[i]['category']} ';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _amountControllers) {
      c.dispose();
    }
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _activeTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final bgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

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
        title: Text('Dana Rencana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
      ),
      body: Column(
        children: [
          // Navigation Tabs (Zakat Style)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return _buildNavChip(index, _tabs[index]['title'], _tabs[index]['icon'], contentColor);
                }),
              ),
            ),
          ),

          // Main Page View
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTabIndex = index),
              physics: const BouncingScrollPhysics(),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                return _buildTabContent(index, isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavChip(int index, String label, IconData icon, Color contentColor) {
    final isSelected = _activeTabIndex == index;
    final tabColor = _tabs[index]['color'] as Color;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _onTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? tabColor : (contentColor.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : contentColor.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                label.split(' ').last, // Use short label
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : contentColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int index, bool isDarkMode) {
    final tab = _tabs[index];
    final category = tab['category'] as String;
    final baseColor = tab['color'] as Color;
    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return targetsAsync.when(
      data: (targets) {
        final filteredTargets = targets.where((t) => t.name.toLowerCase().contains(category.toLowerCase())).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(tab, isDarkMode),
              const SizedBox(height: 32),

              _buildInlineInputForm(index, baseColor, isDarkMode, category),
              const SizedBox(height: 32),

              Text('DAFTAR ${tab['title'].toUpperCase()}', 
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
              const SizedBox(height: 16),
              if (filteredTargets.where((t) => t.category == category).isEmpty)
                _buildEmptyState(tab['icon'], isDarkMode)
              else
                ...filteredTargets.where((t) => t.category == category).map((t) => _buildTargetItem(t, baseColor, isDarkMode)),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> tab, bool isDarkMode) {
    final Color baseColor = tab['color'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(tab['icon'], size: 28, color: baseColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tab['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: baseColor)),
                const SizedBox(height: 4),
                Text(
                  tab['desc'],
                  style: TextStyle(fontSize: 11, color: baseColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineInputForm(int index, Color baseColor, bool isDarkMode, String category) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHighVisInput(
            controller: _nameControllers[index],
            icon: Icons.edit_note_rounded,
            label: 'Nama Rencana',
            unit: '',
            color: AppColors.primary,
            isDarkMode: isDarkMode,
            hint: 'Masukkan Nama Rencana',
          ),
          const SizedBox(height: 16),
          _buildHighVisInput(
            controller: _amountControllers[index],
            icon: Icons.account_balance_wallet_rounded,
            label: 'Dana yang Dibutuhkan',
            unit: 'Rp',
            color: Colors.green,
            isDarkMode: isDarkMode,
            isPremium: true,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              InkWell(
                onTap: () => _pickDateInline(index, isDarkMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target Terkumpul', style: TextStyle(fontSize: 10, color: (isDarkMode ? Colors.white38 : Colors.grey.shade500), fontWeight: FontWeight.bold)),
                          Text(DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDates[index]), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountControllers[index].text.replaceAll('.', '')) ?? 0;
                    if (amount > 0) {
                      final target = SavingTargetModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameControllers[index].text,
                        targetAmount: amount,
                        dueDate: _selectedDates[index],
                        createdAt: DateTime.now(),
                        category: category,
                      );
                      await ref.read(savingTargetServiceProvider).addTarget(target);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Rencana Berhasil Dibuat'),
                          backgroundColor: AppColors.primary,
                        ));
                      }
                      _nameControllers[index].clear();
                      _amountControllers[index].clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Buat Rencana Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickDateInline(int index, bool isDarkMode) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDates[index],
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDates[index] = picked);
    }
  }

  Widget _buildHighVisInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String unit,
    required Color color,
    required bool isDarkMode,
    bool isPremium = false,
    String? hint,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return TextFormField(
      controller: controller,
      keyboardType: isPremium ? TextInputType.number : TextInputType.text,
      inputFormatters: isPremium ? [_RibuanFormatter()] : null,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor),
      decoration: InputDecoration(
        hintText: hint ?? '0',
        hintStyle: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white10 : Colors.black38),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(unit, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ],
            ],
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _deleteTarget(String? targetId) async {
    if (targetId == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Rencana?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Rencana yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(savingTargetServiceProvider).deleteTarget(targetId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rencana berhasil dihapus.')));
      }
    }
  }

  Future<void> _showEditTargetDialog(SavingTargetModel target, Color baseColor) async {
    final nameController = TextEditingController(text: target.name);
    final amountController = TextEditingController(text: _formatDigitsWithDots(target.targetAmount.round().toString()));
    DateTime selectedDate = target.dueDate;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Ubah Rencana', style: TextStyle(fontWeight: FontWeight.bold, color: contentColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighVisInput(
                  controller: nameController,
                  icon: Icons.edit_note_rounded,
                  label: 'Nama Rencana',
                  unit: '',
                  color: AppColors.primary,
                  isDarkMode: isDarkMode,
                  hint: 'Masukkan nama...',
                ),
                const SizedBox(height: 16),
                _buildHighVisInput(
                  controller: amountController,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Dana yang Dibutuhkan',
                  unit: 'Rp',
                  color: Colors.green,
                  isDarkMode: isDarkMode,
                  isPremium: true,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(DateFormat('d MMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                if (amount > 0) {
                  final updatedTarget = target.copyWith(
                    name: nameController.text,
                    targetAmount: amount,
                    dueDate: selectedDate,
                  );
                  await ref.read(savingTargetServiceProvider).updateTarget(updatedTarget);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rencana diperbarui!')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDigitsWithDots(String s) {
    if (s.isEmpty) return s;
    String digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  Widget _buildTargetItem(SavingTargetModel target, Color baseColor, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final transactions = ref.watch(transactionsByGroupProvider(null));
    final balance = transactions.fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
    final progress = (target.targetAmount > 0) ? (balance / target.targetAmount).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(target.name, 
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
              ),
              const SizedBox(width: 8),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: baseColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: baseColor.withValues(alpha: 0.1),
              color: baseColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo('Dana Dibutuhkan', _formatRupiah(target.targetAmount), isDarkMode),
              _buildMiniInfo('Rencana Selesai', DateFormat('d MMM yyyy').format(target.dueDate), isDarkMode),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditTargetDialog(target, baseColor),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Ubah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: baseColor,
                    side: BorderSide(color: baseColor.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteTarget(target.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMiniInfo(String label, String value, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: contentColor.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: contentColor)),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(icon, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            const Text('Belum ada rencana yang dibuat.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
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
