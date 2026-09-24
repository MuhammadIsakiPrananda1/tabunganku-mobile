/// Page: SettingsPage
///
/// Pusat pengaturan aplikasi, tema, keamanan PIN, backup, dan profil.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:tabunganku/core/services/export_service.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/marquee_text.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/features/settings/presentation/pages/crop_page.dart';
import 'package:tabunganku/features/settings/presentation/providers/achievement_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isUploadingPhoto = false;
  String? _uploadError;

  @override
  void dispose() {
    super.dispose();
  }

  void _showMonthlyExportBottomSheet(
      bool isDarkMode, List<TransactionModel> transactions) {
    final regular = transactions.where((t) {
      if (t.category == 'Hutang' || t.category == 'Piutang') return false;
      if (t.id.startsWith('shopping_')) return false;
      return true;
    }).toList();

    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in regular) {
      final k = DateFormat('MMMM yyyy', 'id_ID').format(t.date).toUpperCase();
      grouped.putIfAbsent(k, () => []).add(t);
    }

    final now = DateTime.now();
    final currentMonthKey =
        DateFormat('MMMM yyyy', 'id_ID').format(now).toUpperCase();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final isEndOfMonth = now.day == lastDay;

    final monthKeys = grouped.keys.where((k) {
      if (k == currentMonthKey) {
        return isEndOfMonth;
      }
      return true;
    }).toList();

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
              if (monthKeys.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 40,
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade300),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.teal.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${monthTx.length} Transaksi',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.grey,
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
                                  userName: ref.read(userNameProvider),
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
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.12),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
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
      ref.read(securityProvider.notifier).setExternalOperation(true);

      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await Permission.camera.request().isGranted;
      } else {
        hasPermission = await Permission.photos.request().isGranted;
      }

      if (!hasPermission) return;

      pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
    } finally {
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }

    if (pickedFile == null) return;
    if (!mounted) return;

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

    final streak = ref.watch(savingStreakProvider);

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileCard(
                profile, isDarkMode, rankName, rankIcon, rankColor),
            const SizedBox(height: 24),
            _buildStatsRow(streak, currentBalance, unlockedCount,
                achievements.length, currencyFormatter, isDarkMode),
            const SizedBox(height: 16),
            _buildSectionHeader(
                'Pencapaian ($unlockedCount/${achievements.length})'),
            const SizedBox(height: 8),
            _buildAchievementList(achievements, isDarkMode),
            const SizedBox(height: 8),
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
                  inactiveThumbColor:
                      isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  inactiveTrackColor: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => Colors.transparent),
                ),
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
                () {},
                trailing: Opacity(
                  opacity: 1.0,
                  child: Switch(
                    value: securityState.isBiometricEnabled &&
                        securityState.hasPin,
                    onChanged: (val) {
                      if (!securityState.hasPin) {
                        context.push('/pin-setup');
                      } else {
                        ref
                            .read(securityProvider.notifier)
                            .toggleBiometric(val);
                      }
                    },
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    inactiveThumbColor:
                        isDarkMode ? Colors.white30 : Colors.grey.shade400,
                    inactiveTrackColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) => Colors.transparent),
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
                Icons.privacy_tip_outlined,
                'Kebijakan Privasi',
                () => _showPrivacyPolicyDialog(isDarkMode),
                color: Colors.teal,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.gavel_rounded,
                'Syarat & Ketentuan',
                () => _showTermsDialog(isDarkMode),
                color: Colors.indigo,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.feedback_outlined,
                'Kirim Masukan / Feedback',
                () => context.push('/feedback'),
                subtitle: 'Beri rating & saran untuk aplikasi â­',
                color: Colors.orange,
                isDarkMode: isDarkMode,
              ),
              _buildSettingTile(
                Icons.auto_stories_outlined,
                'Panduan & Pengenalan Aplikasi',
                () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('has_seen_onboarding_intro', false);
                  if (context.mounted) {
                    context.go('/splash');
                  }
                },
                subtitle: 'Lihat kembali slide pengenalan TabunganKu',
                color: Colors.teal,
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
            const Center(
              child: Text(
                'Versi ${AppVersion.version}',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.28 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary
                          .withValues(alpha: isDarkMode ? 0.4 : 0.25),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: isDarkMode ? 0.15 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _isUploadingPhoto
                        ? Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
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
                          color: Colors.red.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Gagal!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MarqueeText(
                        text: (profile.name.isNotEmpty &&
                                profile.name != 'user-xxxx' &&
                                profile.name != 'Pengguna TabunganKu')
                            ? profile.name
                            : UserProfileNotifier.generateDefaultUsername(),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(profile.name),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Ketuk foto untuk menggantinya',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        rankColor.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: rankColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rankIcon, color: rankColor, size: 13),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          rank,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: rankColor,
                          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableRow(
            'Streak',
            '$streak Hari',
            Icons.whatshot_rounded,
            Colors.orange,
            isDarkMode,
          ),
          _buildTableHorizontalDivider(isDarkMode),
          _buildTableRow(
            'Total Saldo',
            formatter.format(currentBalance),
            Icons.account_balance_wallet_rounded,
            Colors.blue,
            isDarkMode,
          ),
          _buildTableHorizontalDivider(isDarkMode),
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
          Expanded(
            child: Row(
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
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: FittedBox(
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
    final displayedItems = achievements.take(10).toList();
    final bool showSeeAllCard = achievements.length > 10;
    final int totalCardCount = displayedItems.length + (showSeeAllCard ? 1 : 0);

    return SizedBox(
      height: 125,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        scrollDirection: Axis.horizontal,
        itemCount: totalCardCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == displayedItems.length && showSeeAllCard) {
            return InkWell(
              onTap: () =>
                  _showAllAchievementsModal(context, achievements, isDarkMode),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lihat Semua\nPencapaian',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final item = displayedItems[index];
          final bool unlocked = item.isUnlocked;

          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDarkMode
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: unlocked
                            ? Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Icon(
                        unlocked ? item.icon : Icons.lock_outline_rounded,
                        size: 15,
                        color: unlocked
                            ? AppColors.primary
                            : (isDarkMode
                                ? Colors.white24
                                : Colors.grey.shade400),
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
                                  : (isDarkMode
                                      ? Colors.white38
                                      : Colors.grey.shade500),
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
                                : (isDarkMode
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.grey.shade600),
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
                        backgroundColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.grey.shade200,
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
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 44,
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.85)
              : AppColors.primary,
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

  void _showAllAchievementsModal(
      BuildContext context, List<Achievement> achievements, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String filter = 'Semua';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final unlocked = achievements.where((a) => a.isUnlocked).toList();
            final locked = achievements.where((a) => !a.isUnlocked).toList();

            final filteredList = filter == 'Terbuka'
                ? unlocked
                : filter == 'Terkunci'
                    ? locked
                    : achievements;

            final contentColor =
                isDarkMode ? Colors.white : AppColors.primaryDark;
            final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar 50 Pencapaian',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: contentColor,
                            ),
                          ),
                          Text(
                            'Terbuka ${unlocked.length} dari ${achievements.length} pencapaian',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: contentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter chips
                  Row(
                    children: [
                      _buildModalFilterChip(
                          'Semua (${achievements.length})',
                          filter == 'Semua',
                          () => setModalState(() => filter = 'Semua'),
                          isDarkMode),
                      const SizedBox(width: 8),
                      _buildModalFilterChip(
                          'Terbuka (${unlocked.length})',
                          filter == 'Terbuka',
                          () => setModalState(() => filter = 'Terbuka'),
                          isDarkMode),
                      const SizedBox(width: 8),
                      _buildModalFilterChip(
                          'Terkunci (${locked.length})',
                          filter == 'Terkunci',
                          () => setModalState(() => filter = 'Terkunci'),
                          isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final isItemUnlocked = item.isUnlocked;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isItemUnlocked
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : (isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isItemUnlocked
                                      ? AppColors.primary
                                          .withValues(alpha: 0.12)
                                      : (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.grey.shade100),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isItemUnlocked
                                      ? item.icon
                                      : Icons.lock_outline_rounded,
                                  color: isItemUnlocked
                                      ? AppColors.primary
                                      : (isDarkMode
                                          ? Colors.white24
                                          : Colors.grey.shade400),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: contentColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isItemUnlocked
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.12)
                                                : (isDarkMode
                                                    ? Colors.white
                                                        .withValues(alpha: 0.05)
                                                    : Colors.grey.shade100),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isItemUnlocked
                                                ? 'TERBUKA'
                                                : 'TERKUNCI',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: isItemUnlocked
                                                  ? AppColors.primary
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10.5,
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: item.progress,
                                              minHeight: 4,
                                              backgroundColor: isDarkMode
                                                  ? Colors.white
                                                      .withValues(alpha: 0.06)
                                                  : Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                isItemUnlocked
                                                    ? AppColors.primary
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(item.progress * 100).toInt()}%',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isItemUnlocked
                                                ? AppColors.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
      },
    );
  }

  Widget _buildModalFilterChip(
      String label, bool isSelected, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
        'Ayo raih target finansialmu lebih mudah dengan TabunganKu! Download aplikasi resmi di sini: https://tabunganku.neverlandstudio.my.id/ ðŸŽ‰');
  }

  void _showPrivacyPolicyDialog(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildInfoBottomSheet(
        isDarkMode: isDarkMode,
        icon: Icons.privacy_tip_outlined,
        iconColor: Colors.teal,
        title: 'Kebijakan Privasi',
        subtitle: 'Terakhir diperbarui: Juni 2026',
        content: [
          _infoSection('ðŸ“± TabunganKu Adalah Aplikasi Lokal',
              'Semua data yang kamu masukkan di TabunganKu â€” mulai dari catatan pemasukan & pengeluaran, target tabungan, celengan bersama, daftar belanja, hingga foto profil â€” semuanya tersimpan 100% di memori HP kamu sendiri. Tidak ada server, tidak ada cloud, tidak ada akun yang perlu dibuat.'),
          _infoSection('ðŸ“‹ Data Apa yang Tersimpan?',
              'TabunganKu menyimpan: (1) Nama dan foto profil yang kamu atur sendiri, (2) Riwayat transaksi pemasukan & pengeluaran, (3) Data target tabungan dan progresnya, (4) Data celengan bersama & anggota grup, (5) Daftar wishlist belanja, (6) Pengaturan PIN keamanan (dalam bentuk terenkripsi), dan (7) Preferensi aplikasi seperti tema dan waktu pengingat.'),
          _infoSection('ðŸ”’ Keamanan Berlapis',
              'Kamu bisa memasang PIN 6 digit dan/atau kunci biometrik (sidik jari/wajah) untuk mencegah orang lain mengakses aplikasi. PIN disimpan dalam bentuk hash terenkripsi, bukan teks biasa, sehingga bahkan pengembang pun tidak bisa membacanya.'),
          _infoSection('ðŸ“¤ Berbagi Data â€” Hanya Atas Kemauanmu',
              'TabunganKu tidak pernah mengirim datamu ke mana pun tanpa izin. Fitur ekspor PDF bulanan dan ekspor CSV hanya berjalan saat kamu menekan tombolnya sendiri, dan hasilnya langsung dikirim ke aplikasi yang kamu pilih (WhatsApp, email, dll).'),
          _infoSection('ðŸ”” Notifikasi Pengingat',
              'Jika kamu mengaktifkan pengingat menabung harian, TabunganKu menjadwalkan notifikasi lokal di HP kamu. Notifikasi ini tidak melewati server manapun â€” sepenuhnya diproses oleh sistem Android/iOS di perangkatmu.'),
          _infoSection('ðŸ—‘ï¸ Menghapus Data',
              'Untuk menghapus semua data aplikasi sekaligus, kamu dapat membersihkan data aplikasi atau menghapus (uninstall) TabunganKu dari HP kamu.'),
          _infoSection('ðŸ“¬ Ada Pertanyaan?',
              'Hubungi tim Neverland Studio di Arlianto032@gmail.com. Kami dengan senang hati menjawab pertanyaan seputar privasi dan keamanan datamu.'),
        ],
      ),
    );
  }

  void _showTermsDialog(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildInfoBottomSheet(
        isDarkMode: isDarkMode,
        icon: Icons.gavel_rounded,
        iconColor: Colors.indigo,
        title: 'Syarat & Ketentuan',
        subtitle: 'Berlaku sejak Juni 2026',
        content: [
          _infoSection('âœ… Untuk Siapa TabunganKu?',
              'TabunganKu dibuat khusus untuk kamu yang ingin mencatat keuangan pribadi secara mandiri â€” mulai dari pemasukan harian, pengeluaran, target menabung, hingga nabung bareng teman atau keluarga lewat fitur Celengan Bersama. Aplikasi ini tidak memerlukan internet maupun akun untuk digunakan.'),
          _infoSection('ðŸ“ Tanggung Jawab Pengguna',
              'Semua data yang kamu masukkan â€” jumlah uang, kategori, catatan â€” adalah tanggung jawabmu sepenuhnya. TabunganKu hanya mencatat apa yang kamu input; kami tidak memverifikasi kebenaran data keuanganmu. Pastikan kamu mencatat dengan teliti agar laporan keuanganmu akurat.'),
          _infoSection('ðŸ‘¥ Fitur Celengan Bersama',
              'Fitur Nabung Bersama memungkinkan kamu membuat grup tabungan dan menambahkan anggota. Semua data grup disimpan lokal di perangkatmu. Kamu sebagai pembuat grup bertanggung jawab atas pengelolaan anggota dan transparansi dana di dalam grup tersebut.'),
          _infoSection('ðŸ“„ Ekspor & Laporan',
              'Hasil ekspor PDF maupun CSV yang dihasilkan TabunganKu hanya bersifat ringkasan dari data yang kamu masukkan sendiri. Dokumen ini tidak memiliki kekuatan hukum sebagai laporan keuangan resmi dan tidak ditandatangani oleh pihak manapun.'),
          _infoSection('ðŸŽ¨ Hak Cipta & Kepemilikan',
              'Seluruh desain antarmuka, ikon, ilustrasi, nama "TabunganKu", dan kode sumber aplikasi ini adalah milik Neverland Studio. Dilarang menggandakan, memodifikasi, atau mendistribusikan ulang dalam bentuk apapun tanpa izin tertulis dari Neverland Studio.'),
          _infoSection('âš ï¸ Batas Tanggung Jawab',
              'TabunganKu adalah alat bantu pencatatan, bukan penasihat keuangan. Kami tidak bertanggung jawab atas keputusan finansial yang kamu buat berdasarkan data di aplikasi ini. Selalu bijak dalam mengelola keuanganmu.'),
          _infoSection('ðŸ”„ Pembaruan Aplikasi',
              'Neverland Studio sewaktu-waktu dapat merilis pembaruan yang menambahkan fitur baru atau mengubah tampilan. Dengan terus menggunakan TabunganKu setelah pembaruan, kamu dianggap menyetujui perubahan yang ada. Syarat & Ketentuan terbaru selalu bisa dibaca di menu ini.'),
        ],
      ),
    );
  }


  Widget _buildInfoBottomSheet({
    required bool isDarkMode,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> content,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
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
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Column(children: content),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(String heading, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing,
      String? subtitle,
      Color? color,
      bool isDarkMode = false}) {
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
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.4),
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
        borderRadius: BorderRadius.circular(22.8),
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
                  indent: 52,
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
              showTopToast(context, 'Keamanan telah dinonaktifkan');
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
              child: Image.asset(
                'assets/icon.webp',
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/icon.png',
                  width: 72,
                  height: 72,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.wallet,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),
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

