import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';

class FinancialHealthCheckupPage extends ConsumerStatefulWidget {
  const FinancialHealthCheckupPage({super.key});

  @override
  ConsumerState<FinancialHealthCheckupPage> createState() =>
      _FinancialHealthCheckupPageState();
}

class _FinancialHealthCheckupPageState
    extends ConsumerState<FinancialHealthCheckupPage> {
  final TextEditingController _incomeCtrl = TextEditingController();
  final TextEditingController _expenseCtrl = TextEditingController();
  final TextEditingController _savingCtrl = TextEditingController();
  final TextEditingController _debtPaymentCtrl = TextEditingController();
  final TextEditingController _liquidAssetsCtrl = TextEditingController();
  final TextEditingController _nonLiquidAssetsCtrl = TextEditingController();
  final TextEditingController _totalDebtCtrl = TextEditingController();

  double _savingRatio = 0;
  double _debtServiceRatio = 0;
  double _liquidityRatio = 0;
  double _debtToAssetRatio = 0;
  int _overallScore = 0;
  String _healthStatus = 'Masukkan Data Keuangan';
  Color _statusColor = Colors.grey;

  // SharedPreferences history storage
  List<Map<String, dynamic>> _checkupHistory = [];

  // Active recommendations list
  final List<Map<String, dynamic>> _recommendations = [];

  // Detail cards expansion state
  final Map<int, bool> _expandedCards = {
    0: false,
    1: false,
    2: false,
    3: false,
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Register listeners to calculate on any input change
    _incomeCtrl.addListener(_calculateHealth);
    _expenseCtrl.addListener(_calculateHealth);
    _savingCtrl.addListener(_calculateHealth);
    _debtPaymentCtrl.addListener(_calculateHealth);
    _liquidAssetsCtrl.addListener(_calculateHealth);
    _nonLiquidAssetsCtrl.addListener(_calculateHealth);
    _totalDebtCtrl.addListener(_calculateHealth);
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _expenseCtrl.dispose();
    _savingCtrl.dispose();
    _debtPaymentCtrl.dispose();
    _liquidAssetsCtrl.dispose();
    _nonLiquidAssetsCtrl.dispose();
    _totalDebtCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString('financial_health_history');
      if (historyStr != null) {
        final List<dynamic> decoded = jsonDecode(historyStr);
        setState(() {
          _checkupHistory =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat riwayat checkup: $e');
    }
  }

  Future<void> _saveToHistory() async {
    final double income = _parseInput(_incomeCtrl);
    final double expense = _parseInput(_expenseCtrl);
    final double saving = _parseInput(_savingCtrl);
    final double debtPayment = _parseInput(_debtPaymentCtrl);
    final double liquidAssets = _parseInput(_liquidAssetsCtrl);
    final double nonLiquidAssets = _parseInput(_nonLiquidAssetsCtrl);
    final double totalDebt = _parseInput(_totalDebtCtrl);

    if (income <= 0 || expense <= 0) {
      showTopToast(context,
          'Silakan masukkan pendapatan dan pengeluaran yang valid terlebih dahulu.',
          isError: true);
      return;
    }

    final newEntry = {
      'date': DateTime.now().toIso8601String(),
      'score': _overallScore,
      'status': _healthStatus,
      'income': income,
      'expense': expense,
      'saving': saving,
      'debtPayment': debtPayment,
      'liquidAssets': liquidAssets,
      'nonLiquidAssets': nonLiquidAssets,
      'totalDebt': totalDebt,
      'savingRatio': _savingRatio,
      'debtServiceRatio': _debtServiceRatio,
      'liquidityRatio': _liquidityRatio,
      'debtToAssetRatio': _debtToAssetRatio,
    };

    setState(() {
      _checkupHistory.insert(0, newEntry);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'financial_health_history', jsonEncode(_checkupHistory));
      if (mounted) {
        showTopToast(context, 'Hasil checkup berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Gagal menyimpan hasil checkup.', isError: true);
      }
    }
  }

  Future<void> _deleteHistoryItem(int index) async {
    setState(() {
      _checkupHistory.removeAt(index);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'financial_health_history', jsonEncode(_checkupHistory));
      if (mounted) {
        showTopToast(context, 'Riwayat checkup telah dihapus.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(context, 'Gagal menghapus riwayat.', isError: true);
      }
    }
  }

  void _loadPastCheckup(Map<String, dynamic> item) {
    String formatToText(double val) {
      if (val == 0) return '';
      final formatted = val.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
      return formatted;
    }

    setState(() {
      _incomeCtrl.text = formatToText((item['income'] as num).toDouble());
      _expenseCtrl.text = formatToText((item['expense'] as num).toDouble());
      _savingCtrl.text = formatToText((item['saving'] as num).toDouble());
      _debtPaymentCtrl.text =
          formatToText((item['debtPayment'] as num).toDouble());
      _liquidAssetsCtrl.text =
          formatToText((item['liquidAssets'] as num).toDouble());
      _nonLiquidAssetsCtrl.text =
          formatToText((item['nonLiquidAssets'] as num).toDouble());
      _totalDebtCtrl.text = formatToText((item['totalDebt'] as num).toDouble());
    });

    _calculateHealth();
    showTopToast(context, 'Hasil checkup masa lalu dimuat ke formulir.');
  }

  double _parseInput(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  void _calculateHealth() {
    final double income = _parseInput(_incomeCtrl);
    final double expense = _parseInput(_expenseCtrl);
    final double saving = _parseInput(_savingCtrl);
    final double debtPayment = _parseInput(_debtPaymentCtrl);
    final double liquidAssets = _parseInput(_liquidAssetsCtrl);
    final double nonLiquidAssets = _parseInput(_nonLiquidAssetsCtrl);
    final double totalDebt = _parseInput(_totalDebtCtrl);

    if (income <= 0 &&
        expense <= 0 &&
        saving <= 0 &&
        debtPayment <= 0 &&
        liquidAssets <= 0 &&
        nonLiquidAssets <= 0 &&
        totalDebt <= 0) {
      setState(() {
        _savingRatio = 0;
        _debtServiceRatio = 0;
        _liquidityRatio = 0;
        _debtToAssetRatio = 0;
        _overallScore = 0;
        _healthStatus = 'Masukkan Data Keuangan';
        _statusColor = Colors.grey;
        _recommendations.clear();
      });
      return;
    }

    // 1. Saving Ratio = (Saving / Income) * 100
    _savingRatio = income > 0 ? (saving / income) * 100 : 0;
    int savingScore = 0;
    if (_savingRatio >= 20) {
      savingScore = 30;
    } else if (_savingRatio >= 15) {
      savingScore = 25;
    } else if (_savingRatio >= 10) {
      savingScore = 20;
    } else if (_savingRatio >= 5) {
      savingScore = 10;
    } else {
      savingScore = 0;
    }

    // 2. Debt Service Ratio = (Debt Payment / Income) * 100
    _debtServiceRatio = income > 0 ? (debtPayment / income) * 100 : 0;
    int debtScore = 0;
    if (debtPayment == 0) {
      debtScore = 30;
    } else if (_debtServiceRatio < 20) {
      debtScore = 30;
    } else if (_debtServiceRatio < 30) {
      debtScore = 25;
    } else if (_debtServiceRatio <= 35) {
      debtScore = 15;
    } else if (_debtServiceRatio <= 50) {
      debtScore = 5;
    } else {
      debtScore = 0;
    }

    // 3. Liquidity Ratio = Liquid Assets / Expense
    _liquidityRatio = expense > 0 ? (liquidAssets / expense) : 0;
    int liquidityScore = 0;
    if (_liquidityRatio >= 6) {
      liquidityScore = 25;
    } else if (_liquidityRatio >= 4) {
      liquidityScore = 20;
    } else if (_liquidityRatio >= 3) {
      liquidityScore = 15;
    } else if (_liquidityRatio >= 1) {
      liquidityScore = 5;
    } else {
      liquidityScore = 0;
    }

    // 4. Debt-to-Asset Ratio = (Total Debt / Total Asset) * 100
    final double totalAssets = liquidAssets + nonLiquidAssets;
    _debtToAssetRatio = totalAssets > 0 ? (totalDebt / totalAssets) * 100 : 0;
    int assetDebtScore = 0;
    if (totalDebt == 0) {
      assetDebtScore = 15;
    } else if (_debtToAssetRatio < 30) {
      assetDebtScore = 15;
    } else if (_debtToAssetRatio < 50) {
      assetDebtScore = 10;
    } else if (_debtToAssetRatio <= 70) {
      assetDebtScore = 5;
    } else {
      assetDebtScore = 0;
    }

    // Calculate Overall Score
    _overallScore = savingScore + debtScore + liquidityScore + assetDebtScore;

    // Determine Health Status
    if (_overallScore >= 80) {
      _healthStatus = 'Sangat Sehat (Excellent)';
      _statusColor = const Color(0xFF00BFA5); // Teal/Primary
    } else if (_overallScore >= 60) {
      _healthStatus = 'Cukup Sehat (Good)';
      _statusColor = const Color(0xFFFFA500); // Amber
    } else {
      _healthStatus = 'Perlu Perbaikan (Poor)';
      _statusColor = const Color(0xFFE53935); // Red
    }

    // Generate Recommendations
    _recommendations.clear();

    if (_savingRatio < 15) {
      _recommendations.add({
        'title': 'Tingkatkan Rasio Menabung',
        'desc':
            'Rasio menabung Anda saat ini ${_savingRatio.toStringAsFixed(1)}% (ideal: >= 20%). Cobalah gunakan metode penganggaran 50/30/20 untuk mengunci pos tabungan di awal bulan sebelum dibelanjakan.',
        'actionText': 'Atur Budget 50/30/20',
        'route': '/budget-rule',
        'icon': Icons.pie_chart_rounded,
        'color': Colors.blue,
      });
    }

    if (_debtServiceRatio > 30) {
      _recommendations.add({
        'title': 'Kendalikan Pembayaran Utang',
        'desc':
            'Cicilan utang bulanan Anda memakan ${_debtServiceRatio.toStringAsFixed(1)}% pendapatan Anda. Batas aman adalah 30%. Batasi penambahan utang konsumtif baru dan susun strategi pelunasan.',
        'actionText': 'Buka Pelunas Hutang',
        'route': '/debt-payoff',
        'icon': Icons.money_off_rounded,
        'color': Colors.redAccent,
      });
    }

    if (_liquidityRatio < 3) {
      _recommendations.add({
        'title': 'Perkuat Dana Darurat',
        'desc':
            'Aset likuid Anda hanya cukup membiayai ${_liquidityRatio.toStringAsFixed(1)} bulan pengeluaran. Idealnya Anda membutuhkan dana darurat sebesar 3-6 bulan pengeluaran untuk mengantisipasi risiko tak terduga.',
        'actionText': 'Kalkulator Dana Darurat',
        'route': '/emergency-fund-calculator',
        'icon': Icons.shield_rounded,
        'color': Colors.orangeAccent,
      });
    }

    if (_debtToAssetRatio >= 50) {
      _recommendations.add({
        'title': 'Turunkan Rasio Utang/Aset',
        'desc':
            'Total utang Anda mencapai ${_debtToAssetRatio.toStringAsFixed(1)}% dari total aset yang dimiliki. Jika rasio di atas 50%, kekayaan bersih Anda rentan jika terjadi krisis keuangan. Prioritaskan pelunasan utang.',
        'actionText': 'Strategi Pelunasan Utang',
        'route': '/debt-payoff',
        'icon': Icons.trending_down_rounded,
        'color': Colors.deepPurple,
      });
    }

    setState(() {});
  }

  Widget _buildTrendIndicator(Color contentColor) {
    if (_checkupHistory.length < 2) return const SizedBox.shrink();

    final int latestScore = _checkupHistory[0]['score'] ?? 0;
    final int prevScore = _checkupHistory[1]['score'] ?? 0;
    final int diff = latestScore - prevScore;

    if (diff == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Skor Anda stabil seperti checkup terakhir (stabil di $latestScore poin). 📊',
          style: GoogleFonts.quicksand(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: contentColor.withOpacity(0.7)),
        ),
      );
    }

    final bool isUp = diff > 0;
    final String sign = isUp ? '+' : '';
    final Color trendColor =
        isUp ? const Color(0xFF00BFA5) : const Color(0xFFE53935);
    final String trendText = isUp ? 'meningkat' : 'menurun';
    final IconData trendIcon =
        isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Skor kesehatan finansial Anda $trendText $sign$diff poin dibanding checkup sebelumnya.',
              style: GoogleFonts.quicksand(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: trendColor,
              ),
            ),
          ),
        ],
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
    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
        ),
        title: Text(
          'Checkup Kesehatan Keuangan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ketahui kondisi kesehatan keuangan Anda berdasarkan 4 rasio finansial utama. Masukkan data keuangan bulanan Anda di bawah ini.',
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.primaryDark.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FORM CARD
            Card(
              color: cardBgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: isDarkMode ? 0 : 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah 1: Masukkan Data Bulanan',
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: contentColor),
                    ),
                    const SizedBox(height: 16),
                    _buildInput('Pendapatan Bersih Bulanan (Gaji, dll)',
                        _incomeCtrl, Icons.wallet_rounded, isDarkMode),
                    const SizedBox(height: 14),
                    _buildInput('Pengeluaran Bulanan (Belanja, Tagihan, dll)',
                        _expenseCtrl, Icons.shopping_bag_rounded, isDarkMode),
                    const SizedBox(height: 14),
                    _buildInput('Tabungan / Investasi Bulanan', _savingCtrl,
                        Icons.savings_rounded, isDarkMode),
                    const SizedBox(height: 14),
                    _buildInput(
                        'Cicilan Utang Bulanan (KPR, Paylater, dll)',
                        _debtPaymentCtrl,
                        Icons.credit_card_rounded,
                        isDarkMode),
                    const SizedBox(height: 20),
                    Text(
                      'Langkah 2: Masukkan Aset & Utang',
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: contentColor),
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                        'Aset Likuid (Cash, Tabungan, Dana Siaga)',
                        _liquidAssetsCtrl,
                        Icons.account_balance_wallet_rounded,
                        isDarkMode),
                    const SizedBox(height: 14),
                    _buildInput(
                        'Aset Non-Likuid (Emas, Saham, Properti)',
                        _nonLiquidAssetsCtrl,
                        Icons.trending_up_rounded,
                        isDarkMode),
                    const SizedBox(height: 14),
                    _buildInput('Total Sisa Nilai Utang Saat Ini',
                        _totalDebtCtrl, Icons.money_off_rounded, isDarkMode),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // RESULTS SECTION (If data inputted)
            if (_overallScore > 0) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      'Skor Kesehatan Finansial Anda',
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: contentColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 16),
                    // Beautiful radial score
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: _overallScore / 100,
                            strokeWidth: 12,
                            backgroundColor: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade200,
                            color: _statusColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_overallScore',
                              style: GoogleFonts.quicksand(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: contentColor),
                            ),
                            Text(
                              '/ 100',
                              style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: contentColor.withOpacity(0.4)),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor.withOpacity(0.3), width: 1.5),
                      ),
                      child: Text(
                        _healthStatus,
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _statusColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Save Button
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: _saveToHistory,
                        icon:
                            const Icon(Icons.bookmark_added_rounded, size: 18),
                        label: Text(
                          'Simpan Hasil Checkup',
                          style: GoogleFonts.quicksand(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Analisis Detail 4 Rasio Keuangan',
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: contentColor),
              ),
              const SizedBox(height: 12),

              // THE 4 RATIO CARDS
              _buildRatioCard(
                index: 0,
                title: 'Rasio Menabung (Saving Ratio)',
                value: '${_savingRatio.toStringAsFixed(1)}%',
                ideal: 'Ideal: >= 20%',
                status: _savingRatio >= 20
                    ? 'Sangat Sehat'
                    : (_savingRatio >= 10 ? 'Cukup Sehat' : 'Perlu Perbaikan'),
                statusColor: _savingRatio >= 20
                    ? Colors.teal
                    : (_savingRatio >= 10 ? Colors.amber : Colors.red),
                description:
                    'Menunjukkan seberapa besar porsi penghasilan yang disisihkan untuk masa depan.',
                details:
                    'Rasio menabung di atas 20% menunjukkan disiplin finansial yang luar biasa. Jika di bawah 10%, keuangan Anda berisiko terhambat pertumbuhannya di masa depan karena habis untuk konsumsi saat ini. Anda bisa meningkatkan rasio ini dengan memotong pengeluaran gaya hidup non-esensial sebesar 5-10% di bulan depan.',
                icon: Icons.savings_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                cardBgColor: cardBgColor,
              ),
              _buildRatioCard(
                index: 1,
                title: 'Beban Pembayaran Utang (Debt Service Ratio)',
                value: '${_debtServiceRatio.toStringAsFixed(1)}%',
                ideal: 'Ideal: < 30%',
                status: _debtServiceRatio <= 30
                    ? 'Sangat Sehat'
                    : (_debtServiceRatio <= 35
                        ? 'Cukup Aman'
                        : 'Bahaya/Tinggi'),
                statusColor: _debtServiceRatio <= 30
                    ? Colors.teal
                    : (_debtServiceRatio <= 35 ? Colors.amber : Colors.red),
                description:
                    'Menunjukkan seberapa banyak pendapatan bulanan habis untuk membayar cicilan utang.',
                details:
                    'Pembayaran cicilan utang di bawah 30% dari penghasilan memberikan ruang gerak finansial yang cukup luas. Jika melebihi 35%, Anda berisiko mengalami kesulitan arus kas bulanan karena gaji langsung habis didebet. Fokus kurangi pengeluaran dan gunakan saldo cadangan untuk melunasi utang kecil dengan bunga tertinggi (Metode Snowball/Avalanche).',
                icon: Icons.credit_card_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                cardBgColor: cardBgColor,
              ),
              _buildRatioCard(
                index: 2,
                title: 'Rasio Likuiditas (Dana Darurat)',
                value: '${_liquidityRatio.toStringAsFixed(1)}x pengeluaran',
                ideal: 'Ideal: 3 - 6x pengeluaran bulanan',
                status: _liquidityRatio >= 6
                    ? 'Sangat Sehat'
                    : (_liquidityRatio >= 3
                        ? 'Cukup Sehat'
                        : 'Perlu Perbaikan'),
                statusColor: _liquidityRatio >= 6
                    ? Colors.teal
                    : (_liquidityRatio >= 3 ? Colors.amber : Colors.red),
                description:
                    'Menunjukkan berapa bulan Anda bisa bertahan hidup dari tabungan jika kehilangan pekerjaan.',
                details:
                    'Rasio likuiditas mengukur kesiapan Anda menghadapi keadaan darurat seperti PHK atau sakit. Aset likuid mencakup cash, tabungan, dan instrumen investasi yang bisa ditarik dalam 24 jam. Jika rasio Anda di bawah 3, Anda perlu segera memfokuskan porsi tabungan Anda untuk memperkuat Dana Darurat.',
                icon: Icons.shield_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                cardBgColor: cardBgColor,
              ),
              _buildRatioCard(
                index: 3,
                title: 'Rasio Utang Terhadap Aset (Debt-to-Asset)',
                value: '${_debtToAssetRatio.toStringAsFixed(1)}%',
                ideal: 'Ideal: < 50%',
                status:
                    _debtToAssetRatio < 50 ? 'Sehat (Aman)' : 'Bahaya (Tinggi)',
                statusColor: _debtToAssetRatio < 50 ? Colors.teal : Colors.red,
                description:
                    'Menunjukkan perbandingan antara seluruh utang Anda dengan total aset yang Anda miliki.',
                details:
                    'Rasio di bawah 50% berarti nilai seluruh kekayaan bersih Anda (aset) masih jauh lebih besar daripada utang Anda. Jika rasio ini di atas 50%, ini berarti sebagian besar aset Anda didanai oleh utang. Risiko kebangkrutan pribadi menjadi tinggi jika nilai aset Anda menurun (misal: harga properti/saham turun).',
                icon: Icons.account_balance_rounded,
                isDarkMode: isDarkMode,
                contentColor: contentColor,
                cardBgColor: cardBgColor,
              ),

              const SizedBox(height: 20),

              // ACTIONABLE RECOMMENDATIONS LIST
              if (_recommendations.isNotEmpty) ...[
                Text(
                  'Rekomendasi Aksi & Solusi Finansial',
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: contentColor),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final item = _recommendations[index];
                    final Color itemColor = item['color'] as Color;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: itemColor.withOpacity(0.2), width: 1),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(item['icon'] as IconData,
                                  color: itemColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: contentColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color: contentColor.withOpacity(0.7),
                                height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: itemColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                context.push(item['route'] as String);
                              },
                              child: Text(
                                item['actionText'] as String,
                                style: GoogleFonts.quicksand(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],

            const SizedBox(height: 24),

            // HISTORY SECTION
            Text(
              'Riwayat Checkup Keuangan Anda',
              style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: contentColor),
            ),
            const SizedBox(height: 8),
            _buildTrendIndicator(contentColor),
            const SizedBox(height: 4),

            if (_checkupHistory.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.03)),
                ),
                child: Center(
                  child: Text(
                    'Belum ada riwayat checkup tersimpan.',
                    style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: contentColor.withOpacity(0.4),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _checkupHistory.length,
                itemBuilder: (context, index) {
                  final item = _checkupHistory[index];
                  final int score = item['score'] ?? 0;
                  final String dateStr = item['date'] ?? '';
                  final String statusText = item['status'] ?? 'Cukup Sehat';

                  // Re-determine color for log status
                  Color logStatusColor = Colors.amber;
                  if (score >= 80) {
                    logStatusColor = const Color(0xFF00BFA5);
                  } else if (score < 60) {
                    logStatusColor = const Color(0xFFE53935);
                  }

                  String displayDate = 'Checkup';
                  try {
                    final DateTime parsed = DateTime.parse(dateStr);
                    displayDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                        .format(parsed);
                  } catch (_) {}

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      onTap: () => _loadPastCheckup(item),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: logStatusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: logStatusColor),
                          ),
                        ),
                      ),
                      title: Text(
                        displayDate,
                        style: GoogleFonts.quicksand(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: contentColor),
                      ),
                      subtitle: Text(
                        'Status: $statusText',
                        style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: contentColor.withOpacity(0.5)),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent.withOpacity(0.7), size: 20),
                        onPressed: () => _deleteHistoryItem(index),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: contentColor.withOpacity(0.4),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_RibuanFormatter()],
          style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.25),
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Rp',
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.only(left: 0, right: 16, top: 12, bottom: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRatioCard({
    required int index,
    required String title,
    required String value,
    required String ideal,
    required String status,
    required Color statusColor,
    required String description,
    required String details,
    required IconData icon,
    required bool isDarkMode,
    required Color contentColor,
    required Color cardBgColor,
  }) {
    final bool isExpanded = _expandedCards[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<int>(index),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedCards[index] = expanded;
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.quicksand(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: contentColor),
          ),
          subtitle: Row(
            children: [
              Text(
                'Nilai: $value ',
                style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: contentColor.withOpacity(0.8)),
              ),
              Text(
                '($status)',
                style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ideal,
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: contentColor.withOpacity(0.6),
                        height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.03)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      details,
                      style: GoogleFonts.quicksand(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: contentColor.withOpacity(0.8),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
