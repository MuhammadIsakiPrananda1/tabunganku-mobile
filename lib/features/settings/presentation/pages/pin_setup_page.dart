/// Feature: Settings — PIN Setup Page
///
/// Halaman untuk mengatur PIN baru, mengganti PIN lama, atau mengkonfirmasi
/// PIN baru. Alur: (opsional) verifikasi PIN lama → input PIN baru → konfirmasi PIN baru.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/pin_keypad.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String _currentPin = '';

  /// True ketika user harus memasukkan PIN lama terlebih dahulu (ganti PIN).
  bool _isOldPinStage = false;

  /// True ketika user diminta mengkonfirmasi PIN baru yang sudah diisi.
  bool _isConfirmStage = false;

  /// Menyimpan PIN pertama saat menunggu konfirmasi.
  String _firstPin = '';

  bool _isError = false;
  String _errorMessage = '';

  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _shakeController;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final security = ref.read(securityProvider);
    if (security.hasPin) _isOldPinStage = true;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ── Input handlers ─────────────────────────────────────────────────────────
  void _onNumber(String digit) {
    if (_currentPin.length >= 4) return;
    setState(() {
      _currentPin += digit;
      _isError = false;
      _errorMessage = '';
    });
    if (_currentPin.length == 4) {
      // Beri jeda singkat agar dot terakhir sempat terrender sebelum aksi.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _handlePinCompletion();
      });
    }
  }

  void _onBackspace() {
    if (_currentPin.isEmpty) return;
    setState(() {
      _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      _isError = false;
      _errorMessage = '';
    });
  }

  Future<void> _handlePinCompletion() async {
    if (_isOldPinStage) {
      await _verifyOldPin();
    } else if (!_isConfirmStage) {
      _enterConfirmStage();
    } else {
      await _saveNewPin();
    }
  }

  /// Verifikasi PIN lama sebelum memperbolehkan ganti PIN.
  Future<void> _verifyOldPin() async {
    final isValid = await ref
        .read(securityProvider.notifier)
        .verifyPin(_currentPin, trackAttempts: false);

    if (isValid) {
      setState(() {
        _isOldPinStage = false;
        _currentPin = '';
      });
    } else {
      _showError('PIN Lama Salah!');
    }
  }

  /// Pindah ke tahap konfirmasi PIN baru.
  void _enterConfirmStage() {
    _firstPin = _currentPin;
    setState(() {
      _isConfirmStage = true;
      _currentPin = '';
    });
  }

  /// Konfirmasi dan simpan PIN baru jika cocok.
  Future<void> _saveNewPin() async {
    if (_currentPin == _firstPin) {
      await ref.read(securityProvider.notifier).setPin(_currentPin);
      if (mounted) {
        context.pop();
        showTopToast(context, 'PIN Keamanan Berhasil Diatur! ✓');
      }
    } else {
      setState(() {
        _isConfirmStage = false;
        _firstPin = '';
      });
      _showError('PIN tidak cocok, silakan coba lagi.');
    }
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
      _currentPin = '';
    });
    _shakeController.forward(from: 0);
    HapticFeedback.vibrate();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ── Responsive sizing ──────────────────────────────────────────
            final maxHeight = constraints.maxHeight;
            final isVeryCompact = maxHeight < 560;
            final isCompact = maxHeight < 700;
            final horizontalPadding =
                constraints.maxWidth < 360 ? 16.0 : 24.0;
            const contentMaxWidth = 380.0;

            final availableWidth =
                (constraints.maxWidth - horizontalPadding * 2)
                    .clamp(0.0, contentMaxWidth);
            final buttonSize = ((availableWidth - 56) / 3).clamp(
              48.0,
              isVeryCompact ? 54.0 : (isCompact ? 64.0 : 72.0),
            );
            final rowSpacing =
                isVeryCompact ? 3.0 : (isCompact ? 6.0 : 10.0);
            final iconContainerSize =
                isVeryCompact ? 48.0 : (isCompact ? 60.0 : 76.0);
            final iconSize =
                isVeryCompact ? 22.0 : (isCompact ? 28.0 : 34.0);
            final iconBottomSpacing =
                isVeryCompact ? 10.0 : (isCompact ? 16.0 : 22.0);
            final titleBottomSpacing = isVeryCompact ? 4.0 : 8.0;
            final descBottomSpacing =
                isVeryCompact ? 12.0 : (isCompact ? 20.0 : 30.0);
            final dotsBottomSpacing = isVeryCompact ? 10.0 : 16.0;
            final keypadBottomSpacing =
                isVeryCompact ? 10.0 : (isCompact ? 16.0 : 28.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Spacer(flex: isCompact ? 1 : 2),

                          // ── Ikon header ────────────────────────────────
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              _headerIcon,
                              size: iconSize,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: iconBottomSpacing),

                          // ── Judul ──────────────────────────────────────
                          Text(
                            _stageTitle,
                            style: GoogleFonts.quicksand(
                              fontSize: isVeryCompact ? 18 : (isCompact ? 20 : 22),
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: titleBottomSpacing),

                          // ── Deskripsi ──────────────────────────────────
                          Text(
                            _stageDescription,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: isVeryCompact ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.black45,
                            ),
                          ),
                          SizedBox(height: descBottomSpacing),

                          // ── PIN dots ───────────────────────────────────
                          PinDots(
                            filledCount: _currentPin.length,
                            dotSize: isCompact ? 13.0 : 16.0,
                            shakeAnimation: _shakeController,
                          ),
                          SizedBox(height: dotsBottomSpacing),

                          // ── Pesan error ────────────────────────────────
                          if (_isError)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          const Spacer(flex: 1),

                          // ── Keypad ─────────────────────────────────────
                          PinKeypad(
                            buttonSize: buttonSize,
                            rowSpacing: rowSpacing,
                            onNumber: _onNumber,
                            onBackspace: _onBackspace,
                          ),
                          SizedBox(height: keypadBottomSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers untuk teks/ikon dinamis berdasarkan stage ─────────────────────

  IconData get _headerIcon {
    if (_isOldPinStage) return Icons.lock_outline_rounded;
    if (_isConfirmStage) return Icons.gpp_good_rounded;
    return Icons.shield_outlined;
  }

  String get _stageTitle {
    if (_isOldPinStage) return 'PIN Lama';
    if (_isConfirmStage) return 'Konfirmasi PIN Baru';
    return 'Atur PIN Baru';
  }

  String get _stageDescription {
    if (_isOldPinStage) return 'Masukkan PIN lama kamu untuk verifikasi';
    if (_isConfirmStage) return 'Masukkan kembali 4 digit PIN baru kamu';
    return 'Gunakan 4 digit angka rahasia untuk keamanan';
  }
}
