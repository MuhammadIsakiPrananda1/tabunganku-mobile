import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/providers/piggy_bank_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class PiggyBankPage extends ConsumerStatefulWidget {
  const PiggyBankPage({super.key});

  @override
  ConsumerState<PiggyBankPage> createState() => _PiggyBankPageState();
}

class _PiggyBankPageState extends ConsumerState<PiggyBankPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _submitAmount() {
    if (_formKey.currentState?.validate() ?? false) {
      final rawValue = _amountController.text.replaceAll('.', '');
      final amount = double.tryParse(rawValue) ?? 0;
      
      if (amount > 0) {
        ref.read(piggyBankProvider.notifier).addAmount(amount);
        _amountController.clear();
        FocusScope.of(context).unfocus();
        _showSuccessSnackBar(amount);
      }
    }
  }

  void _showSuccessSnackBar(double amount) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.savings_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Berhasil memasukkan ${_formatRupiah(amount)}!',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(piggyBankProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 18),
        ),
        title: Text(
          'Tabungan Receh',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

_buildCompactBalanceCard(balance, isDarkMode),

              const SizedBox(height: 32),

Card(
                elevation: isDarkMode ? 1 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'NOMINAL MASUKKAN RECEH',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white24 : Colors.black38,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan Nominal',
                          hintStyle: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white10 : Colors.black26,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(left: 12, right: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rp',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.white.withValues(alpha: 0.03)
                              : AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nominal tidak boleh kosong!';
                          }
                          final cleaned = val.replaceAll('.', '');
                          final amount = double.tryParse(cleaned);
                          if (amount == null || amount <= 0) {
                            return 'Nominal tidak valid.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submitAmount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan ke Celengan',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: balance > 0 ? () => _showBreakJarDialog(context, ref, balance) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: balance > 0 ? Colors.redAccent : Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.gavel_rounded, size: 16),
                          label: Text(
                            'Pecahkan Celengan',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactBalanceCard(double balance, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDarkMode ? 0 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL ISI CELENGAN',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(balance),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Uang receh yang terselamatkan',
            style: GoogleFonts.quicksand(
              fontSize: 10.5,
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showBreakJarDialog(BuildContext context, WidgetRef ref, double balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : Colors.white,
        title: Text('Pecahkan Celengan?', 
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'Kamu akan mengambil semua uang di celengan sebesar ${_formatRupiah(balance)}. Celengan akan kembali kosong.',
          style: GoogleFonts.quicksand(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: GoogleFonts.quicksand(color: Colors.grey, fontSize: 13))),
          ElevatedButton(
            onPressed: () async {

              final transaction = TransactionModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Hasil Pecahkan Celengan',
                description: 'Uang terkumpul dari Tabungan Receh',
                amount: balance,
                type: TransactionType.income,
                date: DateTime.now(),
                category: 'Lainnya',
              );

await ref.read(addTransactionProvider)(transaction);

await ref.read(piggyBankProvider.notifier).reset();
              
              if (mounted) {
                Navigator.pop(context);
                _showBreakSuccess(context, balance);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Pecahkan!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showBreakSuccess(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surfaceDark 
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 56),
            const SizedBox(height: 16),
            Text(
              'Selamat!',
              style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu telah mengumpulkan ${_formatRupiah(amount)} dari uang receh!',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Mantap!', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
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
    final intValue = int.tryParse(newValue.text.replaceAll('.', ''));
    if (intValue == null) return oldValue;
    final newText = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(intValue).trim();
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}
