import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/providers/family_group_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/achievement_provider.dart';
import 'package:tabunganku/providers/budget_provider.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:intl/intl.dart';

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

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await _showImageSourceDialog();
    if (source == null) return;

    XFile? pickedFile;
    try {
      // SET external operation to true to prevent appraisal lockout
      ref.read(securityProvider.notifier).setExternalOperation(true);
      
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

    setState(() => _isUploadingPhoto = true);

    final result = await ref
        .read(userProfileProvider.notifier)
        .uploadAndSetPhoto(File(pickedFile.path));

    if (!mounted) return;
    setState(() {
      _isUploadingPhoto = false;
      _uploadError = result != null ? null : 'Gagal mengupload foto. Coba lagi.';
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    final profile = ref.watch(userProfileProvider);
    final hasCustomPhoto = profile.photoUrl != null && profile.photoUrl!.isNotEmpty;

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(context, Icons.camera_alt_rounded, 'Kamera', ImageSource.camera),
                _buildSourceOption(context, Icons.photo_library_rounded, 'Galeri', ImageSource.gallery),
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
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 30),
                        ),
                        const SizedBox(height: 8),
                        const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

  Widget _buildSourceOption(BuildContext context, IconData icon, String label, ImageSource source) {
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
        content: const Text('Apakah Anda yakin ingin menghapus foto profil dan kembali ke avatar default?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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
    final budgets = ref.watch(currentMonthBudgetsProvider);

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

    // ── Hitung Health Score & Budget ────────────────────────────────
    double healthScore = 100;
    final Map<String, double> budgetConsumption = {};
    for (final budget in budgets) {
      final spent = transactions
          .where((t) =>
              t.category == budget.category &&
              t.type == TransactionType.expense &&
              t.date.month == budget.month &&
              t.date.year == budget.year)
          .fold<double>(0, (sum, t) => sum + t.amount);
      budgetConsumption[budget.category] = spent;
      if (spent > budget.limitAmount) {
        healthScore -= 15;
      } else if (spent > budget.limitAmount * 0.8) {
        healthScore -= 5;
      }
    }
    if (totalExpense > totalIncome && totalIncome > 0) healthScore -= 10;
    healthScore = healthScore.clamp(0, 100);

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
        DateTime checkDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
        if (incomeDates.first.isAtSameMomentAs(checkDate) || 
            incomeDates.first.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
           for (int i = 0; i < incomeDates.length; i++) {
             if (i == 0) {
               streak = 1;
               checkDate = incomeDates[i];
               continue;
             }
             if (incomeDates[i].isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
               streak++;
               checkDate = incomeDates[i];
             } else {
               break;
             }
           }
        }
      }
    }

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let DashboardPage handle the bg color
      // Removed redundant appBar as it caused double title issues
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Kartu Profil ──────────────────────────────────────
            _buildProfileCard(profile, isDarkMode, rankName, rankIcon, rankColor),
            const SizedBox(height: 24),
            
            // ── Statistik Baris ───────────────────────────────────
            _buildStatsRow(streak, currentBalance, unlockedCount, currencyFormatter, isDarkMode),
            const SizedBox(height: 16),

            // ── Kesehatan Keuangan ─────────────────────────────────
            _buildHealthScoreCard(healthScore, isDarkMode),
            const SizedBox(height: 16),

            // ── Lencana Pencapaian ─────────────────────────────────
            _buildSectionHeader('Pencapaian'),
            _buildAchievementList(achievements, isDarkMode),
            const SizedBox(height: 16),

            
            _buildSectionHeader('Preferensi'),
            _buildSettingTile(
              Icons.campaign_outlined,
              'Saluran WhatsApp',
              () async {
                final url = Uri.parse('https://whatsapp.com/channel/0029Vb7hUrM23n3a6dSem72v');
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
            ),
            _buildSettingTile(
              Icons.dark_mode_outlined,
              'Mode Gelap',
              () => ref.read(themeProvider.notifier).toggleTheme(),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (val) =>
                    ref.read(themeProvider.notifier).toggleTheme(),
                activeThumbColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSectionHeader('Keamanan'),
            _buildSettingTile(
              Icons.fingerprint_rounded,
              'Kunci Biometrik',
              () {}, // Empty now as logic is in Switch
              trailing: Opacity(
                opacity: 1.0, // Making it always appear active to encourage setup
                child: Switch(
                  value: securityState.isBiometricEnabled && securityState.hasPin,
                  onChanged: (val) {
                    if (!securityState.hasPin) {
                      context.push('/pin-setup');
                    } else {
                      ref.read(securityProvider.notifier).toggleBiometric(val);
                    }
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
              subtitle: securityState.hasPin ? 'Gunakan sidik jari/wajah' : 'Pasang PIN terlebih dahulu',
            ),
            _buildSettingTile(Icons.lock_outline_rounded, securityState.hasPin ? 'Ubah PIN Keamanan' : 'Pasang PIN Keamanan', () => context.push('/pin-setup')),
            
            if (securityState.hasPin)
              _buildSettingTile(
                Icons.lock_reset_rounded, 
                'Hapus PIN Keamanan', 
                () => _showDeletePinDialog(),
                color: Colors.red,
                subtitle: 'Matikan semua fitur keamanan',
              ),
            const SizedBox(height: 32),

            _buildSectionHeader('Sosial & Komunitas'),
            _buildSettingTile(
              Icons.people_alt_outlined,
              'Undang Keluarga',
              () => context.push('/family-group'),
              subtitle: 'Ajak keluarga menabung bersama',
              color: Colors.blue,
            ),
            _buildSettingTile(
              Icons.camera_alt_outlined,
              'Instagram',
              () async {
                final url = Uri.parse('https://www.instagram.com/tuanmudazaky_/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              subtitle: 'Follow untuk update visual',
              color: Colors.purple,
            ),
            _buildSettingTile(
              Icons.code_rounded,
              'GitHub Developer',
              () async {
                final url = Uri.parse('https://github.com/MuhammadIsakiPrananda1');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              subtitle: 'Cek source code aplikasi',
              color: Colors.black87,
            ),
            _buildSettingTile(
              Icons.share_rounded,
              'Bagikan Aplikasi',
              () => _shareApp(),
              color: Colors.pink,
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('Bantuan & Informasi'),
            _buildSettingTile(Icons.help_outline_rounded, 'Pusat Bantuan', () => _showHelpDialog()),
            _buildSettingTile(Icons.info_outline_rounded, 'Tentang Aplikasi', () => _showAboutDialog()),
            const SizedBox(height: 16),

            const Text('Versi ${AppVersion.version}',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile, bool isDarkMode, String rank, IconData rankIcon, Color rankColor) {
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
                                          _buildDefaultAvatar(profile.name, isDarkMode),
                                    );
                                  } else {
                                    return Image.file(
                                      File(photoUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildDefaultAvatar(profile.name, isDarkMode),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Gagal!',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditNameDialog(profile.name),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ketuk foto untuk menggantinya',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
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
                          fontWeight: FontWeight.w600,
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
      NumberFormat formatter, bool isDarkMode) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard('Streak', '$streak Hari', Icons.whatshot_rounded,
              Colors.orange, isDarkMode),
          const SizedBox(width: 8),
          _buildStatCard('Total Saldo', formatter.format(currentBalance),
              Icons.account_balance_wallet_rounded, Colors.blue, isDarkMode),
          const SizedBox(width: 8),
          _buildStatCard('Lencana', '$unlockedCount/10', Icons.emoji_events_rounded,
              Colors.amber, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      bool isDarkMode) {
    return Expanded(
      child: Container(
        height: 110, // Fixed height for perfect alignment
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements, bool isDarkMode) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = achievements[index];
          final bool unlocked = item.isUnlocked;
          return Container(
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : (isDarkMode ? Colors.white10 : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: unlocked
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                        : null,
                    boxShadow: unlocked ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Icon(
                    item.icon,
                    size: 24,
                    color: unlocked
                        ? AppColors.primary
                        : (isDarkMode ? Colors.white24 : Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.1,
                    fontWeight: unlocked ? FontWeight.w600 : FontWeight.w500,
                    color: unlocked
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : (isDarkMode ? Colors.white24 : Colors.grey.shade400),
                  ),
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
        title: const Text('Ganti Nama', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan nama baru',
              fillColor: AppColors.primary.withValues(alpha: 0.05),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(userProfileProvider.notifier).setName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, bool isDark) {
    return Container(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE9EDEF),
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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share('Ayo raih target finansialmu lebih mudah dengan TabunganKu! Download aplikasi resmi di sini: https://www.mediafire.com/folder/djw53hap89l4l/TabunganKu 🎉');
  }

  // ── Health Score & Budget ──────────────────────────────────────

  Widget _buildHealthScoreCard(double score, bool isDarkMode) {
    String status = 'Sehat';
    Color scoreColor = Colors.green;
    if (score < 40) {
      status = 'Kritis';
      scoreColor = Colors.red;
    } else if (score < 70) {
      status = 'Waspada';
      scoreColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor:
                      isDarkMode ? Colors.white10 : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${score.toInt()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kesehatan Keuangan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdasarkan budget & pengeluaran bulan ini.',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap,
      {Widget? trailing, String? subtitle, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: color ?? AppColors.primary),
            title: Text(title,
                style: TextStyle(
                    color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500)),
            subtitle: subtitle != null
                ? Text(subtitle,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color))
                : null,
            trailing: trailing ??
                Icon(Icons.chevron_right,
                    color: Theme.of(context).textTheme.bodySmall?.color),
          ),
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
        title: const Text('Hapus PIN?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text(
          'Apakah kamu yakin ingin menghapus PIN keamanan? Ini akan mematikan kunci aplikasi dan biometrik.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            'Ada kendala? Hubungi tim support kami melalui email support@neverlandstudio.com atau kunjungi website kami.'),
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
              child: Image.asset('assets/icon.png', width: 72, height: 72, errorBuilder: (_, __, ___) => const Icon(Icons.wallet, size: 72, color: AppColors.primary)),
            ),
            const SizedBox(height: 24),
            const Text('TabunganKu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Versi ${AppVersion.version}', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi pengelola keuangan pribadi yang cerdas dan estetik untuk membantu kamu mencapai tujuan finansial.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
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
