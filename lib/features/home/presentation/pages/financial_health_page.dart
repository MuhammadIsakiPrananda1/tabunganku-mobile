import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class FinancialHealthPage extends ConsumerStatefulWidget {
  const FinancialHealthPage({super.key});

  @override
  ConsumerState<FinancialHealthPage> createState() => _FinancialHealthPageState();
}

class _FinancialHealthPageState extends ConsumerState<FinancialHealthPage> {

  String _currentState = 'intro';
  int _currentQuestionIndex = 0;
  final List<int> _selectedScores = [];

  final List<_QuestionData> _questions = [
    _QuestionData(
      question: 'Berapa persentase pendapatan bulanan yang berhasil kamu tabung?',
      options: [
        _OptionData(text: 'Kurang dari 10%', score: 5),
        _OptionData(text: '10% - 20%', score: 10),
        _OptionData(text: '20% - 30%', score: 15),
        _OptionData(text: 'Lebih dari 30%', score: 20),
      ],
    ),
    _QuestionData(
      question: 'Apakah kamu sudah memiliki Dana Darurat?',
      options: [
        _OptionData(text: 'Belum punya sama sekali', score: 5),
        _OptionData(text: 'Sedikit (kurang dari 3 bulan pengeluaran)', score: 10),
        _OptionData(text: 'Cukup (3 - 6 bulan pengeluaran)', score: 15),
        _OptionData(text: 'Sangat Aman (lebih dari 6 bulan pengeluaran)', score: 20),
      ],
    ),
    _QuestionData(
      question: 'Bagaimana kondisi cicilan / hutang konsumtifmu (Paylater, Kartu Kredit)?',
      options: [
        _OptionData(text: 'Sangat banyak & sering menunggak', score: 5),
        _OptionData(text: 'Cukup besar tapi masih bisa terbayar', score: 10),
        _OptionData(text: 'Kecil & selalu lunas tepat waktu', score: 15),
        _OptionData(text: 'Bebas cicilan/hutang konsumtif sama sekali', score: 20),
      ],
    ),
    _QuestionData(
      question: 'Apakah kamu rutin membagi pos anggaran belanja (budgeting) bulanan?',
      options: [
        _OptionData(text: 'Tidak pernah, uang mengalir begitu saja', score: 5),
        _OptionData(text: 'Hanya sesekali mencatat pengeluaran', score: 10),
        _OptionData(text: 'Selalu mencatat keuangan harian', score: 15),
        _OptionData(text: 'Selalu bagi anggaran di awal bulan (Aturan 50/30/20)', score: 20),
      ],
    ),
    _QuestionData(
      question: 'Bagaimana kebiasaan investasimu untuk masa depan?',
      options: [
        _OptionData(text: 'Belum pernah berinvestasi sama sekali', score: 5),
        _OptionData(text: 'Pernah tapi tidak konsisten', score: 10),
        _OptionData(text: 'Rutin menabung emas / aset stabil', score: 15),
        _OptionData(text: 'Rutin investasi bulanan di berbagai instrumen', score: 20),
      ],
    ),
  ];

  void _startQuiz() {
    setState(() {
      _currentState = 'quiz';
      _currentQuestionIndex = 0;
      _selectedScores.clear();
    });
  }

