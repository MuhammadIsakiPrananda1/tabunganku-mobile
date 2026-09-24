/// Shared PIN Keypad Widget
///
/// Widget numerik keypad yang dipakai bersama oleh [LockScreen] dan
/// [PinSetupPage]. Menggantikan duplikasi `_ResponsiveKeypadButton` yang
/// sebelumnya ada di kedua file tersebut.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PinKeypad — full numeric keypad layout
// ─────────────────────────────────────────────────────────────────────────────

/// Widget keypad angka 0–9 lengkap dengan tombol biometrik (opsional) dan
/// tombol backspace.
///
/// Gunakan [onNumber] untuk menangani input angka dan [onBackspace] untuk
/// menghapus digit terakhir. Jika [showBiometric] = true, tampilkan tombol
/// fingerprint dan panggil [onBiometric] ketika ditekan.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.buttonSize,
    required this.rowSpacing,
    required this.onNumber,
    required this.onBackspace,
    this.showBiometric = false,
    this.onBiometric,
  });

  /// Ukuran diameter setiap tombol keypad (px).
  final double buttonSize;

  /// Jarak vertikal antar baris tombol (px).
  final double rowSpacing;

  /// Callback ketika tombol angka ditekan. Parameter adalah karakter angka
  /// ('0'–'9').
  final ValueChanged<String> onNumber;

  /// Callback ketika tombol backspace ditekan.
  final VoidCallback onBackspace;

  /// Tampilkan tombol fingerprint di posisi kiri bawah.
  final bool showBiometric;

  /// Callback ketika tombol fingerprint ditekan. Wajib diisi jika
  /// [showBiometric] = true.
  final VoidCallback? onBiometric;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Padding(
            padding: EdgeInsets.symmetric(vertical: rowSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final digit in row)
                  _numberButton(digit, colorScheme, isDark),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: rowSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showBiometric)
                _iconButton(
                  Icons.fingerprint_rounded,
                  onBiometric ?? () {},
                  colorScheme,
                  isDark,
                )
              else
                SizedBox(width: buttonSize, height: buttonSize),
              _numberButton('0', colorScheme, isDark),
              _iconButton(
                Icons.backspace_outlined,
                onBackspace,
                colorScheme,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numberButton(String digit, ColorScheme cs, bool isDark) {
    return PinKeypadButton(
      size: buttonSize,
      onTap: () => onNumber(digit),
      backgroundColor: cs.surface,
      activeBackgroundColor:
          AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.22),
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.05),
      activeBorderColor: AppColors.primary,
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      child: Text(
        digit,
        style: GoogleFonts.quicksand(
          fontSize: (buttonSize * 0.36).clamp(18.0, 24.0),
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
    ColorScheme cs,
    bool isDark,
  ) {
    return PinKeypadButton(
      size: buttonSize,
      onTap: onTap,
      backgroundColor: cs.surface,
      activeBackgroundColor:
          AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.22),
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.05),
      activeBorderColor: AppColors.primary,
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      child: Icon(
        icon,
        color: AppColors.primary,
        size: (buttonSize * 0.4).clamp(20.0, 28.0),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PinDots — indikator digit PIN yang sudah diisi
// ─────────────────────────────────────────────────────────────────────────────

/// Baris empat titik yang menunjukkan berapa digit PIN yang sudah dimasukkan.
///
/// [filledCount] adalah jumlah digit yang sudah diisi (0–4). [shakeAnimation]
/// adalah controller animasi getar ketika PIN salah — boleh null jika tidak
/// diperlukan.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.filledCount,
    required this.dotSize,
    this.shakeAnimation,
  });

  final int filledCount;
  final double dotSize;

  /// AnimationController untuk animasi shake. Jika null, dots ditampilkan
  /// statis tanpa animasi.
  final AnimationController? shakeAnimation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dots = _buildRow(cs);

    if (shakeAnimation == null) return dots;

    return AnimatedBuilder(
      animation: shakeAnimation!,
      builder: (context, _) {
        final offset =
            Curves.elasticIn.transform(shakeAnimation!.value) * 10;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: dots,
        );
      },
    );
  }

  Widget _buildRow(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: dotSize < 14 ? 8 : 12),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                active ? cs.primary : cs.primary.withValues(alpha: 0.15),
            border: Border.all(
              color: active
                  ? cs.primary
                  : cs.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PinKeypadButton — tombol individual dengan animasi tekan
// ─────────────────────────────────────────────────────────────────────────────

/// Tombol bulat dengan efek tekan: scale bounce, glowing border, haptic
/// feedback, dan InkWell ripple.
///
/// Digunakan oleh [PinKeypad] secara internal, namun bisa dipakai langsung
/// jika diperlukan.
class PinKeypadButton extends StatefulWidget {
  const PinKeypadButton({
    super.key,
    required this.child,
    required this.size,
    required this.onTap,
    required this.backgroundColor,
    required this.activeBackgroundColor,
    required this.borderColor,
    required this.activeBorderColor,
    this.shadows,
  });

  final Widget child;
  final double size;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color activeBackgroundColor;
  final Color borderColor;
  final Color activeBorderColor;
  final List<BoxShadow>? shadows;

  @override
  State<PinKeypadButton> createState() => _PinKeypadButtonState();
}

class _PinKeypadButtonState extends State<PinKeypadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.84).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    // Jeda 90 ms agar animasi mengecil terlihat jelas sebelum membal balik.
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) _controller.reverse();
    });
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _controller.value;
        final bg =
            Color.lerp(widget.backgroundColor, widget.activeBackgroundColor, p)!;
        final border =
            Color.lerp(widget.borderColor, widget.activeBorderColor, p)!;
        final borderWidth = 1.2 + (p * 1.3);

        return Transform.scale(
          scale: _scale.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
              border: Border.all(color: border, width: borderWidth),
              boxShadow: [
                if (widget.shadows != null) ...widget.shadows!,
                if (p > 0.05)
                  BoxShadow(
                    color: widget.activeBorderColor.withValues(alpha: 0.45 * p),
                    blurRadius: 14 * p,
                    spreadRadius: 2 * p,
                  ),
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  splashColor:
                      widget.activeBorderColor.withValues(alpha: 0.35),
                  highlightColor:
                      widget.activeBorderColor.withValues(alpha: 0.20),
                  child: Center(child: widget.child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
