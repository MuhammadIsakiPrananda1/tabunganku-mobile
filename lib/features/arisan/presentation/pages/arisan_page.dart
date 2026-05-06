import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/arisan_model.dart';
import 'package:tabunganku/providers/arisan_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class ArisanPage extends ConsumerStatefulWidget {
  const ArisanPage({super.key});

  @override
  ConsumerState<ArisanPage> createState() => _ArisanPageState();
}

class _ArisanPageState extends ConsumerState<ArisanPage> {
  String _activeTab = 'Grup'; // 'Grup' or 'Kalkulator'
  
  // Calculator Controllers
  final TextEditingController _calcTargetController = TextEditingController();
  final TextEditingController _calcMembersController = TextEditingController();
  double _calcResult = 0;

  @override
  void dispose() {
    _calcTargetController.dispose();
    _calcMembersController.dispose();
    super.dispose();
  }

  void _calculateArisan() {
    final target = double.tryParse(_calcTargetController.text.replaceAll('.', '')) ?? 0;
    final members = double.tryParse(_calcMembersController.text.replaceAll('.', '')) ?? 1;
    setState(() {
      _calcResult = target / (members > 0 ? members : 1);
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 20),
        ),
        title: Text(
          'Arisan Pintar',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: contentColor,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(isDarkMode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _activeTab == 'Grup' ? _buildGrupContent(isDarkMode) : _buildKalkulatorContent(isDarkMode),
            ),
          ),
        ],
      ),
      floatingActionButton: _activeTab == 'Grup' 
        ? FloatingActionButton.extended(
            onPressed: () => _showAddArisanDialog(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Mulai Arisan', style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          )
        : null,
    );
  }

  Widget _buildTabs(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _buildTabItem('Grup', Icons.groups_rounded),
          _buildTabItem('Kalkulator', Icons.calculate_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, IconData icon) {
    final isSelected = _activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKalkulatorContent(bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      children: [
        _buildInfoCard('Gunakan kalkulator ini untuk merencanakan arisan Anda. Tentukan target dana yang ingin didapat dan jumlah peserta.'),
        const SizedBox(height: 24),
        _buildInputLabel('TARGET DANA YANG DIDAPAT', isDarkMode),
        _buildNumberInput(_calcTargetController, '0', Icons.payments_rounded, isDarkMode, prefix: 'Rp', onChanged: (_) => _calculateArisan()),
        const SizedBox(height: 20),
        _buildInputLabel('JUMLAH PESERTA', isDarkMode),
        _buildNumberInput(_calcMembersController, '0', Icons.person_add_rounded, isDarkMode, onChanged: (_) => _calculateArisan(), isRupiah: false, isSeparator: true),
        const SizedBox(height: 32),
        _buildResultCard('IURAN PER PESERTA', _calcResult, isDarkMode),
      ],
    );
  }

  Widget _buildGrupContent(bool isDarkMode) {
    final arisansAsync = ref.watch(arisanProvider);

    return arisansAsync.when(
      data: (arisans) {
        if (arisans.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }
        return Column(
          children: arisans.map((a) => _buildArisanListItem(a, isDarkMode)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildArisanListItem(ArisanModel arisan, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final wonCount = arisan.members.where((m) => m.hasWon).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(arisan.name, style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor)),
                    Text('${arisan.members.length} Peserta • $wonCount/${arisan.members.length} Selesai', 
                      style: GoogleFonts.quicksand(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(arisan.id),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Iuran / Peserta', style: GoogleFonts.quicksand(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(_formatRupiah(arisan.contributionAmount), style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12, color: contentColor)),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showManageMembersDialog(context, arisan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text('Detail & Kelola', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
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
          const SizedBox(height: 60),
          Icon(Icons.groups_3_rounded, size: 100, color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
          const SizedBox(height: 24),
          Text('Belum Ada Grup Arisan', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white54 : Colors.grey)),
          const SizedBox(height: 8),
          Text('Klik tombol + untuk memulai arisan baru', style: GoogleFonts.quicksand(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // UI Helpers
  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: contentColor.withValues(alpha: 0.5), letterSpacing: 1))
      ),
    );
  }

  Widget _buildNumberInput(TextEditingController controller, String hint, IconData icon, bool isDarkMode, {String? prefix, Function(String)? onChanged, bool isRupiah = true, bool isSeparator = false}) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: (isRupiah || isSeparator) ? [_RibuanFormatter()] : [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: contentColor),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              if (prefix != null) Text(prefix, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
            ],
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildResultCard(String title, double amount, bool isDarkMode) {
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: contentColor.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(_formatRupiah(amount), style: GoogleFonts.quicksand(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  // Dialogs
  void _showAddArisanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final membersController = TextEditingController();
    String selectedPeriod = 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Mulai Arisan Baru', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              _buildSimpleInput('NAMA GRUP ARISAN', nameController, Icons.edit_note_rounded, 'Contoh: Arisan Keluarga'),
              const SizedBox(height: 16),
              _buildSimpleInput('IURAN PER PESERTA', amountController, Icons.payments_rounded, '0', isRupiah: true),
              const SizedBox(height: 16),
              _buildSimpleInput('JUMLAH PESERTA (LIMIT)', membersController, Icons.person_add_rounded, '0', isNumber: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || amountController.text.isEmpty || membersController.text.isEmpty) return;
                    
                    final List<ArisanMemberModel> members = []; // Start empty

                    final arisan = ArisanModel(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      contributionAmount: double.tryParse(amountController.text.replaceAll('.', '')) ?? 0,
                      period: selectedPeriod,
                      startDate: DateTime.now(),
                      members: members,
                    );

                    await ref.read(arisanProvider.notifier).addArisan(arisan);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Simpan & Mulai', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberInlineDialog(BuildContext context, WidgetRef ref, ArisanModel arisan) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Peserta', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Masukkan nama peserta...',
            hintStyle: GoogleFonts.quicksand(fontSize: 12),
          ),
          style: GoogleFonts.quicksand(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.quicksand(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final newMember = ArisanMemberModel(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                paymentDates: [],
              );
              final updatedMembers = [...arisan.members, newMember];
              ref.read(arisanProvider.notifier).updateArisan(arisan.copyWith(members: updatedMembers));
              Navigator.pop(context);
            },
            child: Text('Tambah', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInput(String label, TextEditingController controller, IconData icon, String hint, {bool isRupiah = false, bool isNumber = false, bool isTextArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isTextArea ? TextInputType.multiline : ((isRupiah || isNumber) ? TextInputType.number : TextInputType.text),
          maxLines: isTextArea ? 3 : 1,
          minLines: 1,
          inputFormatters: (isRupiah || isNumber) ? [_RibuanFormatter()] : null,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  if (isRupiah) ...[
                    const SizedBox(width: 8),
                    const Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  ],
                ],
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _showManageMembersDialog(BuildContext context, ArisanModel arisanInitial) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Consumer(
          builder: (context, ref, child) {
            final arisans = ref.watch(arisanProvider).value ?? [];
            final arisan = arisans.firstWhere((a) => a.id == arisanInitial.id,
                orElse: () => arisanInitial);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Text(arisan.name,
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Kelola pembayaran peserta',
                      style: GoogleFonts.quicksand(
                          fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ...arisan.members.map((member) {
                          final index = arisan.members.indexOf(member);
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              member.name,
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.primaryDark),
                            ),
                            trailing: Checkbox(
                              value: member.paymentDates.isNotEmpty,
                              onChanged: (val) {
                                final updatedMembers =
                                    List<ArisanMemberModel>.from(
                                        arisan.members);
                                final newPaymentDates =
                                    List<DateTime>.from(member.paymentDates);
                                if (val == true) {
                                  newPaymentDates.add(DateTime.now());
                                  // Record transaction if it's the user
                                  final userName = ref.read(userNameProvider);
                                  if (member.name.toLowerCase() ==
                                          userName.toLowerCase() ||
                                      member.name.toLowerCase() == 'saya') {
                                    final tx = TransactionModel(
                                      id: DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      title: 'Iuran Arisan: ${arisan.name}',
                                      description:
                                          'Pembayaran iuran arisan ${arisan.name}',
                                      amount: arisan.contributionAmount,
                                      type: TransactionType.expense,
                                      date: DateTime.now(),
                                      category: 'Sosial & Hibah',
                                    );
                                    ref
                                        .read(transactionServiceProvider)
                                        .addTransaction(tx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Transaksi iuran berhasil dicatat!')));
                                  }
                                } else {
                                  newPaymentDates.clear();
                                }
                                updatedMembers[index] = member.copyWith(
                                    paymentDates: newPaymentDates);
                                ref.read(arisanProvider.notifier).updateArisan(
                                    arisan.copyWith(members: updatedMembers));
                              },
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: InkWell(
                            onTap: () {
                              _showAddMemberInlineDialog(context, ref, arisan);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_rounded,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Tambah Peserta',
                                      style: GoogleFonts.quicksand(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.primary)),
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

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Arisan?'),
        content: const Text('Semua data iuran dan putaran akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(arisanProvider.notifier).deleteArisan(id);
              Navigator.pop(context);
            }, 
            child: const Text('Hapus', style: TextStyle(color: Colors.red))
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
