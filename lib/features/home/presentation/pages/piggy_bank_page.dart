import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
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
    showTopToast(context, 'Berhasil memasukkan ${_formatRupiah(amount)}!');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(piggyBankProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: pageBg,
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
            fontSize: 15,
            color: contentColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCompactBalanceCard(balance, isDarkMode),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOMINAL MASUKKAN RECEH *',
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan nominal receh',
                          hintStyle: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white10 : Colors.black26,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.payments_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
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
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderCol, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderCol, width: 1.2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (balance > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _showBreakJarDialog(context, ref, balance),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent, width: 1.2),
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
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactBalanceCard(double balance, bool isDarkMode) {
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String statusLabel = balance > 0 ? 'Terisi' : 'Kosong';
    Color statusColor = balance > 0 ? Colors.teal : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL ISI CELENGAN',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              fmt.format(balance),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Uang receh yang diselamatkan dari pembulatan belanja',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: borderCol,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCell(
                label: 'TIPE TABUNGAN',
                value: 'Tabungan Receh',
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              Container(
                width: 1,
                height: 32,
                color: borderCol,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _StatCell(
                label: 'STATUS',
                value: balance > 0 ? 'Bisa Dipecahkan' : 'Celengan Kosong',
                color: balance > 0 ? Colors.teal : Colors.grey,
              ),
            ],
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
                id: const Uuid().v4(),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

