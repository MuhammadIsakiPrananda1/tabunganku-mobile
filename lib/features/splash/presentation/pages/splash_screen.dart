/// Page: SplashScreen
///
/// Layar pembuka aplikasi dan inisialisasi rute awal.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/services/currency_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const String _introKey = 'has_seen_onboarding_intro';

  bool _isCheckingStatus = true;
  bool _hasSeenIntro = false;

  // Onboarding Liquid Controller
  late final LiquidController _liquidController;
  int _currentPage = 0;

  // Splash Loading Animations
  late AnimationController _splashFadeController;
  late AnimationController _splashProgressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _liquidController = LiquidController();

    // Inisialisasi animasi Splash Loading yang tenang & elegan (Human-crafted)
    _splashFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.20, 0.85, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _splashFadeController,
        curve: const Interval(0.20, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _splashProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashProgressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _checkLaunchStatus();
  }

  Future<void> _checkLaunchStatus() async {
    ref.read(currencyRatesProvider);

    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_introKey) ?? false;

    if (mounted) {
      setState(() {
        _hasSeenIntro = hasSeen;
        _isCheckingStatus = false;
      });
    }

    if (hasSeen) {
      _splashFadeController.forward();
      _splashProgressController.forward();
      await _startAppLogic();
    }
  }

  Future<void> _startAppLogic() async {
    final minimumWait = Future.delayed(const Duration(milliseconds: 1700));

    bool isLoaded = false;
    while (!isLoaded && mounted) {
      final security = ref.read(securityProvider);
      if (security.isInitialized) {
        isLoaded = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    await minimumWait;

    if (!mounted) return;

    final security = ref.read(securityProvider);
    if (security.isBiometricEnabled || security.hasPin) {
      context.go('/lock');
    } else {
      context.go('/dashboard');
    }
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introKey, true);

    if (!mounted) return;

    setState(() {
      _hasSeenIntro = true;
    });

    _splashFadeController.forward(from: 0.0);
    _splashProgressController.forward(from: 0.0);
    await _startAppLogic();
  }

  @override
  void dispose() {
    _splashFadeController.dispose();
    _splashProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const SizedBox.shrink(),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _hasSeenIntro
          ? KeyedSubtree(
              key: const ValueKey('splash_loading'),
              child: _buildSplashLoadingScreen(
                context,
                isDark,
                bgColor,
                textColor,
                subtitleColor,
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('onboarding_slider'),
              child: _buildOnboardingSliderScreen(
                context,
                isDark,
                bgColor,
                textColor,
                subtitleColor,
              ),
            ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// 1. SPLASH SCREEN LOADING (Minimalist, Calm & Human-Crafted)
  /// ═══════════════════════════════════════════════════════════════════════
  Widget _buildSplashLoadingScreen(
    BuildContext context,
    bool isDark,
    Color bgColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final progressTrackColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final footerStudioColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final footerVersionColor =
        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Bagian Tengah: Ikon TabunganKu & Brand Typography
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ikon TabunganKu dengan Squircle & Soft Natural Shadow
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.04),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.40)
                                      : const Color(0xFF0F172A)
                                          .withValues(alpha: 0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: isDark ? 0.08 : 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Image.asset(
                                'assets/icon.webp',
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Brand Typography: Quicksand Font yang Proporsional
                      SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Tabungan',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                        color: textColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Ku',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kelola Finansial Lebih Tenang',
                                style: GoogleFonts.quicksand(
                                  color: subtitleColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bagian Bawah: Progress Bar Ramping & Footer Rapi
              FadeTransition(
                opacity: _contentFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minimalist Linear Progress Bar (Aksen Solid, Tidak Gradien Norak)
                      Container(
                        width: 120,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: progressTrackColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  _progressAnimation.value.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Studio Name
                      Text(
                        'NEVERLAND STUDIO',
                        style: GoogleFonts.quicksand(
                          color: footerStudioColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // App Version
                      Text(
                        'Versi ${AppVersion.fullVersion}',
                        style: GoogleFonts.quicksand(
                          color: footerVersionColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// 2. ONBOARDING SLIDER SCREEN (Smooth Native Slider + Mouse-Scroll Hand Swipe Hint)
  /// ═══════════════════════════════════════════════════════════════════════
  /// ═══════════════════════════════════════════════════════════════════════
  /// 2. ONBOARDING SLIDER SCREEN (Liquid Swipe ala Video Demo + Hand Swipe Handle)
  /// ═══════════════════════════════════════════════════════════════════════
  Widget _buildOnboardingSliderScreen(
    BuildContext context,
    bool isDark,
    Color bgColor,
    Color textColor,
    Color subtitleColor,
  ) {
    // Dynamic contrast colors based on current slide
    final isCurrentDark = _currentPage == 1 ? true : isDark;

    final pages = [
      _buildLiquidPage(
        isDark: isDark,
        bgColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        textColor: isDark ? Colors.white : const Color(0xFF0F172A),
        subtitleColor:
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        title: 'Target Tabungan,\nTerarah & Terukur',
        description:
            'Buat pos tabungan untuk setiap impianmu. Pantau perkembangannya setiap hari dengan target yang jelas dan realistis.',
        illustration: _buildSlide1Illustration(isDark),
        isLastPage: false,
      ),
      _buildLiquidPage(
        isDark: true,
        bgColor: isDark ? const Color(0xFF022C22) : const Color(0xFF0F172A),
        textColor: Colors.white,
        subtitleColor: const Color(0xFF94A3B8),
        title: 'Arus Kas Rapi,\nBebas Bocor Halus',
        description:
            'Ketahui ke mana setiap rupiah mengalir. Kelola anggaran bulanan secara bijak dan nikmati kontrol penuh atas uangmu.',
        illustration: _buildSlide2Illustration(true),
        isLastPage: false,
      ),
      _buildLiquidPage(
        isDark: isDark,
        bgColor: isDark ? const Color(0xFF064E3B) : Colors.white,
        textColor: isDark ? Colors.white : const Color(0xFF0F172A),
        subtitleColor:
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        title: 'Privat & Aman,\nHanya di HP-mu',
        description:
            'Data keuanganmu 100% tersimpan di perangkat lokal. Bebas iklan, tanpa pelacak, dan dilindungi enkripsi PIN serta biometrik.',
        illustration: _buildSlide3Illustration(isDark),
        isLastPage: true,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isCurrentDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isCurrentDark ? const Color(0xFF0F172A) : Colors.white,
        systemNavigationBarIconBrightness:
            isCurrentDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isCurrentDark ? const Color(0xFF0F172A) : Colors.white,
        body: Stack(
          children: [
            // Liquid Swipe Engine ala Video Demo
            LiquidSwipe(
              pages: pages,
              liquidController: _liquidController,
              onPageChangeCallback: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              waveType: WaveType.liquidReveal,
              enableSideReveal: false,
              slideIconWidget: null,
              enableLoop: false,
              fullTransitionValue: 880,
              ignoreUserGestureWhileAnimating: true,
            ),

            // Bottom Indicators (Pill Dots)
            Positioned(
              bottom: 22,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isSelected = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: isSelected ? 24 : 7,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isCurrentDark
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidPage({
    required bool isDark,
    required Color bgColor,
    required Color textColor,
    required Color subtitleColor,
    required String title,
    required String description,
    required Widget illustration,
    required bool isLastPage,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand Pill Glassmorphic & Tombol Lewati (Terintegrasi per slide)
            _buildTopBar(
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              isLastPage: isLastPage,
            ),
            const Spacer(flex: 1),

            // Visual Hero Illustration
            SizedBox(
              height: 230,
              child: Center(child: illustration),
            ),

            const Spacer(flex: 1),

            // Title (Centered bold)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.25,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle Description (Centered medium)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: subtitleColor,
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Bottom Action Area (Tepat di atas titik indikator, tidak berjejer)
            if (isLastPage)
              SizedBox(
                height: 52,
                child: Center(
                  child: _buildStartNowButton(isDark, textColor),
                ),
              )
            else
              _buildBottomSwipeHint(isDark),

            const SizedBox(height: 42), // Spacing for bottom dots
          ],
        ),
      ),
    );
  }

  /// Top Bar yang terintegrasi di setiap halaman slide (berubah warna seketika bersama sapuan gelombang)
  Widget _buildTopBar({
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required bool isLastPage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Pill Glassmorphic
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/icon.webp',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TabunganKu',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Lewati (Sebelum slide terakhir)
          if (!isLastPage)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _completeIntro,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Tulisan Petunjuk Swipe di Bagian Bawah (Hanya Teks, Tidak Bisa Diklik)
  Widget _buildBottomSwipeHint(bool isDark) {
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF475569);
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF64748B);

    return SizedBox(
      height: 52,
      child: Center(
        child: IgnorePointer(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Swipe ke kiri atau kanan',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tombol Mulai Sekarang (Hanya Teks dan Border, Terpusat di Atas Titik Indikator)
  Widget _buildStartNowButton(bool isDark, Color textColor) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF0F172A).withValues(alpha: 0.35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('start_button'),
        borderRadius: BorderRadius.circular(20),
        onTap: _completeIntro,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.3,
            ),
          ),
          child: Text(
            'Mulai Sekarang',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // Visual Slide 1: Stacked Goal Cards yang Keren & Realistis
  Widget _buildSlide1Illustration(bool isDark) {
    return SizedBox(
      width: 270,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Kartu Latar Belakang (Depth Effect)
          Positioned(
            top: 6,
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 240,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                      : const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
          ),

          // Kartu Utama (Target Tabungan)
          Container(
            width: 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : const Color(0xFF0F172A).withValues(alpha: 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Liburan ke Jepang',
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Target: Rp 15.000.000',
                              style: GoogleFonts.quicksand(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '78%',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Amount
                Text(
                  'Rp 11.700.000',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 7,
                    child: LinearProgressIndicator(
                      value: 0.78,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Micro Floating Badge (Streak Nabung)
          Positioned(
            bottom: 2,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+Rp 500.000 Terkumpul',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Visual Slide 2: Kartu Arus Kas & Anggaran Modern dengan Segmented Categories
  Widget _buildSlide2Illustration(bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa Anggaran Juni',
                style: GoogleFonts.quicksand(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hemat 35%',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rp 3.850.000',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 12),

          // Segmented Horizontal Category Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  Expanded(
                    flex: 45,
                    child: Container(color: AppColors.primary),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 30,
                    child: Container(color: const Color(0xFF6366F1)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 25,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mini Recent Transactions List
          _buildMiniTxRow(
            icon: Icons.coffee_rounded,
            title: 'Kopi Pagi',
            amount: '-Rp 25.000',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildMiniTxRow(
            icon: Icons.shopping_bag_outlined,
            title: 'Belanja Mingguan',
            amount: '-Rp 180.000',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTxRow({
    required IconData icon,
    required String title,
    required String amount,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.quicksand(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Visual Slide 3: Keamanan & Privasi Maksimal ala Apple Vault
  Widget _buildSlide3Illustration(bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Perisai Minimalis dengan Lingkaran Konsentris
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '100% Data Lokal & Privat',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tersimpan aman di memori perangkat Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Security Features Checklist
          _buildSecurityCheckItem(
            'Enkripsi PIN & Biometrik Cepat',
            isDark,
          ),
          const SizedBox(height: 6),
          _buildSecurityCheckItem(
            'Bebas Iklan & Tanpa Pelacak Data',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCheckItem(String label, bool isDark) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}




