import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabunganku/core/services/permission_service.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/main.dart' show flutterLocalNotificationsPlugin;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/achievement_provider.dart';
import 'package:tabunganku/providers/budget_provider.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/features/settings/presentation/pages/crop_page.dart';
import 'package:tabunganku/core/services/export_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isUploadingPhoto = false;
  String? _uploadError;
  bool _dailyReminder = false;
  String _defaultCurrency = 'IDR';
  String _reminderTime = '19:00';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('pref_daily_reminder') ?? false;
      _defaultCurrency = prefs.getString('pref_default_currency') ?? 'IDR';
      _reminderTime = prefs.getString('pref_reminder_time') ?? '19:00';
    });
  }

  Future<void> _toggleDailyReminder(bool value) async {
    if (value) {
      await _selectReminderTime();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_daily_reminder', false);
      await _cancelDailyReminder();
      setState(() {
        _dailyReminder = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat menabung dinonaktifkan',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.grey.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  Future<void> _selectReminderTime() async {
    final parts = _reminderTime.split(':');
    final initialHour = parts.length == 2 ? int.tryParse(parts[0]) ?? 19 : 19;
    final initialMinute = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      helpText: 'SETEL JAM PENGINGAT MENABUNG',
      confirmText: 'SETEL',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_daily_reminder', true);
      await prefs.setString('pref_reminder_time', formattedTime);
      
      await _scheduleDailyReminder(selectedTime.hour, selectedTime.minute);

      setState(() {
        _dailyReminder = true;
        _reminderTime = formattedTime;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat menabung harian diaktifkan pukul $formattedTime! ⏰',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  Future<void> _scheduleDailyReminder(int hour, int minute) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(1001);

      // Request permission untuk Android 13+ (Notifikasi)
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'tabunganku_reminder',
        'Pengingat Menabung',
        channelDescription: 'Pengingat harian untuk mencatat tabungan',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1001,
        'Waktunya Menabung! 💰',
        'Ayo raih impian finansialmu, jangan lupa catat tabungan hari ini ya! 😉',
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> _cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(1001);
  }

  Future<void> _changeDefaultCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_default_currency', currency);
    setState(() {
      _defaultCurrency = currency;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showMonthlyExportBottomSheet(bool isDarkMode, List<TransactionModel> transactions) {
    final regular = transactions.where((t) {
      if (t.category == 'Hutang' || t.category == 'Piutang') return false;
      if (t.id.startsWith('shopping_')) return false;
      return true;
    }).toList();

    // Group transactions by month
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in regular) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }

    final monthKeys = grouped.keys.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined,
                        color: Colors.red, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ekspor PDF Bulanan',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Pilih bulan laporan statement yang ingin diunduh',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white38 : Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Month List
              if (monthKeys.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 40,
                            color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada transaksi reguler',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: monthKeys.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final monthKey = monthKeys[index];
                      final monthTx = grouped[monthKey]!;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.02)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.04)
                                : Colors.black.withOpacity(0.02),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthKey,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white70 : Colors.teal.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${monthTx.length} Transaksi',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white38 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await ExportService.shareMonthlyReport(
                                  context: context,
                                  transactions: monthTx,
                                  monthLabel: monthKey,
                                  asPdf: true,
                                );
                              },
                              icon: const Icon(Icons.share_rounded, size: 12),
                              label: Text(
                                'EKSPOR',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    XFile? pickedFile;
    try {
      // SET external operation to true to prevent appraisal lockout
      ref.read(securityProvider.notifier).setExternalOperation(true);

      // Check permissions based on source
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await PermissionService.requestPermission(
          context,
          permission: Permission.camera,
          title: 'Kamera',
          description:
              'Aplikasi membutuhkan akses kamera untuk mengambil foto profil baru Anda secara langsung.',
          icon: Icons.camera_alt_rounded,
        );
      } else {
        hasPermission = await PermissionService.requestPermission(
          context,
          permission: Permission.photos,
          title: 'Galeri',
          description:
              'Aplikasi membutuhkan akses galeri untuk memilih foto profil terbaik dari koleksi foto Anda.',
          icon: Icons.photo_library_rounded,
        );
      }

      if (!hasPermission) return;

      pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
    } finally {
      // UNSET external operation after image picking is done
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }

    if (pickedFile == null) return;
    if (!mounted) return;

    // ── Crop Image (Custom Minimalist 3-Button Screen!) ──────────
    if (!mounted) return;
    final croppedFilePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CropPage(imagePath: pickedFile!.path),
      ),
    );
    if (croppedFilePath == null) return;

    setState(() => _isUploadingPhoto = true);

    final result = await ref
        .read(userProfileProvider.notifier)
        .uploadAndSetPhoto(File(croppedFilePath));

    if (!mounted) return;
    setState(() {
      _isUploadingPhoto = false;
      _uploadError =
          result != null ? null : 'Gagal mengupload foto. Coba lagi.';
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    final profile = ref.watch(userProfileProvider);
    final hasCustomPhoto =
        profile.photoUrl != null && profile.photoUrl!.isNotEmpty;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ubah Foto Profil',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(context, Icons.camera_alt_rounded, 'Kamera',
                    ImageSource.camera),
                _buildSourceOption(context, Icons.photo_library_rounded,
                    'Galeri', ImageSource.gallery),
                if (hasCustomPhoto)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeletePhoto();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 30),
                        ),
                        const SizedBox(height: 6),
                        const Text('Hapus',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
      BuildContext context, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDeletePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto Profil?'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus foto profil dan kembali ke avatar default?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).deletePhoto();
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final profile = ref.watch(userProfileProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final securityState = ref.watch(securityProvider);
    final achievements = ref.watch(achievementsProvider);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;


    // ── Hitung Statistik Dasar ──────────────────────────────────────
    final transactions = (transactionsAsync.value ?? [])
        .where((t) => t.groupId == null)
        .toList();

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final currentBalance = totalIncome - totalExpense;



    final String rankName = _getRankName(totalIncome);
    final IconData rankIcon = _getRankIcon(totalIncome);
    final Color rankColor = _getRankColor(totalIncome);

    // Hitung Streak Menabung (Hari beruntun ada income)
    int streak = 0;
    if (transactions.isNotEmpty) {
      final incomeDates = transactions
          .where((t) => t.type == TransactionType.income)
          .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (incomeDates.isNotEmpty) {
        streak = 1;
        for (int i = 0; i < incomeDates.length - 1; i++) {
          if (incomeDates[i].difference(incomeDates[i + 1]).inDays == 1) {
            streak++;
          } else {
            break;
          }
        }
      }
    }

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Let DashboardPage handle the bg color
      // Removed redundant appBar as it caused double title issues
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Kartu Profil ──────────────────────────────────────
            _buildProfileCard(
                profile, isDarkMode, rankName, rankIcon, rankColor),
            const SizedBox(height: 24),

            // ── Statistik Baris ───────────────────────────────────
            _buildStatsRow(streak, currentBalance, unlockedCount,
                achievements.length, currencyFormatter, isDarkMode),
            const SizedBox(height: 16),

            // ── Lencana Pencapaian ─────────────────────────────────
            _buildSectionHeader('Pencapaian'),
            _buildAchievementList(achievements, isDarkMode),
            const SizedBox(height: 8), // Reduced from 16 to 8

            _buildSectionHeader('Preferensi'),
            _buildSettingGroup([
              _buildSettingTile(
                Icons.dark_mode_outlined,
                'Mode Gelap',
                () => ref.read(themeProvider.notifier).toggleTheme(),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  inactiveTrackColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.transparent),
                ),
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.notifications_active_outlined,
                'Pengingat Menabung',
                () => _dailyReminder ? _selectReminderTime() : _toggleDailyReminder(true),
                trailing: Switch(
                  value: _dailyReminder,
                  onChanged: (val) => _toggleDailyReminder(val),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  inactiveTrackColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.transparent),
                ),
                subtitle: _dailyReminder 
                    ? 'Aktif setiap hari pukul $_reminderTime ⏰' 
                    : 'Ingatkan catat tabungan harian',
                color: Colors.amber,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.picture_as_pdf_outlined,
                'Ekspor Laporan Bulanan (PDF)',
                () => _showMonthlyExportBottomSheet(isDarkMode, transactions),
                subtitle: 'Unduh rekap statement bulanan sekaligus',
                color: Colors.red,
                isDarkMode: isDarkMode,
              ),
            ], isDarkMode),
            const SizedBox(height: 16),

            _buildSectionHeader('Keamanan'),
            _buildSettingGroup([
              _buildSettingTile(
                Icons.fingerprint_rounded,
                'Kunci Biometrik',
                () {}, // Empty now as logic is in Switch
                trailing: Opacity(
                  opacity:
                      1.0, // Making it always appear active to encourage setup
                  child: Switch(
                    value:
                        securityState.isBiometricEnabled && securityState.hasPin,
                    onChanged: (val) {
                      if (!securityState.hasPin) {
                        context.push('/pin-setup');
                      } else {
                        ref.read(securityProvider.notifier).toggleBiometric(val);
                      }
                    },
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    inactiveThumbColor: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                    inactiveTrackColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.transparent),
                  ),
                ),
                subtitle: securityState.hasPin
                    ? 'Gunakan sidik jari/wajah'
                    : 'Pasang PIN terlebih dahulu',
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.lock_outline_rounded,
                securityState.hasPin
                    ? 'Ubah PIN Keamanan'
                    : 'Pasang PIN Keamanan',
                () => context.push('/pin-setup'),
                isDarkMode: isDarkMode,
              ),
              if (securityState.hasPin)
                _buildSettingTile(
                  Icons.lock_reset_rounded,
                  'Hapus PIN Keamanan',
                  () => _showDeletePinDialog(),
                  color: Colors.red,
                  subtitle: 'Matikan semua fitur keamanan',
                  isDarkMode: isDarkMode,
                ),
            ], isDarkMode),
            const SizedBox(height: 16),

            _buildSectionHeader('Sosial & Komunitas'),
            _buildSettingGroup([
              _buildSettingTile(
                Icons.campaign_outlined,
                'Saluran WhatsApp',
                () async {
                  final url = Uri.parse(
                      'https://whatsapp.com/channel/0029Vb7hUrM23n3a6dSem72v');
                  try {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    // Fallback to in-app browser if external fails
                    await launchUrl(
                      url,
                      mode: LaunchMode.platformDefault,
                    );
                  }
                },
                subtitle: 'Join untuk update aplikasi terbaru',
                color: Colors.green,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.camera_alt_outlined,
                'Instagram',
                () async {
                  final url =
                      Uri.parse('https://www.instagram.com/tuanmudazaky_/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                subtitle: 'Follow untuk update visual',
                color: Colors.purple,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.code_rounded,
                'GitHub Developer',
                () async {
                  final url =
                      Uri.parse('https://github.com/MuhammadIsakiPrananda1');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                subtitle: 'Cek source code aplikasi',
                color: isDarkMode ? Colors.white : Colors.black87,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.share_rounded,
                'Bagikan Aplikasi',
                () => _shareApp(),
                color: Colors.pink,
                isDarkMode: isDarkMode,
              ),
            ], isDarkMode),
            const SizedBox(height: 16),

            _buildSectionHeader('Bantuan & Informasi'),
            _buildSettingGroup([
              _buildSettingTile(
                Icons.help_outline_rounded,
                'Pusat Bantuan',
                () => _showHelpDialog(),
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.info_outline_rounded,
                'Tentang Aplikasi',
                () => _showAboutDialog(),
                isDarkMode: isDarkMode,
              ),
            ], isDarkMode),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'Versi ${AppVersion.version}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile, bool isDarkMode, String rank,
      IconData rankIcon, Color rankColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar dengan tombol ganti ─────────────────────────
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
            child: Stack(
              children: [
                // Foto profil
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: _isUploadingPhoto
                        ? Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          )
                        : profile.photoUrl != null
                            ? Builder(
                                builder: (context) {
                                  final photoUrl = profile.photoUrl!;
                                  if (photoUrl.startsWith('http')) {
                                    return Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildDefaultAvatar(
                                              profile.name, isDarkMode),
                                    );
                                  } else {
                                    return Image.file(
                                      File(photoUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildDefaultAvatar(
                                              profile.name, isDarkMode),
                                    );
                                  }
                                },
                              )
                            : _buildDefaultAvatar(profile.name, isDarkMode),
                  ),
                ),
                // Error indicator if upload failed
                if (_uploadError != null)
                  Positioned(
                    bottom: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Gagal!',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                // Badge kamera
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // ── Info profil ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name
                            : 'Pengguna TabunganKu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.1,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditNameDialog(profile.name),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Ketuk foto untuk menggantinya',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.1,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 6),
                // Rank Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: rankColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rankIcon, color: rankColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        rank,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int streak, double currentBalance, int unlockedCount,
      int totalAchievements, NumberFormat formatter, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Streak
          _buildTableRow(
            'Streak',
            '$streak Hari',
            Icons.whatshot_rounded,
            Colors.orange,
            isDarkMode,
          ),
          _buildTableHorizontalDivider(isDarkMode),
          // Row 2: Total Saldo
          _buildTableRow(
            'Total Saldo',
            formatter.format(currentBalance),
            Icons.account_balance_wallet_rounded,
            Colors.blue,
            isDarkMode,
          ),
          _buildTableHorizontalDivider(isDarkMode),
          // Row 3: Lencana
          _buildTableRow(
            'Lencana',
            '$unlockedCount/$totalAchievements',
            Icons.emoji_events_rounded,
            Colors.amber,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHorizontalDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDarkMode
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
    );
  }

  Widget _buildAchievementList(
      List<Achievement> achievements, bool isDarkMode) {
    return SizedBox(
      height: 125, // Height updated to fit the new card design perfectly
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = achievements[index];
          final bool unlocked = item.isUnlocked;

          return Container(
            width: 180, // Symmetrical, compact, and extremely neat card width
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon & Title & Status
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: unlocked
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Icon(
                        unlocked ? item.icon : Icons.lock_outline_rounded,
                        size: 15,
                        color: unlocked
                            ? AppColors.primary
                            : (isDarkMode ? Colors.white24 : Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: unlocked
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                            ),
                          ),
                          Text(
                            unlocked ? 'Terbuka' : 'Terkunci',
                            style: GoogleFonts.quicksand(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: unlocked
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Middle Description Text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 8.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white30 : Colors.black45,
                    ),
                  ),
                ),

                // Bottom Progress Tracker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres',
                          style: GoogleFonts.quicksand(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white30 : Colors.black38,
                          ),
                        ),
                        Text(
                          '${(item.progress * 100).toInt()}%',
                          style: GoogleFonts.quicksand(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: unlocked 
                                ? AppColors.primary 
                                : (isDarkMode ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 2.5,
                        backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          unlocked ? AppColors.primary : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ganti Nama',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan nama baru',
              fillColor: AppColors.primary.withValues(alpha: 0.05),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Nama tidak boleh kosong!';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref
                    .read(userProfileProvider.notifier)
                    .setName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFE9EDEF),
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: isDark ? Colors.white24 : const Color(0xFF919191),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
        'Ayo raih target finansialmu lebih mudah dengan TabunganKu! Download aplikasi resmi di sini: https://tabunganku.neverlandstudio.my.id/ 🎉');
  }

  

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing, String? subtitle, Color? color, bool isDarkMode = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 16),
            ),
            title: Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: color == Colors.red 
                    ? Colors.red.shade600 
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  )
                : null,
            trailing: trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                  size: 16,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.8), // Perfectly seals inner content including the borders!
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length, (index) {
            if (index == children.length - 1) {
              return children[index];
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                children[index],
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52, // Beautifully indented past the icon capsule!
                  endIndent: 16,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showCurrencySelectionDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Pilih Mata Uang Utama',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('IDR', 'Rupiah Indonesia (Rp)', isDarkMode),
            _buildCurrencyOption('USD', 'Dolar Amerika Serikat (\$)', isDarkMode),
            _buildCurrencyOption('EUR', 'Euro Eropa (€)', isDarkMode),
            _buildCurrencyOption('JPY', 'Yen Jepang (¥)', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String value, String label, bool isDarkMode) {
    final isSelected = _defaultCurrency == value;
    return ListTile(
      onTap: () {
        _changeDefaultCurrency(value);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mata uang utama berhasil diubah ke $value ✓',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
          color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color,
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  void _showDeletePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus PIN?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text(
          'Apakah kamu yakin ingin menghapus PIN keamanan? Ini akan mematikan kunci aplikasi dan biometrik.',
          style: TextStyle(fontSize: 11),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(securityProvider.notifier).clearPin();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Keamanan telah dinonaktifkan'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus Sekarang'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pusat Bantuan'),
        content: const Text(
            'Ada kendala? Hubungi tim support kami melalui email Arlianto032@gmail.com atau kunjungi website kami.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'))
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/icon.png',
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) => const Icon(Icons.wallet,
                      size: 72, color: AppColors.primary)),
            ),
            const SizedBox(height: 24),
            const Text('TabunganKu',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const Text('Versi ${AppVersion.version}',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi pengelola keuangan pribadi yang cerdas dan estetik untuk membantu kamu mencapai tujuan finansial.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRankIcon(double totalSaved) {
    if (totalSaved < 100000) return Icons.eco_rounded;
    if (totalSaved < 500000) return Icons.bolt_rounded;
    if (totalSaved < 2000000) return Icons.stars_rounded;
    return Icons.workspace_premium_rounded;
  }

  String _getRankName(double totalSaved) {
    if (totalSaved < 100000) return 'Penabung Pemula';
    if (totalSaved < 500000) return 'Pejuang Cuan';
    if (totalSaved < 2000000) return 'Juragan Tabung';
    return 'Sultan Hemat';
  }

  Color _getRankColor(double totalSaved) {
    if (totalSaved < 100000) return Colors.green;
    if (totalSaved < 500000) return Colors.orange;
    if (totalSaved < 2000000) return Colors.amber;
    return Colors.purple;
  }
}
