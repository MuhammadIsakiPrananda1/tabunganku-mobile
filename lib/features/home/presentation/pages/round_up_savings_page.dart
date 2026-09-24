/// Page: RoundUpSavingsPage
///
/// Fitur tabungan receh otomatis melalui pembulatan pengeluaran.
/// Selisih pembulatan langsung masuk ke PiggyBank.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/providers/piggy_bank_provider.dart';
import 'package:tabunganku/providers/round_up_provider.dart';
import 'package:tabunganku/providers/saving_streak_provider.dart';

class RoundUpSavingsPage extends ConsumerStatefulWidget {
  const RoundUpSavingsPage({super.key});

  @override
  ConsumerState<RoundUpSavingsPage> createState() => _RoundUpSavingsPageState();
}

class _RoundUpSavingsPageState extends ConsumerState<RoundUpSavingsPage> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  int _selectedViewIndex = 0; // 0: Tambah Round-Up, 1: Riwayat

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && _isDropdownOpen) {
      setState(() => _isDropdownOpen = false);
    }
  }

  void _openDropdown() {
    _closeDropdown();
    final overlay = Overlay.of(context);
    final renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        final isDark = _isDark(context);
        final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.primaryDark;
        final subColor = isDark ? Colors.white54 : Colors.grey.shade600;
        final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            Positioned(
              width: size.width > 0 ? size.width : null,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 54),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: _selectedViewIndex == 0
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              splashColor: AppColors.primary.withValues(alpha: 0.15),
                              highlightColor: AppColors.primary.withValues(alpha: 0.08),
                              onTap: () {
                                setState(() => _selectedViewIndex = 0);
                                _closeDropdown();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: (_selectedViewIndex == 0 ? AppColors.primary : Colors.grey).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 16,
                                        color: _selectedViewIndex == 0 ? AppColors.primary : subColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Tambah Pembulatan',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedViewIndex == 0 ? AppColors.primary : textColor,
                                        ),
                                      ),
                                    ),
                                    if (_selectedViewIndex == 0)
                                      const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(color: borderColor, height: 1, thickness: 1),
                          Material(
                            color: _selectedViewIndex == 1
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                              splashColor: AppColors.primary.withValues(alpha: 0.15),
                              highlightColor: AppColors.primary.withValues(alpha: 0.08),
                              onTap: () {
                                setState(() => _selectedViewIndex = 1);
                                _closeDropdown();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: (_selectedViewIndex == 1 ? AppColors.primary : Colors.grey).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.history_rounded,
                                        size: 16,
                                        color: _selectedViewIndex == 1 ? AppColors.primary : subColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Riwayat Pembulatan',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedViewIndex == 1 ? AppColors.primary : textColor,
                                        ),
                                      ),
                                    ),
                                    if (_selectedViewIndex == 1)
                                      const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  @override
  void dispose() {
    _closeDropdown();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) {
    final mode = ref.watch(themeProvider);
    return mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
  }

  Future<void> _applyRoundUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();

    final rawText = _amountCtrl.text.replaceAll('.', '');
    final amount = double.tryParse(rawText) ?? 0;
    if (amount <= 0) return;

    final roundUpState = ref.read(roundUpProvider);
    final savedAmount = RoundUpState.calculateRoundUp(
      amount,
      roundUpState.multiplier.value,
    );

    if (savedAmount <= 0) {
      showTopToast(
        context,
        '⚠️ Nominal sudah bulat, tidak ada yang disimpan.',
      );
      return;
    }

    // Tambah ke round-up history
    await ref.read(roundUpProvider.notifier).addRoundUp(
          originalAmount: amount,
          description: _descCtrl.text.trim(),
        );

    // Tambah ke celengan
    await ref.read(piggyBankProvider.notifier).addAmount(savedAmount);
    await ref.read(piggyBankHistoryProvider.notifier).addLog(savedAmount);

    // Catat aktivitas menabung untuk streak
    await ref.read(savingStreakProvider.notifier).recordSavingActivity();

    _amountCtrl.clear();
    _descCtrl.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (mounted) {
      showTopToast(
        context,
        '✅ ${_formatRupiah(savedAmount)} berhasil masuk ke celengan!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final roundUpState = ref.watch(roundUpProvider);
    final piggyBalance = ref.watch(piggyBankProvider);

    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.primaryDark;
    final subColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 18),
        ),
        title: Text(
          'Tabungan Pembulatan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Dropdown Switcher Kustom (Ripple Full & Halus)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  key: _dropdownKey,
                  onTap: _toggleDropdown,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: AppColors.primary.withValues(alpha: 0.12),
                  highlightColor: AppColors.primary.withValues(alpha: 0.06),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isDropdownOpen ? AppColors.primary : borderColor,
                        width: _isDropdownOpen ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _selectedViewIndex == 0
                                ? Icons.add_circle_outline_rounded
                                : Icons.history_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedViewIndex == 0
                                ? 'Tambah Pembulatan'
                                : 'Riwayat Pembulatan',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isDropdownOpen ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark ? Colors.white70 : AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedViewIndex,
              children: [
                _buildMainTab(
                  roundUpState,
                  piggyBalance,
                  isDark,
                  cardBg,
                  textColor,
                  subColor,
                  borderColor,
                ),
                _buildHistoryTab(roundUpState, isDark, cardBg, textColor, subColor, borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ── Main Tab ─────────────────────────────────────────────────────────────────

  Widget _buildMainTab(
    RoundUpState roundUpState,
    double piggyBalance,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        children: [
          _buildSummaryRow(roundUpState, piggyBalance, isDark, cardBg, textColor, subColor, borderColor),
          const SizedBox(height: 16),
          _buildSettingsCard(roundUpState, isDark, cardBg, textColor, subColor, borderColor),
          const SizedBox(height: 16),
          _buildSimulatorCard(roundUpState, isDark, cardBg, textColor, subColor, borderColor),
          const SizedBox(height: 16),
          _buildInputCard(roundUpState, isDark, cardBg, textColor, subColor, borderColor),
          const SizedBox(height: 16),
          _buildHowItWorksCard(isDark, cardBg, textColor, subColor, borderColor),
        ],
      ),
    );
  }

  // ── Summary Row ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow(
    RoundUpState state,
    double piggyBalance,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Round-Up',
            value: _formatRupiah(state.totalSaved),
            icon: Icons.savings_rounded,
            iconColor: AppColors.primary,
            isDark: isDark,
            cardBg: cardBg,
            textColor: textColor,
            subColor: subColor,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Saldo Celengan',
            value: _formatRupiah(piggyBalance),
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.amber.shade700,
            isDark: isDark,
            cardBg: cardBg,
            textColor: textColor,
            subColor: subColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  // ── Settings Card ─────────────────────────────────────────────────────────

  Widget _buildSettingsCard(
    RoundUpState state,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENGATURAN ROUND-UP',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: subColor,
                      ),
                    ),
                    Text(
                      state.isActive ? 'Aktif — Setiap belanja dibulatkan' : 'Non-aktif',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: state.isActive ? AppColors.primary : subColor,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: state.isActive,
                  onChanged: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(roundUpProvider.notifier).toggleActive();
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          // Multiplier selector
          Text(
            'KELIPATAN PEMBULATAN',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: subColor,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoundUpMultiplier.values.map((m) {
              final selected = state.multiplier == m;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(roundUpProvider.notifier).setMultiplier(m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? Colors.white12 : Colors.grey.shade200),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    m.label,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Simulator Card ────────────────────────────────────────────────────────

  Widget _buildSimulatorCard(
    RoundUpState state,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    final rawText = _amountCtrl.text.replaceAll('.', '');
    final amount = double.tryParse(rawText) ?? 0;
    final savedAmount = RoundUpState.calculateRoundUp(amount, state.multiplier.value);
    final roundedAmount = RoundUpState.calculateRounded(amount, state.multiplier.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.teal.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primaryLight.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIMULASI PEMBULATAN',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          if (amount > 0) ...[
            _SimRow(
              label: 'Belanja',
              value: _formatRupiah(amount),
              icon: Icons.shopping_bag_rounded,
              color: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _SimRow(
              label: 'Dibulatkan ke',
              value: _formatRupiah(roundedAmount),
              icon: Icons.arrow_upward_rounded,
              color: Colors.orange,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _SimRow(
              label: 'Masuk celengan',
              value: _formatRupiah(savedAmount),
              icon: Icons.savings_rounded,
              color: AppColors.primary,
              isDark: isDark,
              highlight: true,
            ),
          ] else
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Masukkan nominal belanja di bawah untuk melihat simulasi pembulatan.',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: subColor,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Input Card ────────────────────────────────────────────────────────────

  Widget _buildInputCard(
    RoundUpState state,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATAT PENGELUARAN & ROUND-UP',
              style: GoogleFonts.quicksand(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: subColor,
              ),
            ),
            const SizedBox(height: 14),
            // Amount field
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _RibuanFormatter(),
              ],
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration(
                'Nominal pengeluaran',
                Icons.payments_rounded,
                isDark,
                borderColor,
                prefix: 'Rp',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nominal tidak boleh kosong';
                }
                final n = double.tryParse(val.replaceAll('.', ''));
                if (n == null || n <= 0) return 'Nominal tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Description field
            TextFormField(
              controller: _descCtrl,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: _inputDecoration(
                'Keterangan (opsional)',
                Icons.note_alt_rounded,
                isDark,
                borderColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: state.isActive ? _applyRoundUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  state.isActive
                      ? 'Tambah Round-Up ke Celengan'
                      : 'Aktifkan Round-Up dulu',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── How It Works Card ─────────────────────────────────────────────────────

  Widget _buildHowItWorksCard(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.indigo.withValues(alpha: 0.10)
            : Colors.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔄', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'CARA KERJA ROUND-UP',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.indigo.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            '1. Pilih kelipatan pembulatan (Rp 1.000–10.000)',
            '2. Setiap kali belanja, catat nominal di atas',
            '3. Selisih pembulatan otomatis masuk ke Celengan',
            '4. Uang terkumpul bisa dipecahkan dari halaman Tabungan Receh',
          ].map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                s,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── History Tab ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab(
    RoundUpState state,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    if (state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat Round-Up',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Mulai aktifkan round-up dan catat pengeluaranmu agar selisih masuk ke celengan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: state.history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final log = state.history[i];
        return _RoundUpLogCard(
          log: log,
          isDark: isDark,
          cardBg: cardBg,
          textColor: textColor,
          subColor: subColor,
          borderColor: borderColor,
          formatRupiah: _formatRupiah,
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    bool isDark,
    Color borderColor, {
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white24 : Colors.black26,
      ),
      prefixIcon: Container(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            if (prefix != null) ...[
              const SizedBox(width: 6),
              Text(
                prefix,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Color cardBg;
  final Color textColor;
  final Color subColor;
  final Color borderColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    required this.subColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool highlight;

  const _SimRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: highlight
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundUpLogCard extends StatelessWidget {
  final RoundUpLog log;
  final bool isDark;
  final Color cardBg;
  final Color textColor;
  final Color subColor;
  final Color borderColor;
  final String Function(double) formatRupiah;

  const _RoundUpLogCard({
    required this.log,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    required this.subColor,
    required this.borderColor,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(log.date);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_circle_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description.isNotEmpty
                      ? log.description
                      : 'Pembulatan belanja',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatRupiah(log.originalAmount)} → ${formatRupiah(log.roundedAmount)}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${formatRupiah(log.savedAmount)}',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ke celengan',
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: subColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text.replaceAll('.', ''));
    if (intValue == null) return oldValue;
    final newText =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
            .format(intValue)
            .trim();
    return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
