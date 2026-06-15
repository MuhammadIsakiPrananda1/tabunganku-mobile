import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/debt_model.dart';
import 'package:tabunganku/providers/debt_provider.dart';

class DebtFormSheet extends ConsumerStatefulWidget {
  final DebtModel? debt;
  final DebtType? initialType;

  const DebtFormSheet({super.key, this.debt, this.initialType});

  static Future<void> show(BuildContext context,
      {DebtModel? debt, DebtType? initialType}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DebtFormSheet(debt: debt, initialType: initialType),
      ),
    );
  }

  @override
  ConsumerState<DebtFormSheet> createState() => _DebtFormSheetState();
}

class _DebtFormSheetState extends ConsumerState<DebtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late DebtType _type;
  DateTime? _debtDate; // Tanggal Hutang – wajib



  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.debt?.title ?? '');
    String formattedAmount = '';
    if (widget.debt != null) {
      final rawAmount = widget.debt!.amount.toInt().toString();
      formattedAmount = rawAmount.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
    }
    _amountController = TextEditingController(text: formattedAmount);
    _contactController =
        TextEditingController(text: widget.debt?.contactName ?? '');
    _descriptionController =
        TextEditingController(text: widget.debt?.description ?? '');
    _type = widget.debt?.type ?? widget.initialType ?? DebtType.hutang;

    // Tanggal hutang: pakai dueDate yang sudah ada, atau hari ini untuk entry baru
    _debtDate = widget.debt?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final cleanAmount =
          _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(cleanAmount) ?? 0;
      final debt = DebtModel(
        id: widget.debt?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        amount: amount,
        type: _type,
        contactName: _contactController.text,
        dueDate: _debtDate,
        isPaid: widget.debt?.isPaid ?? false,
        createdAt: widget.debt?.createdAt ?? DateTime.now(),
      );

      if (widget.debt == null) {
        await ref.read(debtServiceProvider).addDebt(debt);
      } else {
        await ref.read(debtServiceProvider).updateDebt(debt);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.debt == null
                  ? 'Catatan berhasil ditambahkan'
                  : 'Catatan berhasil diperbarui',
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
    final fillColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final borderColor = isDark ? Colors.white10 : Colors.black26;
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final accentColor =
        _type == DebtType.hutang ? const Color(0xFFE53935) : AppColors.primary;

    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: accentColor, width: 1.5),
    );
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pull bar ──────────────────────────────────────────────
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ─────────────────────────────────────────────────
              Center(
                child: Text(
                  widget.debt != null
                      ? 'Edit Catatan'
                      : (_type == DebtType.hutang
                          ? 'Catat Hutang Baru'
                          : 'Catat Piutang Baru'),
                  style: GoogleFonts.quicksand(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type Selector ─────────────────────────────────
                    if (widget.initialType == null || widget.debt != null) ...[
                      _buildLabel('Jenis Catatan', labelColor),
                      const SizedBox(height: 4),
                      _TypeToggle(
                        selected: _type,
                        isDark: isDark,
                        onChanged: (t) => setState(() => _type = t),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Nama Kontak ───────────────────────────────────
                    _buildLabel('Nama Kontak', labelColor, required: true),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _contactController,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Nama harus diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Nama orang / kontak',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 13, color: subColor),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Icon(Icons.person_outline_rounded,
                              size: 20, color: accentColor),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),

                        filled: true,
                        fillColor: fillColor,
                        border: normalBorder,
                        enabledBorder: normalBorder,
                        focusedBorder: focusBorder,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 0, right: 16, top: 12, bottom: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Nominal ───────────────────────────────────────
                    _buildLabel('Nominal', labelColor, required: true),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanSeparatorInputFormatter(),
                      ],
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Nominal harus diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Nominal',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 13, color: subColor),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.payments_rounded,
                                  size: 20, color: accentColor),
                              const SizedBox(width: 8),
                              Text(
                                'Rp',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: fillColor,
                        border: normalBorder,
                        enabledBorder: normalBorder,
                        focusedBorder: focusBorder,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 0, right: 16, top: 12, bottom: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Keterangan ────────────────────────────────────
                    _buildLabel('Keterangan', labelColor, required: true),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Keterangan harus diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan keterangan',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 13, color: subColor),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Icon(Icons.notes_rounded,
                              size: 20, color: accentColor),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: fillColor,
                        border: normalBorder,
                        enabledBorder: normalBorder,
                        focusedBorder: focusBorder,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 0, right: 16, top: 12, bottom: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Tanggal Hutang (WAJIB) ────────────────────────
                    _buildLabel('Tanggal Hutang', labelColor, required: true),
                    const SizedBox(height: 4),
                    FormField<DateTime>(
                      initialValue: _debtDate,
                      validator: (_) => _debtDate == null
                          ? 'Tanggal hutang harus diisi'
                          : null,
                      builder: (field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _debtDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365 * 5)),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: ColorScheme.fromSeed(
                                        seedColor: accentColor,
                                        brightness: isDark
                                            ? Brightness.dark
                                            : Brightness.light,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (date != null) {
                                  setState(() => _debtDate = date);
                                  field.didChange(date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: field.hasError
                                        ? Colors.redAccent
                                        : (isDark
                                            ? Colors.white10
                                            : Colors.black26),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 20, color: accentColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _debtDate == null
                                            ? 'Pilih tanggal hutang'
                                            : DateFormat('EEEE, d MMMM yyyy',
                                                    'id_ID')
                                                .format(_debtDate!),
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _debtDate == null
                                              ? subColor
                                              : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        size: 18, color: subColor),
                                  ],
                                ),
                              ),
                            ),
                            if (field.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 6),
                                child: Text(
                                  field.errorText!,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Submit Button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.debt != null
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.debt != null
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Catatan',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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

  Widget _buildLabel(String text, Color labelColor, {bool required = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

// ── Type Toggle ──────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final DebtType selected;
  final bool isDark;
  final ValueChanged<DebtType> onChanged;

  const _TypeToggle({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Pill(
            label: 'Hutang',
            icon: Icons.call_made_rounded,
            isSelected: selected == DebtType.hutang,
            color: const Color(0xFFE53935),
            isDark: isDark,
            onTap: () => onChanged(DebtType.hutang),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Pill(
            label: 'Piutang',
            icon: Icons.call_received_rounded,
            isSelected: selected == DebtType.piutang,
            color: AppColors.primary,
            isDark: isDark,
            onTap: () => onChanged(DebtType.piutang),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? color.withValues(alpha: isDark ? 0.2 : 0.08)
        : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50);
    final border = isSelected
        ? color.withValues(alpha: 0.5)
        : (isDark ? Colors.white10 : Colors.black26);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ribuan Separator ─────────────────────────────────────────────────────────

class _RibuanSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    int numDigitsBefore = newValue.selection.end -
        newValue.text
            .substring(
                0, math.min(newValue.selection.end, newValue.text.length))
            .replaceAll(RegExp(r'[0-9]'), '')
            .length;

    int newSelectionIndex = 0;
    int digitsCount = 0;
    while (
        digitsCount < numDigitsBefore && newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitsCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
