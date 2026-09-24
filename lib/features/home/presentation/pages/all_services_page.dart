/// Page: AllServicesPage
///
/// Halaman katalog semua fitur & layanan TabunganKu.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class AllServicesPage extends ConsumerStatefulWidget {
  const AllServicesPage({super.key});

  @override
  ConsumerState<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends ConsumerState<AllServicesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_ServiceCategory> _getCategories() {
    return [
      _ServiceCategory(
        title: 'MANAJEMEN KEUANGAN',
        services: [
          _ServiceData(
            icon: Icons.autorenew_rounded,
            title: 'Kelola Langganan',
            subtitle: 'Catat dan kelola biaya langganan bulanan',
            color: Colors.blue,
            route: '/recurring',
            badgeIcon: Icons.calendar_today_rounded,
          ),
          _ServiceData(
            icon: Icons.receipt_long_rounded,
            title: 'Manajemen Tagihan',
            subtitle: 'Daftar tagihan dan cicilan rutin bulanan',
            color: Colors.lightBlue,
            route: '/bills',
            badgeIcon: Icons.notifications_active_rounded,
          ),
          _ServiceData(
            icon: Icons.handshake_rounded,
            title: 'Kalkulator Pelunas Hutang',
            subtitle: 'Strategi pelunasan hutang secara terstruktur',
            color: Colors.redAccent,
            route: '/debt-payoff',
            badgeIcon: Icons.check_circle_rounded,
          ),
        ],
      ),
      _ServiceCategory(
        title: 'TABUNGAN & INVESTASI',
        services: [
          _ServiceData(
            icon: Icons.lock_rounded,
            title: 'Gembok Tabungan Gaji',
            subtitle: 'Auto-split 50/30/20 & gembok tabungan gaji bulanan',
            color: Colors.amber.shade800,
            route: '/payday-vault',
            badgeIcon: Icons.key_rounded,
          ),
          _ServiceData(
            icon: Icons.savings_rounded,
            title: 'Tabungan Receh',
            subtitle: 'Kumpulkan uang recehan jadi tabungan harian',
            color: Colors.pinkAccent,
            route: '/piggy-bank',
            badgeIcon: Icons.add_rounded,
          ),
          _ServiceData(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak Menabung',
            subtitle: 'Pantau konsistensi menabung harian & raih badge',
            color: Colors.deepOrange,
            route: '/saving-streak',
            badgeIcon: Icons.emoji_events_rounded,
          ),
          _ServiceData(
            icon: Icons.toll_rounded,
            title: 'Tabungan Pembulatan',
            subtitle: 'Bulatkan pengeluaran & tabung kembalian receh otomatis',
            color: Colors.indigoAccent,
            route: '/round-up-savings',
            badgeIcon: Icons.auto_fix_high_rounded,
          ),
          _ServiceData(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Dana Rencana',
            subtitle: 'Tabungan khusus untuk tujuan tertentu',
            color: AppColors.primary,
            route: '/saving-plans',
            badgeIcon: Icons.check_rounded,
          ),
          _ServiceData(
            icon: Icons.monetization_on_rounded,
            title: 'Simpanan Emas',
            subtitle: 'Catat dan pantau tabungan emas kamu',
            color: Colors.amber,
            route: '/gold',
            badgeIcon: Icons.auto_awesome_rounded,
          ),
          _ServiceData(
            icon: Icons.trending_up_rounded,
            title: 'Portofolio Investasi',
            subtitle: 'Pantau saham, reksa dana, dan aset lainnya',
            color: Colors.indigo,
            route: '/investment',
            badgeIcon: Icons.show_chart_rounded,
          ),
          _ServiceData(
            icon: Icons.shield_rounded,
            title: 'Proteksi Asuransi',
            subtitle: 'Catat data polis dan premi asuransimu',
            color: Colors.blueGrey,
            route: '/insurance',
            badgeIcon: Icons.favorite_rounded,
          ),
          _ServiceData(
            icon: Icons.flight_takeoff_rounded,
            title: 'Target Luar Negeri',
            subtitle: 'Nabung barang/liburan luar negeri dengan kurs terkini',
            color: Colors.deepPurple,
            route: '/overseas-travel',
            badgeIcon: Icons.explore_rounded,
          ),
          _ServiceData(
            icon: Icons.favorite_rounded,
            title: 'Biaya Nikah Planner',
            subtitle: 'Rencanakan dan siapkan dana biaya pernikahan',
            color: Colors.pinkAccent,
            route: '/nikah-planner',
            badgeIcon: Icons.auto_awesome_rounded,
          ),
          _ServiceData(
            icon: Icons.school_rounded,
            title: 'Biaya Kuliah Planner',
            subtitle: 'Hitung dan siapkan dana kuliah anak',
            color: Colors.blue,
            route: '/kuliah-planner',
            badgeIcon: Icons.star_rounded,
          ),
          _ServiceData(
            icon: Icons.beach_access_rounded,
            title: 'Tabungan Wisata',
            subtitle: 'Rencanakan liburan dan estimasi total biaya perjalanan',
            color: Colors.orange,
            route: '/wisata-planner',
            badgeIcon: Icons.sunny_snowing,
          ),
        ],
      ),
      _ServiceCategory(
        title: 'ALAT & ANALISIS',
        services: [
          _ServiceData(
            icon: Icons.calculate_rounded,
            title: 'Simulasi Tabungan',
            subtitle: 'Simulasi hasil tabungan berdasarkan bunga dan waktu',
            color: Colors.cyan,
            route: '/saving-simulator',
            badgeIcon: Icons.trending_up_rounded,
          ),
          _ServiceData(
            icon: Icons.request_quote_rounded,
            title: 'Kalkulator Pajak',
            subtitle: 'Hitung estimasi pajak bumi, bangunan, dan kendaraan',
            color: Colors.deepPurpleAccent,
            route: '/tax',
            badgeIcon: Icons.percent_rounded,
          ),
          _ServiceData(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Gaji Bersih & PPh 21',
            subtitle: 'Hitung gaji bersih setelah potongan pajak dan BPJS',
            color: Colors.teal,
            route: '/net-salary',
            badgeIcon: Icons.paid_rounded,
          ),
          _ServiceData(
            icon: Icons.notification_important_rounded,
            title: 'Pengingat Pajak',
            subtitle: 'Pengingat batas waktu pembayaran pajak',
            color: Colors.orange,
            route: '/tax-reminder',
            badgeIcon: Icons.schedule_rounded,
          ),
          _ServiceData(
            icon: Icons.pie_chart_rounded,
            title: 'Aturan Budget 50/30/20',
            subtitle: 'Bagi gaji ke kebutuhan, keinginan, dan tabungan',
            color: Colors.teal,
            route: '/budget-rule',
            badgeIcon: Icons.tune_rounded,
          ),
          _ServiceData(
            icon: Icons.home_rounded,
            title: 'Kalkulator KPR & Cicilan',
            subtitle: 'Hitung cicilan dan total bunga KPR rumah',
            color: Colors.deepOrange,
            route: '/kpr-calculator',
            badgeIcon: Icons.key_rounded,
          ),
          _ServiceData(
            icon: Icons.health_and_safety_rounded,
            title: 'Kalkulator Dana Darurat',
            subtitle: 'Hitung berapa dana darurat yang kamu butuhkan',
            color: Colors.redAccent,
            route: '/emergency-fund-calculator',
            badgeIcon: Icons.shield_rounded,
          ),
          _ServiceData(
            icon: Icons.trending_down_rounded,
            title: 'Kalkulator Inflasi',
            subtitle: 'Lihat dampak inflasi terhadap nilai uangmu',
            color: Colors.deepOrange,
            route: '/inflation-calculator',
            badgeIcon: Icons.warning_amber_rounded,
          ),
        ],
      ),
      _ServiceCategory(
        title: 'UTILITAS FINANSIAL',
        services: [
          _ServiceData(
            icon: Icons.stacked_line_chart_rounded,
            title: 'Bunga Majemuk',
            subtitle: 'Hitung bunga berbunga dari investasi atau tabungan',
            color: AppColors.primary,
            route: '/compound-interest',
            badgeIcon: Icons.auto_awesome_rounded,
          ),
          _ServiceData(
            icon: Icons.currency_exchange_rounded,
            title: 'Konverter Valas',
            subtitle: 'Konversi mata uang asing ke rupiah secara real-time',
            color: Colors.blue,
            route: '/currency-converter',
            badgeIcon: Icons.swap_horiz_rounded,
          ),
          _ServiceData(
            icon: Icons.speed_rounded,
            title: 'Kalkulator Aturan 72',
            subtitle: 'Perkirakan waktu uang berkembang 2x lipat',
            color: Colors.indigo,
            route: '/rule-of-72',
            badgeIcon: Icons.timer_rounded,
          ),
          _ServiceData(
            icon: Icons.call_split_rounded,
            title: 'Split Bill',
            subtitle: 'Bagi rata tagihan dengan teman atau keluarga',
            color: Colors.orangeAccent,
            route: '/split-bill',
            badgeIcon: Icons.people_rounded,
          ),
        ],
      ),
      _ServiceCategory(
        title: 'SOSIAL & HADIAH',
        services: [
          _ServiceData(
            icon: Icons.volunteer_activism_rounded,
            title: 'Zakat & Infaq',
            subtitle: 'Hitung dan catat zakat serta infaq kamu',
            color: Colors.teal,
            route: '/zakat',
            badgeIcon: Icons.favorite_rounded,
          ),
          _ServiceData(
            icon: Icons.mosque_rounded,
            title: 'Sedekah Masjid',
            subtitle: 'Catat donasi ke masjid atau musholla',
            color: Colors.lightGreen,
            route: '/mosque-donation',
            badgeIcon: Icons.favorite_rounded,
          ),
          _ServiceData(
            icon: Icons.mosque_rounded,
            title: 'Haji & Umrah',
            subtitle: 'Rencanakan dan tabung biaya haji atau umrah',
            color: Colors.amber.shade800,
            route: '/hajj-umrah',
            badgeIcon: Icons.flight_takeoff_rounded,
          ),
          _ServiceData(
            icon: Icons.emoji_events_rounded,
            title: 'Misi & Challenge',
            subtitle: 'Selesaikan tantangan finansial dan kumpulkan poin',
            color: Colors.amber,
            route: '/challenge',
            badgeIcon: Icons.star_rounded,
          ),
          _ServiceData(
            icon: Icons.nightlight_round_rounded,
            title: 'Mode Ramadan',
            subtitle: 'Pantau pengeluaran dan pencapaian amal di bulan Ramadan',
            color: Colors.teal,
            route: '/ramadan-mode',
            badgeIcon: Icons.auto_awesome_rounded,
          ),
          _ServiceData(
            icon: Icons.handshake_rounded,
            title: 'Hutang Jariyah',
            subtitle: 'Catat dan pantau sedekah jariyah yang masih berjalan',
            color: AppColors.primary,
            route: '/hutang-jariyah',
            badgeIcon: Icons.favorite_rounded,
          ),
        ],
      ),
      _ServiceCategory(
        title: 'KEAMANAN & DOKUMEN',
        services: [
          _ServiceData(
            icon: Icons.lock_outline_rounded,
            title: 'Brankas Finansial',
            subtitle: 'Simpan data rekening, polis, dan dokumen keuangan penting',
            color: Colors.indigo,
            route: '/brankas-finansial',
            badgeIcon: Icons.shield_rounded,
          ),
          _ServiceData(
            icon: Icons.contact_phone_rounded,
            title: 'Kontak Darurat Finansial',
            subtitle: 'Kontak darurat CS bank, asuransi, dan broker investasi',
            color: Colors.redAccent,
            route: '/kontak-darurat',
            badgeIcon: Icons.phone_in_talk_rounded,
          ),
          _ServiceData(
            icon: Icons.note_alt_rounded,
            title: 'Catatan Harian (Notes)',
            subtitle: 'Tulis dan simpan catatan keuangan harian kamu',
            color: Colors.amber.shade700,
            route: '/notes',
            badgeIcon: Icons.edit_rounded,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final filteredCategories = _getCategories().map((category) {
      final matchingServices = category.services.where((service) {
        final titleMatch = service.title.toLowerCase().contains(_searchQuery);
        final subtitleMatch = service.subtitle.toLowerCase().contains(_searchQuery);
        return titleMatch || subtitleMatch;
      }).toList();
      return _ServiceCategory(
        title: category.title,
        services: matchingServices,
      );
    }).where((category) => category.services.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Semua Layanan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Cari layanan atau fitur...',
                hintStyle: GoogleFonts.quicksand(
                  color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color:
                            isDarkMode ? Colors.white38 : Colors.grey.shade400,
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: isDarkMode
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.04))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),
          Expanded(
            child: filteredCategories.isEmpty
                ? _buildEmptyState(isDarkMode)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryHeader(isDarkMode, category.title),
                          _buildCompactCategoryCard(context, isDarkMode, category.services),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Layanan Tidak Ditemukan',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada hasil untuk "$_searchQuery". Coba periksa kembali ejaan kata kunci Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(bool isDarkMode, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 22, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: isDarkMode ? Colors.white38 : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCompactCategoryCard(
      BuildContext context, bool isDarkMode, List<_ServiceData> items) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _buildCompactListItem(context, item, isDarkMode),
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCompactListItem(
      BuildContext context, _ServiceData item, bool isDarkMode) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(item.route);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _buildServiceCartoonIcon(item, isDarkMode),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCartoonIcon(_ServiceData item, bool isDarkMode) {
    final color = item.color;
    final iconColor = isDarkMode
        ? HSLColor.fromColor(color).withLightness(0.78).toColor()
        : HSLColor.fromColor(color).withLightness(0.38).withSaturation(0.85).toColor();

    final cushionColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.72);

    final cushionBorder = isDarkMode
        ? color.withValues(alpha: 0.20)
        : color.withValues(alpha: 0.14);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.10),
                ]
              : [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.06),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? color.withValues(alpha: 0.28)
              : color.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDarkMode ? 0.16 : 0.10),
            blurRadius: 7,
            offset: const Offset(0, 2.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cushionColor,
            border: Border.all(
              color: cushionBorder,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              item.icon,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCategory {
  final String title;
  final List<_ServiceData> services;

  _ServiceCategory({required this.title, required this.services});
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  final IconData? badgeIcon;

  _ServiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    this.badgeIcon,
  });
}

