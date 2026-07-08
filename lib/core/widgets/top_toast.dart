import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

void showTopToast(BuildContext context, String message, {bool isError = false}) {
  final overlay = Overlay.of(context);
  
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return _TopToastWidget(
        message: message,
        isError: isError,
        isDark: isDark,
        onDismissComplete: () {
          entry.remove();
        },
      );
    },
  );

  overlay.insert(entry);
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isDark;
  final VoidCallback onDismissComplete;

  const _TopToastWidget({
    required this.message,
    required this.isError,
    required this.isDark,
    required this.onDismissComplete,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _yAnimation = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Start dismissing animation after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isError ? Colors.redAccent : AppColors.primary;
    final bgColor = widget.isDark 
        ? const Color(0xFF1E293B).withOpacity(0.95) // Sleek dark slate
        : Colors.white.withOpacity(0.95);
    final borderCol = widget.isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _yAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isError 
                        ? Icons.error_outline_rounded 
                        : Icons.check_circle_outline_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
