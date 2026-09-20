import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/features/home/presentation/widgets/target_detail_sheet.dart';

class HajjUmrahPlannerPage extends ConsumerStatefulWidget {
  const HajjUmrahPlannerPage({super.key});

  @override
  ConsumerState<HajjUmrahPlannerPage> createState() =>
      _HajjUmrahPlannerPageState();
}

class _HajjUmrahPlannerPageState extends ConsumerState<HajjUmrahPlannerPage> {
  String _activeType = 'Haji';
  final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _showAddPlanSheet(BuildContext context, String type, bool isDarkMode, Color accentColor, {SavingTargetModel? target}) {
    final isEdit = target != null;
    final nameController = TextEditingController(text: isEdit ? target.name : '');
    final amountController = TextEditingController(
      text: isEdit 
          ? target.targetAmount.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')
          : ''
    );
    DateTime selectedDate = isEdit ? target.dueDate : DateTime.now().add(const Duration(days: 365 * 5));

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
            final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;
            final inset = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: inset > 0 ? inset : MediaQuery.of(context).padding.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'Ubah Rencana $type' : 'Buat Rencana $type Baru',
                        style: GoogleFonts.quicksand(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Nama
                      Text(
                        'Nama Rencana',
                        style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Misal: Haji Reguler 2031 atau Umrah Keluarga',
                          hintStyle: GoogleFonts.quicksand(color: textSecondary.withValues(alpha: 0.5), fontSize: 13),
                          prefixIcon: Icon(Icons.edit_note_rounded, color: accentColor, size: 20),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5FAF9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Nominal
                      Text(
                        'Target Tabungan',
                        style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_RibuanFormatter()],
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Target Nominal',
                          hintStyle: GoogleFonts.quicksand(color: textSecondary.withValues(alpha: 0.5), fontSize: 13),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, color: accentColor, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Rp',
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5FAF9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estimasi
                      Text(
                        'Estimasi Keberangkatan',
                        style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5FAF9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 18, color: accentColor),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right_rounded, color: textSecondary.withValues(alpha: 0.5), size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Simpan Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                            if (name.isEmpty || amount <= 0) {
                              showTopToast(context, 'Lengkapi nama dan nominal rencana.', isError: true);
                              return;
                            }

                             if (isEdit) {
                              final updated = target.copyWith(
                                name: name,
                                targetAmount: amount,
                                dueDate: selectedDate,
                              );
                              await ref.read(savingTargetServiceProvider).updateTarget(updated);
                            } else {
                              final newTarget = SavingTargetModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                targetAmount: amount,
                                dueDate: selectedDate,
                                createdAt: DateTime.now(),
                                category: type,
                              );
                              await ref.read(savingTargetServiceProvider).addTarget(newTarget);
                            }
                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                              showTopToast(context, isEdit ? 'Rencana $type berhasil diperbarui!' : 'Rencana $type berhasil dibuat! ✨');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Simpan Rencana',
                            style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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

  void _confirmDelete(BuildContext context, SavingTargetModel target, Color accentColor) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
        final textSecondary = isDark ? Colors.white60 : AppColors.textSecondary;

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Rencana?',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus rencana "${target.name}"? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.quicksand(fontSize: 13, color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(color: textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(savingTargetServiceProvider).deleteTarget(target.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  showTopToast(context, 'Rencana berhasil dihapus.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

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
          'Rencana Haji & Umrah',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Dropdown untuk Haji / Umrah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _activeType == 'Haji' ? Icons.mosque_rounded : Icons.star_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeType,
                        isExpanded: true,
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: contentColor.withValues(alpha: 0.6), size: 22),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Haji',
                            child: Text('Rencana Perjalanan Haji'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Umrah',
                            child: Text('Rencana Ibadah Umrah'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _activeType = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content List
          Expanded(
            child: _buildPlansTab(_activeType, targetsAsync, isDarkMode, accentColor, contentColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPlanSheet(context, _activeType, isDarkMode, accentColor);
        },
        backgroundColor: accentColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Rencana Baru',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPlansTab(
    String type,
    AsyncValue<List<SavingTargetModel>> targetsAsync,
    bool isDarkMode,
    Color accentColor,
    Color contentColor,
  ) {
    return targetsAsync.when(
      data: (targets) {
        final filtered = targets.where((t) => t.category == type).toList();
        if (filtered.isEmpty) {
          return _buildEmptyState(type, isDarkMode, accentColor);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: filtered.length,
          itemBuilder: (context, idx) {
            return _buildTargetItem(filtered[idx], isDarkMode, accentColor, contentColor);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTargetItem(SavingTargetModel target, bool isDarkMode, Color accentColor, Color contentColor) {
    final targetBalance = target.savedAmount;
    final progress = (target.targetAmount > 0) ? (targetBalance / target.targetAmount).clamp(0.0, 1.0) : 0.0;

    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          TargetDetailSheet.show(
            context: context,
            target: target,
            ref: ref,
            onEdit: () => _showAddPlanSheet(context, target.category, isDarkMode, accentColor, target: target),
            onDelete: () => _confirmDelete(context, target, accentColor),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Item (Nama & Hapus)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.name,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: contentColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimasi: ${DateFormat('MMMM yyyy', 'id_ID').format(target.dueDate)}',
                          style: GoogleFonts.quicksand(fontSize: 11, color: isDarkMode ? Colors.white30 : Colors.black38, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, target, accentColor),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar & persentase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terumpul: ${_fmt.format(targetBalance)}',
                    style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 18),

              // Milestones
              _buildMilestones(target, targetBalance, isDarkMode, accentColor),
              const SizedBox(height: 16),

              // Footer info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniInfo('Target Tabungan', _fmt.format(target.targetAmount), isDarkMode),
                  _buildMiniInfo('Sisa Kekurangan', _fmt.format((target.targetAmount - targetBalance).clamp(0.0, double.infinity)), isDarkMode),
                ],
              ),
            ],
          ),
        ),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF262626) : const Color(0xFFF9FBFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MILESTONE PERJALANAN',
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white30 : Colors.black38,
              letterSpacing: 0.5,
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
                    size: 13,
                    color: isReached ? accentColor : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m['label'] as String,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isReached ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _fmt.format(m['amount'] as double),
                    style: GoogleFonts.quicksand(fontSize: 11, color: isReached ? accentColor : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String type, bool isDarkMode, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(type == 'Haji' ? Icons.mosque_rounded : Icons.star_rounded, size: 48, color: accentColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Rencana $type',
              style: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type == 'Haji'
                  ? 'Mulai rencanakan bekal perjalanan haji\nAnda secara matang dan tenang.'
                  : 'Wujudkan impian ibadah Umrah Anda\ndengan perencanaan yang matang.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white30 : Colors.black38,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
