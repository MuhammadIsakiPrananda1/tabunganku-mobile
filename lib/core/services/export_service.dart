import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:tabunganku/models/transaction_model.dart';

class ExportService {
  /// Format rupiah
  static String _fmtRupiah(double v) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(v);
  }

  /// Generates a plain-text summary for sharing
  static String buildTextSummary({
    required List<TransactionModel> transactions,
    required String monthLabel,
  }) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    final buf = StringBuffer();
    buf.writeln('╔══════════════════════════════╗');
    buf.writeln('   RINGKASAN KEUANGAN');
    buf.writeln('   $monthLabel');
    buf.writeln('╚══════════════════════════════╝');
    buf.writeln();
    buf.writeln('▶ Total Pemasukan : ${_fmtRupiah(income)}');
    buf.writeln('▶ Total Pengeluaran: ${_fmtRupiah(expense)}');
    buf.writeln('▶ Saldo Akhir     : ${_fmtRupiah(balance)}');
    buf.writeln();
    buf.writeln('─── DETAIL TRANSAKSI (${transactions.length} item) ───');
    buf.writeln();

    // Sort descending by date
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      final sign = t.type == TransactionType.income ? '+' : '-';
      final dateStr = DateFormat('dd/MM HH:mm').format(t.date);
      buf.writeln('$sign ${_fmtRupiah(t.amount).padRight(18)} $dateStr  ${t.title}');
    }

    buf.writeln();
    buf.writeln('─────────────────────────────────');
    buf.writeln('Dibuat oleh TabunganKu App');
    buf.writeln(DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now()));

    return buf.toString();
  }

  /// Generates PDF and returns the file path
  static Future<String> buildPdf({
    required List<TransactionModel> transactions,
    required String monthLabel,
  }) async {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;

    final doc = pw.Document();
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    // ── Color palette
    final primaryColor = PdfColor.fromHex('#009688');
    final lightBg = PdfColor.fromHex('#E0F2F1');
    final incomeColor = PdfColor.fromHex('#2E7D32');
    final expenseColor = PdfColor.fromHex('#C62828');
    final balanceColor = balance >= 0
        ? PdfColor.fromHex('#00695C')
        : PdfColor.fromHex('#B71C1C');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TabunganKu',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Laporan Keuangan Bulanan',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    monthLabel,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColor.fromHex('#B2DFDB'), thickness: 1.5),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Dicetak: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              'Hal ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
        build: (ctx) => [
          // ── Summary Cards
          pw.Row(
            children: [
              _pdfSummaryCard(
                  'TOTAL PEMASUKAN', _fmtRupiah(income), incomeColor, lightBg),
              pw.SizedBox(width: 12),
              _pdfSummaryCard(
                  'TOTAL PENGELUARAN', _fmtRupiah(expense), expenseColor, lightBg),
              pw.SizedBox(width: 12),
              _pdfSummaryCard(
                  'SALDO AKHIR', _fmtRupiah(balance), balanceColor, lightBg),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Table Header
          pw.Text(
            'DETAIL TRANSAKSI (${transactions.length} item)',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 8),

          // ── Table
          pw.TableHelper.fromTextArray(
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            headerCellDecoration: pw.BoxDecoration(color: primaryColor),
            oddRowDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F9FAFB'),
            ),
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#E5E7EB'),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.6),  // Tanggal
              1: const pw.FlexColumnWidth(2.8),  // Keterangan
              2: const pw.FlexColumnWidth(1.8),  // Kategori
              3: const pw.FlexColumnWidth(1.8),  // Nominal
              4: const pw.FlexColumnWidth(1.0),  // Jenis
            },
            headers: ['TANGGAL', 'KETERANGAN', 'KATEGORI', 'NOMINAL', 'JENIS'],
            data: sorted.map((t) {
              final isIncome = t.type == TransactionType.income;
              return [
                DateFormat('dd/MM/yyyy\nHH:mm').format(t.date),
                t.title,
                t.category,
                _fmtRupiah(t.amount),
                isIncome ? 'Masuk' : 'Keluar',
              ];
            }).toList(),
            cellAlignments: {
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final safeMonth = monthLabel.replaceAll(' ', '_').replaceAll('/', '-');
    final file = File('${dir.path}/TabunganKu_$safeMonth.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  static pw.Widget _pdfSummaryCard(
      String label, String value, PdfColor color, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: color.flatten(), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
                letterSpacing: 0.8,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main function called from UI
  static Future<void> shareMonthlyReport({
    required BuildContext context,
    required List<TransactionModel> transactions,
    required String monthLabel,
    required bool asPdf,
  }) async {
    if (asPdf) {
      final path = await buildPdf(
          transactions: transactions, monthLabel: monthLabel);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: 'Laporan Keuangan $monthLabel – TabunganKu',
        ),
      );
    } else {
      final text = buildTextSummary(
          transactions: transactions, monthLabel: monthLabel);
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Laporan Keuangan $monthLabel',
        ),
      );
    }
  }
}
