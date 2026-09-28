/// Widget: VipAccessGateSheet
///
/// Lembar modal pilihan paket TabunganKu VIP dengan desain dropdown filter
/// yang setara dan konsisten dengan gaya filter di tab Riwayat.
/// Minimalis, hemat ruang, dan adaptif terhadap Light & Dark Mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/security/crypto_sentinel.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/features/premium/models/premium_package.dart';
import 'package:tabunganku/features/premium/providers/premium_provider.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VipAccessGateSheet extends ConsumerStatefulWidget {
  const VipAccessGateSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom > 0
              ? MediaQuery.of(ctx).viewInsets.bottom
              : MediaQuery.of(ctx).padding.bottom,
        ),
        child: const SingleChildScrollView(
          child: VipAccessGateSheet(),
        ),
      ),
    );
  }

  @override
  ConsumerState<VipAccessGateSheet> createState() => _VipAccessGateSheetState();
}

class _VipAccessGateSheetState extends ConsumerState<VipAccessGateSheet> {
  final TextEditingController _codeController = TextEditingController();
  String _selectedPackageId = '1month'; // Default pilihan paling populer
  bool _isActivating = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cert = ref.read(premiumProvider).certificate;
      if (cert != null) {
        final matchingPkg = PremiumPackage.fromTier(cert.tier);
        setState(() {
          _selectedPackageId = matchingPkg.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  PremiumPackage get _selectedPackage {
    return PremiumPackage.all.firstWhere(
      (p) => p.id == _selectedPackageId,
      orElse: () => PremiumPackage.all.first,
    );
  }

  Future<void> _handleBuyViaWhatsApp() async {
    final pkg = _selectedPackage;
    final profile = ref.read(userProfileProvider);
    final userName = (profile.name.isNotEmpty &&
            profile.name != 'user-xxxx' &&
            profile.name != 'Pengguna TabunganKu')
        ? profile.name
        : 'Pengguna TabunganKu';

    final deviceFingerprint = await CryptoSentinel.getDeviceFingerprint();
    final shortDeviceId = deviceFingerprint.length > 8
        ? deviceFingerprint.substring(0, 8).toUpperCase()
        : deviceFingerprint.toUpperCase();

    final message =
        '''Halo Admin TabunganKu, saya ingin membeli paket VIP TabunganKu:

👑 Paket: ${pkg.durationLabel} (${pkg.badge})
💰 Harga: ${pkg.priceFormatted}
👤 Nama: $userName
📱 ID Perangkat: $shortDeviceId

Mohon petunjuk pembayaran dan tolong kirimkan kode lisensi resminya setelah transfer ya. Terima kasih!''';

    final encodedText = Uri.encodeComponent(message);
    final waUri = Uri.parse('https://wa.me/628995257735?text=$encodedText');

    HapticFeedback.mediumImpact();

    try {
      final launched =
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallbackUri = Uri.parse(
            'https://api.whatsapp.com/send?phone=628995257735&text=$encodedText');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
      if (mounted) {
        showTopToast(
            context, 'Membuka WhatsApp... Silakan hubungi Owner untuk lisensi');
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
            context, 'Gagal membuka WhatsApp. Nomor Owner: 628995257735',
            isError: true);
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _codeController.text = data.text!.trim().toUpperCase();
      });
      HapticFeedback.selectionClick();
      if (mounted) {
        showTopToast(context, 'Kode lisensi ditempel dari clipboard');
      }
    }
  }

  Future<void> _handleCodeActivation([String? explicitCode]) async {
    final code = explicitCode ?? _codeController.text.trim();
    if (code.isEmpty) {
      setState(() =>
          _inlineError = 'Masukkan kode lisensi VIP yang diberikan Owner.');
      return;
    }

    setState(() {
      _isActivating = true;
      _inlineError = null;
    });

    HapticFeedback.mediumImpact();
    final success =
        await ref.read(premiumProvider.notifier).activateLicenseKey(code);

    if (!mounted) return;
    setState(() => _isActivating = false);

    if (success) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
      showTopToast(context, 'Lisensi Resmi VIP Berhasil Diaktifkan! 👑');
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _inlineError =
            'Kode lisensi tidak valid. Pastikan kode sesuai dari Owner via WhatsApp.';
      });
      showTopToast(context, 'Kode lisensi tidak valid', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final premiumState = ref.watch(premiumProvider);
    final activeCert = premiumState.certificate;
    final isVip = premiumState.isVip && activeCert != null;

    // Palette warna adaptif mengikuti riwayat
    final bgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black12;
    final textPrimary = isDarkMode ? Colors.white : Colors.black87;
    final textSecondary = isDarkMode ? Colors.white70 : const Color(0xFF4B5563);
    final textMuted = isDarkMode ? Colors.white38 : const Color(0xFF9CA3AF);
    final accentColor =
        isDarkMode ? const Color(0xFFFFB800) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header minimalis
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: isDarkMode ? 0.18 : 0.1),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PILIH PAKET VIP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Pilih durasi akses sesuai kebutuhan Anda',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Status Paket Aktif (jika ada)
          if (isVip) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDarkMode ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: accentColor, size: 17),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paket Aktif: ${activeCert.packageLabel}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          activeCert.isLifetime
                              ? 'Akses Seumur Hidup (Tanpa Batas Waktu)'
                              : 'Sisa Waktu: ${activeCert.remainingTimeLabel} (${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(activeCert.expiresAt!)})',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── DROPDOWN PAKET (Mengikuti Gaya Filter di Tab Riwayat) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: PopupMenuButton<String>(
                  initialValue: _selectedPackageId,
                  onSelected: (String val) {
                    setState(() => _selectedPackageId = val);
                  },
                  borderRadius: BorderRadius.circular(20),
                  offset: const Offset(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                      width: 1.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  elevation: 6,
                  constraints:
                      const BoxConstraints(minWidth: 280, maxWidth: 360),
                  itemBuilder: (context) => PremiumPackage.all.map((pkg) {
                    final val = pkg.id;
                    final selected = _selectedPackageId == val;
                    final isCurrentActive =
                        isVip && activeCert.tier == pkg.tier;

                    return PopupMenuItem<String>(
                      value: val,
                      height: 48,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                  alpha: isDarkMode
                                      ? (selected ? 0.25 : 0.1)
                                      : (selected ? 0.18 : 0.08)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.workspace_premium_rounded,
                              size: 14,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        pkg.durationLabel,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: selected
                                              ? accentColor
                                              : (isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? accentColor.withValues(
                                                alpha: 0.18)
                                            : const Color(0xFFFDE68A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pkg.badge,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: isDarkMode
                                              ? accentColor
                                              : const Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                    if (isCurrentActive) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'AKTIF',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (pkg.pricePerDayNote != null)
                                  Text(
                                    pkg.pricePerDayNote!,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                      color: textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pkg.priceFormatted,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? accentColor
                                  : (isDarkMode
                                      ? Colors.white70
                                      : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(
                                alpha: isDarkMode ? 0.2 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: 13,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _selectedPackage.durationLabel,
                            style: GoogleFonts.quicksand(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      accentColor.withValues(alpha: isDarkMode ? 0.15 : 0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        accentColor.withValues(alpha: isDarkMode ? 0.35 : 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedPackage.priceFormatted,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? accentColor.withValues(alpha: 0.22)
                            : const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _selectedPackage.badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? accentColor
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_selectedPackage.pricePerDayNote != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 12, color: textMuted),
                  const SizedBox(width: 5),
                  Text(
                    'Biaya setara: ${_selectedPackage.pricePerDayNote}',
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_inlineError != null) ...[
            const SizedBox(height: 6),
            Text(
              _inlineError!,
              style: GoogleFonts.quicksand(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Tombol Beli Paket via WhatsApp
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _handleBuyViaWhatsApp,
              icon: const Icon(Icons.chat_bubble_rounded, size: 17),
              label: Text(
                'BELI VIA WHATSAPP (628995257735)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Container Aktivasi Kode Lisensi dari Owner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.vpn_key_rounded,
                      size: 15,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Punya Kode Lisensi dari Owner?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Masukkan kode lisensi resmi yang dikirimkan oleh Owner untuk mengaktifkan paket:',
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukan Kode Lisensi',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: textMuted,
                            fontSize: 11,
                            letterSpacing: 0.4,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.black.withValues(alpha: 0.25)
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.content_paste_rounded,
                              size: 16,
                              color: textSecondary,
                            ),
                            onPressed: _pasteFromClipboard,
                            tooltip: 'Tempel dari Clipboard',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: accentColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed:
                          _isActivating ? null : () => _handleCodeActivation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode ? accentColor : const Color(0xFF111827),
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        elevation: 0,
                      ),
                      child: _isActivating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            )
                          : Text(
                              'Aktifkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Reset Lisensi jika sedang aktif (untuk testing user)
          if (isVip) ...[
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(premiumProvider.notifier).revokeLicense();
                  if (context.mounted) {
                    Navigator.pop(context);
                    showTopToast(
                        context, 'Lisensi berhasil direset ke tier standar.');
                  }
                },
                child: Text(
                  'Hapus / Reset Lisensi Aktif',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: Colors.redAccent.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
