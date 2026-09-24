/// Page: TaxReminderPage
///
/// Pengingat jadwal pembayaran pajak.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/models/tax_reminder_model.dart';
import 'package:tabunganku/services/tax_reminder_service.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';

class TaxReminderPage extends ConsumerStatefulWidget {
  const TaxReminderPage({super.key});

  @override
  ConsumerState<TaxReminderPage> createState() => _TaxReminderPageState();
}

class _TaxReminderPageState extends ConsumerState<TaxReminderPage> {
  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final remindersAsync = ref.watch(taxRemindersStreamProvider);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Pengingat Pajak',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          final pending = reminders.where((r) => r.status != 'Sudah Bayar').fold(0.0, (s, r) => s + r.amount);
          final paid = reminders.where((r) => r.status == 'Sudah Bayar').fold(0.0, (s, r) => s + r.amount);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(pending, paid, reminders.length, isDarkMode),
                const SizedBox(height: 28),
                Text(
                  'DAFTAR PENGINGAT PAJAK',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                if (reminders.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reminders.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                          color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                        ),
                        itemBuilder: (context, index) => _buildTaxTile(
                          reminders[index],
                          isDarkMode,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaxReminderSheet(isDarkMode),
        backgroundColor: accentColor,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Pengingat',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.notification_important_outlined,
              size: 64,
              color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada pengingat pajak.',
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double pending, double paid, int count, bool isDarkMode) {
    final hexBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PAJAK TERTUNDA',
                style: GoogleFonts.quicksand(
                  color: contentColor.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pending > 0 
                      ? Colors.redAccent.withOpacity(0.1)
                      : Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pending > 0 ? 'Perlu Bayar' : 'Lunas Semua',
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: pending > 0 ? Colors.redAccent : Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(pending),
              style: GoogleFonts.quicksand(
                color: pending > 0 ? Colors.redAccent : contentColor.withOpacity(0.2),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dari $count pengingat terdaftar',
            style: GoogleFonts.quicksand(
              color: contentColor.withOpacity(0.3),
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAJAK LUNAS',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(paid),
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: borderCol,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL REMINDER',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count Pajak',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxTile(TaxReminderModel item, bool isDarkMode) {
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final statusColor = item.status == 'Sudah Bayar' ? accentColor : Colors.redAccent;
    final iconColor = Color(item.colorValue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(item.iconCodePoint), color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 10, color: isDarkMode ? Colors.white30 : Colors.grey),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        DateFormat('d MMMM yyyy', 'id_ID').format(item.dueDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatRupiah(item.amount),
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            onSelected: (val) {
              if (val == 'status') {
                _toggleStatus(item);
              } else if (val == 'edit') {
                _showTaxReminderSheet(isDarkMode, existing: item);
              } else if (val == 'delete') {
                _deleteReminder(item.id);
              }
            },
            icon: Icon(Icons.more_vert_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400, size: 18),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'status',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      item.status == 'Sudah Bayar' ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.status == 'Sudah Bayar' ? 'Tandai Belum Bayar' : 'Tandai Sudah Bayar',
                      style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'edit',
                height: 40,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ubah Pengingat',
                      style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'delete',
                height: 40,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Text(
                      'Hapus Pengingat',
                      style: GoogleFonts.quicksand(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleStatus(TaxReminderModel item) {
    final newStatus = item.status == 'Sudah Bayar' ? 'Belum Bayar' : 'Sudah Bayar';
    ref.read(taxReminderServiceProvider).updateReminder(item.copyWith(status: newStatus));
  }

  void _deleteReminder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Hapus Pengingat?', 
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus data pengingat pajak ini secara permanen?', 
          style: GoogleFonts.quicksand(
            fontSize: 13, 
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal', 
              style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus', 
              style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(taxReminderServiceProvider).deleteReminder(id);
    }
  }

  IconData _getIcon(int codePoint) {
    if (codePoint == Icons.home_rounded.codePoint) {
      return Icons.home_rounded;
    } else if (codePoint == Icons.directions_car_rounded.codePoint) {
      return Icons.directions_car_rounded;
    } else if (codePoint == Icons.wallet_rounded.codePoint) {
      return Icons.wallet_rounded;
    } else if (codePoint == Icons.receipt_rounded.codePoint) {
      return Icons.receipt_rounded;
    } else if (codePoint == Icons.domain_rounded.codePoint) {
      return Icons.domain_rounded;
    } else if (codePoint == Icons.restaurant_rounded.codePoint) {
      return Icons.restaurant_rounded;
    }
    return Icons.notification_important_outlined;
  }

  void _showTaxReminderSheet(bool isDarkMode, {TaxReminderModel? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(
      text: existing != null 
          ? existing.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')
          : '',
    );
    DateTime selectedDate = existing?.dueDate ?? DateTime.now();
    String selectedTaxType = 'PBB';
    
    final List<Map<String, dynamic>> dialogTaxTypes = [
      {'code': 'PBB', 'label': 'Pajak Bumi & Bangunan', 'icon': Icons.home_rounded, 'color': Colors.teal},
      {'code': 'PKB', 'label': 'Pajak Kendaraan Bermotor', 'icon': Icons.directions_car_rounded, 'color': Colors.blue},
      {'code': 'PPh', 'label': 'Pajak Penghasilan (PPh 21)', 'icon': Icons.wallet_rounded, 'color': Colors.amber},
      {'code': 'PPN', 'label': 'Pajak Pertambahan Nilai (PPN)', 'icon': Icons.receipt_rounded, 'color': Colors.purple},
      {'code': 'BPHTB', 'label': 'Bea Perolehan Hak Tanah', 'icon': Icons.domain_rounded, 'color': Colors.indigo},
      {'code': 'PB1', 'label': 'Pajak Restoran & Hotel (PB1)', 'icon': Icons.restaurant_rounded, 'color': Colors.orange},
    ];

    if (existing != null) {
      for (final type in dialogTaxTypes) {
        if ((type['icon'] as IconData).codePoint == existing.iconCodePoint) {
          selectedTaxType = type['code'] as String;
          break;
        }
      }
    }

    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    bool nameHasError = false;
    bool amountHasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 32,
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
                child: Text(
                  existing == null ? 'PENGINGAT PAJAK BARU' : 'UBAH PENGINGAT PAJAK', 
                  style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tipe Pajak', 
                style: GoogleFonts.quicksand(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: isDarkMode ? Colors.white30 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.03) : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      dialogTaxTypes.firstWhere((t) => t['code'] == selectedTaxType)['icon'] as IconData,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTaxType,
                          isExpanded: true,
                          dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                          icon: Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white30 : Colors.grey, size: 20),
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark, fontSize: 13),
                          items: dialogTaxTypes.map((t) {
                            return DropdownMenuItem<String>(
                              value: t['code'] as String,
                              child: Text(
                                t['label'] as String,
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : AppColors.primaryDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setSheetState(() {
                              selectedTaxType = val!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              HighVisInput(
                controller: titleController,
                icon: Icons.bookmark_added_rounded,
                label: 'Nama Pengingat',
                isDarkMode: isDarkMode,
                hintText: 'Contoh: PKB Motor, PBB Rumah',
                hasError: nameHasError,
                onChanged: (val) {
                  if (nameHasError && val.trim().isNotEmpty) {
                    setSheetState(() => nameHasError = false);
                  }
                },
              ),
              const SizedBox(height: 18),
              HighVisInput(
                controller: amountController,
                icon: Icons.payments_rounded,
                label: 'Nominal Pajak',
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
              const SizedBox(height: 18),
              Text(
                'Tanggal Jatuh Tempo', 
                style: GoogleFonts.quicksand(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: isDarkMode ? Colors.white30 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: accentColor,
                            primary: accentColor,
                            onPrimary: Colors.white,
                            brightness: isDarkMode ? Brightness.dark : Brightness.light,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setSheetState(() => selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withOpacity(0.03) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: accentColor, size: 16),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final nameVal = titleController.text.trim();
                    final rawAmount = amountController.text.replaceAll('.', '');
                    final amountVal = double.tryParse(rawAmount) ?? 0.0;

                    setSheetState(() {
                      nameHasError = nameVal.isEmpty;
                      amountHasError = amountVal <= 0;
                    });

                    if (nameHasError || amountHasError) {
                      showTopToast(
                        context, 
                        nameHasError 
                            ? 'Nama pengingat tidak boleh kosong!' 
                            : 'Nominal harus lebih dari 0!', 
                        isError: true,
                      );
                      return;
                    }

                    final selectedData = dialogTaxTypes.firstWhere((t) => t['code'] == selectedTaxType);
                    
                    if (existing == null) {
                      final reminder = TaxReminderModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: nameVal,
                        dueDate: selectedDate,
                        status: 'Belum Bayar',
                        iconCodePoint: (selectedData['icon'] as IconData).codePoint,
                        colorValue: (selectedData['color'] as Color).value,
                        amount: amountVal,
                      );
                      ref.read(taxReminderServiceProvider).addReminder(reminder);
                    } else {
                      final updated = existing.copyWith(
                        title: nameVal,
                        dueDate: selectedDate,
                        iconCodePoint: (selectedData['icon'] as IconData).codePoint,
                        colorValue: (selectedData['color'] as Color).value,
                        amount: amountVal,
                      );
                      ref.read(taxReminderServiceProvider).updateReminder(updated);
                    }

                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        existing == null 
                            ? 'Pengingat Pajak Berhasil Ditambahkan' 
                            : 'Pengingat Pajak Berhasil Diperbarui',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: accentColor,
                    ));
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  label: Text(
                    existing == null ? 'Simpan Pengingat' : 'Simpan Perubahan',
                    style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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



