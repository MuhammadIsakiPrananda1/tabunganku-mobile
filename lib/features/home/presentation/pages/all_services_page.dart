import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';

class AllServicesPage extends ConsumerWidget {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDarkMode ? Colors.white : AppColors.primaryDark, 
            size: 20),
        ),
        title: Text(
          'Semua Layanan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            _buildCategory(context, 'FINANSIAL & TRANSAKSI', [
              _ServiceData(
                icon: Icons.document_scanner_rounded,
                title: 'Smart Receipt',
                subtitle: 'Scan struk belanja otomatis',
                color: Colors.teal,
                route: '/scan-receipt',
              ),
              _ServiceData(
                icon: Icons.loop_rounded,
                title: 'Kelola Langganan',
                subtitle: 'Tagihan rutin & hiburan',
                color: Colors.blue,
                route: '/recurring',
              ),
            ], isDarkMode),

            _buildCategory(context, 'TABUNGAN & RENCANA', [
              _ServiceData(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Dana Rencana',
                subtitle: 'Masa depan cerah terencana',
                color: Colors.teal,
                route: '/saving-plans',
              ),
              _ServiceData(
                icon: Icons.monetization_on_rounded,
                title: 'Simpanan Emas',
                subtitle: 'Tabungan nilai aset stabil',
                color: Colors.amber,
                route: '/gold',
              ),
            ], isDarkMode),

            _buildCategory(context, 'TOOLS & ANALISIS', [
              _ServiceData(
                icon: Icons.calculate_rounded,
                title: 'Simulasi Tabungan',
                subtitle: 'Hitung pertumbuhan bungamu',
                color: Colors.cyan,
                route: '/saving-simulator',
              ),
              _ServiceData(
                icon: Icons.receipt_long_rounded,
                title: 'Manajemen Tagihan',
                subtitle: 'List tagihan bulanan wajib',
                color: Colors.lightBlue,
                route: '/bills',
              ),
              _ServiceData(
                icon: Icons.request_quote_rounded,
                title: 'Hitung Pajak',
                subtitle: 'Kalkulator pajak praktis',
                color: Colors.orange,
                route: '/tax',
              ),
            ], isDarkMode),

            _buildCategory(context, 'INVESTASI & PROTEKSI', [
              _ServiceData(
                icon: Icons.trending_up_rounded,
                title: 'Portofolio Investasi',
                subtitle: 'Pantau aset investasimu',
                color: Colors.indigo,
                route: '/investment',
              ),
              _ServiceData(
                icon: Icons.shield_rounded,
                title: 'Proteksi Asuransi',
                subtitle: 'Keamanan jangka panjang',
                color: Colors.blueGrey,
                route: '/insurance',
              ),
            ], isDarkMode),

            _buildCategory(context, 'SOSIAL & HADIAH', [
              _ServiceData(
                icon: Icons.volunteer_activism_rounded,
                title: 'Zakat & Infaq',
                subtitle: 'Donasi & ibadah harta',
                color: Colors.teal,
                route: '/zakat',
              ),
              _ServiceData(
                icon: Icons.wb_sunny_rounded,
                title: 'Sedekah Subuh',
                subtitle: 'Rutinitas berkah setiap pagi',
                color: Colors.orangeAccent,
                route: '/morning-charity',
              ),
              _ServiceData(
                icon: Icons.emoji_events_rounded,
                title: 'Misi & Challenge',
                subtitle: 'Mainkan misi, raih reward',
                color: Colors.amber,
                route: '/challenge',
              ),
            ], isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<_ServiceData> items, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 32, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
            ),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildListDetailItem(context, item, isDarkMode),
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 20,
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildListDetailItem(BuildContext context, _ServiceData item, bool isDarkMode) {
    return InkWell(
      onTap: () => context.push(item.route, extra: item.extra),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  final dynamic extra;

  _ServiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    this.extra,
  });
}
