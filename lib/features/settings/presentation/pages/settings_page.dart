import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';


class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Akun'),
            _buildSettingTile(Icons.person_outline, 'Edit Profil', () {}),

            _buildSettingTile(Icons.notifications_outlined, 'Notifikasi', () {},
                trailing: Switch(
                  value: _notifications,
                  onChanged: (val) => setState(() => _notifications = val),
                  activeThumbColor: AppColors.primary,
                )),
            const SizedBox(height: 32),
            _buildSectionHeader('Preferensi'),
            _buildSettingTile(Icons.dark_mode_outlined, 'Dark Mode', () {},
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
                  activeThumbColor: AppColors.primary,
                )),
            _buildSettingTile(Icons.language, 'Bahasa', () {}, subtitle: 'Bahasa Indonesia'),
            const SizedBox(height: 32),
            _buildSectionHeader('Lainnya'),
            _buildSettingTile(Icons.help_outline, 'Pusat Bantuan', () {}),
            _buildSettingTile(Icons.info_outline, 'Tentang Aplikasi', () {}),

            const SizedBox(height: 40),
            const Text('Versi 1.3.9', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengguna TabunganKu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),

              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing, String? subtitle, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: TextStyle(color: color ?? Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)) : null,
        trailing: trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }


}
