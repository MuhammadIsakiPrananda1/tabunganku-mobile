import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeSlideController;
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Controller for initial entrance (fade and slide up)
    _fadeSlideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    // Logo animations (starts at 0.0, ends at 0.5)
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    // Text animations (starts at 0.3, ends at 0.8)
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _fadeSlideController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    // 2. Controller for continuous pulse effect on the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start entrance animation
    _fadeSlideController.forward();

    // Navigate to dashboard automatically after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _fadeSlideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background, // Selaras dengan Dashboard Mint Fresh
      body: Stack(
        children: [
          // Background Ornaments (Subtle geometric patterns for Mint Fresh)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Image Group
                SlideTransition(
                  position: _logoSlide,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              // Subtle Mint Glowing Pulse
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 40 * _pulseAnimation.value,
                                spreadRadius: 10 * _pulseAnimation.value,
                              ),
                            ],
                          ),
                          // Menggunakan logo asli
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              'assets/icon.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Animated Text Group
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        const Text(
                          'TabunganKu',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.primaryLight.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Pencatat Keuangan Cerdas',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading and version
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      strokeWidth: 3,
                      backgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'v1.4.1',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
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
}
