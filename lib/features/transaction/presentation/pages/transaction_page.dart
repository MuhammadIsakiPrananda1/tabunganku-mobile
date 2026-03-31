import 'package:flutter/material.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/widgets/transaction_tile.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(dummyTransactions),
          _buildTransactionList(dummyTransactions.where((t) => t.type == TransactionType.income).toList()),
          _buildTransactionList(dummyTransactions.where((t) => t.type == TransactionType.expense).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add transaction logic
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionTile(transaction: transactions[index]);
      },
    );
  }
}
