import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/notification_model.dart';
import 'package:tabunganku/providers/notification_provider.dart';

class NotificationSheet extends ConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              TextButton(
                onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
                child: const Text('Tandai Dibaca'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return _buildEmptyState(isDarkMode);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return _buildNotificationTile(context, ref, n, isDarkMode);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          if (notificationsAsync.hasValue && notificationsAsync.value!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ref.read(notificationNotifierProvider.notifier).clearAll(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.redAccent, width: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hapus Semua Riwayat'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, WidgetRef ref, NotificationModel n, bool isDarkMode) {
    IconData icon;
    Color color;

    switch (n.type) {
      case NotificationType.badge:
        icon = Icons.emoji_events_rounded;
        color = Colors.amber;
        break;
      case NotificationType.savings:
        icon = Icons.track_changes_rounded;
        color = AppColors.primary;
        break;
      case NotificationType.family:
        icon = Icons.family_restroom_rounded;
        color = Colors.blue;
        break;
      case NotificationType.system:
        icon = Icons.info_outline_rounded;
        color = Colors.teal;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!n.isRead) {
          ref.read(notificationNotifierProvider.notifier).markAsRead(n.id);
        }
        // TODO: Handle navigation based on type?
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead
              ? Colors.transparent
              : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: n.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(n.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDarkMode ? Colors.white24 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(n.timestamp),
                    style: TextStyle(
                      fontSize: 9,
                      color: isDarkMode ? Colors.white12 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
