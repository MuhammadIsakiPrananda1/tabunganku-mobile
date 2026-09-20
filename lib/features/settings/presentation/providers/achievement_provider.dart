import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.progress = 0.0,
  });

  Achievement copyWith({bool? isUnlocked, double? progress}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }
}

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final streak = ref.watch(savingStreakProvider);

  final allTransactions = transactionsAsync.asData?.value ?? transactionsAsync.valueOrNull ?? [];
  final transactions = allTransactions.where((t) => t.groupId == null).toList();

  final incomeTransactions = transactions.where((t) => t.type == TransactionType.income).toList();
  final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();

      final totalIncome = incomeTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final totalExpense = expenseTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final currentBalance = totalIncome - totalExpense;

      final totalCount = transactions.length;
      final incomeCount = incomeTransactions.length;
      final expenseCount = expenseTransactions.length;

      return [
        // --- 1-13: PENCAPAIAN SALDO AKTIF ---
        Achievement(
          id: 'half_millionaire',
          title: 'Langkah Awal',
          description: 'Memiliki saldo aktif di atas Rp 100.000.',
          icon: Icons.explore_rounded,
          isUnlocked: currentBalance >= 100000,
          progress: (currentBalance / 100000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'quarter_million',
          title: 'Semangat Baru',
          description: 'Memiliki saldo aktif di atas Rp 250.000.',
          icon: Icons.emoji_events_rounded,
          isUnlocked: currentBalance >= 250000,
          progress: (currentBalance / 250000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'half_million',
          title: 'Hemat Pangkal Kaya',
          description: 'Memiliki saldo aktif di atas Rp 500.000.',
          icon: Icons.savings_rounded,
          isUnlocked: currentBalance >= 500000,
          progress: (currentBalance / 500000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'one_million_balance',
          title: 'Manajer Tabungan',
          description: 'Memiliki saldo aktif di atas Rp 1.000.000.',
          icon: Icons.account_balance_wallet_rounded,
          isUnlocked: currentBalance >= 1000000,
          progress: (currentBalance / 1000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'hemat_terus',
          title: 'Hemat Terus',
          description: 'Memiliki saldo aktif di atas Rp 2.500.000.',
          icon: Icons.account_balance_rounded,
          isUnlocked: currentBalance >= 2500000,
          progress: (currentBalance / 2500000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'sultan_muda',
          title: 'Sultan Muda',
          description: 'Memiliki saldo aktif di atas Rp 5.000.000.',
          icon: Icons.workspace_premium_rounded,
          isUnlocked: currentBalance >= 5000000,
          progress: (currentBalance / 5000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'ten_million_balance',
          title: 'Tuan Muda',
          description: 'Memiliki saldo aktif di atas Rp 10.000.000.',
          icon: Icons.shield_moon_rounded,
          isUnlocked: currentBalance >= 10000000,
          progress: (currentBalance / 10000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'fifteen_million_balance',
          title: 'Benteng Keuangan',
          description: 'Memiliki saldo aktif di atas Rp 15.000.000.',
          icon: Icons.fort_rounded,
          isUnlocked: currentBalance >= 15000000,
          progress: (currentBalance / 15000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'future_billionaire',
          title: 'Calon Miliarder',
          description: 'Memiliki saldo aktif di atas Rp 20.000.000.',
          icon: Icons.flight_takeoff_rounded,
          isUnlocked: currentBalance >= 20000000,
          progress: (currentBalance / 20000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'twentyfive_million_balance',
          title: 'Arsitek Kekayaan',
          description: 'Memiliki saldo aktif di atas Rp 25.000.000.',
          icon: Icons.domain_rounded,
          isUnlocked: currentBalance >= 25000000,
          progress: (currentBalance / 25000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'fifty_million_balance',
          title: 'Raja Tabungan',
          description: 'Memiliki saldo aktif di atas Rp 50.000.000.',
          icon: Icons.workspace_premium_rounded,
          isUnlocked: currentBalance >= 50000000,
          progress: (currentBalance / 50000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'seventyfive_million_balance',
          title: 'Kaisar Finansial',
          description: 'Memiliki saldo aktif di atas Rp 75.000.000.',
          icon: Icons.auto_awesome_motion_rounded,
          isUnlocked: currentBalance >= 75000000,
          progress: (currentBalance / 75000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'hundred_million_balance',
          title: 'Naga Keuangan',
          description: 'Memiliki saldo aktif di atas Rp 100.000.000.',
          icon: Icons.diamond_rounded,
          isUnlocked: currentBalance >= 100000000,
          progress: (currentBalance / 100000000).clamp(0.0, 1.0),
        ),

        // --- 14-22: PENCAPAIAN TOTAL PEMASUKAN ---
        Achievement(
          id: 'first_deposit',
          title: 'Top Up Pertama',
          description: 'Berhasil melakukan pengisian saldo pertama.',
          icon: Icons.add_card_rounded,
          isUnlocked: incomeCount > 0,
          progress: incomeCount > 0 ? 1.0 : 0.0,
        ),
        Achievement(
          id: 'income_500k',
          title: 'Rezeki Awal',
          description: 'Total akumulasi pemasukan mencapai Rp 500.000.',
          icon: Icons.payments_rounded,
          isUnlocked: totalIncome >= 500000,
          progress: (totalIncome / 500000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'millionaire',
          title: 'Millionaire',
          description: 'Total akumulasi pemasukan mencapai Rp 1.000.000.',
          icon: Icons.stars_rounded,
          isUnlocked: totalIncome >= 1000000,
          progress: (totalIncome / 1000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'collector_wealth',
          title: 'Kolektor Harta',
          description: 'Total akumulasi pemasukan mencapai Rp 5.000.000.',
          icon: Icons.monetization_on_rounded,
          isUnlocked: totalIncome >= 5000000,
          progress: (totalIncome / 5000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'level_pro',
          title: 'Level Pro',
          description: 'Total akumulasi pemasukan mencapai Rp 10.000.000.',
          icon: Icons.military_tech_rounded,
          isUnlocked: totalIncome >= 10000000,
          progress: (totalIncome / 10000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_20m',
          title: 'Bintang Finansial',
          description: 'Total akumulasi pemasukan mencapai Rp 20.000.000.',
          icon: Icons.auto_awesome_rounded,
          isUnlocked: totalIncome >= 20000000,
          progress: (totalIncome / 20000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'saving_legend',
          title: 'Legenda Menabung',
          description: 'Total akumulasi pemasukan mencapai Rp 30.000.000.',
          icon: Icons.verified_rounded,
          isUnlocked: totalIncome >= 30000000,
          progress: (totalIncome / 30000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_50m',
          title: 'Konglomerat',
          description: 'Total akumulasi pemasukan mencapai Rp 50.000.000.',
          icon: Icons.castle_rounded,
          isUnlocked: totalIncome >= 50000000,
          progress: (totalIncome / 50000000).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_100m',
          title: 'Dewa Rezeki',
          description: 'Total akumulasi pemasukan mencapai Rp 100.000.000.',
          icon: Icons.legend_toggle_rounded,
          isUnlocked: totalIncome >= 100000000,
          progress: (totalIncome / 100000000).clamp(0.0, 1.0),
        ),

        // --- 23-30: PENCAPAIAN STREAK MENABUNG ---
        Achievement(
          id: 'streak_3',
          title: 'Pemanasan',
          description: 'Menabung secara konsisten selama 3 hari berturut-turut.',
          icon: Icons.speed_rounded,
          isUnlocked: streak >= 3,
          progress: (streak / 3).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_master',
          title: 'Striker',
          description: 'Menabung secara konsisten selama 7 hari berturut-turut.',
          icon: Icons.bolt_rounded,
          isUnlocked: streak >= 7,
          progress: (streak / 7).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_14',
          title: 'Dua Minggu Rajin',
          description: 'Menabung secara konsisten selama 14 hari berturut-turut.',
          icon: Icons.local_fire_department_rounded,
          isUnlocked: streak >= 14,
          progress: (streak / 14).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'disiplin_tinggi',
          title: 'Pahlawan Streak',
          description: 'Menabung secara konsisten selama 30 hari berturut-turut.',
          icon: Icons.local_fire_department_rounded,
          isUnlocked: streak >= 30,
          progress: (streak / 30).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_60',
          title: 'Master Konsistensi',
          description: 'Menabung secara konsisten selama 60 hari berturut-turut.',
          icon: Icons.workspace_premium_outlined,
          isUnlocked: streak >= 60,
          progress: (streak / 60).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_90',
          title: 'Satria Tabungan',
          description: 'Menabung secara konsisten selama 90 hari berturut-turut.',
          icon: Icons.military_tech_outlined,
          isUnlocked: streak >= 90,
          progress: (streak / 90).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_180',
          title: 'Setengah Tahun Rajin',
          description: 'Menabung secara konsisten selama 180 hari berturut-turut.',
          icon: Icons.shield_rounded,
          isUnlocked: streak >= 180,
          progress: (streak / 180).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'streak_365',
          title: 'Suhu Sepanjang Tahun',
          description: 'Menabung secara konsisten selama 365 hari berturut-turut.',
          icon: Icons.military_tech_sharp,
          isUnlocked: streak >= 365,
          progress: (streak / 365).clamp(0.0, 1.0),
        ),

        // --- 31-40: PENCAPAIAN TOTAL TRANSAKSI (PEMASUKAN & PENGELUARAN) ---
        Achievement(
          id: 'trx_1',
          title: 'Perjalanan Dimulai',
          description: 'Mencatat transaksi pertama kali.',
          icon: Icons.check_circle_outline_rounded,
          isUnlocked: totalCount >= 1,
          progress: totalCount >= 1 ? 1.0 : 0.0,
        ),
        Achievement(
          id: 'trx_5',
          title: 'Langkah Kecil',
          description: 'Melakukan total 5 kali transaksi.',
          icon: Icons.touch_app_rounded,
          isUnlocked: totalCount >= 5,
          progress: (totalCount / 5).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'mulai_bijak',
          title: 'Mulai Bijak',
          description: 'Melakukan total 10 kali transaksi.',
          icon: Icons.insights_rounded,
          isUnlocked: totalCount >= 10,
          progress: (totalCount / 10).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_20',
          title: 'Pencatat Handal',
          description: 'Melakukan total 20 kali transaksi.',
          icon: Icons.edit_note_rounded,
          isUnlocked: totalCount >= 20,
          progress: (totalCount / 20).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'super_saving_master',
          title: 'Guru Finansial',
          description: 'Melakukan total 30 kali transaksi.',
          icon: Icons.psychology_rounded,
          isUnlocked: totalCount >= 30,
          progress: (totalCount / 30).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_50',
          title: 'Akuntan Pribadi',
          description: 'Melakukan total 50 kali transaksi.',
          icon: Icons.calculate_rounded,
          isUnlocked: totalCount >= 50,
          progress: (totalCount / 50).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_75',
          title: 'Pakar Keuangan',
          description: 'Melakukan total 75 kali transaksi.',
          icon: Icons.auto_graph_rounded,
          isUnlocked: totalCount >= 75,
          progress: (totalCount / 75).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_100',
          title: 'Kolektor Transaksi',
          description: 'Melakukan total 100 kali transaksi.',
          icon: Icons.receipt_long_rounded,
          isUnlocked: totalCount >= 100,
          progress: (totalCount / 100).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_150',
          title: 'Dewa Pencatat',
          description: 'Melakukan total 150 kali transaksi.',
          icon: Icons.history_edu_rounded,
          isUnlocked: totalCount >= 150,
          progress: (totalCount / 150).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'trx_200',
          title: 'Buku Kas Berjalan',
          description: 'Melakukan total 200 kali transaksi.',
          icon: Icons.menu_book_rounded,
          isUnlocked: totalCount >= 200,
          progress: (totalCount / 200).clamp(0.0, 1.0),
        ),

        // --- 41-45: PENCAPAIAN FREKUENSI PEMASUKAN ---
        Achievement(
          id: 'income_cnt_5',
          title: 'Setoran Rutin',
          description: 'Melakukan 5 kali pengisian saldo.',
          icon: Icons.savings_outlined,
          isUnlocked: incomeCount >= 5,
          progress: (incomeCount / 5).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_cnt_10',
          title: 'Rajin Menabung',
          description: 'Melakukan 10 kali pengisian saldo.',
          icon: Icons.price_change_rounded,
          isUnlocked: incomeCount >= 10,
          progress: (incomeCount / 10).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'penabung_aktif',
          title: 'Penabung Konsisten',
          description: 'Melakukan 20 kali pengisian saldo.',
          icon: Icons.assignment_turned_in_rounded,
          isUnlocked: incomeCount >= 20,
          progress: (incomeCount / 20).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_cnt_30',
          title: 'Mesin Tabungan',
          description: 'Melakukan 30 kali pengisian saldo.',
          icon: Icons.precision_manufacturing_rounded,
          isUnlocked: incomeCount >= 30,
          progress: (incomeCount / 30).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'income_cnt_50',
          title: 'Magnet Uang',
          description: 'Melakukan 50 kali pengisian saldo.',
          icon: Icons.attractions_rounded,
          isUnlocked: incomeCount >= 50,
          progress: (incomeCount / 50).clamp(0.0, 1.0),
        ),

        // --- 46-50: PENCAPAIAN PENGELOLAAN PENGELUARAN ---
        Achievement(
          id: 'first_expense',
          title: 'Pecah Telur',
          description: 'Berhasil mencatat pengeluaran pertama kali.',
          icon: Icons.shopping_bag_rounded,
          isUnlocked: expenseCount > 0,
          progress: expenseCount > 0 ? 1.0 : 0.0,
        ),
        Achievement(
          id: 'exp_cnt_5',
          title: 'Pembeli Bijak',
          description: 'Mencatat 5 kali pengeluaran terencana.',
          icon: Icons.shopping_cart_rounded,
          isUnlocked: expenseCount >= 5,
          progress: (expenseCount / 5).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'exp_cnt_10',
          title: 'Kontrol Diri',
          description: 'Mencatat 10 kali pengeluaran terencana.',
          icon: Icons.thumb_up_alt_rounded,
          isUnlocked: expenseCount >= 10,
          progress: (expenseCount / 10).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'exp_cnt_20',
          title: 'Pengawas Dompet',
          description: 'Mencatat 20 kali pengeluaran terencana.',
          icon: Icons.visibility_rounded,
          isUnlocked: expenseCount >= 20,
          progress: (expenseCount / 20).clamp(0.0, 1.0),
        ),
        Achievement(
          id: 'exp_cnt_50',
          title: 'Master Evaluasi',
          description: 'Mencatat 50 kali pengeluaran terencana.',
          icon: Icons.fact_check_rounded,
          isUnlocked: expenseCount >= 50,
          progress: (expenseCount / 50).clamp(0.0, 1.0),
        ),
      ];
});
