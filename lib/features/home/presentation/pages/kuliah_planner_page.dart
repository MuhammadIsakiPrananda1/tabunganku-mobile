import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class BiayaKuliahPlannerPage extends ConsumerStatefulWidget {
  const BiayaKuliahPlannerPage({super.key});

  @override
  ConsumerState<BiayaKuliahPlannerPage> createState() => _BiayaKuliahPlannerPageState();
}

class _BiayaKuliahPlannerPageState extends ConsumerState<BiayaKuliahPlannerPage> {
  // Config variables - All starting from 0 / clean defaults
  String _childName = '';
  String _academicLevel = 'S1 PTN Favorit';
  int _currentAge = 0;
  int _targetAge = 18;
  double _costToday = 0.0; // Starts from 0
  final double _inflationRate = 10.0; // Fixed 10% annual education inflation
  double _currentSaved = 0.0; // Starts from 0

  // College Cost Presets
  final Map<String, double> _costPresets = {
    'S1 PTN Favorit': 60000000.0,
    'S1 PTS Premium': 150000000.0,
    'S1 Kedokteran': 300000000.0,
    'S1 Luar Negeri': 600000000.0,
  };

  final List<String> _dropdownOptions = [
    'S1 PTN Favorit',
    'S1 PTS Premium',
    'S1 Kedokteran',
    'S1 Luar Negeri',
    'Custom',
  ];

  // Controllers
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _costTodayController = TextEditingController();
  final TextEditingController _currentSavedController = TextEditingController();

