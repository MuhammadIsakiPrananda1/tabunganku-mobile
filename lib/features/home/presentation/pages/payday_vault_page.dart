import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _showSetupSalaryModal(BuildContext context, PaydayVaultModel vault) {
    final initialStr = vault.monthlySalary > 0
        ? _rawFmt.format(vault.monthlySalary).trim()
        : '';
    final salaryCtrl = TextEditingController(text: initialStr);

    int selectedPayday = vault.paydayDate;
    double needs = vault.needsPercent;
    double wants = vault.wantsPercent;
    double savings = vault.savingsPercent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF141414) : Colors.white;
        final txtClr = isDark ? Colors.white : AppColors.primaryDark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final parsedSalary = double.tryParse(
                    salaryCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                0;
            final calcNeeds = parsedSalary * (needs / 100);
            final calcWants = parsedSalary * (wants / 100);
            final calcSavings = parsedSalary * (savings / 100);

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Modal Pemasukan Gaji
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengaturan Pemasukan Gaji',
                                style: GoogleFonts.quicksand(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: txtClr,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Atur nominal & alokasi 50/30/20',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10.5,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Nominal Gaji Pemasukan
                    Text(
                      'GAJI BULANAN (PEMASUKAN)',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    HighVisInput(
                      controller: salaryCtrl,
                      icon: Icons.add_card_rounded,
                      label: '',
                      isDarkMode: isDark,
                      prefixText: 'Rp',
                      hintText: 'Contoh: 10.000.000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanFormatter()],
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Gajian Calendar Picker
                    Text(
                      'TANGGAL GAJIAN RUTIN',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final initialDate = DateTime(
                          now.year,
                          now.month,
                          selectedPayday.clamp(1, 28),
                        );
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(now.year - 1, 1, 1),
                          lastDate: DateTime(now.year + 5, 12, 31),
                          helpText: 'Pilih Tanggal Gajian Bulanan',
                          builder: (context, child) {
                            return Theme(
                              data: isDark
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF1E1E1E),
                                        onSurface: Colors.white,
                                      ),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedPayday = picked.day;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Setiap Tanggal $selectedPayday',
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: txtClr,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pilih Kalender',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Rincian Pos Alokasi
                    Text(
                      'ALOKASI OTOMATIS GAJI',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPosRowMinimal(
                      title: 'Kebutuhan Pokok (50%)',
                      subtitle: 'Tagihan, makan & kebutuhan',
                      amountStr: _currencyFmt.format(calcNeeds),
                      color: Colors.blueAccent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildPosRowMinimal(
                      title: 'Keinginan (30%)',
                      subtitle: 'Hiburan & belanja',
                      amountStr: _currencyFmt.format(calcWants),
                      color: Colors.orangeAccent,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildPosRowMinimal(
                      title: 'Tabungan Vault (20%)',
                      subtitle: 'Otomatis terkunci di Vault',
                      amountStr: _currencyFmt.format(calcSavings),
                      color: Colors.green,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: parsedSalary <= 0
                            ? null
                            : () {
                                ref
                                    .read(paydayVaultProvider.notifier)
                                    .updateSalaryAndRules(
                                      monthlySalary: parsedSalary,
                                      paydayDate: selectedPayday,
                                      needsPercent: needs,
                                      wantsPercent: wants,
                                      savingsPercent: savings,
                                    );
                                Navigator.pop(ctx);
                                HapticFeedback.mediumImpact();
                              },
                        icon: const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                        label: Text(
                          'Simpan Pemasukan Gaji',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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

  void _showLockVaultModal(BuildContext context, PaydayVaultModel vault) {
    int durationDays = 30;
    final suggestedAmount = vault.savingsAmount > 0
        ? vault.savingsAmount
        : vault.monthlySalary * 0.2;
    final initialStr = suggestedAmount > 0
        ? _rawFmt.format(suggestedAmount).trim()
        : '';
    final amountCtrl = TextEditingController(text: initialStr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF141414) : Colors.white;
        final txtClr = isDark ? Colors.white : AppColors.primaryDark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final parsedAmount = double.tryParse(
                    amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
                0;

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Gembok Tabungan',
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: txtClr,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'NOMINAL GEMBOK',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    HighVisInput(
                      controller: amountCtrl,
                      icon: Icons.savings_rounded,
                      label: '',
                      isDarkMode: isDark,
                      prefixText: 'Rp',
                      hintText: 'Masukkan nominal gembok',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanFormatter()],
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'DURASI GEMBOK',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [14, 30, 60, 90].map((days) {
                        final isSelected = durationDays == days;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() => durationDays = days);
                              HapticFeedback.selectionClick();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.grey.shade200),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$days',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : txtClr,
                                    ),
                                  ),
                                  Text(
                                    'Hari',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: parsedAmount <= 0
                            ? null
                            : () {
                                ref
                                    .read(paydayVaultProvider.notifier)
                                    .lockVault(
                                      amount: parsedAmount,
                                      durationDays: durationDays,
                                    );
                                Navigator.pop(ctx);
                                HapticFeedback.heavyImpact();
                              },
                        icon: const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 18),
                        label: Text(
                          'Kunci Tabungan Sekarang',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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

  void _showEmergencyUnlockDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final txtClr = isDark ? Colors.white : AppColors.primaryDark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Buka Darurat Vault',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: txtClr,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mengambil tabungan lebih awal mengurangi disiplin finansial. Tuliskan alasan darurat:',
                style: GoogleFonts.quicksand(
                  fontSize: 11.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: GoogleFonts.quicksand(
                  fontSize: 12.5,
                  color: txtClr,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: Kebutuhan mendesak berobat',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim();
                ref.read(paydayVaultProvider.notifier).emergencyUnlock(
                      reason.isEmpty ? 'Buka darurat tanpa catatan' : reason,
                    );
                Navigator.pop(ctx);
                HapticFeedback.heavyImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Buka Darurat',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final vault = ref.watch(paydayVaultProvider);
    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final txtClr = isDark ? Colors.white : AppColors.primaryDark;
    final cardBg = isDark ? const Color(0xFF141414) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: txtClr, size: 18),
        ),
        title: Text(
          'Gembok Tabungan Gaji',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: txtClr,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan Gaji',
            icon: Icon(Icons.tune_rounded, color: txtClr, size: 20),
            onPressed: () => _showSetupSalaryModal(context, vault),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Status Gembok ─────────────────────────────────────
              _buildVaultLockStatusCard(
                  context, vault, isDark, cardBg, borderCol, txtClr),
              const SizedBox(height: 18),

              // ── Aturan 50/30/20 & Simulasi Gaji ─────────────────────────
              _buildSalarySplitOverview(
                  vault, isDark, cardBg, borderCol, txtClr),
              const SizedBox(height: 18),

              // ── Tips Financial Discipline ────────────────────────────────
              _buildDisciplineTipsCard(isDark, cardBg, borderCol, txtClr),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vault Lock Status Card Minimalist ─────────────────────────────────────
  Widget _buildVaultLockStatusCard(
    BuildContext context,
    PaydayVaultModel vault,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color txtClr,
  ) {
    final isLocked = vault.isVaultLocked;
    final isExpired = vault.isLockExpired;
    final remaining = vault.remainingTime;

    Color stateColor;
    IconData stateIcon;
    String statusTitle;
    String statusSubtitle;

    if (!isLocked) {
      stateColor = Colors.grey;
      stateIcon = Icons.lock_open_rounded;
      statusTitle = 'Vault Belum Digembok';
      statusSubtitle = 'Kunci 20% gajimu begitu gajian agar tidak terpakai.';
    } else if (isExpired) {
      stateColor = Colors.green;
      stateIcon = Icons.lock_open_rounded;
      statusTitle = 'Gembok Telah Terbuka!';
      statusSubtitle =
          'Hebat! Kamu disiplin menabung selama ${vault.lockDurationDays} hari.';
    } else {
      stateColor = Colors.amber.shade800;
      stateIcon = Icons.lock_rounded;
      statusTitle = 'Vault Sedang Terkunci';
      statusSubtitle =
          'Uang aman dalam gembok untuk menjaga disiplin keuangan.';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(stateIcon, size: 36, color: stateColor),
          ),
          const SizedBox(height: 12),

          Text(
            statusTitle,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: txtClr,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          if (isLocked) ...[
            Text(
              'NOMINAL GEMBOK',
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _currencyFmt.format(vault.lockedAmount),
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),

            if (!isExpired) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _timeUnitBox('$days', 'Hari', isDark),
                  const SizedBox(width: 6),
                  _timeUnitBox('$hours', 'Jam', isDark),
                  const SizedBox(width: 6),
                  _timeUnitBox('$minutes', 'Menit', isDark),
                  const SizedBox(width: 6),
                  _timeUnitBox('$seconds', 'Detik', isDark),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],

          if (!isLocked) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (vault.monthlySalary <= 0) {
                    _showSetupSalaryModal(context, vault);
                  } else {
                    _showLockVaultModal(context, vault);
                  }
                },
                icon: const Icon(Icons.lock_outline_rounded,
                    color: Colors.white, size: 18),
                label: Text(
                  vault.monthlySalary <= 0
                      ? 'Atur Gaji & Gembok'
                      : 'Gembok Tabungan Gaji',
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (isExpired) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(paydayVaultProvider.notifier).unlockVault();
                  HapticFeedback.mediumImpact();
                },
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                label: Text(
                  'Klaim & Buka Vault',
                  style: GoogleFonts.quicksand(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: () => _showEmergencyUnlockDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Buka Darurat',
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeUnitBox(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value.padLeft(2, '0'),
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Salary Split Overview Minimalist ──────────────────────────────────────
  Widget _buildSalarySplitOverview(
    PaydayVaultModel vault,
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color txtClr,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
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
                      'ALOKASI GAJI 50/30/20',
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vault.monthlySalary > 0
                          ? _currencyFmt.format(vault.monthlySalary)
                          : 'Belum diatur',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: txtClr,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showSetupSalaryModal(context, vault),
                icon: const Icon(Icons.edit_rounded,
                    size: 18, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bar Visual
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 50,
                    child: Container(color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 30,
                    child: Container(color: Colors.orangeAccent),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 20,
                    child: Container(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          _buildPosRowMinimal(
            title: '50% Kebutuhan Pokok',
            subtitle: 'Tagihan, sewa & konsumsi',
            amountStr: _currencyFmt.format(vault.needsAmount),
            color: Colors.blueAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildPosRowMinimal(
            title: '30% Keinginan',
            subtitle: 'Hiburan & belanja gaya hidup',
            amountStr: _currencyFmt.format(vault.wantsAmount),
            color: Colors.orangeAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildPosRowMinimal(
            title: '20% Tabungan Gembok',
            subtitle: 'Vault terkunci otomatis',
            amountStr: _currencyFmt.format(vault.savingsAmount),
            color: Colors.green,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPosRowMinimal({
    required String title,
    required String subtitle,
    required String amountStr,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountStr,
            style: GoogleFonts.quicksand(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tips Financial Discipline Minimalist ──────────────────────────────────
  Widget _buildDisciplineTipsCard(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color txtClr,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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
                Text(
                  'Prinsip "Pay Yourself First"',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: txtClr,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kunci 20% tabungan di awal gajian agar terbiasa menabung secara konsisten.',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    color: Colors.grey,
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
