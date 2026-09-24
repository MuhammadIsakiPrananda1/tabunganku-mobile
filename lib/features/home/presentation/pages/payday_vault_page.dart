/// Page: PaydayVaultPage
///
/// Brankas gajian (alokasi otomatis penerimaan gaji).
/// Desain rapi, clean, dan seimbang dengan visualisasi modern alokasi 50/30/20,
/// kartu gembok interaktif, metrik seimbang, serta modal form intuitif.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/payday_vault_model.dart';
import 'package:tabunganku/providers/payday_vault_provider.dart';

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PaydayVaultPage extends ConsumerStatefulWidget {
  const PaydayVaultPage({super.key});

  @override
  ConsumerState<PaydayVaultPage> createState() => _PaydayVaultPageState();
}

class _PaydayVaultPageState extends ConsumerState<PaydayVaultPage> {
  final _currencyFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final _rawFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Refresh countdown setiap detik agar timer countdown real-time
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Menghitung hari tersisa sampai tanggal gajian berikutnya
  int _calculateDaysUntilPayday(int? paydayDay) {
    if (paydayDay == null || paydayDay <= 0) return -1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDaysThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveDay = paydayDay > maxDaysThisMonth ? maxDaysThisMonth : paydayDay;
    DateTime nextPayday = DateTime(now.year, now.month, effectiveDay);

    if (nextPayday.isBefore(today)) {
      // Jika tanggal gajian bulan ini sudah lewat, hitung untuk bulan depan
      final maxDaysNextMonth = DateTime(now.year, now.month + 2, 0).day;
      final effectiveNextDay = paydayDay > maxDaysNextMonth ? maxDaysNextMonth : paydayDay;
      nextPayday = DateTime(now.year, now.month + 1, effectiveNextDay);
    }

    return nextPayday.difference(today).inDays;
  }

