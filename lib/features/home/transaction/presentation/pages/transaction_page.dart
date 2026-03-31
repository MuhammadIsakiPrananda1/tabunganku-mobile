import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/widgets/transaction_tile.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  TransactionType? _selectedFilter;
  bool _isGeneratingPdf = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _generatePdf(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdf = pw.Document();
      final dateStr = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Transaksi - $dateStr',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('TabunganKu',
                        style: pw.TextStyle(
                            fontSize: 14, color: PdfColors.blueGrey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Tanggal', 'Keterangan', 'Kategori', 'Tipe', 'Nominal'],
                data: transactions.map((t) {
                  return [
                    DateFormat('dd/MM/yyyy').format(t.date),
                    t.title,
                    t.category,
                    t.type == TransactionType.income ? 'Masuk' : 'Keluar',
                    _formatCurrency(t.amount),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Pemasukan: ${_formatCurrency(transactions.where((t) => t.type == TransactionType.income).fold(0, (sum, t) => sum + t.amount.toInt()))}'),
                      pw.Text('Total Pengeluaran: ${_formatCurrency(transactions.where((t) => t.type == TransactionType.expense).fold(0, (sum, t) => sum + t.amount.toInt()))}'),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/transaksi_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          transactionsAsync.when(
            data: (transactions) => IconButton(
              icon: _isGeneratingPdf 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded),
              onPressed: () => _generatePdf(transactions),
              tooltip: 'Unduh laporan PDF',
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                const SizedBox(width: 8),
                _buildFilterChip('Masuk', TransactionType.income),
                const SizedBox(width: 8),
                _buildFilterChip('Keluar', TransactionType.expense),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _selectedFilter == null
                    ? transactions
                    : transactions.where((t) => t.type == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi'));
                }

                // Group by month
                final Map<String, List<TransactionModel>> grouped = {};
                for (var t in filtered) {
                  final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(t.date);
                  if (!grouped.containsKey(monthYear)) {
                    grouped[monthYear] = [];
                  }
                  grouped[monthYear]!.add(t);
                }

                final groupKeys = grouped.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groupKeys.length,
                  itemBuilder: (context, groupIndex) {
                    final monthKey = groupKeys[groupIndex];
                    final monthTransactions = grouped[monthKey]!;
                    
                    final totalIncome = monthTransactions
                        .where((t) => t.type == TransactionType.income)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final totalExpense = monthTransactions
                        .where((t) => t.type == TransactionType.expense)
                        .fold(0.0, (sum, t) => sum + t.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                monthKey,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (totalExpense > 0)
                                    Text(
                                      'Saldo keluar: ${_formatCurrency(totalExpense)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  if (totalIncome > 0)
                                    Text(
                                      'Saldo masuk: ${_formatCurrency(totalIncome)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Transactions in this month
                        ...monthTransactions.map((t) => TransactionTile(transaction: t)),
                        const Divider(height: 32),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    final isSelected = _selectedFilter == type;
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = type;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
