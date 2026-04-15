import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/main.dart';

class NotificationService {
  Future<void> showAchievementNotification(String title, String description) async {
    const androidDetails = AndroidNotificationDetails(
      'achievement_channel_v2',
      'Pencapaian Baru',
      channelDescription: 'Notifikasi saat mendapatkan pencapaian baru',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await flutterLocalNotificationsPlugin.show(
      title.hashCode,
      'Pencapaian Baru Terbuka! 🎉',
      '$title: $description',
      notificationDetails,
    );
  }

  Future<void> showTargetReachedNotification(String targetName, String amount) async {
    const androidDetails = AndroidNotificationDetails(
      'target_reached_channel_v2',
      'Target Tercapai',
      channelDescription: 'Notifikasi saat target tabungan terpenuhi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await flutterLocalNotificationsPlugin.show(
      targetName.hashCode,
      'Target Tabungan Tercapai! 💰',
      'Selamat! Target "$targetName" senilai $amount telah terpenuhi.',
      notificationDetails,
    );
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService());
