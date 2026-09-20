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
  final IconData badgeIcon;
  final Color color;

  const _CartoonIconInfo({
    required this.mainIcon,
    required this.badgeIcon,
    required this.color,
  });
}

_CartoonIconInfo _getCartoonIconData(CartoonIconType type) {
  switch (type) {
    case CartoonIconType.income:
      return const _CartoonIconInfo(
        mainIcon: Icons.payments_rounded,
        badgeIcon: Icons.add_rounded,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.expense:
      return const _CartoonIconInfo(
        mainIcon: Icons.receipt_long_rounded,
        badgeIcon: Icons.remove_rounded,
        color: Color(0xFFF43F5E),
      );
    case CartoonIconType.budget:
      return const _CartoonIconInfo(
        mainIcon: Icons.pie_chart_rounded,
        badgeIcon: Icons.tune_rounded,
        color: Color(0xFF0284C7),
      );
    case CartoonIconType.debt:
      return const _CartoonIconInfo(
        mainIcon: Icons.handshake_rounded,
        badgeIcon: Icons.credit_card_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.nabungBersama:
      return const _CartoonIconInfo(
        mainIcon: Icons.groups_rounded,
        badgeIcon: Icons.savings_rounded,
        color: Color(0xFFEC4899),
      );
    case CartoonIconType.shoppingList:
      return const _CartoonIconInfo(
        mainIcon: Icons.shopping_cart_rounded,
        badgeIcon: Icons.checklist_rounded,
        color: Color(0xFF8B5CF6),
      );
    case CartoonIconType.buyingTarget:
      return const _CartoonIconInfo(
        mainIcon: Icons.track_changes_rounded,
        badgeIcon: Icons.emoji_events_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.more:
      return const _CartoonIconInfo(
        mainIcon: Icons.grid_view_rounded,
        badgeIcon: Icons.auto_awesome_rounded,
        color: Color(0xFF6366F1),
      );
    case CartoonIconType.challenge:
      return const _CartoonIconInfo(
        mainIcon: Icons.emoji_events_rounded,
        badgeIcon: Icons.star_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.recurring:
      return const _CartoonIconInfo(
        mainIcon: Icons.published_with_changes_rounded,
        badgeIcon: Icons.alarm_rounded,
        color: Color(0xFF3B82F6),
      );
    case CartoonIconType.zakat:
      return const _CartoonIconInfo(
        mainIcon: Icons.volunteer_activism_rounded,
        badgeIcon: Icons.favorite_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.simulator:
      return const _CartoonIconInfo(
        mainIcon: Icons.calculate_rounded,
        badgeIcon: Icons.trending_up_rounded,
        color: Color(0xFF06B6D4),
      );
    case CartoonIconType.goldSavings:
      return const _CartoonIconInfo(
        mainIcon: Icons.workspace_premium_rounded,
        badgeIcon: Icons.star_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.savingPlans:
      return const _CartoonIconInfo(
        mainIcon: Icons.savings_rounded,
        badgeIcon: Icons.flag_rounded,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.tax:
      return const _CartoonIconInfo(
        mainIcon: Icons.receipt_rounded,
        badgeIcon: Icons.percent_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.bills:
      return const _CartoonIconInfo(
        mainIcon: Icons.receipt_long_rounded,
        badgeIcon: Icons.bolt_rounded,
        color: Color(0xFF0EA5E9),
      );
    case CartoonIconType.investment:
      return const _CartoonIconInfo(
        mainIcon: Icons.trending_up_rounded,
        badgeIcon: Icons.show_chart_rounded,
        color: Color(0xFF6366F1),
      );
    case CartoonIconType.insurance:
      return const _CartoonIconInfo(
        mainIcon: Icons.shield_rounded,
        badgeIcon: Icons.health_and_safety_rounded,
        color: Color(0xFF64748B),
      );
    case CartoonIconType.travel:
      return const _CartoonIconInfo(
        mainIcon: Icons.flight_takeoff_rounded,
        badgeIcon: Icons.explore_rounded,
        color: Color(0xFF8B5CF6),
      );
    case CartoonIconType.wedding:
      return const _CartoonIconInfo(
        mainIcon: Icons.favorite_rounded,
        badgeIcon: Icons.auto_awesome_rounded,
        color: Color(0xFFEC4899),
      );
    case CartoonIconType.education:
      return const _CartoonIconInfo(
        mainIcon: Icons.school_rounded,
        badgeIcon: Icons.star_rounded,
        color: Color(0xFF0284C7),
      );
    case CartoonIconType.house:
      return const _CartoonIconInfo(
        mainIcon: Icons.home_rounded,
        badgeIcon: Icons.key_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.fire:
      return const _CartoonIconInfo(
        mainIcon: Icons.local_fire_department_rounded,
        badgeIcon: Icons.bolt_rounded,
        color: Color(0xFFEF4444),
      );
    case CartoonIconType.ramadan:
      return const _CartoonIconInfo(
        mainIcon: Icons.nightlight_round,
        badgeIcon: Icons.star_rounded,
        color: Color(0xFF10B981),
      );
    case CartoonIconType.mosque:
      return const _CartoonIconInfo(
        mainIcon: Icons.mosque_rounded,
        badgeIcon: Icons.star_rounded,
        color: Color(0xFF059669),
      );
    case CartoonIconType.emergency:
      return const _CartoonIconInfo(
        mainIcon: Icons.health_and_safety_rounded,
        badgeIcon: Icons.shield_rounded,
        color: Color(0xFFEF4444),
      );
    case CartoonIconType.notes:
      return const _CartoonIconInfo(
        mainIcon: Icons.edit_note_rounded,
        badgeIcon: Icons.bookmark_rounded,
        color: Color(0xFFF59E0B),
      );
    case CartoonIconType.health:
      return const _CartoonIconInfo(
        mainIcon: Icons.medical_services_rounded,
        badgeIcon: Icons.favorite_rounded,
        color: Color(0xFF0D9488),
      );
    case CartoonIconType.splitBill:
      return const _CartoonIconInfo(
        mainIcon: Icons.call_split_rounded,
        badgeIcon: Icons.people_rounded,
        color: Color(0xFFF97316),
      );
    case CartoonIconType.vault:
      return const _CartoonIconInfo(
        mainIcon: Icons.lock_rounded,
        badgeIcon: Icons.security_rounded,
        color: Color(0xFF64748B),
      );
  }
}

/// 2D Cartoon Icon Widget with high-clarity recognizable iconography and cute cartoon sticker badge
class CartoonIconWidget extends StatelessWidget {
  final CartoonIconType type;
  final double size;
  final bool isDarkMode;

  const CartoonIconWidget({
    super.key,
    required this.type,
    this.size = 38,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final info = _getCartoonIconData(type);
    final color = info.color;

    final iconColor = isDarkMode
        ? HSLColor.fromColor(color).withLightness(0.82).withSaturation(0.85).toColor()
        : HSLColor.fromColor(color).withLightness(0.38).withSaturation(0.85).toColor();

    final badgeBg = color;

    final bubbleColor = isDarkMode
        ? color.withValues(alpha: 0.16)
        : color.withValues(alpha: 0.18);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Soft cartoon backdrop circle bubble
          Container(
            width: size * 0.74,
            height: size * 0.74,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
            ),
          ),

          // Primary crystal-clear vector icon
          Icon(
            info.mainIcon,
            size: size * 0.62,
            color: iconColor,
          ),

          // Cute 2D cartoon corner sticker badge
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: size * 0.42,
              height: size * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeBg,
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    offset: const Offset(0, 1.2),
                    blurRadius: 1.5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  info.badgeIcon,
                  size: size * 0.23,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