  void _selectOption(int score) {
    _selectedScores.add(score);
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _currentState = 'result';
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentState = 'intro';
      _currentQuestionIndex = 0;
      _selectedScores.clear();
    });
  }

  int _calculateTotalScore() {
    return _selectedScores.fold(0, (sum, score) => sum + score);
  }

  _HealthGrade _getGrade(int score) {
    if (score <= 45) {
      return _HealthGrade(
        title: 'KRITIS',
        color: Colors.redAccent,
        description: 'Pertahanan finansialmu berada dalam kondisi kritis. Kamu sangat rentan apabila terjadi pengeluaran mendadak. Mulailah menghemat belanja non-esensial dan kumpulkan dana darurat.',
        recommendations: [
          _ActionRecommendation(
            title: 'Mulai Tabungan Receh',
            subtitle: 'Kumpulkan uang kecilmu agar jadi bukit',
            route: '/piggy-bank',
            icon: Icons.savings_rounded,
          ),
          _ActionRecommendation(
            title: 'Aturan Budget 50/30/20',
            subtitle: 'Bagi gajimu ke pos Kebutuhan, Keinginan & Tabungan',
            route: '/budget-rule',
            icon: Icons.pie_chart_rounded,
          ),
          _ActionRecommendation(
            title: 'Kalkulator Bebas Hutang',
            subtitle: 'Rancang rencana pelunasan cicilan konsumtif',
            route: '/debt-payoff',
            icon: Icons.money_off_rounded,
          ),
        ],
      );
    } else if (score <= 65) {
      return _HealthGrade(
        title: 'WASPADA',
        color: Colors.orangeAccent,
        description: 'Keuanganmu cukup stabil namun belum memiliki jaring pengaman yang memadai. Kurangi ketergantungan pada paylater dan prioritaskan pengisian tabungan dana darurat.',
        recommendations: [
          _ActionRecommendation(
            title: 'Tabungan Dana Darurat',
            subtitle: 'Sisihkan khusus untuk kebutuhan darurat medis/kerja',
            route: '/emergency-fund',
            icon: Icons.health_and_safety_rounded,
          ),
          _ActionRecommendation(
            title: 'Kelola Langganan Rutin',
            subtitle: 'Hapus langganan streaming yang jarang dipakai',
            route: '/recurring',
            icon: Icons.loop_rounded,
          ),
          _ActionRecommendation(
            title: 'Simulasi Pertumbuhan Tabungan',
            subtitle: 'Hitung pertumbuhan dana impianmu',
            route: '/saving-simulator',
            icon: Icons.calculate_rounded,
          ),
        ],
      );
    } else if (score <= 85) {
      return _HealthGrade(
        title: 'SEHAT',
        color: Colors.green,
        description: 'Selamat! Pengelolaan keuanganmu sudah sehat dan disiplin. Kamu siap menghadapi ketidakpastian. Langkah berikutnya adalah memaksimalkan pertumbuhan asetmu.',
        recommendations: [
          _ActionRecommendation(
            title: 'Dana Rencana Masa Depan',
            subtitle: 'Buat target tabungan spesifik berjangka',
            route: '/saving-plans',
            icon: Icons.assignment_turned_in_rounded,
          ),
          _ActionRecommendation(
            title: 'Investasi Emas',
            subtitle: 'Lindungi nilai mata uangmu dengan emas stabil',
            route: '/gold',
            icon: Icons.monetization_on_rounded,
          ),
          _ActionRecommendation(
            title: 'Portofolio Investasi',
            subtitle: 'Pantau dan diversifikasi seluruh aset investasimu',
            route: '/investment',
            icon: Icons.trending_up_rounded,
          ),
        ],
      );
    } else {
      return _HealthGrade(
        title: 'SANGAT SEHAT (FINANCIAL HERO)',
        color: Colors.teal,
        description: 'Luar biasa! Kamu adalah Financial Hero. Kamu menguasai perencanaan anggaran, memiliki dana darurat solid, dan konsisten berinvestasi. Pertahankan kedisiplinan luar biasa ini!',
        recommendations: [
          _ActionRecommendation(
            title: 'Rencana Kebebasan Finansial (FIRE)',
            subtitle: 'Hitung kapan kamu bisa pensiun dini secara mandiri',
            route: '/fire-calculator',
            icon: Icons.insights_rounded,
          ),
          _ActionRecommendation(
            title: 'Simulasi Bunga Majemuk',
            subtitle: 'Lihat efek bola salju pertumbuhan investasi jangka panjang',
            route: '/compound-interest',
            icon: Icons.trending_up_rounded,
          ),
          _ActionRecommendation(
            title: 'Zakat & Sedekah Harta',
            subtitle: 'Bersihkan dan berkahi aset keuanganmu',
            route: '/zakat',
            icon: Icons.volunteer_activism_rounded,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              size: 18),
        ),
        title: Text(
          'Cek Kesehatan Finansial',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(isDarkMode),
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    switch (_currentState) {
      case 'quiz':
        return _buildQuizScreen(isDarkMode);
      case 'result':
        return _buildResultScreen(isDarkMode);
      case 'intro':
      default:
        return _buildIntroScreen(isDarkMode);
    }
  }

  Widget _buildIntroScreen(bool isDarkMode) {
    return SingleChildScrollView(
      key: const ValueKey('intro_key'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: isDarkMode ? 0.12 : 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 72,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Seberapa Sehat Keuanganmu?',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ikuti checkup kesehatan keuangan 1 menit untuk mengetahui skor keuanganmu, analisis risiko, serta rekomendasi langkah menabung yang tepat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              height: 1.6,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),

          _buildInfoRow(
            isDarkMode,
            Icons.speed_rounded,
            'Skor Akurat',
            'Dapatkan skor dinamis 25-100 berdasarkan jawabanmu.',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            isDarkMode,
            Icons.psychology_rounded,
            'Rekomendasi Cerdas',
            'Saran finansial personal yang disesuaikan dengan kebutuhan tabunganmu.',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            isDarkMode,
            Icons.link_rounded,
            'Terintegrasi Langsung',
            'Ambil tindakan menabung segera melalui tautan fitur aplikasi terintegrasi.',
          ),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Mulai Cek Kesehatan',
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDarkMode, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 11.5,
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScreen(bool isDarkMode) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      key: ValueKey('quiz_key_$_currentQuestionIndex'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 40),

          Text(
            currentQuestion.question,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 32),

          ...List.generate(currentQuestion.options.length, (idx) {
            final option = currentQuestion.options[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF111111) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _selectOption(option.score),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [

                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.text,
                            style: GoogleFonts.quicksand(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen(bool isDarkMode) {
    final totalScore = _calculateTotalScore();
    final grade = _getGrade(totalScore);

    return SingleChildScrollView(
      key: const ValueKey('result_key'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            width: 150,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: grade.color.withValues(alpha: isDarkMode ? 0.05 : 0.03),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: totalScore / 100,
                    strokeWidth: 10,
                    backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(grade.color),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalScore',
                      style: GoogleFonts.quicksand(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : AppColors.primaryDark,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Skor',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: grade.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: grade.color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Text(
              grade.title,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: grade.color,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            grade.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              height: 1.6,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 32),

          Divider(
            height: 1,
            color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rekomendasi Langkah Nyata',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(grade.recommendations.length, (idx) {
            final action = grade.recommendations[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF111111) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => context.push(action.route),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: isDarkMode ? 0.12 : 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(action.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.title,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                action.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
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
                          color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _resetQuiz,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Ulangi Checkup',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuestionData {
  final String question;
  final List<_OptionData> options;

  _QuestionData({required this.question, required this.options});
}

class _OptionData {
  final String text;
  final int score;

  _OptionData({required this.text, required this.score});
}

class _HealthGrade {
  final String title;
  final Color color;
  final String description;
  final List<_ActionRecommendation> recommendations;

  _HealthGrade({
    required this.title,
    required this.color,
    required this.description,
    required this.recommendations,
  });
}

class _ActionRecommendation {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;

  _ActionRecommendation({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}
