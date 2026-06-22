import 'dart:ui';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'features/settings/presentation/providers/security_provider.dart';
import 'features/auth/presentation/pages/lock_screen.dart';
import 'core/widgets/notification_observer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {

    await androidPlugin.requestNotificationsPermission();

const channel = AndroidNotificationChannel(
      'tabunganku_activity',
      'Aktivitas TabunganKu',
      description: 'Notifikasi untuk pencapaian dan aktivitas menabung',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

await androidPlugin.deleteNotificationChannel(channel.id);

    await androidPlugin.createNotificationChannel(channel);
    debugPrint('NotificationChannel re-created: ${channel.id}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

try {
    tz_data.initializeTimeZones();
    final dynamic location = await FlutterTimezone.getLocalTimezone();

    final String locationName = location is String
        ? location
        : (location as dynamic).identifier.toString();
    tz.setLocalLocation(tz.getLocation(locationName));
    debugPrint('Timezone set to: $locationName');
  } catch (e) {
    debugPrint(
        'Gagal mendeteksi timezone otomatis: $e. Menggunakan Asia/Jakarta sebagai default.');
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      debugPrint('Fallback Asia/Jakarta juga gagal. Menggunakan UTC.');
    }
  }

await _initNotifications();

await initializeDateFormatting('id_ID', null);

FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };

  runApp(
    const ProviderScope(
      child: TabunganKuApp(),
    ),
  );
}

class TabunganKuApp extends ConsumerStatefulWidget {
  const TabunganKuApp({super.key});

  @override
  ConsumerState<TabunganKuApp> createState() => _TabunganKuAppState();
}

class _TabunganKuAppState extends ConsumerState<TabunganKuApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return NotificationObserver(
      child: MaterialApp.router(
        title: 'TabunganKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: appRouter,
        builder: (context, child) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Consumer(
              builder: (context, ref, _) {
                final security = ref.watch(securityProvider);
                final router = ref.watch(appRouterProvider);

String location = '/';
                try {
                  location =
                      router.routerDelegate.currentConfiguration.fullPath;
                } catch (_) {}

                final isLockableRoute = location != '/' &&
                    location != '/splash' &&
                    location != '/pin-setup' &&
                    location != '/lock';

                final isSecurityEnabled =
                    security.hasPin || security.isBiometricEnabled;

                if (isSecurityEnabled &&
                    !security.isAuthorized &&
                    isLockableRoute) {
                  return Stack(
                    children: [
                      if (child != null) child,
                      const LockScreen(),
                    ],
                  );
                }
                return child ?? const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}
