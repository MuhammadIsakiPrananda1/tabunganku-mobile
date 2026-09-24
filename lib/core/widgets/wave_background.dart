import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single Smooth & Calm Wave Background Widget
/// Menampilkan satu (1) gelombang minimalis dengan gerakan yang sangat pelan,
/// tenang, dan mulus (zen fluid motion), serta merespons pergeseran slide secara halus.
class AnimatedWaveBackground extends StatefulWidget {
  final PageController? pageController;
  final bool isDark;
  final double heightFraction; // Porsi tinggi layar yang diisi gelombang (0.0 - 1.0)
  final Alignment alignment; // Posisi gelombang (Alignment.bottomCenter atau Alignment.topCenter)

  const AnimatedWaveBackground({
    super.key,
    this.pageController,
    required this.isDark,
    this.heightFraction = 0.40,
    this.alignment = Alignment.bottomCenter,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Gerakan sangat pelan & santai (14 detik per putaran gelombang)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        // Ambil scroll progress dari PageController jika ada
        double scrollProgress = 0.0;
        if (widget.pageController != null &&
            widget.pageController!.hasClients &&
            widget.pageController!.position.haveDimensions) {
          scrollProgress = widget.pageController!.page ?? 0.0;
        }

        return CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            animationValue: _waveController.value,
            scrollOffset: scrollProgress,
            isDark: widget.isDark,
            heightFraction: widget.heightFraction,
            isBottom: widget.alignment == Alignment.bottomCenter,
          ),
        );
      },
    );
  }
}

typedef SingleWavePainter = WavePainter;

/// CustomPainter untuk menggambar TEPAT SATU (1) gelombang yang super halus & minimalis
class WavePainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;
  final bool isDark;
  final double heightFraction;
  final bool isBottom;

  WavePainter({
    required this.animationValue,
    required this.scrollOffset,
    required this.isDark,
    required this.heightFraction,
    required this.isBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseHeight = size.height * heightFraction;
    final baseY = isBottom ? size.height - baseHeight : baseHeight;

    // Parameter gelombang tunggal yang tenang & elegan
    const double amplitude = 20.0; // Ayunan gelombang lembut
    final double waveLength = size.width * 1.30; // Rentang gelombang lebar & rileks
    final double phaseShift = (animationValue * 2 * math.pi) + (scrollOffset * 1.2);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: isBottom ? Alignment.topCenter : Alignment.bottomCenter,
        end: isBottom ? Alignment.bottomCenter : Alignment.topCenter,
        colors: isDark
            ? [
                const Color(0xFF10B981).withValues(alpha: 0.22),
                const Color(0xFF0F766E).withValues(alpha: 0.08),
                const Color(0xFF0F172A).withValues(alpha: 0.02),
              ]
            : [
                const Color(0xFF10B981).withValues(alpha: 0.18),
                const Color(0xFF06B6D4).withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.0),
              ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();

    if (isBottom) {
      path.moveTo(0, size.height);
      path.lineTo(0, baseY);
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, baseY);
    }

    // Menggambar kontur kurva gelombang sinusoidal mulus dengan step halus
    final step = size.width / 50.0;
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY +
          math.sin((x / waveLength) * 2 * math.pi + phaseShift) * amplitude;
      path.lineTo(x, y);
    }

    if (isBottom) {
      path.lineTo(size.width, size.height);
    } else {
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Garis aksen tipis (stroke) di puncak gelombang untuk sentuhan modern & clean
    final strokePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: isDark
            ? [
                const Color(0xFF10B981).withValues(alpha: 0.15),
                const Color(0xFF34D399).withValues(alpha: 0.35),
                const Color(0xFF06B6D4).withValues(alpha: 0.15),
              ]
            : [
                const Color(0xFF10B981).withValues(alpha: 0.20),
                const Color(0xFF10B981).withValues(alpha: 0.40),
                const Color(0xFF06B6D4).withValues(alpha: 0.20),
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final linePath = Path();
    for (double x = 0; x <= size.width + step; x += step) {
      final y = baseY +
          math.sin((x / waveLength) * 2 * math.pi + phaseShift) * amplitude;
      if (x == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant SingleWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.isDark != isDark ||
        oldDelegate.heightFraction != heightFraction;
  }
}

/// Aksen gelombang minimalis untuk latar kartu (seperti Slider Target Tabungan)
class CardWavePainter extends CustomPainter {
  final Color waveColor;
  final double progress; // 0.0 - 1.0

  CardWavePainter({
    required this.waveColor,
    this.progress = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, h);
    path.lineTo(0, h * 0.74);
    path.cubicTo(
      w * 0.28,
      h * (0.64 - progress * 0.04),
      w * 0.65,
      h * (0.84 + progress * 0.03),
      w,
      h * 0.72,
    );
    path.lineTo(w, h);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardWavePainter oldDelegate) =>
      oldDelegate.waveColor != waveColor || oldDelegate.progress != progress;
}
