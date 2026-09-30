import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/transaction_model.dart';

class TransactionDetailSheet extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    String formatRupiah(double amount) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Badge Tipe Transaksi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isExpense
                    ? (isDarkMode
                        ? Colors.redAccent.withValues(alpha: 0.15)
                        : Colors.red.shade50)
                    : (isDarkMode
                        ? Colors.greenAccent.withValues(alpha: 0.15)
                        : Colors.green.shade50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isExpense ? 'PENGELUARAN' : 'PEMASUKAN',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isExpense
                      ? (isDarkMode ? Colors.redAccent.shade100 : Colors.red.shade700)
                      : (isDarkMode ? Colors.greenAccent.shade400 : Colors.green.shade700),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nominal
            Text(
              formatRupiah(transaction.amount),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.teal.shade900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            // Garis Pembatas Putus-putus
            Row(
              children: List.generate(
                32,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    height: 1,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tabel Detail Transaksi dengan Garis Pembatas
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    _buildReceiptRow(
                      context,
                      ref,
                      label: 'ID Transaksi',
                      value: '#${transaction.id.replaceAll('paid_debt_', '').replaceAll('shopping_', '').toUpperCase()}',
                      isId: true,
                    ),
                    _buildTableDivider(isDarkMode),
                    _buildReceiptRow(
                      context,
                      ref,
                      label: 'Waktu',
                      value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(transaction.date),
                    ),
                    _buildTableDivider(isDarkMode),
                    _buildReceiptRow(
                      context,
                      ref,
                      label: 'Jam',
                      value: DateFormat('HH:mm:ss', 'id_ID').format(transaction.date),
                    ),
                    _buildTableDivider(isDarkMode),
                    _buildReceiptRow(
                      context,
                      ref,
                      label: 'Kategori',
                      value: transaction.category,
                    ),
                    _buildTableDivider(isDarkMode),
                    _buildReceiptRow(
                      context,
                      ref,
                      label: transaction.id.startsWith('shopping_')
                          ? 'Nama Barang'
                          : 'Keterangan',
                      value: transaction.title,
                      subValue: transaction.description.isNotEmpty &&
                              transaction.description != transaction.title
                          ? transaction.description
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi (Edit Nominal & Hapus)
            if (onEdit != null || onDelete != null)
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onEdit?.call();
                        },
                        icon: const Icon(Icons.edit_document, size: 18),
                        label: Text(
                          'Edit Nominal',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.blue.shade900.withValues(alpha: 0.3)
                              : Colors.blue.shade50,
                          foregroundColor:
                              isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 12),
                  if (onDelete != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete?.call();
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text(
                          'Hapus',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.red.shade900.withValues(alpha: 0.3)
                              : Colors.red.shade50,
                          foregroundColor:
                              isDarkMode ? Colors.red.shade200 : Colors.red.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String value,
    String? subValue,
    bool isId = false,
  }) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade300;

    return InkWell(
      onTap: isId
          ? () {
              Clipboard.setData(ClipboardData(text: value));
              showTopToast(context, 'ID Transaksi berhasil disalin');
            }
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kolom Label
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.shade100.withValues(alpha: 0.75),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            // Garis Vertikal Pemisah Kolom
            Container(
              width: 1,
              color: borderColor,
            ),
            // Kolom Nilai / Value
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (isId) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ],
                      ],
                    ),
                    if (subValue != null && subValue.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subValue,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableDivider(bool isDarkMode) {
    return Container(
      height: 1,
      color: isDarkMode
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.shade300,
    );
  }
}
