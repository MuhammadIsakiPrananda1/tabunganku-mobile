import 'dart:io';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:tabunganku/models/transaction_model.dart';

class ExportService {

  static String _fmtRupiah(double v) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(v);
  }

  static String _fmtDecimal(double v) {
    return NumberFormat.decimalPattern('id_ID').format(v);
  }

  static String _getDateRangeText(List<TransactionModel> transactions, String monthLabel) {
    if (transactions.isEmpty) return monthLabel;
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    final start = DateFormat('dd MMM yyyy', 'id_ID').format(sorted.first.date).toUpperCase();
    final end = DateFormat('dd MMM yyyy', 'id_ID').format(sorted.last.date).toUpperCase();
    return '$start sampai $end';
  }

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

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      final sign = t.type == TransactionType.income ? '+' : '-';
      final dateStr = DateFormat('dd/MM HH:mm').format(t.date);
      buf.writeln(
          '$sign ${_fmtRupiah(t.amount).padRight(18)} $dateStr  ${t.title}');
    }

    buf.writeln();
    buf.writeln('─────────────────────────────────');
    buf.writeln('Dibuat oleh TabunganKu App');
    buf.writeln(
        DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now()));

    return buf.toString();
  }

  static Future<String> buildPdf({
    required List<TransactionModel> transactions,
    required String monthLabel,
    String? userName,
  }) async {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final balance = income - expense;
    const double saldoAwal = 0.0;

    final poppinsRegular =
        await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final poppinsMedium =
        await rootBundle.load("assets/fonts/Poppins-Medium.ttf");
    final poppinsBold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final logoData = await rootBundle.load('assets/icon.png');

    final fontRegular = pw.Font.ttf(poppinsRegular);
    final fontMedium = pw.Font.ttf(poppinsMedium);
    final fontBold = pw.Font.ttf(poppinsBold);
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final doc = pw.Document();

    // Sort chronologically for running balance
    final chronological = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    double currentBalance = saldoAwal;
    final List<Map<String, dynamic>> transactionRows = [];
    for (final t in chronological) {
      if (t.type == TransactionType.income) {
        currentBalance += t.amount;
      } else {
        currentBalance -= t.amount;
      }
      transactionRows.add({
        'transaction': t,
        'balanceAfter': currentBalance,
      });
    }

    final primaryColor = PdfColor.fromHex('#FF9800'); // Seabank premium orange vibe

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      height: 36,
                      width: 36,
                      child: pw.Image(logoImage),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'TabunganKu',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'REKENING KORAN',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'S/N TK-${DateFormat('yyMMdd').format(DateTime.now())}Q${transactions.length}',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 8.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now()).toUpperCase(),
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 8.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey300, thickness: 0.8),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'halaman ${ctx.pageNumber} dr ${ctx.pagesCount}',
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ),
        build: (ctx) => [
          // Customer & Contact Info Row (First page only, handled sequentially)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer Name Left Column
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      (userName == null || userName.isEmpty) ? 'PENGGUNA TABUNGANKU' : userName.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 13,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Contact Info Right Column
              pw.Container(
                width: 220,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hubungi kami',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 8.5,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 45,
                          child: pw.Text('Email', style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColors.grey600)),
                        ),
                        pw.Text('arlianto032@gmail.com', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.black)),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 45,
                          child: pw.Text('Website', style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColors.grey600)),
                        ),
                        pw.Text('tabunganku.neverlandstudio.my.id', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.black)),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Hubungi kami via live chat di aplikasi TabunganKu',
                      style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Ringkasan Rekening Section
          pw.Center(
            child: pw.Text(
              'RINGKASAN REKENING',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
                color: PdfColors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Center(
            child: pw.Text(
              _getDateRangeText(transactions, monthLabel),
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.SizedBox(height: 12),

          // Ringkasan Table
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _tableHeader('REKENING', fontBold),
                  _tableHeader('SALDO AWAL (IDR)', fontBold, align: pw.Alignment.centerRight),
                  _tableHeader('TRANSAKSI KELUAR (IDR)', fontBold, align: pw.Alignment.centerRight),
                  _tableHeader('TRANSAKSI MASUK (IDR)', fontBold, align: pw.Alignment.centerRight),
                  _tableHeader('SALDO AKHIR (IDR)', fontBold, align: pw.Alignment.centerRight),
                ],
              ),
              pw.TableRow(
                children: [
                  _tableCell('TABUNGAN', fontRegular),
                  _tableCell(_fmtDecimal(saldoAwal), fontRegular, align: pw.Alignment.centerRight),
                  _tableCell(_fmtDecimal(expense), fontRegular, align: pw.Alignment.centerRight),
                  _tableCell(_fmtDecimal(income), fontRegular, align: pw.Alignment.centerRight),
                  _tableCell(_fmtDecimal(balance), fontBold, align: pw.Alignment.centerRight),
                ],
              ),
            ],
          ),
          // Ringkasan Total
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'TOTAL: ${_fmtDecimal(balance)}',
              style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black),
            ),
          ),
          pw.SizedBox(height: 32),

          // Detail Transaksi Header
          pw.Center(
            child: pw.Text(
              'TABUNGAN - RINCIAN TRANSAKSI',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 10,
                color: PdfColors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 12),

          // Detail Transaksi Table
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColors.grey100, width: 0.5),
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(50),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _tableHeader('TANGGAL', fontBold),
                  _tableHeader('TRANSAKSI', fontBold),
                  _tableHeader('KELUAR (IDR)', fontBold, align: pw.Alignment.centerRight),
                  _tableHeader('MASUK (IDR)', fontBold, align: pw.Alignment.centerRight),
                  _tableHeader('SALDO AKHIR (IDR)', fontBold, align: pw.Alignment.centerRight),
                ],
              ),
              ...transactionRows.map((row) {
                final t = row['transaction'] as TransactionModel;
                final balanceAfter = row['balanceAfter'] as double;
                final isIncome = t.type == TransactionType.income;
                final dateStr = DateFormat('dd MMM', 'id_ID').format(t.date).toUpperCase();

                return pw.TableRow(
                  children: [
                    _tableCell(dateStr, fontRegular),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            t.title,
                            style: pw.TextStyle(font: fontMedium, fontSize: 8, color: PdfColors.black),
                          ),
                          pw.SizedBox(height: 1.5),
                          pw.Text(
                            t.category,
                            style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey500),
                          ),
                        ],
                      ),
                    ),
                    _tableCell(!isIncome ? _fmtDecimal(t.amount) : '', fontRegular, align: pw.Alignment.centerRight),
                    _tableCell(isIncome ? _fmtDecimal(t.amount) : '', fontRegular, align: pw.Alignment.centerRight),
                    _tableCell(_fmtDecimal(balanceAfter), fontBold, align: pw.Alignment.centerRight),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 24),

          // Ketentuan Umum & Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: pw.BorderRadius.circular(6),
              color: PdfColors.grey50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ketentuan Umum',
                  style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColors.black),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'E-Statement ini dibuat secara otomatis oleh sistem aplikasi TabunganKu dan tidak memerlukan tanda tangan basah pejabat bank. Mohon periksa e-Statement di atas dan hubungi kami jika terdapat ketidaksesuaian pencatatan keuangan Anda.',
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Syarat Layanan',
                  style: pw.TextStyle(font: fontBold, fontSize: 7.5, color: PdfColors.black),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Seluruh catatan transaksi pada laporan ini disimpan secara lokal di perangkat pengguna. Keakuratan data sepenuhnya bergantung pada input transaksi yang Anda lakukan di aplikasi TabunganKu.',
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.grey600),
                ),
              ],
            ),
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

  static pw.Widget _tableHeader(String text, pw.Font font,
      {pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.black,
          font: font,
          fontSize: 7.5,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font,
      {pw.Alignment align = pw.Alignment.centerLeft, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static Future<void> shareMonthlyReport({
    required BuildContext context,
    required List<TransactionModel> transactions,
    required String monthLabel,
    required bool asPdf,
    String? userName,
  }) async {
    try {
      if (asPdf) {
        final path =
            await buildPdf(transactions: transactions, monthLabel: monthLabel, userName: userName);
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
    } catch (e) {
      debugPrint('Error sharing report: $e');
      if (context.mounted) {
        showTopToast(context, 'Gagal membagikan laporan: $e', isError: true);
      }
    }
  }
}
