
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecializedSavingPage extends ConsumerStatefulWidget {
  final String title;
  final IconData icon;
  final Color baseColor;
  final String category;

  const SpecializedSavingPage({
    super.key,
    required this.title,
    required this.icon,
    required this.baseColor,
    required this.category,
  });

  @override
  ConsumerState<SpecializedSavingPage> createState() => _SpecializedSavingPageState();
}

class _SpecializedSavingPageState extends ConsumerState<SpecializedSavingPage> {
  late final TextEditingController _nameController;
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365));

  bool _nameHasError = false;
  bool _amountHasError = false;
  bool _dateIsFocused = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '${widget.category} ');
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(savingTargetsStreamProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: contentColor)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _buildAddButton(isDarkMode)),
          ),
        ],
      ),
      body: targetsAsync.when(
        data: (targets) {
          final filteredTargets = targets.where((t) => t.name.toLowerCase().contains(widget.category.toLowerCase())).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(isDarkMode),
                const SizedBox(height: 32),

                _buildInlineInputForm(isDarkMode),
                const SizedBox(height: 32),

                Text('TARGET ${widget.title.toUpperCase()}', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                if (filteredTargets.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...filteredTargets.map((t) => _buildTargetItem(t, isDarkMode)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildInlineInputForm(bool isDarkMode) {
    final Color dateBorderColor;
    final double dateBorderWidth;
    if (_dateIsFocused) {
      dateBorderColor = AppColors.primary;
      dateBorderWidth = 1.8;
    } else {
      dateBorderColor = isDarkMode 
          ? Colors.white.withValues(alpha: 0.05) 
          : Colors.grey.shade200;
      dateBorderWidth = 1.2;
    }

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
            controller: _nameController,
            icon: Icons.edit_note_rounded,
            label: 'Nama Rencana',
            unit: '',
            color: AppColors.primary,
            isDarkMode: isDarkMode,
            hint: 'Masukkan nama...',
            hasError: _nameHasError,
            onChanged: (val) {
              if (_nameHasError && val.trim().isNotEmpty) {
                setState(() => _nameHasError = false);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildHighVisInput(
            controller: _amountController,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Nominal Target',
            unit: 'Rp',
            color: Colors.green,
            isDarkMode: isDarkMode,
            isPremium: true,
            hasError: _amountHasError,
            onChanged: (val) {
              if (_amountHasError) {
                final amt = double.tryParse(val.replaceAll('.', '')) ?? 0;
                if (amt > 0) {
                  setState(() => _amountHasError = false);
                }
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    setState(() => _dateIsFocused = true);
                    await _pickDateInline(isDarkMode);
                    setState(() => _dateIsFocused = false);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dateBorderColor,
                        width: dateBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(DateFormat('d/M/yy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    final nameVal = _nameController.text.trim();
                    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

                    setState(() {
                      _nameHasError = nameVal.isEmpty;
                      _amountHasError = amount <= 0;
                    });

                    if (_nameHasError || _amountHasError) {
                      String errorMessage = 'Nama rencana tidak boleh kosong!';
                      if (_amountHasError) {
                        errorMessage = 'Nominal target harus lebih dari 0!';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
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

                    final target = SavingTargetModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameVal,
                      targetAmount: amount,
                      dueDate: _selectedDate,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(savingTargetServiceProvider).addTarget(target);
                    _amountController.clear();
                    setState(() {
                      _nameHasError = false;
                      _amountHasError = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Rencana Berhasil Dibuat',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateInline(bool isDarkMode) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return HighVisInput(
      controller: controller,
      icon: icon,
      label: label,
      isDarkMode: isDarkMode,
      prefixText: unit.isNotEmpty ? unit : null,
      hintText: hint,
      keyboardType: isPremium ? TextInputType.number : TextInputType.text,
      inputFormatters: isPremium ? [_RibuanFormatter()] : null,
      hasError: hasError,
      onChanged: onChanged,
    );
  }

  Widget _buildAddButton(bool isDarkMode) {
    return InkWell(
      onTap: () => _showAddTargetSheet(isDarkMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 16, color: widget.baseColor),
            const SizedBox(width: 4),
            Text('Tambah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.baseColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.baseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.baseColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: 28, color: widget.baseColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: widget.baseColor)),
                const SizedBox(height: 4),
                Text(
                  'Rencanakan dana masa depanmu dengan target yang produktif.',
                  style: TextStyle(fontSize: 11, color: widget.baseColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetItem(SavingTargetModel target, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final transactions = ref.watch(transactionsByGroupProvider(null));
    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
    final progress = (target.targetAmount > 0) ? (targetBalance / target.targetAmount).clamp(0.0, 1.0) : 0.0;

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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: contentColor)),
              ),
              const SizedBox(width: 8),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: widget.baseColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: widget.baseColor.withValues(alpha: 0.1),
              color: widget.baseColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo('Target', _formatRupiah(target.targetAmount), isDarkMode),
              _buildMiniInfo('Jatuh Tempo', DateFormat('d MMM yyyy').format(target.dueDate), isDarkMode),
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
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(widget.icon, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            const Text('Belum ada rencana yang dibuat.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddTargetSheet(bool isDarkMode) {
    final nameController = TextEditingController(text: '${widget.category} ');
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 365));

    bool nameHasError = false;
    bool amountHasError = false;
    bool dateIsFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 28,
            right: 28,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('BUAT RENCANA', 
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.teal.shade900)),
              ),
              const SizedBox(height: 24),
              _buildCompactInput(
                'Nama Rencana', 
                nameController, 
                Icons.edit_note_rounded, 
                isDarkMode, 
                isPremium: false,
                hasError: nameHasError,
                onChanged: (val) {
                  if (nameHasError && val.trim().isNotEmpty) {
                    setSheetState(() => nameHasError = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildCompactInput(
                'Nominal Target', 
                amountController, 
                Icons.account_balance_wallet_rounded, 
                isDarkMode, 
                isPremium: true,
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
              _buildDatePicker(
                selectedDate, 
                (d) => setSheetState(() => selectedDate = d), 
                isDarkMode,
                isFocused: dateIsFocused,
                onTapDate: () => setSheetState(() => dateIsFocused = true),
                onDoneDate: () => setSheetState(() => dateIsFocused = false),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final nameVal = nameController.text.trim();
                    final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;

                    setSheetState(() {
                      nameHasError = nameVal.isEmpty;
                      amountHasError = amount <= 0;
                    });

                    if (nameHasError || amountHasError) {
                      String errorMessage = 'Nama rencana tidak boleh kosong!';
                      if (amountHasError) {
                        errorMessage = 'Nominal target harus lebih dari 0!';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
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

                    final target = SavingTargetModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameVal,
                      targetAmount: amount,
                      dueDate: selectedDate,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(savingTargetServiceProvider).addTarget(target);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Rencana Berhasil Dibuat',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Buat Rencana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInput(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    bool isDarkMode, {
    required bool isPremium,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return HighVisInput(
      controller: controller,
      icon: icon,
      label: label,
      isDarkMode: isDarkMode,
      prefixText: isPremium ? 'Rp' : null,
      hintText: isPremium ? '0' : 'Masukkan nama...',
      keyboardType: isPremium ? TextInputType.number : TextInputType.text,
      inputFormatters: isPremium ? [_RibuanFormatter()] : null,
      hasError: hasError,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(
    DateTime selected, 
    Function(DateTime) onPicked, 
    bool isDarkMode, {
    bool isFocused = false,
    VoidCallback? onTapDate,
    VoidCallback? onDoneDate,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final Color dateBorderColor;
    final double dateBorderWidth;
    if (isFocused) {
      dateBorderColor = AppColors.primary;
      dateBorderWidth = 1.8;
    } else {
      dateBorderColor = isDarkMode 
          ? Colors.white.withValues(alpha: 0.05) 
          : Colors.grey.shade200;
      dateBorderWidth = 1.2;
    }

    return InkWell(
      onTap: () async {
        if (onTapDate != null) onTapDate();
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (onDoneDate != null) onDoneDate();
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dateBorderColor,
            width: dateBorderWidth,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TARGET SELESAI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.4))),
                const SizedBox(height: 2),
                Text(DateFormat('d MMMM yyyy').format(selected), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: contentColor)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: contentColor.withValues(alpha: 0.3)),
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
