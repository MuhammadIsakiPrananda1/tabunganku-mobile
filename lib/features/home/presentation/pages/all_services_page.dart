import 'package:flutter/material.dart';
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
          _ServiceData(
            icon: Icons.receipt_long_rounded,
            title: 'Manajemen Tagihan',
            subtitle: 'List tagihan bulanan wajib',
            color: Colors.lightBlue,
            route: '/bills',
          ),
          _ServiceData(
            icon: Icons.money_off_rounded,
            title: 'Kalkulator Pelunas Hutang',
            subtitle: 'Rencana bebas hutang lebih cepat',
            color: Colors.redAccent,
            route: '/debt-payoff',
          ),
        ],
      ),
      _ServiceCategory(
        title: 'TABUNGAN & INVESTASI',
        services: [
          _ServiceData(
            icon: Icons.savings_rounded,
            title: 'Tabungan Receh',
            subtitle: 'Kumpulkan uang kecilmu',
            color: Colors.pinkAccent,
            route: '/piggy-bank',
          ),
          _ServiceData(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Dana Rencana',
            subtitle: 'Masa depan cerah terencana',
            color: AppColors.primary,
            route: '/saving-plans',
          ),
          _ServiceData(
            icon: Icons.monetization_on_rounded,
            title: 'Simpanan Emas',
            subtitle: 'Tabungan nilai aset stabil',
            color: Colors.amber,
            route: '/gold',
          ),
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
          _ServiceData(
            icon: Icons.flight_takeoff_rounded,
            title: 'Target Luar Negeri',
            subtitle: 'Nabung dengan kurs real-time',
            color: Colors.deepPurple,
            route: '/overseas-travel',
          ),
          _ServiceData(
            icon: Icons.favorite_rounded,
            title: 'Biaya Nikah Planner',
            subtitle: 'Estimasi & nabung biaya pernikahan',
            color: Colors.pinkAccent,
            route: '/nikah-planner',
          ),
          _ServiceData(
            icon: Icons.school_rounded,
            title: 'Biaya Kuliah Planner',
            subtitle: 'Rencanakan biaya S1/S2 anak',
            color: Colors.blue,
            route: '/kuliah-planner',
          ),
          _ServiceData(
            icon: Icons.beach_access_rounded,
            title: 'Tabungan Wisata',
            subtitle: 'Planner liburan & Muscle/estimasi biaya',
            color: Colors.orange,
            route: '/wisata-planner',
          ),
        ],
      ),
      _ServiceCategory(
        title: 'ALAT & ANALISIS',
        services: [
          _ServiceData(
            icon: Icons.calculate_rounded,
            title: 'Simulasi Tabungan',
            subtitle: 'Hitung pertumbuhan bungamu',
            color: Colors.cyan,
            route: '/saving-simulator',
          ),
          _ServiceData(
            icon: Icons.calculate_rounded,
            title: 'Kalkulator Pajak',
            subtitle: 'Hitung estimasi PBB & PKB',
            color: Colors.deepPurpleAccent,
            route: '/tax',
          ),
          _ServiceData(
            icon: Icons.wallet_membership_rounded,
            title: 'Gaji Bersih & PPh 21',
            subtitle: 'Hitung Take Home Pay dipotong pajak & BPJS',
            color: Colors.teal,
            route: '/net-salary',
          ),
          _ServiceData(
            icon: Icons.notification_important_rounded,
            title: 'Pengingat Pajak',
            subtitle: 'Jangan lewatkan jatuh tempo',
            color: Colors.orange,
            route: '/tax-reminder',
          ),
          _ServiceData(
            icon: Icons.pie_chart_rounded,
            title: 'Aturan Budget 50/30/20',
            subtitle: 'Bagi pendapatanmu secara ideal',
            color: Colors.teal,
            route: '/budget-rule',
          ),
          _ServiceData(
            icon: Icons.insights_rounded,
            title: 'Kebebasan Finansial (FIRE)',
            subtitle: 'Hitung kapan kamu bisa bebas bekerja',
            color: Colors.deepPurple,
            route: '/fire-calculator',
          ),
          _ServiceData(
            icon: Icons.health_and_safety_rounded,
            title: 'Cek Kesehatan Finansial',
            subtitle: 'Analisis skor & tips menabungmu',
            color: Colors.green,
            route: '/financial-health',
          ),
          _ServiceData(
            icon: Icons.home_work_rounded,
            title: 'Kalkulator KPR & Cicilan',
            subtitle: 'Simulasi angsuran rumah & kredit',
            color: Colors.deepOrange,
            route: '/kpr-calculator',
          ),
          _ServiceData(
            icon: Icons.security_rounded,
            title: 'Kalkulator Dana Darurat',
            subtitle: 'Hitung kebutuhan dana cadangan darurat',
            color: Colors.redAccent,
            route: '/emergency-fund-calculator',
          ),
        ],
      ),
      _ServiceCategory(
        title: 'UTILITAS FINANSIAL',
        services: [
          _ServiceData(
            icon: Icons.trending_up_rounded,
            title: 'Bunga Majemuk',
            subtitle: 'Simulasi pertumbuhan aset',
            color: AppColors.primary,
            route: '/compound-interest',
          ),
          _ServiceData(
            icon: Icons.currency_exchange_rounded,
            title: 'Konverter Valas',
            subtitle: 'Cek nilai tukar mata uang',
            color: Colors.blue,
            route: '/currency-converter',
          ),
          _ServiceData(
            icon: Icons.qr_code_2_rounded,
            title: 'QRIS Pembayaran Zaky',
            subtitle: 'Dana Bisnis & Order Kuota',
            color: Colors.redAccent,
            route: '/qris-payment',
          ),
        ],
      ),
      _ServiceCategory(
        title: 'SOSIAL & HADIAH',
        services: [
          _ServiceData(
            icon: Icons.volunteer_activism_rounded,
            title: 'Zakat & Infaq',
            subtitle: 'Donasi & ibadah harta',
            color: Colors.teal,
            route: '/zakat',
          ),
          _ServiceData(
            icon: Icons.mosque_rounded,
            title: 'Sedekah Masjid',
            subtitle: 'Catat sedekah untuk rumah ibadah',
            color: Colors.lightGreen,
            route: '/mosque-donation',
          ),
          _ServiceData(
            icon: Icons.mosque_rounded,
            title: 'Haji & Umrah',
            subtitle: 'Rencanakan ibadah suci',
            color: Colors.amber.shade800,
            route: '/hajj-umrah',
          ),
          _ServiceData(
            icon: Icons.emoji_events_rounded,
            title: 'Misi & Challenge',
            subtitle: 'Mainkan misi, raih reward',
            color: Colors.amber,
            route: '/challenge',
          ),
          _ServiceData(
            icon: Icons.nightlight_round_rounded,
            title: 'Mode Ramadan',
            subtitle: 'Tracker pengeluaran & target amal',
            color: Colors.teal,
            route: '/ramadan-mode',
          ),
          _ServiceData(
            icon: Icons.volunteer_activism_rounded,
            title: 'Hutang Jariyah',
            subtitle: 'Catatan sedekah/jariyah berlangsung',
            color: Colors.lightGreen,
            route: '/hutang-jariyah',
          ),
        ],
      ),
      _ServiceCategory(
        title: 'KEAMANAN & DOKUMEN',
        services: [
          _ServiceData(
            icon: Icons.lock_outline_rounded,
            title: 'Brankas Finansial',
            subtitle: 'Simpan nomor rekening, polis & data penting',
            color: Colors.indigo,
            route: '/brankas-finansial',
          ),
          _ServiceData(
            icon: Icons.contact_phone_rounded,
            title: 'Kontak Darurat Finansial',
            subtitle: 'Daftar kontak cs bank, broker, asuransi',
            color: Colors.redAccent,
            route: '/kontak-darurat',
          ),
          _ServiceData(
            icon: Icons.note_alt_rounded,
            title: 'Catatan Harian (Notes)',
            subtitle: 'Tulis memo, pin & favoritkan catatanmu',
            color: Colors.amber.shade700,
            route: '/notes',
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
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
              size: 18),
        ),
        title: Text(
          'Semua Layanan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                hintStyle: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.bold),
                prefixIcon: Icon(Icons.search_rounded,
                    color: isDarkMode ? Colors.white38 : Colors.black38, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            size: 18,
                            color: isDarkMode ? Colors.white38 : Colors.black38),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
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
      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildCompactCategoryCard(
      BuildContext context, bool isDarkMode, List<_ServiceData> items) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade100,
        ),
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
                  indent: 64,
                  endIndent: 16,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.grey.shade50,
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
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isDarkMode ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
            ),
          ],
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

  _ServiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
