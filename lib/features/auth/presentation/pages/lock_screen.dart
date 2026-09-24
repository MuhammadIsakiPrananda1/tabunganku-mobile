/// Page: LockScreen
///
/// Layar kunci keamanan PIN / biometrik untuk melindungi akses aplikasi.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/widgets/pin_keypad.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/providers/user_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String _inputPin = '';
  bool _isError = false;
  String _errorMessage = '';
  int _remainingLockoutSeconds = 0;

  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  Timer? _lockoutTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLockoutStatus());
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Lockout countdown ──────────────────────────────────────────────────────
  void _checkLockoutStatus() {
    final security = ref.read(securityProvider);
    if (security.isLockedOut) {
      _startLockoutCountdown(security.remainingLockoutSeconds);
    }
  }

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    setState(() {
      _remainingLockoutSeconds = seconds;
      _inputPin = '';
      _isError = false;
      _errorMessage = '';
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(securityProvider).remainingLockoutSeconds;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _remainingLockoutSeconds = 0;
          _isError = false;
          _errorMessage = '';
        });
        HapticFeedback.lightImpact();
      } else {
        setState(() => _remainingLockoutSeconds = remaining);
      }
    });
  }

  String _formatLockoutTimer(int totalSeconds) {
    if (totalSeconds < 60) return '$totalSeconds detik';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) return '$minutes menit';
    return '$minutes menit ${seconds.toString().padLeft(2, '0')} dtk';
  }

  // ── Input handlers ─────────────────────────────────────────────────────────
  Future<void> _authenticateBiometric() async {
    if (_remainingLockoutSeconds > 0) return;
    final authenticated =
        await ref.read(securityProvider.notifier).authenticate();
    if (authenticated && mounted) {
      _navigateToDashboardIfOnLockRoute();
    }
  }

  void _onNumberPressed(String number) {
    if (_remainingLockoutSeconds > 0) return;
    if (_inputPin.length >= 4) return;
    setState(() {
      _inputPin += number;
      _isError = false;
      _errorMessage = '';
    });
    if (_inputPin.length == 4) _verifyPin();
  }

  void _onBackspace() {
    if (_remainingLockoutSeconds > 0) return;
    if (_inputPin.isEmpty) return;
    setState(() {
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      _isError = false;
      _errorMessage = '';
    });
  }

  Future<void> _verifyPin() async {
    final notifier = ref.read(securityProvider.notifier);
    final success = await notifier.verifyPin(_inputPin);

    if (success) {
      await notifier.recordSuccessAuth();
      if (mounted) _navigateToDashboardIfOnLockRoute();
      return;
    }

    // PIN salah — tampilkan pesan dan tangani lockout
    final security = ref.read(securityProvider);
    final isLocked = security.isLockedOut;
    final failed = security.failedAttempts;

    final String message;
    if (isLocked) {
      message = 'PIN salah $failed kali. Terkunci sementara.';
    } else {
      final remaining = 3 - failed;
      message = remaining == 1
          ? 'PIN Salah! Sisa 1 kesempatan lagi.'
          : 'PIN Salah. Silakan coba lagi.';
    }

    setState(() {
      _isError = true;
      _errorMessage = message;
      _inputPin = '';
    });
    _shakeController.forward(from: 0);
    HapticFeedback.vibrate();

    if (isLocked) {
      _startLockoutCountdown(security.remainingLockoutSeconds);
    }
  }

  void _navigateToDashboardIfOnLockRoute() {
    try {
      final path =
          GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
      if (path == '/lock') context.go('/dashboard');
    } catch (_) {}
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final security = ref.watch(securityProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLockedOut = _remainingLockoutSeconds > 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ── Responsive sizing ────────────────────────────────────────
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
              final rowSpacing = isVeryCompact ? 3.0 : (isCompact ? 6.0 : 10.0);
              final avatarSize =
                  isVeryCompact ? 52.0 : (isCompact ? 68.0 : 86.0);
              final headerBottomSpacing =
                  isVeryCompact ? 10.0 : (isCompact ? 16.0 : 26.0);
              final dotsBottomSpacing =
                  isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
              final keypadBottomSpacing =
                  isVeryCompact ? 10.0 : (isCompact ? 16.0 : 32.0);

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Spacer(flex: isCompact ? 1 : 2),

                            // ── Header profil ──────────────────────────────
                            _ProfileHeader(
                              profile: profile,
                              avatarSize: avatarSize,
                            ),
                            SizedBox(height: headerBottomSpacing),

                            // ── Status (lockout atau PIN dots) ─────────────
                            if (isLockedOut) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  'Coba lagi dalam '
                                  '${_formatLockoutTimer(_remainingLockoutSeconds)}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(height: dotsBottomSpacing),
                            ] else ...[
                              PinDots(
                                filledCount: _inputPin.length,
                                dotSize: isCompact ? 13.0 : 16.0,
                                shakeAnimation: _shakeController,
                              ),
                              SizedBox(height: dotsBottomSpacing),
                              if (_isError && _errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(
                                      color: colorScheme.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],

                            const Spacer(flex: 1),

                            // ── Keypad ─────────────────────────────────────
                            IgnorePointer(
                              ignoring: isLockedOut,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isLockedOut ? 0.35 : 1.0,
                                child: PinKeypad(
                                  buttonSize: buttonSize,
                                  rowSpacing: rowSpacing,
                                  onNumber: _onNumberPressed,
                                  onBackspace: _onBackspace,
                                  showBiometric: security.isBiometricEnabled &&
                                      !isLockedOut,
                                  onBiometric: _authenticateBiometric,
                                ),
                              ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileHeader — avatar + salam pembuka
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.avatarSize,
  });

  final UserProfile profile;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(child: _buildAvatarContent(colorScheme)),
        ),
        SizedBox(height: avatarSize < 70 ? 8 : 12),

        // Salam
        Text(
          'Selamat Datang Kembali,',
          style: GoogleFonts.quicksand(
            fontSize: avatarSize < 70 ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          profile.name,
          style: GoogleFonts.quicksand(
            fontSize: avatarSize < 70 ? 18 : 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent(ColorScheme cs) {
    final url = profile.photoUrl;
    if (url == null) return _defaultAvatar(cs);
    if (url.startsWith('http')) {
      return Image.network(url,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar(cs));
    }
    return Image.file(File(url),
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultAvatar(cs));
  }

  Widget _defaultAvatar(ColorScheme cs) {
    return Container(
      color: cs.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: avatarSize * 0.52,
          color: cs.primary,
        ),
      ),
    );
  }
}

