import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class NetSalaryCalculatorPage extends ConsumerStatefulWidget {
  const NetSalaryCalculatorPage({super.key});

  @override
  ConsumerState<NetSalaryCalculatorPage> createState() => _NetSalaryCalculatorPageState();
}

class _NetSalaryCalculatorPageState extends ConsumerState<NetSalaryCalculatorPage> {
  final TextEditingController _basicSalaryController = TextEditingController();
  final TextEditingController _allowanceController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();

  String _ptkpStatus = 'TK/0';
  bool _hasNpwp = true;
  bool _deductBpjsTk = true;
  bool _deductBpjsKes = true;

  // PTKP Status Table
  final Map<String, double> _ptkpTable = {
    'TK/0': 54000000.0,
    'TK/1': 58500000.0,
    'TK/2': 63000000.0,
    'TK/3': 67500000.0,
    'K/0': 58500000.0,
    'K/1': 63000000.0,
    'K/2': 67500000.0,
    'K/3': 72000000.0,
  };

  final List<String> _ptkpOptions = [
    'TK/0',
    'TK/1',
    'TK/2',
    'TK/3',
    'K/0',
    'K/1',
    'K/2',
    'K/3',
  ];

  @override
  void dispose() {
    _basicSalaryController.dispose();
    _allowanceController.dispose();
    _bonusController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF4F7F6);

    // Get input numbers
    final basicSalary = double.tryParse(_basicSalaryController.text.replaceAll('.', '')) ?? 0.0;
    final allowance = double.tryParse(_allowanceController.text.replaceAll('.', '')) ?? 0.0;
    final bonus = double.tryParse(_bonusController.text.replaceAll('.', '')) ?? 0.0;

    // 1. Gross Income (Penghasilan Bruto Bulanan)
    final grossMonthly = basicSalary + allowance + bonus;

    // 2. BPJS Calculations
    // BPJS Ketenagakerjaan: JHT (2% of basic), JP (1% of basic, max base Rp 10.021.000 in 2024)
    double jhtDeduction = 0.0;
    double jpDeduction = 0.0;
    if (_deductBpjsTk && basicSalary > 0) {
      jhtDeduction = basicSalary * 0.02;
      
      final jpBase = basicSalary > 10021000.0 ? 10021000.0 : basicSalary;
      jpDeduction = jpBase * 0.01;
    }
    final totalBpjsTk = jhtDeduction + jpDeduction;

    // BPJS Kesehatan: 1% of basic + fixed allowance, max base Rp 12.000.000
    double bpjsKesDeduction = 0.0;
    if (_deductBpjsKes && grossMonthly > 0) {
      final bpjsKesBase = (basicSalary + allowance) > 12000000.0
          ? 12000000.0
          : (basicSalary + allowance);
      bpjsKesDeduction = bpjsKesBase * 0.01;
    }
    final totalBpjs = totalBpjsTk + bpjsKesDeduction;

    // 3. Position Fee (Biaya Jabatan): 5% of gross, max Rp 500.000 per month
    final positionFee = (grossMonthly * 0.05) > 500000.0 ? 500000.0 : (grossMonthly * 0.05);

    // 4. Net Monthly Income (Penghasilan Netto Bulanan)
    // Note: Deductions for tax calculation are Biaya Jabatan + JHT + JP (BPJS Kesehatan is NOT a tax deduction under progressive method)
    final netMonthly = grossMonthly - positionFee - totalBpjsTk;

    // 5. Annualized Net Income
    final netAnnual = netMonthly * 12;

    // 6. PTKP (Penghasilan Tidak Kena Pajak)
    final ptkpLimit = _ptkpTable[_ptkpStatus] ?? 54000000.0;

    // 7. PKP (Penghasilan Kena Pajak Setahun)
    final pkpAnnual = (netAnnual - ptkpLimit).clamp(0.0, double.infinity);

    // 8. Progressive Tax (PPh 21 Setahun)
    double taxAnnual = 0.0;
    double remainingPkp = pkpAnnual;

