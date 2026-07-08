import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/services/bills_service.dart';
import 'package:google_fonts/google_fonts.dart';

class BillingManagementPage extends ConsumerStatefulWidget {
  const BillingManagementPage({super.key});

  @override
  ConsumerState<BillingManagementPage> createState() =>
      _BillingManagementPageState();
}

class _BillingManagementPageState extends ConsumerState<BillingManagementPage> {
  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  double _calculateTotalPending(List<BillModel> bills) {
    return bills.where((b) => !b.isPaid).fold(0.0, (s, b) => s + b.amount);
  }

  int _getDaysUntilDue(int dueDay) {
    final today = DateTime.now();
    var nextDue = DateTime(today.year, today.month, dueDay);
    if (nextDue.isBefore(today)) {
      nextDue = DateTime(today.year, today.month + 1, dueDay);
    }
    return nextDue.difference(today).inDays;
  }

  void _showAddBillSheet(bool isDarkMode) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    int dueDay = DateTime.now().day;
    bool nameHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 28,
            right: 28,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'TAMBAH TAGIHAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                HighVisInput(
                  controller: nameController,
                  icon: Icons.receipt_long_rounded,
                  label: 'Nama Tagihan',
                  isDarkMode: isDarkMode,
                  hintText: 'Contoh: Listrik, Air, Internet',
                  hasError: nameHasError,
                  onChanged: (val) {
                    if (nameHasError && val.trim().isNotEmpty) {
                      setSheetState(() => nameHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                HighVisInput(
                  controller: amountController,
                  icon: Icons.payments_rounded,
                  label: 'Nominal',
                  prefixText: 'Rp',
                  isDarkMode: isDarkMode,
                  hintText: 'Masukkan Nominal',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RibuanFormatter(),
                  ],
                  hasError: amountHasError,
                  onChanged: (val) {
                    if (amountHasError) {
                      final amount = double.tryParse(val.replaceAll('.', '')) ?? 0.0;
                      if (amount > 0) {
                        setSheetState(() => amountHasError = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildDayPickerSheet(
                  dueDay,
                  (newDay) => setSheetState(() => dueDay = newDay),
                  isDarkMode,
                  context,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nameVal = nameController.text.trim();
                      final rawAmount = amountController.text.replaceAll('.', '');
                      final amountVal = double.tryParse(rawAmount) ?? 0.0;

                      setSheetState(() {
                        nameHasError = nameVal.isEmpty;
                        amountHasError = amountVal <= 0;
                      });

                      if (nameHasError || amountHasError) return;

                      final bill = BillModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameVal,
                        amount: amountVal,
                        dueDay: dueDay,
                        isPaid: false,
                      );
                      final navigator = Navigator.of(context);
                      await ref.read(billsServiceProvider).addBill(bill);
                      navigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayPickerSheet(
    int selected,
    Function(int) onPicked,
    bool isDarkMode,
    BuildContext ctx,
  ) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'TANGGAL JATUH TEMPO',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: contentColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: ctx,
              backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Tanggal',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: 31,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(
                          'Tanggal ${i + 1}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          onPicked(i + 1);
                          Navigator.pop(context);
                        },
                        selected: selected == (i + 1),
                        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Text(
                  'Tanggal $selected',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: contentColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.expand_more_rounded,
                  color: contentColor.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _editBill(BillModel bill, bool isDarkMode) {
    final nameController = TextEditingController(text: bill.name);
    final amountController = TextEditingController(
      text: bill.amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      ),
    );
    int dueDay = bill.dueDay;
    bool nameHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 28,
            right: 28,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'UBAH TAGIHAN',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                HighVisInput(
                  controller: nameController,
                  icon: Icons.label_important_rounded,
                  label: 'Nama Tagihan',
                  isDarkMode: isDarkMode,
                  hintText: 'Nama tagihan',
                  hasError: nameHasError,
                  onChanged: (val) {
                    if (nameHasError && val.trim().isNotEmpty) {
                      setSheetState(() => nameHasError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                HighVisInput(
                  controller: amountController,
                  icon: Icons.payments_rounded,
                  label: 'Nominal',
                  prefixText: 'Rp',
                  isDarkMode: isDarkMode,
                  hintText: 'Masukkan Nominal',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _RibuanFormatter(),
                  ],
                  hasError: amountHasError,
                  onChanged: (val) {
                    if (amountHasError) {
                      final amount = double.tryParse(val.replaceAll('.', '')) ?? 0.0;
                      if (amount > 0) {
                        setSheetState(() => amountHasError = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildDayPickerSheet(
                  dueDay,
                  (newDay) => setSheetState(() => dueDay = newDay),
                  isDarkMode,
                  context,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nameVal = nameController.text.trim();
                      final rawAmount = amountController.text.replaceAll('.', '');
                      final amountVal = double.tryParse(rawAmount) ?? 0.0;

                      setSheetState(() {
                        nameHasError = nameVal.isEmpty;
                        amountHasError = amountVal <= 0;
                      });

                      if (nameHasError || amountHasError) return;

                      final updatedBill = bill.copyWith(
                        name: nameVal,
                        amount: amountVal,
                        dueDay: dueDay,
                      );
                      final navigator = Navigator.of(context);
                      await ref.read(billsServiceProvider).updateBill(updatedBill);
                      navigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteBill(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        title: Text(
          'Hapus Tagihan?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Tagihan akan dihapus secara permanen.',
          style: GoogleFonts.quicksand(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(billsServiceProvider).deleteBill(id);
    }
  }

  void _showBillDetailSheet(BillModel bill) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FutureBuilder<List<BillModel>>(
              future: ref.read(billsServiceProvider).getBills(),
              builder: (context, snapshot) {
                final list = snapshot.data ?? [];
                final currentBill = list.firstWhere((b) => b.id == bill.id, orElse: () => bill);
                
                final daysUntilDue = _getDaysUntilDue(currentBill.dueDay);
                final isOverdue = daysUntilDue < 0 && !currentBill.isPaid;
                final statusColor = isOverdue ? Colors.redAccent : (currentBill.isPaid ? Colors.green : AppColors.primary);
                
                final today = DateTime.now();
                final totalDaysInMonth = DateTime(today.year, today.month + 1, 0).day;
                final elapsed = (totalDaysInMonth - daysUntilDue.clamp(0, totalDaysInMonth)).toDouble();
                final progress = currentBill.isPaid ? 1.0 : (elapsed / totalDaysInMonth).clamp(0.0, 1.0);

                final sheetBg = isDark ? const Color(0xFF151515) : Colors.white;
                final cardBg = isDark ? AppColors.surfaceDark : const Color(0xFFF9FAFB);
                final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
                final txtClr = isDark ? Colors.white : AppColors.primaryDark;

                return Container(
                  decoration: BoxDecoration(
                    color: sheetBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentBill.name,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: txtClr,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tagihan Bulanan',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final updated = currentBill.copyWith(
                                isPaid: !currentBill.isPaid,
                                lastPaidDate: !currentBill.isPaid ? DateTime.now() : null,
                              );
                              await ref.read(billsServiceProvider).updateBill(updated);
                              setSheetState(() {});
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                currentBill.isPaid ? 'LUNAS' : (isOverdue ? 'TERLEWAT' : 'BELUM BAYAR'),
                                style: GoogleFonts.quicksand(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderCol, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 9,
                                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                    ),
                                  ),
                                  Text(
                                    currentBill.isPaid ? '100%' : '${(progress * 100).toInt()}%',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: txtClr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATUS PEMBAYARAN',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentBill.isPaid ? 'Sudah Dibayar' : (isOverdue ? 'Jatuh Tempo!' : 'Menunggu Pembayaran'),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'NOMINAL TAGIHAN',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatRupiah(currentBill.amount),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: txtClr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderCol, width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: statusColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'JATUH TEMPO',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey,
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Tanggal ${currentBill.dueDay}',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: txtClr,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tiap bulan',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderCol, width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: isDark ? Colors.white60 : Colors.grey,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'STATUS TERKINI',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey,
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currentBill.isPaid ? 'Lunas' : 'Belum Bayar',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: txtClr,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currentBill.isPaid
                                          ? 'Dibayar: ${DateFormat('d MMM yyyy').format(currentBill.lastPaidDate!)}'
                                          : (daysUntilDue >= 0 ? '$daysUntilDue Hari lagi' : 'Terlewat'),
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: currentBill.isPaid
                                            ? Colors.green
                                            : (isOverdue ? Colors.redAccent : Colors.orange),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _editBill(currentBill, isDark);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Ubah Tagihan',
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C1C1C) : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context); // Close detail sheet
                                _deleteBill(currentBill.id);
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsServiceProvider).watchBills();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
        ),
        title: Text(
          'Manajemen Tagihan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BillModel>>(
        stream: billsAsync,
        builder: (context, snapshot) {
          final bills = snapshot.data ?? [];
          final totalPending = _calculateTotalPending(bills);
          final unpaidCount = bills.where((b) => !b.isPaid).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bills.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                AppColors.primary.withValues(alpha: 0.15),
                                Colors.teal.shade900.withValues(alpha: 0.3)
                              ]
                            : [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.3 : 0.08,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAGIHAN MENUNGGU',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: isDarkMode
                                ? Colors.teal.shade300
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatRupiah(totalPending),
                            style: GoogleFonts.quicksand(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$unpaidCount tagihan',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                if (bills.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 60,
                            color: contentColor.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada tagihan',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: contentColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._buildBillList(bills, isDarkMode, contentColor),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillSheet(isDarkMode),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Tambah Tagihan',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  List<Widget> _buildBillList(
    List<BillModel> bills,
    bool isDarkMode,
    Color contentColor,
  ) {
    final unpaidBills = bills.where((b) => !b.isPaid).toList();
    final paidBills = bills.where((b) => b.isPaid).toList();
    final widgets = <Widget>[];

    if (unpaidBills.isNotEmpty) {
      widgets.add(
        Text(
          'BELUM DIBAYAR',
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: contentColor.withValues(alpha: 0.4),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
      widgets.addAll(unpaidBills.map((b) => _buildBillItem(b, isDarkMode)));
    }

    if (paidBills.isNotEmpty) {
      if (unpaidBills.isNotEmpty) widgets.add(const SizedBox(height: 24));
      widgets.add(
        Text(
          'SUDAH DIBAYAR',
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: contentColor.withValues(alpha: 0.4),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
      widgets.addAll(paidBills.map((b) => _buildBillItem(b, isDarkMode)));
    }

    return widgets;
  }

  Widget _buildBillItem(BillModel bill, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final daysUntilDue = _getDaysUntilDue(bill.dueDay);
    final isOverdue = daysUntilDue < 0 && !bill.isPaid;
    final statusColor = isOverdue ? Colors.red : (bill.isPaid ? Colors.green : AppColors.primary);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDarkMode ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
          border: Border.all(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showBillDetailSheet(bill),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.85,
                            child: Checkbox(
                              value: bill.isPaid,
                              onChanged: (val) {
                                ref.read(billsServiceProvider).updateBill(
                                  bill.copyWith(
                                    isPaid: val ?? false,
                                    lastPaidDate: val == true ? DateTime.now() : null,
                                  ),
                                );
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                bill.name,
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: bill.isPaid ? contentColor.withValues(alpha: 0.5) : contentColor,
                                  decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: statusColor.withValues(alpha: isDarkMode ? 0.1 : 0.08),
                            ),
                            child: Text(
                              _formatRupiah(bill.amount),
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: bill.isPaid ? contentColor.withValues(alpha: 0.4) : statusColor,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: contentColor.withValues(alpha: 0.6),
                              ),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') _editBill(bill, isDarkMode);
                              if (value == 'delete') _deleteBill(bill.id);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_rounded, size: 16, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Edit',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Hapus',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: statusColor.withValues(alpha: isDarkMode ? 0.08 : 0.06),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bill.isPaid
                              ? 'Dibayar ${DateFormat('d MMM yyyy').format(bill.lastPaidDate!)}'
                              : 'Jatuh tempo tgl ${bill.dueDay}${isOverdue ? ' • Jatuh Tempo' : daysUntilDue >= 0 ? ' • ${daysUntilDue}h lagi' : ''}',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


