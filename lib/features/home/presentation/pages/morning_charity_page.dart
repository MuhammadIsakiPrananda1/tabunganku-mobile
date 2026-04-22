import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/providers/morning_charity_provider.dart';

class MorningCharityPage extends ConsumerStatefulWidget {
  const MorningCharityPage({super.key});

  @override
  ConsumerState<MorningCharityPage> createState() => _MorningCharityPageState();
}

class _MorningCharityPageState extends ConsumerState<MorningCharityPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _recordCharity(double amount) async {
    if (amount <= 0) return;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Sedekah Subuh',
      description: 'Sedekah rutin harian',
      amount: amount,
      type: TransactionType.expense,
      date: DateTime.now(),
      category: 'Gift',
    );

    await ref.read(transactionServiceProvider).addTransaction(transaction);
    
    if (mounted) {
      _amountController.clear();
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alhamdulillah, sedekah berhasil dicatat! ✨', style: GoogleFonts.comicNeue(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(morningCharityProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDarkMode ? Colors.white : AppColors.primaryDark, 
            size: 20),
        ),
        title: Text(
          'Sedekah Subuh',
          style: GoogleFonts.comicNeue(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO INPUT SECTION (Compact & Normal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOMINAL SEDEKAH',
                    style: GoogleFonts.comicNeue(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_RibuanFormatter()],
                    style: GoogleFonts.comicNeue(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.comicNeue(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error.withValues(alpha: 0.1),
                      ),
                      prefixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Rp', 
                            style: GoogleFonts.comicNeue(
                              fontSize: 14, 
                              fontWeight: FontWeight.w900, 
                              color: AppColors.error
                            )
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),

            // 2. QUICK AMOUNTS
            Row(
              children: [
                _buildQuickChip('2.000', isDarkMode),
                const SizedBox(width: 8),
                _buildQuickChip('5.000', isDarkMode),
                const SizedBox(width: 8),
                _buildQuickChip('10.000', isDarkMode),
                const SizedBox(width: 8),
                _buildQuickChip('50.000', isDarkMode),
              ],
            ),

            const SizedBox(height: 28),

            // 3. STATS ROW
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatCard(
                    'TOTAL',
                    _formatRupiah(stats.totalAmount),
                    Icons.volunteer_activism_rounded,
                    Colors.orange,
                    isDarkMode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactStatCard(
                    'STREAK',
                    '${stats.currentStreak} Hari',
                    Icons.local_fire_department_rounded,
                    Colors.redAccent,
                    isDarkMode,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 4. ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
                  _recordCharity(amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ).copyWith(
                  elevation: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.pressed) ? 0 : 8),
                ),
                child: Text(
                  'Catat Keberkahan Sekarang',
                  style: GoogleFonts.comicNeue(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. HISTORY SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RIWAYAT KEBERKAHAN',
                  style: GoogleFonts.comicNeue(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
                Icon(Icons.history_rounded, size: 16, color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryList(stats, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.comicNeue(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.comicNeue(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, bool isDarkMode) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _amountController.text = label;
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.comicNeue(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white60 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(MorningCharityStats stats, bool isDarkMode) {
    if (stats.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'Mulai langkah berkah pertamamu hari ini!',
          style: GoogleFonts.comicNeue(color: isDarkMode ? Colors.white12 : Colors.grey.shade400, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.history.length,
      itemBuilder: (context, index) {
        final t = stats.history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatRupiah(t.amount),
                      style: GoogleFonts.comicNeue(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(t.date),
                      style: GoogleFonts.comicNeue(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white24 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
            ],
          ),
        );
      },
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