    // Tax Brackets (Tarif Progresif Pasal 17 UU HPP)
    final List<Map<String, dynamic>> taxBrackets = [
      {'limit': 60000000.0, 'rate': 0.05},
      {'limit': 190000000.0, 'rate': 0.15}, // 60jt to 250jt
      {'limit': 250000000.0, 'rate': 0.25}, // 250jt to 500jt
      {'limit': 450000000.0, 'rate': 0.30}, // 500jt to 5M
      {'limit': double.infinity, 'rate': 0.35}, // above 5M
    ];

    List<double> bracketTaxes = [];
    for (var bracket in taxBrackets) {
      final double limit = bracket['limit'];
      final double rate = bracket['rate'];

      if (remainingPkp > 0) {
        final taxableInBracket = remainingPkp > limit ? limit : remainingPkp;
        final taxInBracket = taxableInBracket * rate;
        bracketTaxes.add(taxInBracket);
        taxAnnual += taxInBracket;
        remainingPkp -= taxableInBracket;
      } else {
        bracketTaxes.add(0.0);
      }
    }

    // 9. NPWP Penalty (+20% tax if no NPWP)
    if (!_hasNpwp) {
      taxAnnual *= 1.2;
    }

    // 10. Monthly PPh 21
    final taxMonthly = taxAnnual / 12;

    // 11. Take Home Pay (Gaji Bersih Diterima)
    final takeHomePay = grossMonthly - totalBpjs - taxMonthly;

    // 12. Percentage calculations for the bar chart
    double thpPercent = 0.0;
    double taxPercent = 0.0;
    double bpjsPercent = 0.0;
    if (grossMonthly > 0) {
      thpPercent = takeHomePay / grossMonthly;
      taxPercent = taxMonthly / grossMonthly;
      bpjsPercent = totalBpjs / grossMonthly;
    }

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
          'Gaji Bersih & PPh 21',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadingSection(isDarkMode),
            const SizedBox(height: 24),

