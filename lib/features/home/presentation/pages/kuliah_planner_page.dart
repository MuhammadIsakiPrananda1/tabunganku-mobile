import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class BiayaKuliahPlannerPage extends ConsumerStatefulWidget {
  const BiayaKuliahPlannerPage({super.key});

  @override
  ConsumerState<BiayaKuliahPlannerPage> createState() => _BiayaKuliahPlannerPageState();
}

class _BiayaKuliahPlannerPageState extends ConsumerState<BiayaKuliahPlannerPage> {
  final String _prefKeyKuliah = 'kuliah_planner_data_v1';

  // Config variables
  String _childName = '';
  String _academicLevel = 'S1 Dalam Negeri';
  int _currentAge = 0;
  int _targetAge = 18;
  double _costToday = 0.0;
  double _inflationRate = 10.0; // Keep standard 10% inflation baseline as slider helper
  double _currentSaved = 0.0;

  // Controllers
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _costTodayController = TextEditingController();
  final TextEditingController _currentSavedController = TextEditingController();

  final List<String> _levels = [
    'S1 Dalam Negeri',
    'S1 Luar Negeri',
    'S2 Dalam Negeri',
    'S2 Luar Negeri',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlannerData();
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _costTodayController.dispose();
    _currentSavedController.dispose();
    super.dispose();
  }

