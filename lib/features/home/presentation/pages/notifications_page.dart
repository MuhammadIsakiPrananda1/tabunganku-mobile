/// Page: NotificationsPage
///
/// Pusat notifikasi in-app dan pengingat keuangan.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/notification_model.dart';
import 'package:tabunganku/providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationNotifierProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
            size: 18,
          ),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) {
              if (notifications.isEmpty) return const SizedBox.shrink();
              final hasUnread = notifications.any((n) => !n.isRead);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnread)
                    TextButton(
                      onPressed: () => ref
                          .read(notificationNotifierProvider.notifier)
                          .markAllAsRead(),
                      child: Text(
                        'Tandai Dibaca',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () =>
                        _confirmClearAll(context, ref, isDarkMode),
                    tooltip: 'Hapus Semua',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(isDarkMode);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return _buildNotificationTile(context, ref, n, isDarkMode);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: GoogleFonts.quicksand(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Semua Notifikasi?',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Semua riwayat notifikasi akan dihapus secara permanen.',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationNotifierProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 52,
                color: isDarkMode
                    ? Colors.white38
                    : AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Notifikasi',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Semua kabar dan aktivitas terbaru akan muncul di sini',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref,
      NotificationModel n, bool isDarkMode) {
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
      case NotificationType.system:
        icon = Icons.info_outline_rounded;
        color = Colors.teal;
        break;
      case NotificationType.bills:
        icon = Icons.receipt_long_rounded;
        color = Colors.redAccent;
        break;
      case NotificationType.investment:
        icon = Icons.trending_up_rounded;
        color = Colors.indigo;
        break;
      case NotificationType.tax:
        icon = Icons.account_balance_rounded;
        color = Colors.deepPurpleAccent;
        break;
      case NotificationType.recurring:
        icon = Icons.loop_rounded;
        color = Colors.teal;
        break;
      case NotificationType.healthCheck:
        icon = Icons.health_and_safety_rounded;
        color = Colors.green;
        break;
      case NotificationType.gold:
        icon = Icons.monetization_on_rounded;
        color = Colors.amber.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: n.isRead
            ? (isDarkMode
                ? const Color(0xFF161D26)
                : Colors.white)
            : (isDarkMode
                ? AppColors.primary.withValues(alpha: 0.10)
                : const Color(0xFFF0FDF4)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: n.isRead
              ? (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFE2E8F0))
              : AppColors.primary.withValues(alpha: 0.22),
          width: 1,
        ),
        boxShadow: n.isRead
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!n.isRead) {
              ref.read(notificationNotifierProvider.notifier).markAsRead(n.id);
            }
            _showNotificationDetail(context, ref, n, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDarkMode ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
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
                              style: GoogleFonts.quicksand(
                                fontWeight:
                                    n.isRead ? FontWeight.w600 : FontWeight.w700,
                                fontSize: 13.5,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(n.timestamp),
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: isDarkMode
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(n.timestamp),
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              color: isDarkMode
                                  ? Colors.white24
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!n.isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Baru',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: isDarkMode
                                    ? Colors.white24
                                    : const Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, WidgetRef ref,
      NotificationModel n, bool isDarkMode) {
    IconData icon;
    Color color;
    String categoryName;

    switch (n.type) {
      case NotificationType.badge:
        icon = Icons.emoji_events_rounded;
        color = Colors.amber;
        categoryName = 'Pencapaian 🏅';
        break;
      case NotificationType.savings:
        icon = Icons.track_changes_rounded;
        color = AppColors.primary;
        categoryName = 'Target Tabungan 🎯';
        break;
      case NotificationType.system:
        icon = Icons.info_outline_rounded;
        color = Colors.teal;
        categoryName = 'Informasi Sistem ℹ️';
        break;
      case NotificationType.bills:
        icon = Icons.receipt_long_rounded;
        color = Colors.redAccent;
        categoryName = 'Tagihan Rutin 🧾';
        break;
      case NotificationType.investment:
        icon = Icons.trending_up_rounded;
        color = Colors.indigo;
        categoryName = 'Investasi 📈';
        break;
      case NotificationType.tax:
        icon = Icons.account_balance_rounded;
        color = Colors.deepPurpleAccent;
        categoryName = 'Pajak & Keuangan 🏛️';
        break;
      case NotificationType.recurring:
        icon = Icons.loop_rounded;
        color = Colors.teal;
        categoryName = 'Transaksi Rutin 🔄';
        break;
      case NotificationType.healthCheck:
        icon = Icons.health_and_safety_rounded;
        color = Colors.green;
        categoryName = 'Kesehatan Finansial 🩺';
        break;
      case NotificationType.gold:
        icon = Icons.monetization_on_rounded;
        color = Colors.amber.shade700;
        categoryName = 'Tabungan Emas 🪙';
        break;
    }

    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24 + MediaQuery.of(ctx).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header: Category badge + Delete button + Close button
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDarkMode ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          categoryName,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .deleteNotification(n.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notifikasi dihapus',
                            style: GoogleFonts.quicksand(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Hapus Notifikasi',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: isDarkMode
                          ? Colors.red.shade300
                          : Colors.red.shade400,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    tooltip: 'Tutup',
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDarkMode
                          ? Colors.white54
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Notification Title
              Text(
                n.title,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              // Date & Time
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: isDarkMode
                        ? Colors.white38
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(n.timestamp),
                    style: GoogleFonts.quicksand(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white38
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDarkMode ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Telah Dibaca',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Message Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF161D26)
                      : const Color(0xFFF1F5F9).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: SelectableText(
                  n.message,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.90)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Close / OK Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

