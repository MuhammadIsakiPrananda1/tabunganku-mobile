
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/bill_model.dart';
import 'package:tabunganku/services/bills_service.dart';
import 'package:google_fonts/google_fonts.dart';

class BillsTrackerPage extends ConsumerStatefulWidget {
  const BillsTrackerPage({super.key});

  @override
  ConsumerState<BillsTrackerPage> createState() => _BillsTrackerPageState();
}

class _BillsTrackerPageState extends ConsumerState<BillsTrackerPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  int _dueDay = 1;

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billsServiceProvider).watchBills();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text('Kelola Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BillModel>>(
        stream: billsAsync,
        builder: (context, snapshot) {
          final bills = snapshot.data ?? [];
          final totalPending = bills.where((b) => !b.isPaid).fold(0.0, (s, b) => s + b.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildSummaryCard(totalPending, bills.length, isDarkMode),
                const SizedBox(height: 32),

                _buildInlineInputForm(isDarkMode),
                const SizedBox(height: 32),

                Text('TAGIHAN BULANAN', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                if (bills.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...bills.map((b) => _buildBillItem(b, isDarkMode)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInlineInputForm(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHighVisInput(
            controller: _nameController,
            icon: Icons.receipt_long_rounded,
            label: 'Nama Tagihan',
            unit: '',
            color: AppColors.primary,
            isDarkMode: isDarkMode,
            hint: 'Masukkan Nama Tagihan',
          ),
          const SizedBox(height: 16),
          _buildHighVisInput(
            controller: _amountController,
            icon: Icons.payments_rounded,
            label: 'Nominal',
            unit: 'Rp',
            color: Colors.green,
            isDarkMode: isDarkMode,
            isPremium: true,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              InkWell(
                onTap: () => _showDayPickerInline(isDarkMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jatuh Tempo Tiap Bulan', style: TextStyle(fontSize: 10, color: (isDarkMode ? Colors.white38 : Colors.grey.shade500), fontWeight: FontWeight.bold)),
                          Text('Tanggal $_dueDay', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
                    if (_nameController.text.isNotEmpty && amount > 0) {
                      final bill = BillModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        amount: amount,
                        dueDay: _dueDay,
                        isPaid: false,
                      );
                      await ref.read(billsServiceProvider).addBill(bill);
                      _nameController.clear();
                      _amountController.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Tagihan Berhasil Ditambahkan'),
                          backgroundColor: AppColors.primary,
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Tagihan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDayPickerInline(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PILIH TANGGAL JATUH TEMPO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = day == _dueDay;
                  return InkWell(
                    onTap: () {
                      setState(() => _dueDay = day);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text('$day', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : null)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighVisInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String unit,
    required Color color,
    required bool isDarkMode,
    bool isPremium = false,
    String? hint,
  }) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    return TextFormField(
      controller: controller,
      keyboardType: isPremium ? TextInputType.number : TextInputType.text,
      inputFormatters: isPremium ? [_RibuanFormatter()] : null,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor),
      decoration: InputDecoration(
        hintText: hint ?? '0',
        hintStyle: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white10 : Colors.black38),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(unit, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ],
            ],
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildAddButton(bool isDarkMode) {
    return InkWell(
      onTap: () => _showAddBillSheet(isDarkMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double pending, int count, bool isDarkMode) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text('TOTAL TAGIHAN PENDING', style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_formatRupiah(pending), 
              style: GoogleFonts.plusJakartaSans(color: pending > 0 ? AppColors.primary : contentColor.withValues(alpha: 0.1), fontSize: 36, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text('Dari $count tagihan terdaftar', style: TextStyle(color: contentColor.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _deleteBill(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Tagihan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Data tagihan ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(billsServiceProvider).deleteBill(id);
    }
  }

  void _showEditBillSheet(BillModel bill, bool isDarkMode) {
    final nameController = TextEditingController(text: bill.name);
    final amountController = TextEditingController(text: bill.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.'));
    int dueDay = bill.dueDay;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('UBAH TAGIHAN', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.teal.shade900)),
              ),
              const SizedBox(height: 24),
              _buildCompactInput('Nama Tagihan', nameController, Icons.label_important_rounded, isDarkMode, isPremium: false),
              const SizedBox(height: 16),
              _buildCompactInput('Nominal Tagihan', amountController, Icons.payments_rounded, isDarkMode, isPremium: true),
              const SizedBox(height: 16),
              _buildDayPicker(dueDay, (d) => setSheetState(() => dueDay = d), isDarkMode),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                    if (nameController.text.isNotEmpty && amount > 0) {
                      final updatedBill = bill.copyWith(
                        name: nameController.text,
                        amount: amount,
                        dueDay: dueDay,
                      );
                      await ref.read(billsServiceProvider).updateBill(updatedBill);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillItem(BillModel bill, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: bill.isPaid,
              onChanged: (val) {
                ref.read(billsServiceProvider).updateBill(bill.copyWith(isPaid: val ?? false, lastPaidDate: val == true ? DateTime.now() : null));
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.name, 
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: bill.isPaid ? contentColor.withValues(alpha: 0.3) : contentColor, decoration: bill.isPaid ? TextDecoration.lineThrough : null)),
                Text('Jatuh tempo: Tanggal ${bill.dueDay}', style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_formatRupiah(bill.amount), 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: bill.isPaid ? contentColor.withValues(alpha: 0.2) : AppColors.primary)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit_note_rounded, size: 22, color: contentColor.withValues(alpha: 0.3)),
            onPressed: () => _showEditBillSheet(bill, isDarkMode),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 22, color: contentColor.withValues(alpha: 0.2)),
            onPressed: () => _deleteBill(bill.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            const Text('Belum ada tagihan.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet(bool isDarkMode) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    int dueDay = 1;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('TAMBAH TAGIHAN', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.teal.shade900)),
              ),
              const SizedBox(height: 24),
              _buildCompactInput('Nama Tagihan', nameController, Icons.label_important_rounded, isDarkMode, isPremium: false),
              const SizedBox(height: 16),
              _buildCompactInput('Nominal Tagihan', amountController, Icons.payments_rounded, isDarkMode, isPremium: true),
              const SizedBox(height: 16),
              _buildDayPicker(dueDay, (d) => setSheetState(() => dueDay = d), isDarkMode),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
                    if (nameController.text.isNotEmpty && amount > 0) {
                      final bill = BillModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        amount: amount,
                        dueDay: dueDay,
                      );
                      await ref.read(billsServiceProvider).addBill(bill);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Simpan Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, {required bool isPremium}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5))),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isPremium ? TextInputType.number : TextInputType.text,
          inputFormatters: isPremium ? [_RibuanFormatter()] : null,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor),
          decoration: InputDecoration(
            hintText: isPremium ? '0' : 'e.g. Listrik, Wifi',
            hintStyle: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white10 : Colors.teal.shade50),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    const Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                  ],
                ],
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDayPicker(int selected, Function(int) onPicked, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('TANGGAL JATUH TEMPO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5))),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: 31,
                        itemBuilder: (context, i) => ListTile(
                          title: Text('Tanggal ${i + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: selected == (i + 1) ? FontWeight.bold : FontWeight.normal)),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Setiap Tanggal $selected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
                  const Spacer(),
                  Icon(Icons.expand_more_rounded, color: contentColor.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
