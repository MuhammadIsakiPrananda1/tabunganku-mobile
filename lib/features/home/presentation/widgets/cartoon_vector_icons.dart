import 'package:flutter/material.dart';

enum CartoonIconType {
  income,
  expense,
  budget,
  debt,
  nabungBersama,
  shoppingList,
  buyingTarget,
  more,
  challenge,
  recurring,
  zakat,
  simulator,
  goldSavings,
  savingPlans,
  tax,
  bills,
  investment,
  insurance,
  travel,
  wedding,
  education,
  house,
  fire,
  ramadan,
  mosque,
  emergency,
  notes,
  health,
  splitBill,
  vault,
}

class _CartoonIconInfo {
  final IconData mainIcon;
  final Color color;

  const _CartoonIconInfo({
    required this.mainIcon,
    required this.color,
  });
}

_CartoonIconInfo _getCartoonIconData(CartoonIconType type) {
  switch (type) {
    case CartoonIconType.income:
      return const _CartoonIconInfo(
        mainIcon: Icons.payments_rounded,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.expense:
      return const _CartoonIconInfo(
        mainIcon: Icons.receipt_long_rounded,
        color: Color(0xFFF43F5E),
      );
    case CartoonIconType.budget:
      return const _CartoonIconInfo(
        mainIcon: Icons.pie_chart_rounded,
        color: Color(0xFF0284C7),
      );
    case CartoonIconType.debt:
      return const _CartoonIconInfo(
        mainIcon: Icons.handshake_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.nabungBersama:
      return const _CartoonIconInfo(
        mainIcon: Icons.savings_rounded,
        color: Color(0xFFEC4899),
      );
    case CartoonIconType.shoppingList:
      return const _CartoonIconInfo(
        mainIcon: Icons.shopping_bag_rounded,
        color: Color(0xFF8B5CF6),
      );
    case CartoonIconType.buyingTarget:
      return const _CartoonIconInfo(
        mainIcon: Icons.track_changes_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.more:
      return const _CartoonIconInfo(
        mainIcon: Icons.grid_view_rounded,
        color: Color(0xFF6366F1),
      );
    case CartoonIconType.challenge:
      return const _CartoonIconInfo(
        mainIcon: Icons.emoji_events_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.recurring:
      return const _CartoonIconInfo(
        mainIcon: Icons.published_with_changes_rounded,
        color: Color(0xFF3B82F6),
      );
    case CartoonIconType.zakat:
      return const _CartoonIconInfo(
        mainIcon: Icons.volunteer_activism_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.simulator:
      return const _CartoonIconInfo(
        mainIcon: Icons.calculate_rounded,
        color: Color(0xFF06B6D4),
      );
    case CartoonIconType.goldSavings:
      return const _CartoonIconInfo(
        mainIcon: Icons.workspace_premium_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.savingPlans:
      return const _CartoonIconInfo(
        mainIcon: Icons.flag_rounded,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.tax:
      return const _CartoonIconInfo(
        mainIcon: Icons.receipt_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.bills:
      return const _CartoonIconInfo(
        mainIcon: Icons.bolt_rounded,
        color: Color(0xFF0EA5E9),
      );
    case CartoonIconType.investment:
      return const _CartoonIconInfo(
        mainIcon: Icons.trending_up_rounded,
        color: Color(0xFF6366F1),
      );
    case CartoonIconType.insurance:
      return const _CartoonIconInfo(
        mainIcon: Icons.shield_rounded,
        color: Color(0xFF64748B),
      );
    case CartoonIconType.travel:
      return const _CartoonIconInfo(
        mainIcon: Icons.flight_takeoff_rounded,
        color: Color(0xFF8B5CF6),
      );
    case CartoonIconType.wedding:
      return const _CartoonIconInfo(
        mainIcon: Icons.favorite_rounded,
        color: Color(0xFFEC4899),
      );
    case CartoonIconType.education:
      return const _CartoonIconInfo(
        mainIcon: Icons.school_rounded,
        color: Color(0xFF0284C7),
      );
    case CartoonIconType.house:
      return const _CartoonIconInfo(
        mainIcon: Icons.home_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.fire:
      return const _CartoonIconInfo(
        mainIcon: Icons.local_fire_department_rounded,
        color: Color(0xFFEF4444),
      );
    case CartoonIconType.ramadan:
      return const _CartoonIconInfo(
        mainIcon: Icons.nightlight_round,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.mosque:
      return const _CartoonIconInfo(
        mainIcon: Icons.mosque_rounded,
        color: Color(0xFF059669),
      );
    case CartoonIconType.emergency:
      return const _CartoonIconInfo(
        mainIcon: Icons.medical_services_rounded,
        color: Color(0xFFEF4444),
      );
    case CartoonIconType.notes:
      return const _CartoonIconInfo(
        mainIcon: Icons.edit_note_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.health:
      return const _CartoonIconInfo(
        mainIcon: Icons.healing_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.splitBill:
      return const _CartoonIconInfo(
        mainIcon: Icons.call_split_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.vault:
      return const _CartoonIconInfo(
        mainIcon: Icons.lock_rounded,
        color: Color(0xFF64748B),
      );
  }
}

/// Clean & Cute Action Icon Widget with soft cushion depth and crystal-clear iconography
class CartoonIconWidget extends StatelessWidget {
  final CartoonIconType type;
  final double size;
  final bool isDarkMode;

  const CartoonIconWidget({
    super.key,
    required this.type,
    this.size = 35,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final info = _getCartoonIconData(type);
    final color = info.color;

    final iconColor = isDarkMode
        ? HSLColor.fromColor(color).withLightness(0.78).withSaturation(0.85).toColor()
        : HSLColor.fromColor(color).withLightness(0.38).withSaturation(0.85).toColor();

    final cushionColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.72);

    final cushionBorder = isDarkMode
        ? color.withValues(alpha: 0.22)
        : color.withValues(alpha: 0.15);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cushionColor,
        border: Border.all(
          color: cushionBorder,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          info.mainIcon,
          size: size * 0.60,
          color: iconColor,
        ),
      ),
    );
  }
}