  Future<void> _loadPlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyKuliah);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _childName = decoded['childName'] as String? ?? '';
      _academicLevel = decoded['academicLevel'] as String? ?? 'S1 Dalam Negeri';
      _currentAge = decoded['currentAge'] as int? ?? 0;
      _targetAge = decoded['targetAge'] as int? ?? 18;
      _costToday = (decoded['costToday'] as num?)?.toDouble() ?? 0.0;
      _inflationRate = (decoded['inflationRate'] as num?)?.toDouble() ?? 10.0;
      _currentSaved = (decoded['currentSaved'] as num?)?.toDouble() ?? 0.0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePlannerData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'childName': _childName,
      'academicLevel': _academicLevel,
      'currentAge': _currentAge,
      'targetAge': _targetAge,
      'costToday': _costToday,
      'inflationRate': _inflationRate,
      'currentSaved': _currentSaved,
    };
    await prefs.setString(_prefKeyKuliah, jsonEncode(data));
  }

  // Calculated getters
  int get _yearsToStudy {
    final diff = _targetAge - _currentAge;
    return diff <= 0 ? 1 : diff;
  }

  double get _futureCost {
    // Compound interest: CostToday * (1 + inflation/100)^YearsToStudy
    return _costToday * pow((1 + _inflationRate / 100.0), _yearsToStudy);
  }

  double get _recommendedMonthlySavings {
    final gap = _futureCost - _currentSaved;
    if (gap <= 0) return 0.0;
    return gap / (_yearsToStudy * 12);
  }

  void _saveParameters() async {
    setState(() {
      if (_childNameController.text.trim().isNotEmpty) {
        _childName = _childNameController.text.trim();
      }
      final costText = _costTodayController.text.replaceAll('.', '');
      final cost = double.tryParse(costText) ?? 0.0;
      if (cost > 0) _costToday = cost;

      final savedText = _currentSavedController.text.replaceAll('.', '');
      final saved = double.tryParse(savedText) ?? 0.0;
      if (saved >= 0) _currentSaved = saved;
    });

    await _savePlannerData();

    _childNameController.clear();
    _costTodayController.clear();
    _currentSavedController.clear();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Planner Pendidikan Anak berhasil disimpan!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF2F8FD);
    final accentColor = const Color(0xFF2196F3); // Ocean Blue

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
          '🎓 Rencana Kuliah Anak',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          // Elegant Cost Projection Dashboard Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF0F3A5F), const Color(0xFF0B253F)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_academicLevel • ${_childName.isEmpty ? "Belum Diisi" : _childName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white70 : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.school_rounded, color: isDarkMode ? Colors.white : accentColor),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimasi Biaya Masa Depan (${_yearsToStudy} Thn Lagi):',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.blue.shade900.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_futureCost),
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdasarkan biaya saat ini: Rp ${NumberFormat.decimalPattern('id_ID').format(_costToday)} (Inflasi $_inflationRate%/Thn)',
                  style: GoogleFonts.quicksand(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white38 : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: isDarkMode ? Colors.white10 : Colors.blue.shade100),
                const SizedBox(height: 14),

                // Saving Advice
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tabungan Terkumpul',
                            style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_currentSaved),
                            style: GoogleFonts.quicksand(fontSize: 11.5, fontWeight: FontWeight.bold, color: contentColor),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rekomendasi Nabung / Bln',
                            style: GoogleFonts.quicksand(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_recommendedMonthlySavings),
                            style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Planner Controls
          Text(
            '⚙️ Atur Parameter & Kalkulator',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          ),
          const SizedBox(height: 14),

          // Parameters Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                // Age Slider Current
                _buildSliderRow(
                  'Umur Anak Sekarang',
                  '$_currentAge Tahun',
                  _currentAge.toDouble(),
                  0,
                  17,
                  (val) {
                    setState(() {
                      _currentAge = val.round();
                    });
                    _savePlannerData();
                  },
                ),
                const SizedBox(height: 16),

                // Age Slider Target
                _buildSliderRow(
                  'Target Mulai Kuliah',
                  '$_targetAge Tahun',
                  _targetAge.toDouble(),
                  18,
                  25,
                  (val) {
                    setState(() {
                      _targetAge = val.round();
                    });
                    _savePlannerData();
                  },
                ),
                const SizedBox(height: 16),

                // Inflation Slider
                _buildSliderRow(
                  'Estimasi Inflasi Pendidikan',
                  '$_inflationRate%',
                  _inflationRate,
                  3.0,
                  15.0,
                  (val) {
                    setState(() {
                      _inflationRate = double.parse(val.toStringAsFixed(1));
                    });
                    _savePlannerData();
                  },
                  divisions: 120,
                ),
                const SizedBox(height: 20),

                // Academic Level Dropdown Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tingkat Pendidikan',
                      style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor),
                    ),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _academicLevel,
                          dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 11.5),
                          items: _levels.map((l) {
                            return DropdownMenuItem(value: l, child: Text(l));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _academicLevel = val ?? _levels.first;
                            });
                            _savePlannerData();
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _showEditValuesDialog(isDarkMode, accentColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Edit Detail Nama & Biaya',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label, 
    String displayVal, 
    double currentVal, 
    double minVal, 
    double maxVal, 
    Function(double) onChanged,
    {int? divisions}
  ) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor),
            ),
            Text(
              displayVal,
              style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2196F3)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF2196F3),
            inactiveTrackColor: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
            thumbColor: const Color(0xFF2196F3),
            overlayColor: const Color(0xFF2196F3).withOpacity(0.12),
            trackHeight: 4,
          ),
          child: Slider(
            min: minVal,
            max: maxVal,
            value: currentVal,
            divisions: divisions ?? (maxVal - minVal).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showEditValuesDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sesuaikan Rincian Target',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
              ),
              const SizedBox(height: 20),

              // Child Name
              Text(
                'Nama Anak',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _childNameController,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Masukkan Nama Anak',
                  hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 16),

              // Cost today
              Text(
                'Uang Kuliah Hari Ini',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _costTodayController,
                keyboardType: TextInputType.number,
                inputFormatters: [_RibuanFormatter()],
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Masukkan Uang Kuliah Hari Ini',
                  hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rp',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Savings
              Text(
                'Tabungan Terkumpul',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _currentSavedController,
                keyboardType: TextInputType.number,
                inputFormatters: [_RibuanFormatter()],
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Masukkan Tabungan Terkumpul',
                  hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rp',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveParameters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Rincian Baru',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
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
