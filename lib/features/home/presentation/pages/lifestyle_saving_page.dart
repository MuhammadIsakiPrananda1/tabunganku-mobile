import 'dart:math';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/features/home/presentation/pages/saving_target_form_page.dart';

class LifestyleSavingPage extends ConsumerStatefulWidget {
  const LifestyleSavingPage({super.key});

  @override
  ConsumerState<LifestyleSavingPage> createState() => _LifestyleSavingPageState();
}

class _LifestyleSavingPageState extends ConsumerState<LifestyleSavingPage> {
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  String _selectedFrequency = 'Harian';
  String _selectedPreset = 'Kustom (Ketik Sendiri)';

  final List<String> _frequencies = [
    'Harian',
    'Setiap 2 hari',
    'Setiap 3 hari',
    'Mingguan',
    'Bulanan',
  ];

  final double _annualInterestRate = 6.0; // Asumsi bunga 6% per tahun
  final double _goldPricePerGram = 1200000; // Asumsi Rp 1.200.000 / gram

  // Presets
  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Kopi Kekinian',
      'cost': '25.000',
      'frequency': 'Harian',
    },
    {
      'name': 'Boba & Camilan',
      'cost': '30.000',
      'frequency': 'Setiap 3 hari',
    },
    {
      'name': 'Rokok / Vapor',
      'cost': '35.000',
      'frequency': 'Harian',
    },
    {
      'name': 'Jajan Ojol',
      'cost': '50.000',
      'frequency': 'Setiap 2 hari',
    },
    {
      'name': 'Streaming TV',
      'cost': '150.000',
      'frequency': 'Bulanan',
    },
    {
      'name': 'Kustom (Ketik Sendiri)',
      'cost': '0',
      'frequency': 'Harian',
    },
  ];

  @override
  void dispose() {
    _habitNameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  double _getFrequencyMultiplier(String freq) {
    switch (freq) {
      case 'Harian':
        return 30.0;
      case 'Setiap 2 hari':
        return 15.0;
      case 'Setiap 3 hari':
        return 10.0;
      case 'Mingguan':
        return 4.0;
      case 'Bulanan':
      default:
        return 1.0;
    }
  }

  double _calculateMonthlyCost() {
    final double cost = double.tryParse(_costController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    final double mult = _getFrequencyMultiplier(_selectedFrequency);
    return cost * mult;
  }

  double _calculateFutureValue(double monthlyAmount, int years) {
    if (_annualInterestRate <= 0) return monthlyAmount * 12 * years;
    final double r = (_annualInterestRate / 100) / 12;
    final int n = years * 12;
    return monthlyAmount * (pow(1 + r, n) - 1) / r;
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _habitNameController.text = preset['name'];
      _costController.text = preset['cost'];
      _selectedFrequency = preset['frequency'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final surfaceColor = isDarkMode ? AppColors.surfaceDark : Colors.white;

    final double monthlySavings = _calculateMonthlyCost();
    final double yearlySavings = monthlySavings * 12;

    // Projections
    final List<Map<String, dynamic>> projections = [
      {
        'year': 1,
        'value': _calculateFutureValue(monthlySavings, 1),
        'item': 'Emas 3gr / HP Entry',
        'icon': Icons.smartphone_rounded,
        'color': Colors.teal,
      },
      {
        'year': 5,
        'value': _calculateFutureValue(monthlySavings, 5),
        'item': 'Motor Matic Baru',
        'icon': Icons.motorcycle_rounded,
        'color': Colors.blueAccent,
      },
      {
        'year': 10,
        'value': _calculateFutureValue(monthlySavings, 10),
        'item': 'Biaya Umrah / DP KPR',
        'icon': Icons.home_work_rounded,
        'color': Colors.deepOrange,
      },
      {
        'year': 20,
        'value': _calculateFutureValue(monthlySavings, 20),
        'item': 'Mobil Baru / Kuliah Anak',
        'icon': Icons.directions_car_rounded,
        'color': Colors.purple,
      },
    ];

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
          'Detektor Pemborosan Receh',
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
            // Info Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hitung akumulasi biaya jajan harian kecil Anda jika ditabung atau diinvestasikan dalam jangka panjang.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown Preset
            Text(
              'Pilih Kebiasaan Jajan:',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: contentColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                  width: 1.2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPreset,
                  isExpanded: true,
                  dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                    fontSize: 11.5,
                  ),
                  icon: Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPreset = val;
                        final preset = _presets.firstWhere((p) => p['name'] == val);
                        if (val == 'Kustom (Ketik Sendiri)') {
                          _habitNameController.clear();
                          _costController.clear();
                        } else {
                          _habitNameController.text = preset['name'];
                          _costController.text = preset['cost'];
                          _selectedFrequency = preset['frequency'];
                        }
                      });
                    }
                  },
                  items: _presets.map((preset) => DropdownMenuItem<String>(
                    value: preset['name'],
                    child: Text(preset['name'], style: GoogleFonts.quicksand(fontSize: 11.5)),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conditional Custom Input Name
            if (_selectedPreset == 'Kustom (Ketik Sendiri)') ...[
              HighVisInput(
                controller: _habitNameController,
                icon: Icons.edit_note_rounded,
                label: 'Nama Pengeluaran Kustom',
                isDarkMode: isDarkMode,
                hintText: 'Masukkan Nama Pengeluaran',
              ),
              const SizedBox(height: 16),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: HighVisInput(
                    controller: _costController,
                    icon: Icons.payments_rounded,
                    label: 'Biaya Sekali Jajan',
                    prefixText: 'Rp',
                    isDarkMode: isDarkMode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _RibuanFormatter(),
                    ],
                    hintText: 'Masukkan Nominal',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frekuensi',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFrequency,
                            isExpanded: true,
                            dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                              fontSize: 11,
                            ),
                            icon: Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFrequency = val;
                                });
                              }
                            },
                            items: _frequencies.map((f) => DropdownMenuItem(
                              value: f,
                              child: Text(f, style: GoogleFonts.quicksand(fontSize: 11)),
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Total Per Bulan',
                          style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.4)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(monthlySavings),
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 30, width: 1, color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Total Per Tahun',
                          style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.4)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(yearlySavings),
                          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Table Projections
            Text(
              'Proyeksi Masa Depan (Bunga Majemuk 6%):',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: contentColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projections.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final proj = projections[index];
                  final double val = proj['value'];
                  final double goldGrams = val / _goldPricePerGram;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(proj['icon'], color: proj['color'], size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${proj['year']} Tahun',
                                      style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor),
                                    ),
                                    Text(
                                      proj['item'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatRupiah(val),
                              style: GoogleFonts.quicksand(fontSize: 11.5, fontWeight: FontWeight.bold, color: proj['color']),
                            ),
                            Text(
                              '~ ${goldGrams.toStringAsFixed(1)} gr Emas',
                              style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Tip Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Colors.teal, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tips: Cukup kurangi 50% jajan Anda untuk menabung ${_formatRupiah(yearlySavings / 2)}/tahun tanpa kehilangan kenyamanan jajan harian.',
                      style: GoogleFonts.quicksand(
                        fontSize: 10.5,
                        color: isDarkMode ? Colors.teal.shade300 : Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Button Action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (yearlySavings <= 0) {
                    showTopToast(context, 'Silakan masukkan nominal pengeluaran jajan terlebih dahulu.', isError: true);
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavingTargetFormPage(
                        target: SavingTargetModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: 'Hemat ${_habitNameController.text}',
                          targetAmount: yearlySavings,
                          dueDate: DateTime.now().add(const Duration(days: 365)),
                          createdAt: DateTime.now(),
                          category: 'Pembelian',
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.savings_rounded, size: 18),
                label: Text(
                  'Mulai Tabung Hemat Kopi & Boba',
                  style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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