            // FORM SECTION CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                ),
                boxShadow: isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Gaji Pokok Bulanan',
                    controller: _basicSalaryController,
                    icon: Icons.payments_rounded,
                    isDarkMode: isDarkMode,
                    iconColor: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Tunjangan Bulanan (Transport, Makan, dll)',
                    controller: _allowanceController,
                    icon: Icons.add_card_rounded,
                    isDarkMode: isDarkMode,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Bonus / THR Bulanan (Opsional)',
                    controller: _bonusController,
                    icon: Icons.celebration_rounded,
                    isDarkMode: isDarkMode,
                    iconColor: Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  
                  // PTKP Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Status PTKP (Tanggungan)',
                          value: _ptkpStatus,
                          items: _ptkpOptions,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _ptkpStatus = val;
                              });
                            }
                          },
                          isDarkMode: isDarkMode,
                          contentColor: contentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Switch Options
                  _buildToggleRow(
                    label: 'Memiliki NPWP',
                    subtitle: 'Pajak +20% lebih mahal jika tidak memiliki NPWP',
                    value: _hasNpwp,
                    onChanged: (val) => setState(() => _hasNpwp = val),
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(height: 16, color: Colors.white10),
                  _buildToggleRow(
                    label: 'Potong BPJS Ketenagakerjaan',
                    subtitle: 'JHT (2%) & JP (1% dari maks Rp 10.021.000)',
                    value: _deductBpjsTk,
                    onChanged: (val) => setState(() => _deductBpjsTk = val),
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(height: 16, color: Colors.white10),
                  _buildToggleRow(
                    label: 'Potong BPJS Kesehatan',
                    subtitle: 'BPJS Kesehatan Karyawan (1% dari maks Rp 12.000.000)',
                    value: _deductBpjsKes,
                    onChanged: (val) => setState(() => _deductBpjsKes = val),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // RESULTS & SUMMARY SECTION
            if (grossMonthly > 0) ...[
              _buildResultsDashboard(
                isDarkMode,
                grossMonthly,
                takeHomePay,
                taxMonthly,
                totalBpjs,
                thpPercent,
                taxPercent,
                bpjsPercent,
                jhtDeduction,
                jpDeduction,
                bpjsKesDeduction,
                positionFee,
                ptkpLimit,
                pkpAnnual,
                taxAnnual,
                bracketTaxes,
                taxBrackets,
              ),
              const SizedBox(height: 24),
              _buildEducationalSection(isDarkMode),
            ] else
              _buildEmptyState(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadingSection(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hitung Take Home Pay',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: contentColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kalkulator pajak penghasilan PPh 21 & iuran jaminan sosial BPJS.',
          style: GoogleFonts.quicksand(
            fontSize: 11.5,
            color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
    Color? iconColor,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final resolvedIconColor = iconColor ?? (isDarkMode ? Colors.white70 : const Color(0xFF2E3D49));
    final inputBgColor = isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100;

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
              color: contentColor.withOpacity(0.5),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_RibuanFormatter()],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
            hintStyle: GoogleFonts.quicksand(fontSize: 13, color: isDarkMode ? Colors.white30 : Colors.grey.shade400),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: resolvedIconColor, size: 16),
                  const SizedBox(width: 4),
                  Text('Rp', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 14, top: 12, bottom: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
    required Color contentColor,
  }) {
    final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: contentColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: contentColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 10, bottom: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.group_rounded,
              color: isDarkMode ? Colors.tealAccent : AppColors.primaryDark,
              size: 18,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: contentColor.withOpacity(0.5),
          ),
          items: items.map((String val) {
            double amount = _ptkpTable[val] ?? 54000000.0;
            String text = '$val (PTKP: Rp ${NumberFormat.compactLong(locale: 'id_ID').format(amount)})';
            return DropdownMenuItem<String>(
              value: val,
              child: Text(text),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    final titleColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 9.5,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: isDarkMode ? Colors.tealAccent : AppColors.primary,
            activeTrackColor: (isDarkMode ? Colors.tealAccent : AppColors.primary).withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsDashboard(
    bool isDarkMode,
    double grossMonthly,
    double takeHomePay,
    double taxMonthly,
    double totalBpjs,
    double thpPercent,
    double taxPercent,
    double bpjsPercent,
    double jht,
    double jp,
    double bpjsKes,
    double positionFee,
    double ptkpLimit,
    double pkpAnnual,
    double taxAnnual,
    List<double> bracketTaxes,
    List<Map<String, dynamic>> taxBrackets,
  ) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final totalBpjsTk = jht + jp;
    final netAnnual = (grossMonthly - positionFee - totalBpjsTk) * 12;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Take Home Pay Header
          Center(
            child: Column(
              children: [
                Text(
                  'ESTIMASI GAJI BERSIH (THP)',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatRupiah(takeHomePay),
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.tealAccent : AppColors.primaryDark,
                    ),
                  ),
                ),
                Text(
                  'dari total bruto ${_formatRupiah(grossMonthly)}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stacked Segment Bar Chart
          _buildSegmentBarChart(thpPercent, taxPercent, bpjsPercent, isDarkMode),
          const SizedBox(height: 24),

          // Breakdown List
          _buildBreakdownRow(
            label: 'Penghasilan Bruto',
            value: _formatRupiah(grossMonthly),
            color: contentColor,
            isBold: true,
          ),
          if (totalBpjs > 0) ...[
            _buildBreakdownRow(
              label: 'Potongan BPJS Karyawan',
              value: '- ${_formatRupiah(totalBpjs)}',
              color: Colors.blueAccent,
              subtitle: 'JHT: ${_formatRupiah(jht)} | JP: ${_formatRupiah(jp)} | Kes: ${_formatRupiah(bpjsKes)}',
            ),
          ],
          _buildBreakdownRow(
            label: 'Pajak PPh 21 Bulanan',
            value: taxMonthly > 0 ? '- ${_formatRupiah(taxMonthly)}' : 'Rp 0',
            color: taxMonthly > 0 ? Colors.redAccent : Colors.green,
            subtitle: taxMonthly > 0 
                ? 'Efektif ${(taxPercent * 100).toStringAsFixed(1)}% dari bruto'
                : 'Bebas Pajak (di bawah PTKP)',
          ),
          
          const Divider(height: 24, color: Colors.white10),
          
          _buildBreakdownRow(
            label: 'Gaji Bersih Diterima (THP)',
            value: _formatRupiah(takeHomePay),
            color: isDarkMode ? Colors.tealAccent : AppColors.primary,
            isBold: true,
          ),

          const SizedBox(height: 12),
          
          // Expansion Detail PPh 21
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Lihat Rincian Perhitungan Pajak',
                style: GoogleFonts.quicksand(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.tealAccent : AppColors.primary,
                ),
              ),
              iconColor: isDarkMode ? Colors.tealAccent : AppColors.primary,
              collapsedIconColor: isDarkMode ? Colors.white30 : Colors.grey.shade400,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Penghasilan Bruto Setahun', _formatRupiah(grossMonthly * 12), isDarkMode),
                      _buildDetailRow('Biaya Jabatan Setahun', '- ${_formatRupiah(positionFee * 12)}', isDarkMode, note: '5% dari bruto, maks Rp 6 jt/thn'),
                      if (totalBpjsTk > 0)
                        _buildDetailRow('Potongan JHT & JP Setahun', '- ${_formatRupiah(totalBpjsTk * 12)}', isDarkMode, note: 'Hanya JHT & JP pengurang pajak'),
                      const Divider(color: Colors.white10),
                      _buildDetailRow('Penghasilan Netto Setahun', _formatRupiah(netAnnual), isDarkMode, isBold: true),
                      _buildDetailRow('PTKP Setahun ($_ptkpStatus)', '- ${_formatRupiah(ptkpLimit)}', isDarkMode),
                      const Divider(color: Colors.white10),
                      _buildDetailRow('Penghasilan Kena Pajak (PKP)', _formatRupiah(pkpAnnual), isDarkMode, isBold: true),
                      
                      const SizedBox(height: 12),
                      Text(
                        'Rincian Tarif Progresif Setahun:',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(taxBrackets.length, (idx) {
                        final bracket = taxBrackets[idx];
                        final rate = (bracket['rate'] * 100).toInt();
                        final taxInBracket = bracketTaxes.length > idx ? bracketTaxes[idx] : 0.0;
                        
                        String label = '';
                        if (idx == 0) {
                          label = 'Lapisan 1 (s.d Rp 60jt) @5%';
                        } else if (idx == 1) {
                          label = 'Lapisan 2 (>Rp 60jt - Rp 250jt) @15%';
                        } else if (idx == 2) {
                          label = 'Lapisan 3 (>Rp 250jt - Rp 500jt) @25%';
                        } else if (idx == 3) {
                          label = 'Lapisan 4 (>Rp 500jt - Rp 5M) @30%';
                        } else {
                          label = 'Lapisan 5 (>Rp 5M) @35%';
                        }

                        if (taxInBracket > 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.quicksand(fontSize: 10, color: isDarkMode ? Colors.white38 : Colors.grey.shade600, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _formatRupiah(taxInBracket),
                                  style: GoogleFonts.quicksand(fontSize: 10, color: contentColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      
                      const Divider(color: Colors.white10),
                      _buildDetailRow('Total Pajak Terutang Setahun', _formatRupiah(taxAnnual), isDarkMode, isBold: true),
                      if (!_hasNpwp && taxAnnual > 0)
                        _buildDetailRow('Penalti Tanpa NPWP (+20%)', 'Termasuk (+20% penalti)', isDarkMode, note: 'Sesuai UU PPh'),
                      _buildDetailRow('Pajak PPh 21 Bulanan (Dibagi 12)', _formatRupiah(taxMonthly), isDarkMode, isBold: true, color: Colors.redAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBarChart(double thp, double tax, double bpjs, bool isDarkMode) {
    // Prevent zero division layout crashes
    if (thp == 0 && tax == 0 && bpjs == 0) return const SizedBox.shrink();
    
    // Ensure small values are still slightly visible if they exist
    double minVisibleWidth = 0.05;
    double adjustedThp = thp;
    double adjustedTax = tax;
    double adjustedBpjs = bpjs;

    if (thp > 0 && thp < minVisibleWidth) adjustedThp = minVisibleWidth;
    if (tax > 0 && tax < minVisibleWidth) adjustedTax = minVisibleWidth;
    if (bpjs > 0 && bpjs < minVisibleWidth) adjustedBpjs = minVisibleWidth;

    double total = adjustedThp + adjustedTax + adjustedBpjs;
    double thpWidth = adjustedThp / total;
    double taxWidth = adjustedTax / total;
    double bpjsWidth = adjustedBpjs / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The Segmented Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 14,
            width: double.infinity,
            color: Colors.transparent,
            child: Row(
              children: [
                if (thp > 0)
                  Expanded(
                    flex: (thpWidth * 1000).round(),
                    child: Container(color: isDarkMode ? Colors.tealAccent : AppColors.primary),
                  ),
                if (bpjs > 0)
                  Expanded(
                    flex: (bpjsWidth * 1000).round(),
                    child: Container(color: Colors.blueAccent),
                  ),
                if (tax > 0)
                  Expanded(
                    flex: (taxWidth * 1000).round(),
                    child: Container(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // Legends
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (thp > 0)
              _buildLegendItem(
                color: isDarkMode ? Colors.tealAccent : AppColors.primary,
                label: 'Gaji Bersih',
                percentage: '${(thp * 100).toStringAsFixed(1)}%',
                isDarkMode: isDarkMode,
              ),
            if (bpjs > 0)
              _buildLegendItem(
                color: Colors.blueAccent,
                label: 'BPJS Karyawan',
                percentage: '${(bpjs * 100).toStringAsFixed(1)}%',
                isDarkMode: isDarkMode,
              ),
            if (tax > 0)
              _buildLegendItem(
                color: Colors.redAccent,
                label: 'Pajak PPh 21',
                percentage: '${(tax * 100).toStringAsFixed(1)}%',
                isDarkMode: isDarkMode,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String percentage,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($percentage)',
          style: GoogleFonts.quicksand(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isBold ? color : color.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 12.5,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.quicksand(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode, {bool isBold = false, Color? color, String? note}) {
    final defaultColor = isDarkMode ? Colors.white70 : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
                  color: color ?? defaultColor,
                ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 1),
            Text(
              note,
              style: GoogleFonts.quicksand(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEducationalSection(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.01) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: isDarkMode ? Colors.tealAccent : AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Informasi & Edukasi Finansial',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoItem(
            'PTKP (Penghasilan Tidak Kena Pajak)',
            'Batas pendapatan tahunan yang dibebaskan dari pajak. Untuk lajang tanpa tanggungan (TK/0), batasnya adalah Rp 54.000.000/tahun (Rp 4.500.000/bulan). Semakin banyak tanggungan, PTKP akan bertambah.',
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Biaya Jabatan 5%',
            'Pengurang wajib pajak karyawan resmi yang diasumsikan sebagai biaya pemeliharaan pekerjaan. Ditetapkan sebesar 5% dari bruto, dengan plafon maksimal Rp 500.000 per bulan (Rp 6.000.000/tahun).',
            isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Plafon Iuran BPJS Karyawan',
            'Iuran Jaminan Pensiun (JP) dihitung maksimal dari gaji pokok Rp 10.021.000 (iuran maks karyawan Rp 100.210). Sedangkan BPJS Kesehatan dihitung maksimal dari total gaji Rp 12.000.000 (iuran maks karyawan Rp 120.000).',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String desc, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.tealAccent : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          desc,
          style: GoogleFonts.quicksand(
            fontSize: 9.5,
            height: 1.4,
            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 44, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'Masukkan Gaji Pokok untuk\nmelihat hasil kalkulasi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white30 : Colors.grey),
          ),
        ],
      ),
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
