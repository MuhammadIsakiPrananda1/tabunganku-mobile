import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';

class SavingSimulatorPage extends ConsumerStatefulWidget {
  const SavingSimulatorPage({super.key});

  @override
  ConsumerState<SavingSimulatorPage> createState() => _SavingSimulatorPageState();
}

class _SavingSimulatorPageState extends ConsumerState<SavingSimulatorPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '12');
  String _unit = 'Bulan';
  double _targetAmount = 0;
  int _durationCount = 12;

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(text) ?? 0;
    final dur = int.tryParse(_durationController.text) ?? 1;
    
    setState(() {
      _targetAmount = amount;
      _durationCount = dur;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final transactions = ref.watch(transactionsByGroupProvider(null));
    
    // Calculate current personal balance (non-manual)
    final currentBalance = transactions
        .fold<double>(0, (s, t) => s + (t.type == TransactionType.income ? t.amount : -t.amount));

    final remaining = (_targetAmount - currentBalance).clamp(0.0, double.infinity);
    final progress = _targetAmount > 0 ? (currentBalance / _targetAmount).clamp(0.0, 1.0) : 0.0;
    
    double daily = 0, weekly = 0, monthly = 0;
    int totalDays = 1;
    if (_durationCount > 0) {
      if (_unit == 'Hari') totalDays = _durationCount;
      if (_unit == 'Minggu') totalDays = _durationCount * 7;
      if (_unit == 'Bulan') totalDays = _durationCount * 30;
      if (_unit == 'Tahun') totalDays = _durationCount * 365;

      daily = remaining / totalDays;
      weekly = remaining / (totalDays / 7);
      monthly = remaining / (totalDays / 30);
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Simulasi Tabungan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hitung Tabungan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.5)),
                const SizedBox(height: 8),
                Text('Rencanakan masa depan finansialmu dengan tepat.', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                
                const SizedBox(height: 32),

                // FORM SECTION
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET DANA IMPIAN *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white24 : Colors.black38, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanSeparatorInputFormatter()],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: isDarkMode ? Colors.white12 : Colors.black26),
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                            const SizedBox(width: 8),
                          ],
                        ),
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onChanged: (_) => _calculate(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DURASI *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white24 : Colors.black38, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _durationController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  hintText: '12',
                                  prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                                  filled: false,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                ),
                                onChanged: (_) => _calculate(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SATUAN *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white24 : Colors.black38, letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _unit,
                                      isExpanded: true,
                                      icon: const Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Icon(Icons.expand_more_rounded, color: AppColors.primary),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                                      borderRadius: BorderRadius.circular(16),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87),
                                      items: ['Hari', 'Minggu', 'Bulan', 'Tahun']
                                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                          .toList(),
                                      onChanged: (v) {
                                        setState(() => _unit = v!);
                                        _calculate();
                                      },
                                    ),
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

                const SizedBox(height: 48),

                // RESULTS DASHBOARD
                if (_targetAmount > 0) ...[
                  // PROGRESS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PROGRES TABUNGAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                            Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _InfoPiece(
                              label: 'Saldo Saat Ini',
                              value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(currentBalance),
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                            Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _InfoPiece(
                              label: 'Kekurangan',
                              value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(remaining),
                              color: remaining > 0 ? Colors.red.shade400 : Colors.green.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // SETORAN RUTIN
                  const Text('RENCANA SETORAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(label: 'HARIAN', amount: daily, color: const Color(0xFF3498DB), isDarkMode: isDarkMode),
                      const SizedBox(width: 12),
                      _StatCard(label: 'MINGGUAN', amount: weekly, color: const Color(0xFFF39C12), isDarkMode: isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(label: 'SETORAN BULANAN', amount: monthly, color: const Color(0xFF27AE60), isDarkMode: isDarkMode, isWide: true),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Target akan tercapai pada ${ DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now().add(Duration(days: totalDays))) }',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                   Center(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(vertical: 80),
                       child: Column(
                         children: [
                           Icon(Icons.pie_chart_outline_rounded, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                           const SizedBox(height: 24),
                           const Text('Masukkan target dan durasi\nuntuk melihat perhitungan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                         ],
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
}

class _InfoPiece extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPiece({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDarkMode;
  final bool isWide;

  const _StatCard({required this.label, required this.amount, required this.color, required this.isDarkMode, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );

    return isWide ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }
}

class _RibuanSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final formatted = digitsOnly.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
