import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:uuid/uuid.dart';

class SavingsAdjustmentDialog extends ConsumerStatefulWidget {
  final SavingTargetModel currentTarget;
  final bool isAdd;

  const SavingsAdjustmentDialog({
    super.key,
    required this.currentTarget,
    required this.isAdd,
  });

  static void show(
    BuildContext context,
    WidgetRef ref,
    SavingTargetModel currentTarget, {
    required bool isAdd,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => SavingsAdjustmentDialog(
        currentTarget: currentTarget,
        isAdd: isAdd,
      ),
    );
  }

  @override
  ConsumerState<SavingsAdjustmentDialog> createState() => _SavingsAdjustmentDialogState();
}

class _SavingsAdjustmentDialogState extends ConsumerState<SavingsAdjustmentDialog> {
  late final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: inset > 0 ? inset : MediaQuery.of(context).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.isAdd ? 'Tambah Tabungan' : 'Tarik Tabungan',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: contentColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                        children: [
                          TextSpan(text: widget.isAdd ? 'Nominal Tabungan ' : 'Nominal Penarikan '),
                          const TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_RibuanFormatter()],
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan Nominal',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white10 : Colors.black26,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isAdd ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
                                color: widget.isAdd ? Colors.teal : Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isAdd ? Colors.teal : Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isAdd ? Colors.teal : Colors.redAccent,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final amountText = _amountController.text.replaceAll('.', '');
                        final amount = double.tryParse(amountText) ?? 0.0;
                        if (amount <= 0) {
                          showTopToast(context, 'Nominal tidak valid!', isError: true);
                          return;
                        }

                        double newSavedAmount = widget.currentTarget.savedAmount;
                        if (widget.isAdd) {
                          newSavedAmount += amount;
                        } else {
                          newSavedAmount = (newSavedAmount - amount).clamp(0.0, double.infinity);
                        }

                        final updatedTarget = widget.currentTarget.copyWith(savedAmount: newSavedAmount);
                        await ref.read(savingTargetServiceProvider).updateTarget(updatedTarget);

                        // Create transaction to sync with main wallet balance
                        final tx = TransactionModel(
                          id: const Uuid().v4(),
                          title: widget.isAdd
                              ? 'Alokasi: ${widget.currentTarget.name}'
                              : 'Tarik: ${widget.currentTarget.name}',
                          description: widget.isAdd
                              ? 'Alokasi saldo ke target tabungan'
                              : 'Penarikan saldo dari target tabungan',
                          amount: amount,
                          type: widget.isAdd ? TransactionType.expense : TransactionType.income,
                          date: DateTime.now(),
                          category: 'Tabungan',
                        );
                        await ref.read(transactionServiceProvider).addTransaction(tx);

                        if (context.mounted) {
                          Navigator.pop(context);
                          showTopToast(context, widget.isAdd ? 'Tabungan berhasil ditambahkan!' : 'Tabungan berhasil ditarik!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isAdd ? Colors.teal : Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: (widget.isAdd ? Colors.teal : Colors.redAccent).withOpacity(0.3),
                      ),
                      child: Text(
                        widget.isAdd ? 'Simpan Tabungan' : 'Simpan Penarikan',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
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
