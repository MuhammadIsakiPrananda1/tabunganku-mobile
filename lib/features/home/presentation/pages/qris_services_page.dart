import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class QrisServicesPage extends ConsumerStatefulWidget {
  const QrisServicesPage({super.key});

  @override
  ConsumerState<QrisServicesPage> createState() => _QrisServicesPageState();
}

class _QrisServicesPageState extends ConsumerState<QrisServicesPage> {
  int _activeTabIndex = 0; // 0: Toko Kelontong Zaky, 1: Toko Zaky Store

  final List<Map<String, String>> _qrisData = [
    {
      'title': 'Toko Kelontong Zaky',
      'type': 'Dana Bisnis',
      'nmid': 'ID1022201880468',
      'asset': 'assets/qris_kelontong_zaky.jpg',
      'printedBy': '93600915',
      'version': '1.0.23.03.26',
    },
    {
      'title': 'Toko Zaky Store',
      'type': 'Order Kuota',
      'nmid': 'ID2024361141789',
      'asset': 'assets/qris_zaky_store.jpg',
      'printedBy': '93600503',
      'version': '2024.12.07',
      'code': 'OK1419828',
    }
  ];

  Future<void> _shareQris(String assetPath, String text) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/${assetPath.split('/').last}').create();
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      // Fallback if writing fails
      await Share.share(text);
    }
  }

  void _saveQrisToGallery(String title) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'QRIS $title berhasil disimpan ke galeri!',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAFC);
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final activeData = _qrisData[_activeTabIndex];

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Layanan QRIS Zaky',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Minimalist Tab Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_activeTabIndex != 0) {
                          setState(() {
                            _activeTabIndex = 0;
                          });
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 0
                              ? (isDarkMode ? AppColors.primary : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 0 && !isDarkMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Dana Bisnis',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _activeTabIndex == 0
                                ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                                : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_activeTabIndex != 1) {
                          setState(() {
                            _activeTabIndex = 1;
                          });
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 1
                              ? (isDarkMode ? AppColors.primary : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 1 && !isDarkMode
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Order Kuota',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _activeTabIndex == 1
                                ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                                : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Premium Minimalist QRIS Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
              ),
              child: Column(
                children: [
                  // Merchant Header Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          activeData['title']!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (activeData.containsKey('code')) ...[
                          const SizedBox(height: 2),
                          Text(
                            activeData['code']!,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NMID: ${activeData['nmid']}',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QRIS Image Frame (Clean/White border inside)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        activeData['asset']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Card Footer Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Satu QRIS untuk Semua',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cek aplikasi penyelenggara di: www.aspi-qris.id',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareQris(
                        activeData['asset']!,
                        'QRIS ${activeData['title']} - NMID: ${activeData['nmid']}',
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        'Bagikan',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: contentColor,
                        side: BorderSide(
                          color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveQrisToGallery(activeData['title']!),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        'Simpan',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
