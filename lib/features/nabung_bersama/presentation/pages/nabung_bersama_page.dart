import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/nabung_bersama_model.dart';
import 'package:tabunganku/providers/nabung_bersama_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class NabungBersamaPage extends ConsumerStatefulWidget {
  const NabungBersamaPage({super.key});

  @override
  ConsumerState<NabungBersamaPage> createState() => _NabungBersamaPageState();
}

class _NabungBersamaPageState extends ConsumerState<NabungBersamaPage> {
  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 16),
        ),
        title: Text(
          'Nabung Bersama',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: contentColor,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: _buildGrupContent(isDarkMode),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNabungBersamaDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        hoverElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Grup Baru',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildGrupContent(bool isDarkMode) {
    final nabungBersamaAsync = ref.watch(nabungBersamaProvider);

    return nabungBersamaAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }
        return Column(
          children: list.map((a) => _buildNabungBersamaListItem(a, isDarkMode)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(
        child: Text(
          'Gagal memuat data grup',
          style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNabungBersamaListItem(NabungBersamaModel item, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final totalMembers = item.members.length;
    final totalSaved = item.members.fold(0.0, (sum, m) => sum + (m.paymentDates.length * item.contributionAmount));
    final targetVal = item.targetAmount > 0 ? item.targetAmount : 1.0;
    final progress = (totalSaved / targetVal).clamp(0.0, 1.0);
    final isCompleted = totalSaved >= item.targetAmount && item.targetAmount > 0;
    
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderClr = isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEDEFF2);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderClr),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name, 
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          color: contentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '$totalMembers Peserta', 
                            style: GoogleFonts.quicksand(
                              color: Colors.grey, 
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                          ),
                          Text(
                            isCompleted ? 'Target Tercapai' : 'Sedang Berjalan', 
                            style: GoogleFonts.quicksand(
                              color: isCompleted ? Colors.green : AppColors.primary, 
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(item.id),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                  ),
                ),
              ],
            ),
          ),

Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progres Tabungan',
                      style: GoogleFonts.quicksand(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.quicksand(
                        color: isCompleted ? Colors.green : AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Terkumpul: ${_formatRupiah(totalSaved)} dari ${_formatRupiah(item.targetAmount)}',
                  style: GoogleFonts.quicksand(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Container(height: 1, color: borderClr),

Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rencana Iuran', 
                        style: GoogleFonts.quicksand(
                          color: Colors.grey, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${_formatRupiah(item.contributionAmount)} / kali', 
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w800, 
                          fontSize: 13, 
                          color: contentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showManageMembersDialog(context, item),
                  icon: const Icon(Icons.manage_accounts_rounded, size: 14),
                  label: Text(
                    'Kelola Tabungan',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_2_rounded, 
              size: 40, 
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Grup', 
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: isDarkMode ? Colors.white54 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan Grup Baru untuk menabung bersama\nteman atau keluarga tercinta.', 
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 11, 
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: labelColor,
        ),
      ),
    );
  }

  void _showAddNabungBersamaDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final targetController = TextEditingController();
    String selectedPeriod = 'Monthly';
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12, left: 24, right: 24
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade300, 
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Grup Nabung Bersama Baru', 
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: labelColor),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSimpleInput('Nama Grup', nameController, Icons.edit_note_rounded, 'Masukkan nama grup', isDarkMode),
            const SizedBox(height: 18),
            _buildSimpleInput('Rencana Iuran per Pengisian', amountController, Icons.payments_rounded, 'Masukkan nominal iuran', isDarkMode, isRupiah: true),
            const SizedBox(height: 18),
            _buildSimpleInput('Target Tabungan Bersama', targetController, Icons.track_changes_rounded, 'Masukkan total target tabungan grup', isDarkMode, isRupiah: true),
            const SizedBox(height: 26),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || amountController.text.isEmpty || targetController.text.isEmpty) return;
                  
                  final List<NabungBersamaMemberModel> members = [];

                  final item = NabungBersamaModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    contributionAmount: double.tryParse(amountController.text.replaceAll('.', '')) ?? 0,
                    targetAmount: double.tryParse(targetController.text.replaceAll('.', '')) ?? 0,
                    period: selectedPeriod,
                    startDate: DateTime.now(),
                    members: members,
                  );

                  await ref.read(nabungBersamaProvider.notifier).addNabungBersama(item);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan & Mulai', 
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberInlineDialog(BuildContext context, WidgetRef ref, NabungBersamaModel item) {
    final nameController = TextEditingController();
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    final labelColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final fillColor = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black26;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Peserta Baru',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan nama peserta',
                  hintStyle: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_rounded, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 46),
                  filled: true,
                  fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.quicksand(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;
                      final newMember = NabungBersamaMemberModel(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        paymentDates: [],
                      );
                      final updatedMembers = [...item.members, newMember];
                      ref.read(nabungBersamaProvider.notifier).updateNabungBersama(item.copyWith(members: updatedMembers));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Tambah',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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

  Widget _buildSimpleInput(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    String hint, 
    bool isDarkMode, 
    {bool isRupiah = false, 
    bool isNumber = false, 
    bool isTextArea = false,
  }) {
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    final fillColor = isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black26;

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label, labelColor),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isTextArea ? TextInputType.multiline : (isRupiah ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
          maxLines: isTextArea ? 3 : 1,
          minLines: 1,
          inputFormatters: (isRupiah || isNumber) ? [_RibuanFormatter()] : null,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 13, 
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  if (isRupiah) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Rp', 
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primary, 
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 46),
            filled: true,
            fillColor: fillColor,
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showManageMembersDialog(BuildContext context, NabungBersamaModel itemInitial) {
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, child) {
            final list = ref.watch(nabungBersamaProvider).value ?? [];
            final item = list.firstWhere((a) => a.id == itemInitial.id, orElse: () => itemInitial);

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [

                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola tabungan & kontribusi iuran anggota grup',
                    style: GoogleFonts.quicksand(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ...item.members.map((member) {
                          final index = item.members.indexOf(member);
                          final contribCount = member.paymentDates.length;
                          final savedAmount = contribCount * item.contributionAmount;
                          final hasSaved = contribCount > 0;
                          final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasSaved 
                                    ? AppColors.primary.withValues(alpha: 0.15) 
                                    : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEDEFF2)),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  children: [

                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: hasSaved
                                              ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]
                                              : [Colors.grey.shade400, Colors.grey.shade500],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: hasSaved
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          initial,
                                          style: GoogleFonts.quicksand(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.name,
                                            style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.5,
                                              color: isDarkMode ? Colors.white : AppColors.primaryDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: hasSaved 
                                                  ? Colors.green.withValues(alpha: 0.08) 
                                                  : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: hasSaved 
                                                    ? Colors.green.withValues(alpha: 0.15) 
                                                    : Colors.transparent,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  hasSaved ? Icons.savings_rounded : Icons.pending_actions_rounded,
                                                  size: 10,
                                                  color: hasSaved ? Colors.green : Colors.grey,
                                                ),
                                                const SizedBox(width: 5),
                                                Flexible(
                                                  child: Text(
                                                    hasSaved 
                                                        ? '${_formatRupiah(savedAmount)} (${contribCount}x)'
                                                        : 'Belum ada tabungan',
                                                    style: GoogleFonts.quicksand(
                                                      fontSize: 9.5,
                                                      color: hasSaved ? Colors.green.shade600 : Colors.grey.shade600,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              title: Text('Hapus Peserta?', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15)),
                                              content: Text('Hapus "${member.name}" dari grup ini?', style: GoogleFonts.quicksand(fontSize: 12)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: Text('Batal', style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold)),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: Text('Hapus', style: GoogleFonts.quicksand(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            final updatedMembers = List<NabungBersamaMemberModel>.from(item.members)..removeAt(index);
                                            ref.read(nabungBersamaProvider.notifier).updateNabungBersama(
                                                item.copyWith(members: updatedMembers));
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEDEFF2)),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jumlah Kontribusi Iuran',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                                      ),
                                    ),

                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF4F6F8),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E8EB),
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [

                                          _buildCircleActionButton(
                                            icon: Icons.remove_rounded,
                                            onPressed: !hasSaved ? null : () {
                                              final updatedMembers = List<NabungBersamaMemberModel>.from(item.members);
                                              final newPaymentDates = List<DateTime>.from(member.paymentDates)..removeLast();
                                              updatedMembers[index] = member.copyWith(paymentDates: newPaymentDates);
                                              ref.read(nabungBersamaProvider.notifier).updateNabungBersama(
                                                  item.copyWith(members: updatedMembers));
                                            },
                                            isDarkMode: isDarkMode,
                                            color: Colors.redAccent,
                                          ),
                                          const SizedBox(width: 10),

                                          Text(
                                            '${contribCount}x',
                                            style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12.5,
                                              color: isDarkMode ? Colors.white : AppColors.primaryDark,
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          _buildCircleActionButton(
                                            icon: Icons.add_rounded,
                                            onPressed: () {
                                              final updatedMembers = List<NabungBersamaMemberModel>.from(item.members);
                                              final newPaymentDates = List<DateTime>.from(member.paymentDates)..add(DateTime.now());
                                              
                                              final userName = ref.read(userNameProvider);
                                              if (member.name.toLowerCase() == userName.toLowerCase() ||
                                                  member.name.toLowerCase() == 'saya') {
                                                final tx = TransactionModel(
                                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                                  title: 'Iuran Nabung Bersama: ${item.name}',
                                                  description: 'Pembayaran iuran nabung bersama ${item.name}',
                                                  amount: item.contributionAmount,
                                                  type: TransactionType.expense,
                                                  date: DateTime.now(),
                                                  category: 'Sosial & Hibah',
                                                );
                                                ref.read(transactionServiceProvider).addTransaction(tx);
                                              }

                                              updatedMembers[index] = member.copyWith(paymentDates: newPaymentDates);
                                              ref.read(nabungBersamaProvider.notifier).updateNabungBersama(
                                                  item.copyWith(members: updatedMembers));
                                            },
                                            isDarkMode: isDarkMode,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: InkWell(
                            onTap: () {
                              _showAddMemberInlineDialog(context, ref, item);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tambah Peserta Baru',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDarkMode,
    required Color color,
  }) {
    final isDisabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.transparent
                : color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled
                  ? (isDarkMode ? Colors.white10 : Colors.grey.shade300)
                  : color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: isDisabled
                ? Colors.grey.shade400
                : color,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Hapus Grup?', 
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: Text(
          'Semua data iuran grup ini akan dihapus secara permanen.', 
          style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal', style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              ref.read(nabungBersamaProvider.notifier).deleteNabungBersama(id);
              Navigator.pop(context);
            }, 
            child: Text('Hapus', style: GoogleFonts.quicksand(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
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
