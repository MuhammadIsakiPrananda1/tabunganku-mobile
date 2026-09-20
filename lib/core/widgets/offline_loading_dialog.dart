import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';

class OfflineLoadingDialog extends StatefulWidget {
  final String title;
  final String message;
  final Color accentColor;
  final VoidCallback onDismiss;
  final VoidCallback? onRetry;

  const OfflineLoadingDialog({
    super.key,
    this.title = 'Koneksi Terputus',
    required this.message,
    this.accentColor = AppColors.primary,
    required this.onDismiss,
    this.onRetry,
  });

  @override
  State<OfflineLoadingDialog> createState() => _OfflineLoadingDialogState();
}

class _OfflineLoadingDialogState extends State<OfflineLoadingDialog> {
  bool _isConnecting = false;

  Future<void> _handleRetry() async {
    if (_isConnecting) return;
    setState(() {
      _isConnecting = true;
    });

    try {
      final results = await Connectivity().checkConnectivity();
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) {
        showTopToast(context, 'Koneksi internet berhasil terhubung!');
        widget.onRetry?.call();
      } else {
        setState(() {
          _isConnecting = false;
        });
        showTopToast(context, 'Sinyal belum ada. Silakan periksa jaringan Wi-Fi atau data seluler.');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = widget.accentColor;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- GIF Animation ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/no_internet_robot.gif',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: primaryAccent,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Title ---
                  Text(
                    widget.title,
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // --- Description ---
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onDismiss,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Keluar Page',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isConnecting ? null : _handleRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isConnecting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Coba Lagi',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
