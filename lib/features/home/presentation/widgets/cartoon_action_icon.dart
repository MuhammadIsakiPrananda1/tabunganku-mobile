import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/constants/quick_action_type.dart';
import 'cartoon_vector_icons.dart';

/// Configuration for 2D Cartoon Action Icons
class CartoonActionConfig {
  final CartoonIconType cartoonType;
  final Color baseColor;

  const CartoonActionConfig({
    required this.cartoonType,
    required this.baseColor,
  });

  static CartoonActionConfig fromType(QuickActionType? type, bool isDarkMode) {
    switch (type) {
      case QuickActionType.income:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.income,
          baseColor: Color(0xFF10B981), // Emerald Mint
        );
      case QuickActionType.expense:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.expense,
          baseColor: Color(0xFFF43F5E), // Coral Pink / Red
        );
      case QuickActionType.budget:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.budget,
          baseColor: Color(0xFF0284C7), // Sky Cyan
        );
      case QuickActionType.debt:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.debt,
          baseColor: Color(0xFFF59E0B), // Honey Amber
        );
      case QuickActionType.nabungBersama:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.nabungBersama,
          baseColor: Color(0xFFEC4899), // Strawberry Pink
        );
      case QuickActionType.shoppingList:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.shoppingList,
          baseColor: Color(0xFF8B5CF6), // Grape Lavender
        );
      case QuickActionType.buyingTarget:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.buyingTarget,
          baseColor: Color(0xFF0D9488), // Oceanic Teal
        );
      case QuickActionType.challenge:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.challenge,
          baseColor: Color(0xFFF59E0B),
        );
      case QuickActionType.recurring:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.recurring,
          baseColor: Color(0xFF3B82F6),
        );
      case QuickActionType.zakat:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.zakat,
          baseColor: Color(0xFF0D9488),
        );
      case QuickActionType.simulator:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.simulator,
          baseColor: Color(0xFF06B6D4),
        );
      case QuickActionType.goldSavings:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.goldSavings,
          baseColor: Color(0xFFF59E0B),
        );
      case QuickActionType.savingPlans:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.savingPlans,
          baseColor: Color(0xFF10B981),
        );
      case QuickActionType.tax:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.tax,
          baseColor: Color(0xFFF97316),
        );
      case QuickActionType.bills:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.bills,
          baseColor: Color(0xFF0EA5E9),
        );
      case QuickActionType.investment:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.investment,
          baseColor: Color(0xFF6366F1),
        );
      case QuickActionType.insurance:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.insurance,
          baseColor: Color(0xFF64748B),
        );
      case null:
      default:
        return const CartoonActionConfig(
          cartoonType: CartoonIconType.more,
          baseColor: Color(0xFF6366F1), // Royal Indigo
        );
    }
  }
}

/// 2D Cartoon Action Button Widget with tactile arcade comic button feel and custom vector artwork
class CartoonActionButton extends StatefulWidget {
  final CartoonActionConfig config;
  final String label;
  final String? subLabel;
  final VoidCallback onTap;
  final bool isDarkMode;

  const CartoonActionButton({
    super.key,
    required this.config,
    required this.label,
    this.subLabel,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<CartoonActionButton> createState() => _CartoonActionButtonState();
}

class _CartoonActionButtonState extends State<CartoonActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final color = widget.config.baseColor;

    // Pastel candy pod background
    final bgColor = isDark
        ? color.withValues(alpha: 0.18)
        : HSLColor.fromColor(color).withLightness(0.95).withSaturation(0.70).toColor();

    // Bold 2D cartoon border
    final borderColor = isDark
        ? color.withValues(alpha: 0.50)
        : HSLColor.fromColor(color).withLightness(0.72).withSaturation(0.65).toColor();

    // 2D Comic Solid Shadow
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.50)
        : HSLColor.fromColor(color).withLightness(0.68).withSaturation(0.60).toColor();

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, _isPressed ? 2.5 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: borderColor,
                  width: 2.0,
                ),
                boxShadow: [
                  // Flat comic 2D bottom shadow (tactile button pop)
                  BoxShadow(
                    color: shadowColor,
                    offset: _isPressed ? const Offset(0, 1.0) : const Offset(0, 3.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: CartoonIconWidget(
                  type: widget.config.cartoonType,
                  size: 38,
                  isDarkMode: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF1E293B),
            ),
          ),
          if (widget.subLabel != null && widget.subLabel!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                widget.subLabel!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
