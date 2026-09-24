/// Entry point aplikasi TabunganKu.
///
/// Urutan inisialisasi:
///   1. [_AppInitializer.run] — timezone, notifikasi, error handler, locale
///   2. [SharedPreferences] — baca preferensi awal (balance visibility)
///   3. [runApp] dengan [ProviderScope] + override provider awal
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/notification_observer.dart';
import 'features/auth/presentation/pages/lock_screen.dart';
import 'features/settings/presentation/providers/security_provider.dart';
import 'providers/balance_visibility_provider.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Singleton plugin (diakses oleh NotificationService)
// ─────────────────────────────────────────────────────────────────────────────

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host.contains('neverlandstudio.my.id') ||
            host.contains('localhost') ||
            host.contains('10.0.2.2') ||
            host.contains('127.0.0.1');
      };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nonaktifkan fetch font runtime — pakai font lokal dari assets
  GoogleFonts.config.allowRuntimeFetching = false;

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await _AppInitializer.run();

  final prefs = await SharedPreferences.getInstance();
  final initialShowBalance = prefs.getBool('pref_show_balance') ?? true;

  runApp(
    ProviderScope(
      overrides: [
        balanceVisibilityProvider.overrideWith(
          (ref) => BalanceVisibilityNotifier(initialShowBalance),
        ),
      ],
      child: const TabunganKuApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppInitializer
// ─────────────────────────────────────────────────────────────────────────────

/// Mengurus semua inisialisasi sebelum [runApp] dipanggil.
///
/// Dipisahkan ke class sendiri agar mudah di-test dan di-trace ketika ada
/// masalah pada startup sequence.
class _AppInitializer {
  const _AppInitializer._();

  static Future<void> run() async {
    // Terapkan HttpOverrides untuk mencegah HandshakeException pada Android/Cloudflare
    HttpOverrides.global = _AppHttpOverrides();

    await Future.wait([
      _initTimezone(),
      _initNotifications(),
      initializeDateFormatting('id_ID', null),
    ]);
    _setupErrorHandlers();
  }

  // ── Timezone ───────────────────────────────────────────────────────────────

  static Future<void> _initTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final dynamic location = await FlutterTimezone.getLocalTimezone();
      final String locationName = location is String
          ? location
          : (location as dynamic).identifier.toString();
      tz.setLocalLocation(tz.getLocation(locationName));
      debugPrint('Timezone: $locationName');
    } catch (e) {
      debugPrint('Gagal detect timezone: $e — fallback ke Asia/Jakarta');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {
        debugPrint('Fallback Asia/Jakarta gagal — pakai UTC');
      }
    }
  }

  // ── Local Notifications ────────────────────────────────────────────────────

  static Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _setupAndroidNotificationChannel();
  }

  static Future<void> _setupAndroidNotificationChannel() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

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

    // Re-create channel untuk memastikan config terbaru diterapkan
    await androidPlugin.deleteNotificationChannel(channel.id);
    await androidPlugin.createNotificationChannel(channel);
    debugPrint('NotificationChannel re-created: ${channel.id}');
  }

  // ── Error Handlers ─────────────────────────────────────────────────────────

  static void _setupErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Unhandled error: $error\n$stack');
      return true;
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TabunganKuApp
// ─────────────────────────────────────────────────────────────────────────────

class TabunganKuApp extends ConsumerStatefulWidget {
  const TabunganKuApp({super.key});

  @override
  ConsumerState<TabunganKuApp> createState() => _TabunganKuAppState();
}

class _TabunganKuAppState extends ConsumerState<TabunganKuApp>
    with WidgetsBindingObserver {
  // ── Lifecycle ──────────────────────────────────────────────────────────────

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = _resolveIsDark(themeMode, context);

    _applySystemUiOverlay(isDark);

    return NotificationObserver(
      child: MaterialApp.router(
        title: 'TabunganKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: appRouter,
        builder: (context, child) => _appBuilder(context, child, themeMode),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _resolveIsDark(ThemeMode themeMode, BuildContext context) {
    return themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
  }

  void _applySystemUiOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  /// Builder yang membungkus child router dengan SafeArea, dismiss keyboard,
  /// dan lapisan LockScreen jika sesi belum terautentikasi.
  Widget _appBuilder(
    BuildContext context,
    Widget? child,
    ThemeMode themeMode,
  ) {
    final isDark = _resolveIsDark(themeMode, context);

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: SafeArea(
        top: false,
        bottom: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Consumer(
            builder: (context, ref, _) {
              final security = ref.watch(securityProvider);
              final router = ref.watch(appRouterProvider);

              final shouldLock = _shouldShowLockScreen(security, router);
              if (shouldLock) {
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
        ),
      ),
    );
  }

  /// Tentukan apakah LockScreen perlu ditampilkan berdasarkan state keamanan
  /// dan route saat ini.
  bool _shouldShowLockScreen(SecurityState security, GoRouter router) {
    if (!security.hasPin && !security.isBiometricEnabled) return false;
    if (security.isAuthorized) return false;

    String location = '/';
    try {
      location = router.routerDelegate.currentConfiguration.fullPath;
    } catch (_) {}

    const lockableExclusions = {'/', '/splash', '/pin-setup', '/lock'};
    return !lockableExclusions.contains(location);
  }
}
