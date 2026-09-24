/// Page: TimeValueMoneyPage
///
/// Kalkulator nilai waktu uang (time value of money).
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class TimeValueMoneyPage extends ConsumerStatefulWidget {
  const TimeValueMoneyPage({super.key});

  @override
  ConsumerState<TimeValueMoneyPage> createState() =>
      _TimeValueMoneyPageState();
}

class _TimeValueMoneyPageState extends ConsumerState<TimeValueMoneyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final _formatCompact = NumberFormat.compactCurrency(
      locale: 'id_ID', symbol: 'Rp', decimalDigits: 2);

  // PV → FV
  final _pvAmountCtrl = TextEditingController();
  final _pvRateCtrl = TextEditingController(text: '8');
  final _pvYearsCtrl = TextEditingController(text: '10');
  String _pvCompounding = 'Tahunan';

  // FV → PV
  final _fvAmountCtrl = TextEditingController();
  final _fvRateCtrl = TextEditingController(text: '8');
  final _fvYearsCtrl = TextEditingController(text: '10');

  bool _pvHasResult = false;
  double _fvResult = 0;
  double _pvResult = 0;
  List<double> _fvGrowthPoints = [];
  bool _fvHasResult = false;

  final _compoundingOptions = ['Tahunan', 'Semesteran', 'Kuartalan', 'Bulanan', 'Harian'];

  int _compoundingN(String label) {
    switch (label) {
      case 'Semesteran': return 2;
      case 'Kuartalan': return 4;
      case 'Bulanan': return 12;
      case 'Harian': return 365;
      default: return 1;
    }
  }

  void _calculateFV() {
    final pv = _parseAmount(_pvAmountCtrl.text);
    final r = (double.tryParse(_pvRateCtrl.text) ?? 8) / 100;
    final years = int.tryParse(_pvYearsCtrl.text) ?? 10;
    final n = _compoundingN(_pvCompounding);

    if (pv <= 0 || years <= 0) return;

    // FV = PV * (1 + r/n)^(n*t)
    final fv = pv * pow(1 + r / n, n * years);

    // Growth points untuk chart
    final points = <double>[];
    for (int y = 0; y <= years; y++) {
      points.add(pv * pow(1 + r / n, n * y));
    }

    setState(() {
      _fvResult = fv;
      _fvGrowthPoints = points;
      _pvHasResult = true;
    });
  }

  void _calculatePV() {
    final fv = _parseAmount(_fvAmountCtrl.text);
    final r = (double.tryParse(_fvRateCtrl.text) ?? 8) / 100;
    final years = int.tryParse(_fvYearsCtrl.text) ?? 10;

    if (fv <= 0 || years <= 0) return;

    // PV = FV / (1 + r)^t
    final pv = fv / pow(1 + r, years);

    setState(() {
      _pvResult = pv;
      _fvHasResult = true;
    });
  }

  double _parseAmount(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pvAmountCtrl.dispose();
    _pvRateCtrl.dispose();
    _pvYearsCtrl.dispose();
    _fvAmountCtrl.dispose();
    _fvRateCtrl.dispose();
    _fvYearsCtrl.dispose();
    super.dispose();
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
          'Nilai Waktu Uang',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600, fontSize: 12),
          labelColor: Colors.deepPurple,
          unselectedLabelColor:
              isDarkMode ? Colors.white38 : Colors.grey.shade400,
          indicatorColor: Colors.deepPurple,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Sekarang → Masa Depan'),
            Tab(text: 'Masa Depan → Sekarang'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFVTab(isDarkMode),
          _buildPVTab(isDarkMode),
        ],
      ),
    );
  }

  // ── TAB 1: PV → FV ────────────────────────────────────────────────────────
  Widget _buildFVTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoBanner(
            isDarkMode: isDarkMode,
            text:
                'Uang Rp1 juta hari ini akan bernilai LEBIH di masa depan jika diinvestasikan.',
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 20),
          _buildFormCard(isDarkMode, children: [
            _buildField(
              label: 'Jumlah Uang Saat Ini (PV)',
              controller: _pvAmountCtrl,
              isDarkMode: isDarkMode,
              prefix: 'Rp',
              onChanged: (_) => setState(() => _pvHasResult = false),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _buildField(
                  label: 'Suku Bunga / Return (%)',
                  controller: _pvRateCtrl,
                  isDarkMode: isDarkMode,
                  suffix: '%',
                  isCurrency: false,
                  onChanged: (_) => setState(() => _pvHasResult = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Jangka Waktu',
                  controller: _pvYearsCtrl,
                  isDarkMode: isDarkMode,
                  suffix: 'tahun',
                  isCurrency: false,
                  onChanged: (_) => setState(() => _pvHasResult = false),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Text('Frekuensi Bunga',
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: isDarkMode
                        ? Colors.white38
                        : Colors.grey.shade500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _compoundingOptions.map((opt) {
                final sel = _pvCompounding == opt;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _pvCompounding = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.deepPurple
                          : (isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(opt,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: sel
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white54
                                    : Colors.grey.shade600))),
                  ),
                );
              }).toList(),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculateFV,
              icon: const Icon(Icons.trending_up_rounded, size: 18),
              label: Text('Hitung Nilai Masa Depan',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          if (_pvHasResult) ...[
            const SizedBox(height: 20),
            _buildFVResult(isDarkMode),
            const SizedBox(height: 20),
            _buildGrowthChart(isDarkMode),
            const SizedBox(height: 20),
            _buildFVInsight(isDarkMode),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFVResult(bool isDarkMode) {
    final pv = _parseAmount(_pvAmountCtrl.text);
    final gain = _fvResult - pv;
    final gainPct = pv > 0 ? (gain / pv * 100) : 0;
    final years = int.tryParse(_pvYearsCtrl.text) ?? 10;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nilai dalam $years Tahun',
              style: GoogleFonts.quicksand(
                  color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          Text(_formatCurrency.format(_fvResult),
              style: GoogleFonts.quicksand(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _resultChip('Modal Awal', _formatCompact.format(pv), Colors.white),
              _resultChip(
                  'Keuntungan',
                  '+${_formatCompact.format(gain)}',
                  Colors.greenAccent),
              _resultChip(
                  'Gain %',
                  '+${gainPct.toStringAsFixed(1)}%',
                  Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultChip(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.quicksand(
                color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.quicksand(
                color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGrowthChart(bool isDarkMode) {
    if (_fvGrowthPoints.isEmpty) return const SizedBox.shrink();
    final maxVal = _fvGrowthPoints.reduce(max);
    final minVal = _fvGrowthPoints.reduce(min);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grafik Pertumbuhan',
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : AppColors.primaryDark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _fvGrowthPoints.asMap().entries.map((entry) {
                final idx = entry.key;
                final val = entry.value;
                final barH = maxVal > minVal
                    ? ((val - minVal) / (maxVal - minVal))
                    : 1.0;
                final isLast = idx == _fvGrowthPoints.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + idx * 30),
                          height: (barH * 80).clamp(4.0, 80.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLast
                                  ? [Colors.deepPurple, Colors.purple]
                                  : [
                                      Colors.deepPurple.withValues(alpha: 0.3),
                                      Colors.deepPurple.withValues(alpha: 0.5)
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tahun 0',
                  style: GoogleFonts.quicksand(
                      fontSize: 10,
                      color: isDarkMode
                          ? Colors.white38
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w600)),
              Text('Tahun ${_fvGrowthPoints.length - 1}',
                  style: GoogleFonts.quicksand(
                      fontSize: 10,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFVInsight(bool isDarkMode) {
    final pv = _parseAmount(_pvAmountCtrl.text);
    final rate = double.tryParse(_pvRateCtrl.text) ?? 8;
    final years = int.tryParse(_pvYearsCtrl.text) ?? 10;
    final doublingYears = 72 / rate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.deepPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.deepPurple, size: 18),
              const SizedBox(width: 8),
              Text('Insight',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '📊 Dengan return $rate% per tahun, uangmu akan BERLIPAT ganda setiap ${doublingYears.toStringAsFixed(1)} tahun (Aturan 72).',
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isDarkMode
                    ? Colors.purple.shade200
                    : Colors.deepPurple.shade700),
          ),
          if (years >= doublingYears) ...[
            const SizedBox(height: 6),
            Text(
              '💎 Dalam $years tahun, uangmu bisa berlipat ${(years / doublingYears).toStringAsFixed(1)}x lipat!',
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.purple.shade200
                      : Colors.deepPurple.shade700),
            ),
          ],
        ],
      ),
    );
  }

  // ── TAB 2: FV → PV ────────────────────────────────────────────────────────
  Widget _buildPVTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoBanner(
            isDarkMode: isDarkMode,
            text:
                'Berapa yang harus kamu investasikan SEKARANG agar punya uang sejumlah tertentu di masa depan?',
            color: Colors.teal,
          ),
          const SizedBox(height: 20),
          _buildFormCard(isDarkMode, children: [
            _buildField(
              label: 'Target Uang di Masa Depan (FV)',
              controller: _fvAmountCtrl,
              isDarkMode: isDarkMode,
              prefix: 'Rp',
              onChanged: (_) => setState(() => _fvHasResult = false),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _buildField(
                  label: 'Suku Bunga / Return (%)',
                  controller: _fvRateCtrl,
                  isDarkMode: isDarkMode,
                  suffix: '%',
                  isCurrency: false,
                  onChanged: (_) => setState(() => _fvHasResult = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Dalam Berapa Tahun',
                  controller: _fvYearsCtrl,
                  isDarkMode: isDarkMode,
                  suffix: 'tahun',
                  isCurrency: false,
                  onChanged: (_) => setState(() => _fvHasResult = false),
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculatePV,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text('Hitung Modal yang Dibutuhkan',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          if (_fvHasResult) ...[
            const SizedBox(height: 20),
            _buildPVResult(isDarkMode),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPVResult(bool isDarkMode) {
    final fv = _parseAmount(_fvAmountCtrl.text);
    final rate = double.tryParse(_fvRateCtrl.text) ?? 8;
    final years = int.tryParse(_fvYearsCtrl.text) ?? 10;
    final interestEarned = fv - _pvResult;
    final effectivePct = fv > 0 ? (_pvResult / fv * 100) : 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00897B), Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modal yang Perlu Diinvestasikan Sekarang',
                  style: GoogleFonts.quicksand(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              const SizedBox(height: 6),
              Text(_formatCurrency.format(_pvResult),
                  style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30)),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _resultChip('Target', _formatCompact.format(fv), Colors.white),
                  _resultChip(
                      'Bunga Didapat',
                      _formatCompact.format(interestEarned),
                      Colors.greenAccent),
                  _resultChip(
                      'Efisiensi',
                      '${effectivePct.toStringAsFixed(1)}% modal',
                      Colors.amber),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.teal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: Colors.teal, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '💡 Kamu hanya perlu menyediakan ${_formatCurrency.format(_pvResult)} sekarang, sisanya ${_formatCurrency.format(interestEarned)} akan dihasilkan dari bunga dalam $years tahun dengan return $rate%.',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isDarkMode
                          ? Colors.teal.shade200
                          : Colors.teal.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────
  Widget _buildInfoBanner({
    required bool isDarkMode,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isDarkMode ? color.withValues(alpha: 0.8) : color)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isDarkMode,
      {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isDarkMode,
    String? prefix,
    String? suffix,
    String? hint,
    bool isCurrency = true,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color:
                    isDarkMode ? Colors.white38 : Colors.grey.shade500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isCurrency
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isCurrency
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          onChanged: onChanged,
          style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDarkMode ? Colors.white : AppColors.primaryDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.quicksand(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                fontSize: 13),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                fontSize: 13),
            suffixText: suffix,
            suffixStyle: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                fontSize: 13),
            filled: true,
            fillColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.white10
                        : Colors.grey.shade100)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.deepPurple, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

