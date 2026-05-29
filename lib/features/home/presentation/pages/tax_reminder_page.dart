import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/models/tax_reminder_model.dart';
import 'package:tabunganku/services/tax_reminder_service.dart';

class TaxReminderPage extends ConsumerStatefulWidget {
  const TaxReminderPage({super.key});

  @override
  ConsumerState<TaxReminderPage> createState() => _TaxReminderPageState();
}

class _TaxReminderPageState extends ConsumerState<TaxReminderPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final remindersAsync = ref.watch(taxRemindersStreamProvider);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Mint Green Accent & Classic Black/Light background
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
        data: (reminders) => reminders.isEmpty
            ? _buildEmptyState(isDarkMode)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    'Jadwal Pembayaran Pajak',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jangan biarkan denda menumpuk, catat tanggal jatuh temponya.',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: contentColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
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
                          isFirst: index == 0,
                          isLast: index == reminders.length - 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(isDarkMode),
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
    final cardBgColor = isDarkMode ? AppColors.surfaceDark : Colors.white;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notification_important_outlined, size: 48, color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pengingat',
              style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white30 : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan jadwal pajak Anda seperti PKB atau PBB agar tidak terlambat membayar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(fontSize: 11, color: isDarkMode ? Colors.white30.withOpacity(0.5) : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxTile(TaxReminderModel item, bool isDarkMode, {bool isFirst = false, bool isLast = false}) {
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);
    final statusColor = item.status == 'Sudah Bayar' ? accentColor : Colors.redAccent;
    final iconColor = Color(item.colorValue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.status,
              style: GoogleFonts.quicksand(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
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

  void _deleteReminder(String id) {
    ref.read(taxReminderServiceProvider).deleteReminder(id);
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

  Future<void> _showAddDialog(bool isDarkMode) async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedTaxType = 'PBB';
    final accentColor = isDarkMode ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

    final List<Map<String, dynamic>> dialogTaxTypes = [
      {'code': 'PBB', 'label': 'Pajak Bumi & Bangunan', 'icon': Icons.home_rounded, 'color': Colors.teal},
      {'code': 'PKB', 'label': 'Pajak Kendaraan Bermotor', 'icon': Icons.directions_car_rounded, 'color': Colors.blue},
      {'code': 'PPh', 'label': 'Pajak Penghasilan (PPh 21)', 'icon': Icons.wallet_rounded, 'color': Colors.amber},
      {'code': 'PPN', 'label': 'Pajak Pertambahan Nilai (PPN)', 'icon': Icons.receipt_rounded, 'color': Colors.purple},
      {'code': 'BPHTB', 'label': 'Bea Perolehan Hak Tanah', 'icon': Icons.domain_rounded, 'color': Colors.indigo},
      {'code': 'PB1', 'label': 'Pajak Restoran & Hotel (PB1)', 'icon': Icons.restaurant_rounded, 'color': Colors.orange},
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Pengingat Baru',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
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
                              setState(() {
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
                Text(
                  'Nama Pengingat', 
                  style: GoogleFonts.quicksand(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: isDarkMode ? Colors.white30 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Contoh: PKB Motor, PBB Rumah',
                    hintStyle: GoogleFonts.quicksand(fontSize: 13, color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25)),
                    prefixIcon: Icon(Icons.bookmark_added_rounded, color: accentColor, size: 18),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
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
                      setState(() => selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final selectedData = dialogTaxTypes.firstWhere((t) => t['code'] == selectedTaxType);
                final reminder = TaxReminderModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  dueDate: selectedDate,
                  status: 'Belum Bayar',
                  iconCodePoint: (selectedData['icon'] as IconData).codePoint,
                  colorValue: (selectedData['color'] as Color).value,
                );
                ref.read(taxReminderServiceProvider).addReminder(reminder);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
