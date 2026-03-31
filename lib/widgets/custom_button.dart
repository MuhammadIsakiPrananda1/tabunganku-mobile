import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLoading ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? Colors.grey.shade400
                : (widget.isSecondary ? Colors.white : const Color(0xFF6366E1)),
            borderRadius: BorderRadius.circular(8),
            border: widget.isSecondary
                ? Border.all(color: const Color(0xFF6366E1), width: 1.5)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isSecondary ? const Color(0xFF6366E1) : Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isSecondary ? const Color(0xFF6366E1) : Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
