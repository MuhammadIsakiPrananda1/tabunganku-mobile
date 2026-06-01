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
  bool _nameHasError = false;
  bool _amountHasError = false;

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
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
        title: Text('Kelola Tagihan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: contentColor)),
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
                  style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: contentColor.withValues(alpha: 0.4))),
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
          HighVisInput(
            controller: _nameController,
            icon: Icons.receipt_long_rounded,
            label: 'Nama Tagihan',
            isDarkMode: isDarkMode,
            hintText: 'Contoh: Listrik, Wifi, Kost, dll...',
            hasError: _nameHasError,
            onChanged: (val) {
              if (_nameHasError && val.trim().isNotEmpty) {
                setState(() => _nameHasError = false);
              }
            },
          ),
          const SizedBox(height: 16),
          HighVisInput(
            controller: _amountController,
            icon: Icons.payments_rounded,
            label: 'Nominal',
            prefixText: 'Rp',
            isDarkMode: isDarkMode,
            hintText: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _RibuanFormatter(),
            ],
            hasError: _amountHasError,
            onChanged: (val) {
              if (_amountHasError) {
                final amount = double.tryParse(val.replaceAll('.', '')) ?? 0.0;
                if (amount > 0) {
                  setState(() => _amountHasError = false);
                }
              }
            },
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
                          Text('Jatuh Tempo Tiap Bulan', style: GoogleFonts.quicksand(fontSize: 10, color: (isDarkMode ? Colors.white38 : Colors.grey.shade500), fontWeight: FontWeight.bold)),
                          Text('Tanggal $_dueDay', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12)),
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
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final nameVal = _nameController.text.trim();
                    final rawAmount = _amountController.text.replaceAll('.', '');
                    final amountVal = double.tryParse(rawAmount) ?? 0.0;

                    setState(() {
                      _nameHasError = nameVal.isEmpty;
                      _amountHasError = amountVal <= 0;
                    });

                    if (_nameHasError || _amountHasError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _nameHasError
                                    ? 'Nama tagihan tidak boleh kosong!'
                                    : 'Nominal harus lebih dari 0!',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                      return;
                    }

                    final bill = BillModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameVal,
                      amount: amountVal,
                      dueDay: _dueDay,
                      isPaid: false,
                    );
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(billsServiceProvider).addBill(bill);
                    _nameController.clear();
                    _amountController.clear();
                    messenger.showSnackBar(const SnackBar(
                      content: Text('Tagihan Berhasil Ditambahkan'),
                      backgroundColor: AppColors.primary,
                    ));
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('Simpan Tagihan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PILIH TANGGAL JATUH TEMPO', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
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
                        border: Border.all(color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white12 : Colors.grey.shade300)),
                      ),
                      child: Center(
                        child: Text('$day', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87))),
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
          Text('TOTAL TAGIHAN PENDING', style: GoogleFonts.quicksand(color: contentColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_formatRupiah(pending), 
              style: GoogleFonts.quicksand(color: pending > 0 ? AppColors.primary : contentColor.withValues(alpha: 0.1), fontSize: 36, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text('Dari $count tagihan terdaftar', style: GoogleFonts.quicksand(color: contentColor.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _deleteBill(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        title: Text('Hapus Tagihan?', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Apakah kamu yakin ingin menghapus data tagihan ini secara permanen?', style: GoogleFonts.quicksand(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
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
                  style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
              ),
              const SizedBox(height: 24),
              HighVisInput(
                controller: nameController,
                icon: Icons.label_important_rounded,
                label: 'Nama Tagihan',
                isDarkMode: isDarkMode,
                hintText: 'Contoh: Listrik, Wifi, dll...',
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
                label: 'Nominal Tagihan',
                prefixText: 'Rp',
                isDarkMode: isDarkMode,
                hintText: '0',
                keyboardType: TextInputType.number,
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
              _buildDayPicker(dueDay, (d) => setSheetState(() => dueDay = d), isDarkMode),
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

                    if (nameHasError || amountHasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  nameHasError
                                      ? 'Nama tagihan tidak boleh kosong!'
                                      : 'Nominal harus lebih dari 0!',
                                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Simpan Perubahan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14)),
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
      padding: const EdgeInsets.all(14),
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
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: bill.isPaid ? contentColor.withValues(alpha: 0.3) : contentColor, decoration: bill.isPaid ? TextDecoration.lineThrough : null)),
                Row(
                  children: [
                    Text('Tiap Tgl ${bill.dueDay}', style: GoogleFonts.quicksand(color: isDarkMode ? Colors.white24 : Colors.black38, fontSize: 11, fontWeight: FontWeight.bold)),
                    if (bill.lastPaidDate != null) ...[
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, fontSize: 10)),
                      const SizedBox(width: 8),
                      Text('Lunas: ${DateFormat('d MMM').format(bill.lastPaidDate!)}', style: GoogleFonts.quicksand(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatRupiah(bill.amount), 
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: bill.isPaid ? contentColor.withValues(alpha: 0.3) : contentColor)),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, size: 18, color: contentColor.withValues(alpha: 0.3)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') _showEditBillSheet(bill, isDarkMode);
              if (value == 'delete') _deleteBill(bill.id);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Edit', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Hapus', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                  ],
                ),
              ),
            ],
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
            Text('Belum ada tagihan.', style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker(int selected, Function(int) onPicked, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('TANGGAL JATUH TEMPO', style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5))),
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
                    Text('Pilih Tanggal', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: 31,
                        itemBuilder: (context, i) => ListTile(
                          title: Text('Tanggal ${i + 1}', textAlign: TextAlign.center, style: GoogleFonts.quicksand(fontWeight: selected == (i + 1) ? FontWeight.bold : FontWeight.bold, fontSize: 13)),
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
                  Text('Setiap Tanggal $selected', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12, color: contentColor)),
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

class HighVisInput extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final String? prefixText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const HighVisInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    this.prefixText,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.style,
    this.hasError = false,
    this.onChanged,
  });

  @override
  State<HighVisInput> createState() => _HighVisInputState();
}

class _HighVisInputState extends State<HighVisInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentColor = widget.isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = widget.isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100;

    final Color borderColor;
    final double borderWidth;
    if (widget.hasError) {
      borderColor = Colors.red.shade400;
      borderWidth = 1.5;
    } else if (_isFocused) {
      borderColor = AppColors.primary;
      borderWidth = 1.8;
    } else {
      borderColor = widget.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
      borderWidth = 1.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 20),
              if (widget.prefixText != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.prefixText!,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType ?? TextInputType.text,
                  inputFormatters: widget.inputFormatters,
                  style: widget.style ?? GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: contentColor,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white30 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
