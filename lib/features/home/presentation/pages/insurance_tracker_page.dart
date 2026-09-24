/// Page: InsuranceTrackerPage
///
/// Pelacak polis asuransi dan pengingat premi.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/models/insurance_model.dart';
import 'package:tabunganku/services/insurance_service.dart';
import 'package:google_fonts/google_fonts.dart';

class InsuranceTrackerPage extends ConsumerStatefulWidget {
  const InsuranceTrackerPage({super.key});

  @override
  ConsumerState<InsuranceTrackerPage> createState() => _InsuranceTrackerPageState();
}

class _InsuranceTrackerPageState extends ConsumerState<InsuranceTrackerPage> {
  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final insuranceAsync = ref.watch(insuranceServiceProvider).watchInsurance();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Asuransi & Proteksi',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: contentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<InsuranceModel>>(
        stream: insuranceAsync,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final totalPremi = items.fold(0.0, (s, i) => s + i.premiumAmount);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(totalPremi, items.length, isDarkMode),
                const SizedBox(height: 28),
                Text(
                  'POLIS TERDAFTAR',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  _buildEmptyState(isDarkMode)
                else
                  ...items.map((i) => _buildInsuranceItem(i, isDarkMode)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInsuranceSheet(isDarkMode),
        backgroundColor: AppColors.primary,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Polis',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSummaryCard(double premi, int count, bool isDarkMode) {
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String statusLabel = count > 0 ? 'Terlindungi' : 'Belum Ada';
    Color statusColor = count > 0 ? Colors.teal : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMASI PREMI BULANAN',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              fmt.format(premi),
              style: GoogleFonts.quicksand(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count > 0
                ? 'dari total $count polis aktif'
                : 'Belum menetapkan perlindungan asuransi',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
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
              _StatCell(
                label: 'POLIS AKTIF',
                value: '$count Polis',
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              Container(
                width: 1,
                height: 32,
                color: borderCol,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _StatCell(
                label: 'STATUS PROTEKSI',
                value: count > 0 ? 'Aktif Terlindungi' : 'Tidak Ada Proteksi',
                color: count > 0 ? Colors.teal : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteInsurance(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Polis?',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Data polis asuransi ini akan dihapus secara permanen.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.quicksand(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(insuranceServiceProvider).deleteInsurance(id);
    }
  }

  Widget _buildInsuranceItem(InsuranceModel item, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final remainingDays = item.expiryDate.difference(DateTime.now()).inDays;
    final isNearExpiry = remainingDays < 30;

    final tagAccentColor = isNearExpiry ? Colors.orangeAccent : Colors.teal;
    final tagBgColor = isNearExpiry 
        ? Colors.orangeAccent.withValues(alpha: 0.1)
        : Colors.teal.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.04 : 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditInsuranceSheet(item, isDarkMode),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.policyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: contentColor,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 18, color: contentColor.withValues(alpha: 0.4)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: borderCol,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    color: cardBg,
                    elevation: 4,
                    onSelected: (value) {
                      if (value == 'edit') _showEditInsuranceSheet(item, isDarkMode);
                      if (value == 'delete') _deleteInsurance(item.id);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 18, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Ubah',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENYEDIA',
                          style: GoogleFonts.quicksand(
                            fontSize: 8,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.provider,
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREMI BULANAN',
                          style: GoogleFonts.quicksand(
                            fontSize: 8,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(item.premiumAmount),
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'MASA BERLAKU',
                        style: GoogleFonts.quicksand(
                          fontSize: 8,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tagBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          remainingDays > 0 ? 'Sisa $remainingDays Hari' : 'Kedaluwarsa',
                          style: GoogleFonts.quicksand(
                            color: tagAccentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
              Icons.health_and_safety_rounded,
              size: 64,
              color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada polis terdaftar.',
              style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInsuranceSheet(bool isDarkMode) {
    final nameController = TextEditingController();
    final providerController = TextEditingController();
    final premiController = TextEditingController();
    DateTime? expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 24,
            top: 16,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Tambah Polis Asuransi',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCompactInput('Nama Polis', nameController, Icons.shield_rounded, isDarkMode, isPremium: false, hint: 'Nama Polis'),
              const SizedBox(height: 16),
              _buildCompactInput('Penyedia Layanan', providerController, Icons.business_rounded, isDarkMode, isPremium: false, hint: 'Penyedia Layanan'),
              const SizedBox(height: 16),
              _buildCompactInput('Premi Bulanan', premiController, Icons.payments_rounded, isDarkMode, isPremium: true, hint: 'Premi Bulanan'),
              const SizedBox(height: 16),
              _buildDatePicker(expiryDate, (d) => setSheetState(() => expiryDate = d), isDarkMode),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final premi = double.tryParse(premiController.text.replaceAll('.', '')) ?? 0;
                    if (nameController.text.isEmpty) {
                      showTopToast(context, 'Nama Polis tidak boleh kosong!', isError: true);
                      return;
                    }
                    if (premi <= 0) {
                      showTopToast(context, 'Premi Bulanan harus diisi!', isError: true);
                      return;
                    }
                    if (expiryDate == null) {
                      showTopToast(context, 'Masa berlaku tanggal belum dipilih!', isError: true);
                      return;
                    }

                    final ins = InsuranceModel(
                      id: const Uuid().v4(),
                      policyName: nameController.text,
                      provider: providerController.text,
                      premiumAmount: premi,
                      expiryDate: expiryDate!,
                    );
                    await ref.read(insuranceServiceProvider).addInsurance(ins);
                    if (context.mounted) {
                      Navigator.pop(context);
                      showTopToast(context, 'Polis Berhasil Disimpan');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Polis',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditInsuranceSheet(InsuranceModel item, bool isDarkMode) {
    final nameController = TextEditingController(text: item.policyName);
    final providerController = TextEditingController(text: item.provider);
    final premiController = TextEditingController(
      text: item.premiumAmount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.',
      ),
    );
    DateTime? expiryDate = item.expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).padding.bottom + 24,
            top: 16,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Ubah Polis Asuransi',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCompactInput('Nama Polis', nameController, Icons.shield_rounded, isDarkMode, isPremium: false, hint: 'Nama Polis'),
              const SizedBox(height: 16),
              _buildCompactInput('Penyedia Layanan', providerController, Icons.business_rounded, isDarkMode, isPremium: false, hint: 'Penyedia Layanan'),
              const SizedBox(height: 16),
              _buildCompactInput('Premi Bulanan', premiController, Icons.payments_rounded, isDarkMode, isPremium: true, hint: 'Premi Bulanan'),
              const SizedBox(height: 16),
              _buildDatePicker(expiryDate, (d) => setSheetState(() => expiryDate = d), isDarkMode),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(insuranceServiceProvider).deleteInsurance(item.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.error),
                        foregroundColor: AppColors.error,
                      ),
                      child: Text('Hapus', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final premi = double.tryParse(premiController.text.replaceAll('.', '')) ?? 0;
                        if (nameController.text.isEmpty) {
                          showTopToast(context, 'Nama Polis tidak boleh kosong!', isError: true);
                          return;
                        }
                        if (premi <= 0) {
                          showTopToast(context, 'Premi Bulanan harus diisi!', isError: true);
                          return;
                        }
                        if (expiryDate == null) {
                          showTopToast(context, 'Masa berlaku tanggal belum dipilih!', isError: true);
                          return;
                        }

                        final updatedIns = item.copyWith(
                          policyName: nameController.text,
                          provider: providerController.text,
                          premiumAmount: premi,
                          expiryDate: expiryDate,
                        );
                        await ref.read(insuranceServiceProvider).updateInsurance(updatedIns);
                        if (context.mounted) {
                          Navigator.pop(context);
                          showTopToast(context, 'Polis Berhasil Diperbarui');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update Polis',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInput(String label, TextEditingController controller, IconData icon, bool isDarkMode, {required bool isPremium, String? hint}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final iconColor = isDarkMode ? Colors.white.withValues(alpha: 0.7) : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isPremium ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: isPremium ? [_RibuanFormatter()] : null,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13,
              color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  if (isPremium) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Rp',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.only(left: 0, right: 16, top: 14, bottom: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(DateTime? selected, Function(DateTime) onPicked, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final iconColor = isDarkMode ? Colors.white.withValues(alpha: 0.7) : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Masa Berlaku',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: iconColor, size: 18),
                const SizedBox(width: 12),
                Text(
                  selected != null ? DateFormat('d MMMM yyyy').format(selected) : 'Pilih masa berlaku...',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: selected != null
                        ? contentColor
                        : (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.25)),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: contentColor.withOpacity(0.3)),
              ],
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

