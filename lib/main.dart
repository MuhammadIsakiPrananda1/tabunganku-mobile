import 'dart:ui';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

/// Global instance agar bisa diakses dari mana saja
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Request permission untuk Android 13+
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inisialisasi notifikasi di level app (bukan di widget)
  await _initNotifications();
  
  // Inisialisasi locale data untuk DateFormat('...', 'id_ID')
  await initializeDateFormatting('id_ID', null);

  // Tangkap unhandled Flutter errors agar tidak force close diam-diam
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Tangkap error di luar Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true; // true = error sudah ditangani, jangan crash
  };

  runApp(
    const ProviderScope(
      child: TabunganKuApp(),
    ),
  );
}

class TabunganKuApp extends ConsumerWidget {
  const TabunganKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TabunganKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