  // ================= MODAL PENGATURAN GAJI =================
  void _showSetupSalaryModal(BuildContext context, PaydayVaultModel vault) {
    final initialStr = vault.monthlySalary > 0
        ? _rawFmt.format(vault.monthlySalary).trim()
        : '';
    final salaryCtrl = TextEditingController(text: initialStr);
    int? selectedPayday = vault.paydayDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
        final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
        final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);
        final divClr = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08);

        return StatefulBuilder(
          builder: (context, setModalState) {
            final parsedSalary = double.tryParse(
                    salaryCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                0;
            final calcNeeds = parsedSalary * (vault.needsPercent / 100);
            final calcWants = parsedSalary * (vault.wantsPercent / 100);
            final calcSavings = parsedSalary * (vault.savingsPercent / 100);

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 16
                    : MediaQuery.of(context).padding.bottom + 20,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Form
                    Text(
                      'Pengaturan Gaji Bulanan',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 1: Nominal Gaji
                    Text(
                      'Nominal Gaji Bulanan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: salaryCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanFormatter(),
                      ],
                      onChanged: (_) => setModalState(() {}),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: txtClr,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal gaji',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          width: 44,
                          child: Text(
                            'Rp',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: divClr),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: divClr),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 2: Tanggal Gajian Rutin (Dropdown 1-31)
                    Text(
                      'Tanggal Gajian Setiap Bulan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: divClr),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedPayday,
                          hint: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Pilih tanggal gajian kamu',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          isExpanded: true,
                          dropdownColor:
                              isDark ? AppColors.surfaceDark : Colors.white,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: txtClr,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: subClr,
                            size: 20,
                          ),
                          items: List.generate(31, (index) {
                            final day = index + 1;
                            return DropdownMenuItem<int?>(
                              value: day,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tanggal $day setiap bulan',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedPayday = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedPayday != null
                          ? 'Siklus alokasi gaji akan berjalan otomatis setiap tanggal $selectedPayday tiap bulannya.'
                          : 'Pilih tanggal penerimaan gaji bulanan kamu.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: subClr,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Simulasi Realtime Pos Alokasi 50/30/20
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: divClr),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian Alokasi Otomatis (50/30/20)',
                            style: GoogleFonts.quicksand(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: txtClr,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildPosMiniBar(
                            title: '50% Kebutuhan Pokok',
                            amount: _currencyFmt.format(calcNeeds),
                            color: const Color(0xFF3B82F6),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 6),
                          _buildPosMiniBar(
                            title: '30% Keinginan & Gaya Hidup',
                            amount: _currencyFmt.format(calcWants),
                            color: const Color(0xFFF97316),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 6),
                          _buildPosMiniBar(
                            title: '20% Tabungan Gembok',
                            amount: _currencyFmt.format(calcSavings),
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (parsedSalary <= 0 || selectedPayday == null)
                            ? null
                            : () {
                                ref
                                    .read(paydayVaultProvider.notifier)
                                    .updateSalaryAndRules(
                                      monthlySalary: parsedSalary,
                                      paydayDate: selectedPayday,
                                      needsPercent: vault.needsPercent,
                                      wantsPercent: vault.wantsPercent,
                                      savingsPercent: vault.savingsPercent,
                                    );
                                Navigator.pop(ctx);
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pengaturan gaji berhasil disimpan',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Simpan Pengaturan Gaji',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
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

  // ================= MODAL GEMBOK TABUNGAN =================
  void _showLockVaultModal(BuildContext context, PaydayVaultModel vault) {
    int durationDays = 30;
    final suggestedAmount = vault.savingsAmount > 0
        ? vault.savingsAmount
        : (vault.monthlySalary > 0 ? vault.monthlySalary * 0.2 : 500000.0);

    final amountCtrl = TextEditingController(
      text: _rawFmt.format(suggestedAmount).trim(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
        final divClr = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06);

        return StatefulBuilder(
          builder: (context, setModalState) {
            final parsedAmount = double.tryParse(
                    amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                0;

            final unlockDate =
                DateTime.now().add(Duration(days: durationDays));
            final unlockDateStr =
                DateFormat('d MMMM yyyy', 'id_ID').format(unlockDate);

            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Form
                    Text(
                      'Gembok Tabungan Gaji',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pilihan Preset Cepat Nominal
                    if (vault.monthlySalary > 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final v20 = vault.monthlySalary * 0.2;
                                amountCtrl.text = _rawFmt.format(v20).trim();
                                setModalState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: divClr),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                '20% Gaji (Rekomendasi)',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final v10 = vault.monthlySalary * 0.1;
                                amountCtrl.text = _rawFmt.format(v10).trim();
                                setModalState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: divClr),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                '10% Gaji',
                                style: GoogleFonts.quicksand(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Input Nominal
                    Text(
                      'Nominal yang Digembok',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanFormatter(),
                      ],
                      onChanged: (_) => setModalState(() {}),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: txtClr,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal gembok',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          width: 44,
                          child: Text(
                            'Rp',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: divClr),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: divClr),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.amber.shade700,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Durasi Gembok (Grid Simetris 4 Opsi)
                    Text(
                      'Durasi Gembok Tabungan',
                      style: GoogleFonts.quicksand(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildDurationCard(
                          days: 14,
                          label: '2 Minggu',
                          isSelected: durationDays == 14,
                          onTap: () => setModalState(() => durationDays = 14),
                          isDark: isDark,
                          divClr: divClr,
                        ),
                        const SizedBox(width: 8),
                        _buildDurationCard(
                          days: 30,
                          label: '1 Bulan',
                          isSelected: durationDays == 30,
                          onTap: () => setModalState(() => durationDays = 30),
                          isDark: isDark,
                          divClr: divClr,
                        ),
                        const SizedBox(width: 8),
                        _buildDurationCard(
                          days: 60,
                          label: '2 Bulan',
                          isSelected: durationDays == 60,
                          onTap: () => setModalState(() => durationDays = 60),
                          isDark: isDark,
                          divClr: divClr,
                        ),
                        const SizedBox(width: 8),
                        _buildDurationCard(
                          days: 90,
                          label: '3 Bulan',
                          isSelected: durationDays == 90,
                          onTap: () => setModalState(() => durationDays = 90),
                          isDark: isDark,
                          divClr: divClr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Keterangan Estimasi Buka Gembok
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(
                            alpha: isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(
                              alpha: isDark ? 0.3 : 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Gembok terbuka otomatis pada: $unlockDateStr',
                              style: GoogleFonts.quicksand(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Tombol Kunci Sekarang
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: parsedAmount <= 0
                            ? null
                            : () {
                                ref.read(paydayVaultProvider.notifier).lockVault(
                                      amount: parsedAmount,
                                      durationDays: durationDays,
                                    );
                                Navigator.pop(ctx);
                                HapticFeedback.heavyImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tabungan ${_currencyFmt.format(parsedAmount)} berhasil digembok selama $durationDays hari!',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    backgroundColor: Colors.amber.shade800,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.lock_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Kunci Tabungan Sekarang',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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

  // ================= DIALOG BUKA DARURAT =================
  void _showEmergencyUnlockDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
        final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Buka Darurat Vault?',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: txtClr,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Membuka gembok lebih awal dapat mengurangi kedisiplinan target tabunganmu. Tuliskan alasan mendesak:',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: subClr,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: GoogleFonts.quicksand(
                  fontSize: 12.5,
                  color: txtClr,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: Biaya pengobatan darurat',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tetap Gembok',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  fontSize: 12.5,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim();
                ref.read(paydayVaultProvider.notifier).emergencyUnlock(
                      reason.isEmpty
                          ? 'Buka darurat tanpa keterangan'
                          : reason,
                    );
                Navigator.pop(ctx);
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vault telah dibuka secara darurat',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Buka Sekarang',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= MAIN BUILD METHOD =================
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final vault = ref.watch(paydayVaultProvider);
    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final divClr = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final txtClr = isDark ? Colors.white : const Color(0xFF1E293B);
    final subClr = isDark ? Colors.white54 : const Color(0xFF64748B);

    final daysUntilPayday = _calculateDaysUntilPayday(vault.paydayDate);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: isDark ? Colors.white70 : AppColors.primaryDark,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: Text(
                      'Gembok Tabungan Gaji',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Content Scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. MASTER VAULT CARD (HERO)
                    _buildMasterVaultCard(
                      context: context,
                      vault: vault,
                      isDark: isDark,
                      cardBg: cardBg,
                      divClr: divClr,
                      txtClr: txtClr,
                      subClr: subClr,
                    ),
                    const SizedBox(height: 16),

                    // 2. METRIK SEIMBANG (Tabungan 20% & Siklus Gajian)
                    _buildBalancedMetricsRow(
                      vault: vault,
                      daysUntilPayday: daysUntilPayday,
                      isDark: isDark,
                      cardBg: cardBg,
                      divClr: divClr,
                      txtClr: txtClr,
                      subClr: subClr,
                    ),
                    const SizedBox(height: 16),

                    // 3. ALOKASI CERDAS 50/30/20 (SIMETRIS & RAPI)
                    _buildSalarySplitSection(
                      context: context,
                      vault: vault,
                      isDark: isDark,
                      cardBg: cardBg,
                      divClr: divClr,
                      txtClr: txtClr,
                      subClr: subClr,
                    ),
                    const SizedBox(height: 16),

                    // 4. STATISTIK DISIPLIN & TIPS KEUANGAN
                    _buildDisciplineInsightCard(
                      vault: vault,
                      isDark: isDark,
                      cardBg: cardBg,
                      divClr: divClr,
                      txtClr: txtClr,
                      subClr: subClr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 1. MASTER VAULT CARD =================
  Widget _buildMasterVaultCard({
    required BuildContext context,
    required PaydayVaultModel vault,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    final isLocked = vault.isVaultLocked;
    final isExpired = vault.isLockExpired;
    final remaining = vault.remainingTime;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (!isLocked) {
      badgeColor = const Color(0xFF64748B);
      badgeText = 'Belum Digembok';
      badgeIcon = Icons.lock_open_rounded;
    } else if (isExpired) {
      badgeColor = const Color(0xFF10B981);
      badgeText = 'Gembok Terbuka • Siap Klaim';
      badgeIcon = Icons.check_circle_rounded;
    } else {
      badgeColor = Colors.amber.shade800;
      badgeText = 'Gembok Aktif • Terkunci';
      badgeIcon = Icons.lock_rounded;
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    // Progress gembok (berapa persen waktu sudah terlewati)
    double lockProgress = 0.0;
    if (isLocked && vault.lockedUntil != null && vault.lockDurationDays > 0) {
      final totalSeconds = vault.lockDurationDays * 24 * 3600;
      final remainingSeconds = remaining.inSeconds;
      final elapsed = totalSeconds - remainingSeconds;
      lockProgress = (elapsed / totalSeconds).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLocked && !isExpired
              ? Colors.amber.withValues(alpha: isDark ? 0.35 : 0.4)
              : divClr,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row Header: Status Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeColor),
                    const SizedBox(width: 5),
                    Text(
                      badgeText,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked && !isExpired)
                Text(
                  '${vault.lockDurationDays} Hari Komitmen',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subClr,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Central Visual Vault
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLocked
                    ? (isExpired
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [Colors.amber.shade700, Colors.amber.shade900])
                    : [
                        isDark ? Colors.white12 : Colors.grey.shade200,
                        isDark ? Colors.white10 : Colors.grey.shade300,
                      ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                if (isLocked)
                  BoxShadow(
                    color: (isExpired
                            ? const Color(0xFF10B981)
                            : Colors.amber.shade700)
                        .withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Icon(
              isLocked
                  ? (isExpired ? Icons.lock_open_rounded : Icons.lock_rounded)
                  : Icons.savings_outlined,
              size: 34,
              color: isLocked ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 14),

          // Label & Nominal
          Text(
            isLocked ? 'TOTAL DANA TERKUNCI' : 'TABUNGAN SIAP DIGEMBOK',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: subClr,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isLocked
                  ? _formatRupiah(vault.lockedAmount)
                  : (vault.savingsAmount > 0
                      ? _formatRupiah(vault.savingsAmount)
                      : 'Rp 0'),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isLocked
                    ? (isExpired ? const Color(0xFF10B981) : Colors.amber.shade800)
                    : txtClr,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLocked
                ? (isExpired
                    ? 'Selamat! Komitmen gembok telah selesai secara penuh'
                    : 'Uang diamankan dari godaan belanja konsumtif')
                : 'Kunci minimal 20% gaji setiap awal bulan untuk disiplin keuangan',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: subClr,
            ),
          ),
          const SizedBox(height: 16),

          // Countdown Timer Simetris (Hanya jika sedang terkunci & belum expired)
          if (isLocked && !isExpired) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: divClr),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimerBox('$days', 'HARI', isDark),
                      Text(':',
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: subClr)),
                      _buildTimerBox('$hours', 'JAM', isDark),
                      Text(':',
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: subClr)),
                      _buildTimerBox('$minutes', 'MENIT', isDark),
                      Text(':',
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: subClr)),
                      _buildTimerBox('$seconds', 'DETIK', isDark),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: lockProgress,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amber.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tombol Aksi Utama
          if (!isLocked) ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (vault.monthlySalary <= 0) {
                    _showSetupSalaryModal(context, vault);
                  } else {
                    _showLockVaultModal(context, vault);
                  }
                },
                icon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  vault.monthlySalary <= 0
                      ? 'Atur Gaji & Mulai Gembok'
                      : 'Kunci Tabungan Gaji Sekarang',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else if (isExpired) ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(paydayVaultProvider.notifier).unlockVault();
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tabungan berhasil diklaim dan masuk kembali ke saldo utama!',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'Klaim Tabungan Sukses',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Status Sedang Terkunci: Tombol Buka Darurat
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => _showEmergencyUnlockDialog(context),
                icon: const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.redAccent),
                label: Text(
                  'Buka Gembok Darurat',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= 2. METRIK SEIMBANG =================
  Widget _buildBalancedMetricsRow({
    required PaydayVaultModel vault,
    required int daysUntilPayday,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    return Row(
      children: [
        // Metrik 1: Target 20%
        Expanded(
          child: _buildMetricTile(
            title: 'Tabungan 20%',
            value: vault.savingsAmount > 0
                ? _formatShortRupiah(vault.savingsAmount)
                : 'Rp 0',
            subtitle: 'Alokasi Vault',
            icon: Icons.savings_rounded,
            iconColor: const Color(0xFF10B981),
            isDark: isDark,
            cardBg: cardBg,
            divClr: divClr,
            txtClr: txtClr,
            subClr: subClr,
          ),
        ),
        const SizedBox(width: 12),

        // Metrik 2: Jadwal Gajian
        Expanded(
          child: _buildMetricTile(
            title: 'Jadwal Gajian',
            value: vault.paydayDate != null
                ? 'Tgl ${vault.paydayDate}'
                : 'Belum Diatur',
            subtitle: vault.paydayDate != null
                ? (daysUntilPayday == 0 ? 'Hari Ini!' : '$daysUntilPayday Hari Lagi')
                : 'Atur Tanggal',
            icon: Icons.calendar_month_rounded,
            iconColor: Colors.amber.shade700,
            isDark: isDark,
            cardBg: cardBg,
            divClr: divClr,
            txtClr: txtClr,
            subClr: subClr,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: divClr),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  if (onTap != null)
                    Icon(Icons.edit_rounded, size: 12, color: subClr),
                ],
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: txtClr,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subClr,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 3. SEKSI ALOKASI 50/30/20 =================
  Widget _buildSalarySplitSection({
    required BuildContext context,
    required PaydayVaultModel vault,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: divClr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Seksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATURAN FINANSIAL 50/30/20',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: subClr,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alokasi Gaji Terencana',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: txtClr,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showSetupSalaryModal(context, vault),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ubah Gaji',
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Multi-segment Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 50,
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 30,
                    child: Container(color: const Color(0xFFF97316)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 20,
                    child: Container(color: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3 Kartu Pos Alokasi Simetris
          _buildAllocCard(
            title: 'Kebutuhan Pokok',
            percent: '50%',
            desc: 'Tagihan, sewa, makan & transportasi',
            amount: _formatRupiah(vault.needsAmount),
            color: const Color(0xFF3B82F6),
            icon: Icons.receipt_long_rounded,
            isDark: isDark,
            divClr: divClr,
            txtClr: txtClr,
            subClr: subClr,
          ),
          const SizedBox(height: 8),
          _buildAllocCard(
            title: 'Keinginan & Lifestyle',
            percent: '30%',
            desc: 'Hiburan, hobi & belanja santai',
            amount: _formatRupiah(vault.wantsAmount),
            color: const Color(0xFFF97316),
            icon: Icons.coffee_rounded,
            isDark: isDark,
            divClr: divClr,
            txtClr: txtClr,
            subClr: subClr,
          ),
          const SizedBox(height: 8),
          _buildAllocCard(
            title: 'Tabungan Vault',
            percent: '20%',
            desc: 'Otomatis terkunci di gembok gaji',
            amount: _formatRupiah(vault.savingsAmount),
            color: const Color(0xFF10B981),
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            divClr: divClr,
            txtClr: txtClr,
            subClr: subClr,
          ),
        ],
      ),
    );
  }

  Widget _buildAllocCard({
    required String title,
    required String percent,
    required String desc,
    required String amount,
    required Color color,
    required IconData icon,
    required bool isDark,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: txtClr,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amount,
                      style: GoogleFonts.quicksand(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        percent,
                        style: GoogleFonts.quicksand(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        desc,
                        style: GoogleFonts.quicksand(
                          fontSize: 10.5,
                          color: subClr,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4. INSIGHT & DISIPLIN FINANSIAL =================
  Widget _buildDisciplineInsightCard({
    required PaydayVaultModel vault,
    required bool isDark,
    required Color cardBg,
    required Color divClr,
    required Color txtClr,
    required Color subClr,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: divClr),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prinsip "Pay Yourself First"',
                      style: GoogleFonts.quicksand(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: txtClr,
                      ),
                    ),
                    if (vault.unlockedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${vault.unlockedCount}x Berhasil',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Begitu gajian masuk, langsung kunci minimal 20% di awal bulan. Jangan menabung sisa pengeluaran, tetapi belanjakan sisa tabungan.',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: subClr,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildTimerBox(String value, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.padLeft(2, '0'),
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.amber.shade800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required int days,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color divClr,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : divClr,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$days',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosMiniBar({
    required String title,
    required String amount,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.quicksand(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatRupiah(double amount) {
    return _currencyFmt.format(amount);
  }

  String _formatShortRupiah(double amount) {
    if (amount >= 1000000) {
      final jt = amount / 1000000;
      if (jt == jt.roundToDouble()) {
        return 'Rp ${jt.toInt()} Jt';
      }
      return 'Rp ${jt.toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      final rb = (amount / 1000).toInt();
      return 'Rp $rb Rb';
    }
    return _formatRupiah(amount);
  }
}