  @override
  void dispose() {
    _childNameController.dispose();
    _costTodayController.dispose();
    _currentSavedController.dispose();
    super.dispose();
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

  // Smart helper to display preset name matching the cost
  String get _displayAcademicLevel {
    if (_academicLevel == 'Custom') {
      for (final entry in _costPresets.entries) {
        if ((_costToday - entry.value).abs() < 1) {
          return entry.key;
        }
      }
      return 'Custom Biaya';
    }
    return _academicLevel;
  }

  void _saveParameters() {
    setState(() {
      _childName = _childNameController.text.trim();
      
      if (_academicLevel != 'Custom') {
        _costToday = _costPresets[_academicLevel] ?? 0.0;
      } else {
        final costText = _costTodayController.text.replaceAll('.', '');
        _costToday = double.tryParse(costText) ?? 0.0;
      }

      final savedText = _currentSavedController.text.replaceAll('.', '');
      _currentSaved = double.tryParse(savedText) ?? 0.0;
    });

    _childNameController.clear();
    _costTodayController.clear();
    _currentSavedController.clear();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rencana Pendidikan Anak berhasil diperbarui!',
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
          'Rencana Kuliah Anak',
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
          // Premium Minimalist Dashboard Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF0F3A5F), // Deep sky/ocean blue
                        const Color(0xFF0B253F),
                      ]
                    : [
                        const Color(0xFFE3F2FD), // Soft baby blue light
                        const Color(0xFFF2F8FD),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(isDarkMode ? 0.05 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDarkMode
                    ? accentColor.withOpacity(0.1)
                    : accentColor.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RENCANA KULIAH',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? Colors.white70 : Colors.blue.shade900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : accentColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _displayAcademicLevel,
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _childName.isEmpty ? 'Target Kuliah Anak' : 'Target Kuliah: $_childName',
                  style: GoogleFonts.quicksand(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Estimasi Biaya Masa Depan (${_yearsToStudy} Thn Lagi):',
                  style: GoogleFonts.quicksand(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white30 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_futureCost),
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uang Kuliah Sekarang: Rp ${NumberFormat.decimalPattern('id_ID').format(_costToday)} (Inflasi $_inflationRate%/thn)',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade200),
                const SizedBox(height: 16),
                
                // Savings summary row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tabungan Terkumpul',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_currentSaved),
                              style: GoogleFonts.quicksand(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Nabung / Bulan',
                            style: GoogleFonts.quicksand(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_recommendedMonthlySavings),
                              style: GoogleFonts.quicksand(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Parameter Perencanaan Card (Premium, Rapi & Aesthetic)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.02 : 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parameter Perencanaan',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 18),
                
                _buildSummaryRow(isDarkMode, contentColor, 'Nama Anak', _childName.isEmpty ? '-' : _childName, Icons.child_care_rounded, const Color(0xFF2196F3)),
                _buildSummaryRow(isDarkMode, contentColor, 'Tingkat Pendidikan', _displayAcademicLevel, Icons.school_rounded, const Color(0xFF4CAF50)),
                _buildSummaryRow(isDarkMode, contentColor, 'Umur Anak Sekarang', '$_currentAge Tahun', Icons.calendar_today_rounded, const Color(0xFFFF9800)),
                _buildSummaryRow(isDarkMode, contentColor, 'Mulai Kuliah', '$_targetAge Tahun ($_yearsToStudy Tahun Lagi)', Icons.rocket_launch_rounded, const Color(0xFFE91E63)),
                _buildSummaryRow(isDarkMode, contentColor, 'Estimasi Inflasi', '$_inflationRate% / Tahun', Icons.trending_up_rounded, const Color(0xFF9C27B0)),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditValuesDialog(isDarkMode, accentColor),
                    icon: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                    label: Text(
                      'Sesuaikan Rencana',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
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

  Widget _buildSummaryRow(bool isDarkMode, Color contentColor, String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required String valueText,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool isDarkMode,
    required Color contentColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: contentColor,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
                Text(
                  valueText,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: contentColor,
                  ),
                ),
                IconButton(
                  onPressed: onIncrement,
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
    required Color contentColor,
    required Color accentColor,
  }) {
    final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : const Color(0xFFF8F9FA);
    
    final String sanitizedValue = items.contains(value) ? value : 'S1 PTN Favorit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: contentColor.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: sanitizedValue,
          dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: contentColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.school_rounded,
              color: accentColor.withOpacity(0.8),
              size: 18,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: contentColor.withOpacity(0.5),
          ),
          items: items.map((String val) {
            String labelText = val;
            if (_costPresets.containsKey(val)) {
              final presetCost = _costPresets[val]!;
              labelText = '$val (Rp ${NumberFormat.compactLong(locale: 'id_ID').format(presetCost)})';
            } else if (val == 'Custom') {
              labelText = 'Custom (Input Manual)';
            }
            return DropdownMenuItem<String>(
              value: val,
              child: Text(labelText),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showEditValuesDialog(bool isDarkMode, Color accentColor) {
    if (!_dropdownOptions.contains(_academicLevel)) {
      _academicLevel = 'S1 PTN Favorit';
    }

    _childNameController.text = _childName;
    _costTodayController.text = _costToday > 0 ? NumberFormat.decimalPattern('id_ID').format(_costToday.round()) : '';
    _currentSavedController.text = _currentSaved > 0 ? NumberFormat.decimalPattern('id_ID').format(_currentSaved.round()) : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;

        return StatefulBuilder(
          builder: (context, setModalState) {
            bool showCustomCost = _academicLevel == 'Custom';

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
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
                      'Sesuaikan Rencana Kuliah',
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(
                          Icons.child_care_rounded,
                          color: accentColor.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Counter Umur Anak Sekarang
                    _buildCounterRow(
                      label: 'Umur Anak Sekarang',
                      valueText: '$_currentAge Tahun',
                      onDecrement: () {
                        if (_currentAge > 0) {
                          setModalState(() {
                            _currentAge--;
                            if (_targetAge <= _currentAge) {
                              _targetAge = _currentAge + 1;
                            }
                          });
                          setState(() {});
                        }
                      },
                      onIncrement: () {
                        if (_currentAge < 17) {
                          setModalState(() {
                            _currentAge++;
                            if (_targetAge <= _currentAge) {
                              _targetAge = _currentAge + 1;
                            }
                          });
                          setState(() {});
                        }
                      },
                      isDarkMode: isDarkMode,
                      contentColor: contentColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 8),

                    // Counter Target Mulai Kuliah
                    _buildCounterRow(
                      label: 'Target Mulai Kuliah',
                      valueText: '$_targetAge Tahun',
                      onDecrement: () {
                        if (_targetAge > _currentAge + 1 && _targetAge > 18) {
                          setModalState(() {
                            _targetAge--;
                          });
                          setState(() {});
                        }
                      },
                      onIncrement: () {
                        if (_targetAge < 25) {
                          setModalState(() {
                            _targetAge++;
                          });
                          setState(() {});
                        }
                      },
                      isDarkMode: isDarkMode,
                      contentColor: contentColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 18),

                    // Dropdown Pilihan Universitas
                    _buildDropdownField(
                      label: 'Pilihan Universitas & Jenjang',
                      value: _academicLevel,
                      items: _dropdownOptions,
                      onChanged: (val) {
                        setModalState(() {
                          _academicLevel = val ?? 'S1 PTN Favorit';
                          showCustomCost = _academicLevel == 'Custom';
                          if (_academicLevel != 'Custom') {
                            _costToday = _costPresets[_academicLevel] ?? 0.0;
                            _costTodayController.text = NumberFormat.decimalPattern('id_ID').format(_costToday.round());
                          }
                        });
                        setState(() {});
                      },
                      isDarkMode: isDarkMode,
                      contentColor: contentColor,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 18),

                    // Conditionally show custom cost input
                    if (showCustomCost) ...[
                      Text(
                        'Biaya Kuliah Hari Ini',
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
                          hintText: 'Masukkan Biaya Kuliah Hari Ini',
                          hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    ],
       
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
       
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveParameters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Simpan Rencana',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
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
