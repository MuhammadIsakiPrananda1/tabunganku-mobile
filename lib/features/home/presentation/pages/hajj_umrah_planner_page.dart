import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class HajjUmrahPlannerPage extends ConsumerStatefulWidget {
  const HajjUmrahPlannerPage({super.key});

  @override
  ConsumerState<HajjUmrahPlannerPage> createState() => _HajjUmrahPlannerPageState();
}

class _HajjUmrahPlannerPageState extends ConsumerState<HajjUmrahPlannerPage> {
  String _activeType = 'Haji'; // Haji, Umrah
  
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365 * 5));

  final List<Map<String, dynamic>> _programTypes = [
    {'code': 'Haji', 'label': 'Perjalanan Haji', 'icon': Icons.mosque_rounded},
    {'code': 'Umrah', 'label': 'Ibadah Umrah', 'icon': Icons.star_rounded},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  IconData _getProgramIcon(String code) {
    return _programTypes.firstWhere((p) => p['code'] == code)['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Mint Green Accent & Pure Dark/Light backgrounds
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background;

    final targetsAsync = ref.watch(savingTargetsStreamProvider);

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
          'Haji & Umrah', 
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ),
      body: targetsAsync.when(
        data: (targets) {
          final filteredTargets = targets.where((t) => t.category == _activeType).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(accentColor),
                const SizedBox(height: 28),

                Text(
                  'Pilih Program', 
                  style: GoogleFonts.quicksand(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: contentColor.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),

                // Premium Dropdown like Tax & Zakat & Mosque
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(_getProgramIcon(_activeType), color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activeType,
                            isExpanded: true,
                            dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                            icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withOpacity(0.4), size: 20),
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                            items: _programTypes.map((p) {
                              return DropdownMenuItem<String>(
                                value: p['code'] as String,
                                child: Text(
                                  p['label'] as String,
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _activeType = val!;
                                _nameController.clear();
                                _amountController.clear();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildInputForm(isDarkMode, accentColor),
                
                const SizedBox(height: 36),
                Text(
                  'Rencana Aktif', 
                  style: GoogleFonts.quicksand(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: contentColor.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 12),
                if (filteredTargets.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...filteredTargets.map((t) => _buildTargetItem(t, isDarkMode, accentColor)),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildInfoCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _activeType == 'Haji' 
                ? 'Persiapkan bekal perjalanan haji Anda sedini mungkin untuk ibadah yang lebih tenang.' 
                : 'Wujudkan impian ibadah Umrah Anda dengan perencanaan keuangan yang matang.',
              style: GoogleFonts.quicksand(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(bool isDarkMode, Color accentColor) {
    return Column(
      children: [
        _buildAlignedInput(
          'Nama Rencana', 
          _nameController, 
          Icons.edit_note_rounded, 
          isDarkMode,
          accentColor,
          hint: 'Nama Rencana',
        ),
        const SizedBox(height: 20),
        _buildAlignedInput(
          'Target Tabungan', 
          _amountController, 
          Icons.account_balance_wallet_rounded, 
          isDarkMode,
          accentColor,
          isAmount: true,
          hint: 'Target Tabungan',
        ),
        const SizedBox(height: 20),
        _buildDatePicker(isDarkMode, accentColor),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => _saveTarget(accentColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Simpan Rencana', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildAlignedInput(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    bool isDarkMode, 
    Color accentColor,
    {bool isAmount = false, 
    required String hint}
  ) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label, 
            style: GoogleFonts.quicksand(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: contentColor.withOpacity(0.4),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isAmount ? TextInputType.number : TextInputType.text,
          inputFormatters: isAmount ? [_RibuanFormatter()] : null,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.25),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 18),
                  if (isAmount) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Rp', 
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDarkMode, Color accentColor) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Estimasi Keberangkatant', 
            style: GoogleFonts.quicksand(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: contentColor.withOpacity(0.4),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: accentColor),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate), 
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor)
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveTarget(Color accentColor) async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount <= 0 || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapi nama dan nominal rencana.',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final target = SavingTargetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      targetAmount: amount,
      dueDate: _selectedDate,
      createdAt: DateTime.now(),
      category: _activeType,
    );

    await ref.read(savingTargetServiceProvider).addTarget(target);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Rencana $_activeType Berhasil Dibuat',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      _nameController.clear();
      _amountController.clear();
    }
  }

  Widget _buildTargetItem(SavingTargetModel target, bool isDarkMode, Color accentColor) {
    final transactions = ref.watch(transactionsByGroupProvider(null));
    final targetBalance = transactions
        .where((t) => !t.date.isBefore(target.createdAt))
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));
    final progress = (target.targetAmount > 0) ? (targetBalance / target.targetAmount).clamp(0.0, 1.0) : 0.0;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  target.name, 
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: contentColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%', 
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: accentColor.withOpacity(0.1),
              color: accentColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildMilestones(target, targetBalance, isDarkMode, accentColor),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniInfo('Target', _formatRupiah(target.targetAmount), isDarkMode),
              _buildMiniInfo('Estimasi', DateFormat('MMM yyyy').format(target.dueDate), isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(SavingTargetModel target, double balance, bool isDarkMode, Color accentColor) {
    final milestones = target.category == 'Haji' 
      ? [
          {'label': 'Daftar (Porsi)', 'amount': 25000000.0},
          {'label': 'Pelunasan', 'amount': target.targetAmount * 0.8},
          {'label': 'Siap Berangkat', 'amount': target.targetAmount},
        ]
      : [
          {'label': 'Booking DP', 'amount': 5000000.0},
          {'label': 'Pelunasan', 'amount': target.targetAmount * 0.9},
          {'label': 'Siap Berangkat', 'amount': target.targetAmount},
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestone Perjalanan', 
          style: GoogleFonts.quicksand(
            fontSize: 9, 
            fontWeight: FontWeight.bold, 
            color: isDarkMode ? Colors.white30 : Colors.black38,
          ),
        ),
        const SizedBox(height: 10),
        ...milestones.map((m) {
          final isReached = balance >= (m['amount'] as double);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  isReached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: isReached ? accentColor : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m['label'] as String, 
                    style: GoogleFonts.quicksand(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: isReached ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatRupiah(m['amount'] as double), 
                  style: GoogleFonts.quicksand(fontSize: 11, color: isReached ? accentColor : Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMiniInfo(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.quicksand(
            fontSize: 9, 
            color: isDarkMode ? Colors.white30 : Colors.black38, 
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: GoogleFonts.quicksand(
            fontSize: 13, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 40, color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'Belum ada rencana aktif.', 
              style: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade400, 
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
