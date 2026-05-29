import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/overseas_travel_model.dart';
import 'package:tabunganku/providers/overseas_travel_provider.dart';
import 'package:tabunganku/services/currency_service.dart';
import 'package:uuid/uuid.dart';

class OverseasTravelPage extends ConsumerStatefulWidget {
  const OverseasTravelPage({super.key});

  @override
  ConsumerState<OverseasTravelPage> createState() => _OverseasTravelPageState();
}

class _OverseasTravelPageState extends ConsumerState<OverseasTravelPage> {
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'United States Dollar', 'country': 'US'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'country': 'JP'},
    {'code': 'KRW', 'name': 'South Korean Won', 'country': 'KR'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'country': 'SG'},
    {'code': 'EUR', 'name': 'Euro', 'country': 'EU'},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'country': 'SA'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'country': 'MY'},
    {'code': 'THB', 'name': 'Thai Baht', 'country': 'TH'},
  ];

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    final goalsAsync = ref.watch(overseasTravelStreamProvider);
    final ratesAsync = ref.watch(currencyRatesProvider);

    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);

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
          'Target Luar Negeri',
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
            _buildInfoCard(isDarkMode),
            const SizedBox(height: 28),
            Text(
              'TARGET AKTIF',
              style: GoogleFonts.quicksand(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: contentColor.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 12),
            goalsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return _buildEmptyState(isDarkMode);
                }
                return Column(
                  children: goals.map((goal) {
                    final rates = ratesAsync.valueOrNull ?? {};
                    final currentRate = rates[goal.currencyCode] ?? 1.0;
                    return _buildGoalResultCard(goal, currentRate, isDarkMode);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3D49)),
                  ),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(isDarkMode),
        backgroundColor: const Color(0xFF2E3D49),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Target',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public_rounded,
            color: isDarkMode ? Colors.white70 : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rencanakan liburanmu dengan memantau kurs mata uang asing secara real-time. Tabungan ini tidak tercatat di riwayat utama.',
              style: GoogleFonts.quicksand(
                fontSize: 10,
                color: isDarkMode ? Colors.white70 : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(Icons.flight_takeoff_rounded, size: 48, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'Belum ada target liburan',
            style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white30 : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalResultCard(OverseasTravelGoalModel goal, double rate, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final idrFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final foreignFormat = NumberFormat.simpleCurrency(name: goal.currencyCode);

    final targetIdr = goal.targetForeignAmount * rate;
    final progress = (goal.collectedIdrAmount / targetIdr).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(_getFlag(goal.countryCode), style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.destinationName,
                        style: GoogleFonts.quicksand(
                          color: contentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(goal),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withOpacity(0.6), size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              idrFormat.format(goal.collectedIdrAmount),
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: contentColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Target: ${foreignFormat.format(goal.targetForeignAmount)} (~${idrFormat.format(targetIdr)})',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              color: isDarkMode ? Colors.white30 : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $percent%',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.tealAccent : const Color(0xFF2E3D49),
                ),
              ),
              Flexible(
                child: Text(
                  'Kurs: 1 ${goal.currencyCode} = ${idrFormat.format(rate)}',
                  style: GoogleFonts.quicksand(fontSize: 9, color: contentColor.withOpacity(0.3)),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.tealAccent : AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () => _showAddSavingDialog(goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white.withOpacity(0.08) : const Color(0xFF2E3D49),
                foregroundColor: isDarkMode ? Colors.white : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                'Tambah Tabungan',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCurrency = 'USD';
    String selectedCountry = 'US';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final iconColor = isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF2E3D49);
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 16,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Tambah Target Baru',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildCompactInput('Nama Tujuan', nameController, Icons.map_rounded, isDarkMode, isText: true, hint: 'Nama Tujuan'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              'Valuta Asing',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54,
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.currency_exchange_rounded, color: iconColor, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCurrency,
                                      isExpanded: true,
                                      dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                                      icon: Icon(Icons.arrow_drop_down_rounded, color: contentColor.withOpacity(0.4), size: 20),
                                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark, fontSize: 13),
                                      items: _currencies.map((c) {
                                        return DropdownMenuItem(
                                          value: c['code'],
                                          child: Text('${_getFlag(c['country']!)} ${c['code']}'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          selectedCurrency = val!;
                                          selectedCountry = _currencies.firstWhere((c) => c['code'] == val)['country']!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildCompactInput('Nominal Target', amountController, Icons.ads_click_rounded, isDarkMode, isText: false, hint: 'Nominal Target'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nama Tujuan tidak boleh kosong!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final targetVal = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                    if (targetVal <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nominal Target harus diisi!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final goal = OverseasTravelGoalModel(
                      id: const Uuid().v4(),
                      destinationName: nameController.text,
                      currencyCode: selectedCurrency,
                      targetForeignAmount: targetVal,
                      collectedIdrAmount: 0,
                      createdAt: DateTime.now(),
                      countryCode: selectedCountry,
                    );

                    ref.read(overseasTravelServiceProvider).addGoal(goal);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Target liburan berhasil dibuat!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                        backgroundColor: const Color(0xFF2E3D49),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3D49),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Target',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, {required bool isText, String? hint}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final iconColor = isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF2E3D49);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isText ? TextInputType.text : TextInputType.number,
          inputFormatters: isText ? [] : [_RibuanFormatter()],
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showAddSavingDialog(OverseasTravelGoalModel goal) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Tambah Tabungan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Masukkan nominal dalam Rupiah untuk tujuan ${goal.destinationName}', style: GoogleFonts.quicksand(fontSize: 13, color: contentColor.withOpacity(0.7))),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [_RibuanFormatter()],
              autofocus: true,
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white.withOpacity(0.8) : const Color(0xFF2E3D49)),
                hintText: 'Nominal',
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.quicksand(color: isDarkMode ? Colors.white38 : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.replaceAll('.', '');
              final amount = double.tryParse(text) ?? 0;
              if (amount > 0) {
                final updatedGoal = goal.copyWith(
                  collectedIdrAmount: goal.collectedIdrAmount + amount,
                );
                ref.read(overseasTravelServiceProvider).updateGoal(updatedGoal);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white.withOpacity(0.08) : const Color(0xFF2E3D49),
              foregroundColor: isDarkMode ? Colors.white : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Simpan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(OverseasTravelGoalModel goal) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus Target?', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor)),
        content: Text(
          'Apakah kamu yakin ingin menghapus target liburan ke ${goal.destinationName}?',
          style: GoogleFonts.quicksand(color: contentColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.quicksand(color: isDarkMode ? Colors.white38 : Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(overseasTravelServiceProvider).deleteGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getFlag(String countryCode) {
    if (countryCode == 'EU') return '🇪🇺';
    return countryCode.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
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
