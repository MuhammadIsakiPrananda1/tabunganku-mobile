import 'package:flutter/material.dart';
import 'package:tabunganku/core/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pengaturan', 
          style: TextStyle(
            color: Colors.teal.shade900, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.background,
                    child: Icon(Icons.person_rounded, color: AppColors.primary, size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengguna Neverland Studio',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Anggota Premium • v1.1.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade600.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildHeading('Keamanan'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Ubah PIN',
            subtitle: 'Perbarui PIN 6-digit keamanan Anda',
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          _buildHeading('Preferensi'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifikasi',
            subtitle: 'Atur pemberitahuan transaksi',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.translate_rounded,
            title: 'Bahasa',
            subtitle: 'Bahasa Indonesia (Default)',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang TabunganKu',
            subtitle: 'Syarat & Ketentuan, Kebijakan Privasi',
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          
          // Logout Button
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.red.shade100),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 20),
                SizedBox(width: 8),
                Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Copyright Footer
          Center(
            child: Opacity(
              opacity: 0.4,
              child: Column(
                children: [
                  const Text(
                    '© 2026 NEVERLAND STUDIO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dibuat dengan sepenuh hati untuk TabunganKu.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900.withOpacity(0.5),
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Anda perlu memasukkan PIN kembali saat ingin masuk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal.shade900)
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
        onTap: onTap,
      ),
    );
  }
}
