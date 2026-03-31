import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/family_group_provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../models/family_group_model.dart';
import '../../../../models/transaction_model.dart';
import '../widgets/name_setup_sheet.dart';

class FamilyGroupPage extends ConsumerStatefulWidget {
  const FamilyGroupPage({super.key});

  @override
  ConsumerState<FamilyGroupPage> createState() => _FamilyGroupPageState();
}

class _FamilyGroupPageState extends ConsumerState<FamilyGroupPage> {
  final _joinCodeController = TextEditingController();
  final _createGroupController = TextEditingController();
  late ScrollController _scrollController;
  bool _isFabExtended = true;
  Timer? _hideTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll listener removed as per user request to move away from scroll-based expansion
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isFabExtended) {
        setState(() => _isFabExtended = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideTimer?.cancel();
    _joinCodeController.dispose();
    _createGroupController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.teal.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _handleJoin() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (ref.read(userNameProvider).isEmpty) {
      showNameSetupSheet(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(familyGroupServiceProvider).joinGroup(code);
      _joinCodeController.clear();
      _showSuccess('Berhasil bergabung ke keluarga!');
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreate() async {
    if (ref.read(userNameProvider).isEmpty) {
      showNameSetupSheet(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isCreating = false;
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48, height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Buat Grup Keluarga',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beri nama grup untuk keluarga kamu.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _createGroupController,
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tabungan Liburan Keluarga',
                    prefixIcon: const Icon(Icons.group, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: isCreating ? null : () async {
                      final name = _createGroupController.text.trim();
                      if (name.isEmpty) return;
                      setModalState(() => isCreating = true);
                      try {
                        await ref.read(familyGroupServiceProvider).createGroup(name);
                        _createGroupController.clear();
                        if (context.mounted) Navigator.pop(context);
                        _showSuccess('Keluarga baru berhasil dibuat!');
                      } catch (e) {
                        if (context.mounted) _showError(e.toString().replaceAll("Exception: ", ""));
                      } finally {
                        if (mounted) setModalState(() => isCreating = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isCreating
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Buat Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showAddFamilyTransaction(String groupId, {TransactionModel? existingTx}) async {
    final amountController = TextEditingController(
      text: existingTx != null ? _formatNumberNoDots(existingTx.amount) : '',
    );
    final customCategoryController = TextEditingController(
      text: existingTx != null && !['Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat'].contains(existingTx.category) 
          ? existingTx.category : '',
    );
    
    String selectedCategory = existingTx?.category ?? 'Tabungan';
    // If it's a custom category, set dropdown to 'Lainnya'
    if (existingTx != null && !['Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat'].contains(existingTx.category)) {
      selectedCategory = 'Lainnya';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text(existingTx != null ? 'Edit Tabungan' : 'Tambah Tabungan', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                const SizedBox(height: 8),
                Text(existingTx != null ? 'Perbarui catatan tabungan keluarga Anda.' : 'Catat pemasukan untuk saldo bersama keluarga.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 32),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter(),
                        ],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 44,
                          letterSpacing: -2,
                          color: AppColors.primaryDark,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey.shade200, fontWeight: FontWeight.w900),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                const Text('Pilih Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  items: [
                    'Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 
                    'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 
                    'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat', 
                    'Lainnya'
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setModalState(() => selectedCategory = newValue);
                    }
                  },
                ),
                
                if (selectedCategory == 'Lainnya') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: customCategoryController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Nama Kategori Kustom...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity, height: 64,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amountText = amountController.text.replaceAll('.', '');
                      final amount = double.tryParse(amountText) ?? 0;
                      if (amount <= 0) return;
                      
                      String finalCategory = selectedCategory;
                      if (selectedCategory == 'Lainnya' && customCategoryController.text.isNotEmpty) {
                        finalCategory = customCategoryController.text.trim();
                      }
                      
                      if (existingTx != null) {
                        // Update
                        final updatedTx = existingTx.copyWith(
                          amount: amount,
                          category: finalCategory,
                          title: finalCategory,
                        );
                        await ref.read(transactionServiceProvider).updateTransaction(updatedTx);
                        if (context.mounted) Navigator.pop(context);
                        _showSuccess('Tabungan berhasil diperbarui!');
                      } else {
                        // Add
                        final tx = TransactionModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: finalCategory,
                          description: 'Entry via Tabungan Keluarga',
                          amount: amount,
                          type: TransactionType.income,
                          date: DateTime.now(),
                          category: finalCategory,
                          groupId: groupId,
                        );
                        await ref.read(transactionServiceProvider).addTransaction(tx);
                        if (context.mounted) Navigator.pop(context);
                        _showSuccess('Tabungan berhasil dicatat!');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: Text(existingTx != null ? 'Update Tabungan' : 'Simpan Tabungan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumberNoDots(double value) {
    return value.toInt().toString();
  }

  void _showTransactionActions(TransactionModel transaction, String groupId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Aksi Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.edit_rounded, color: Colors.blue)),
              title: const Text('Edit Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ubah nominal atau kategori'),
              onTap: () {
                Navigator.pop(context);
                _showAddFamilyTransaction(groupId, existingTx: transaction);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.delete_forever_rounded, color: Colors.red)),
              title: const Text('Hapus Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text('Data akan dihapus permanen'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTransaction(transaction);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTransaction(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text('Data tabungan ini akan dihapus dan saldo grup akan otomatis menyesuaikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(transactionServiceProvider).deleteTransaction(transaction.id);
              if (context.mounted) Navigator.pop(context);
              _showSuccess('Transaksi berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatK(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.0', '')} K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    final groupId = ref.watch(userGroupIdProvider);
    final groupAsync = ref.watch(familyGroupStreamProvider);

    // Prompt Setup Name Automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userName.isEmpty && ModalRoute.of(context)?.isCurrent == true) {
        // Debounce to prevent multiple dialogs
        showNameSetupSheet(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keluarga', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primaryDark,
      ),
      body: (groupId == null || groupId.isEmpty)
          ? _buildNoGroupView(userName)
          : groupAsync.when(
              data: (group) {
          if (group == null) {
            // Document deleted or doesn't exist anymore
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(userGroupIdProvider.notifier).setGroupId(null);
            });
            return _buildNoGroupView(userName);
          }
          return _buildGroupDashboard(group, userName);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              const Text('Menghubungkan ke Cloud...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        error: (e, st) => Container(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Koneksi Gagal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Terjadi kesalahan saat memuat data keluarga. Pastikan internet aktif atau cek aturan Firestore Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Detail: $e',
                    style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(familyGroupStreamProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (groupId != null && groupId.isNotEmpty)
          ? _buildSmartFab(groupId)
          : null,
    );
  }

  Widget _buildSmartFab(String groupId) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
      height: 56,
      width: _isFabExtended ? 190 : 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _showAddFamilyTransaction(groupId),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 24),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutQuart,
                      child: SizedBox(
                        width: _isFabExtended ? null : 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _isFabExtended ? 1 : 0,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'Tambah Tabungan',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoGroupView(String userName) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.family_restroom, size: 64, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tabungan Keluarga',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName.isEmpty
                ? 'Halo! Silakan atur nama Anda terlebih dahulu untuk mulai menabung bersama.'
                : 'Halo, $userName!\nGabung dengan keluarga kamu atau buat grup baru sekarang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 48),
          
          // Container Buat Baru
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Buat Keluarga Baru'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: _handleCreate,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ATAU', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _joinCodeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2),
                  decoration: InputDecoration(
                    hintText: 'Ketik Kode',
                    hintStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, letterSpacing: 0, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gabung dengan Kode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGroupDashboard(FamilyGroupModel group, String userName) {
    // Check if sync repair is needed (current user name not in group but a random name is)
    final prefixes = ['Sultan', 'Jagoan', 'Pejuang', 'Juragan', 'Master', 'Pendekar', 'Bintang'];
    final suffixes = ['Hemat', 'Cuan', 'Tabung', 'MasaDepan', 'Bijak', 'Sukses'];
    String? randomNameInGroup;
    for (var m in group.members) {
      for (var p in prefixes) {
        for (var s in suffixes) {
          if (m == '$p $s') { randomNameInGroup = m; break; }
        }
        if (randomNameInGroup != null) break;
      }
      if (randomNameInGroup != null) break;
    }

    final needsSync = !group.members.contains(userName) && randomNameInGroup != null;

    // Format mata uang
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsSync) 
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_problem_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sinkronisasi Nama', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                        Text('Gunakan nama "$userName" di grup ini?', style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      _showSuccess('Memperbarui nama di grup...');
                      await ref.read(familyGroupServiceProvider).trySyncMemberName(userName);
                    },
                    child: const Text('Sinkron'),
                  )
                ],
              ),
            ),
          
          // Header Group Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                      onPressed: () async {
                         // Konfirmasi Keluar
                         final act = await showDialog(context: context, builder: (c) => AlertDialog(
                           title: const Text('Keluar Grup?'),
                           content: const Text('Kamu akan menghapus aksesmu dari grup ini secara lokal.'),
                           actions: [
                             TextButton(onPressed: ()=>Navigator.pop(c, false), child: const Text('Batal')),
                             TextButton(onPressed: ()=>Navigator.pop(c, true), child: const Text('Keluar', style: TextStyle(color: Colors.red))),
                           ],
                         ));
                         if (act == true) {
                           await ref.read(familyGroupServiceProvider).leaveGroup();
                         }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text('TOTAL SALDO BERSAMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 8),
                Text(
                  formatCurrency.format(group.totalGroupSavings),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                ),
                const SizedBox(height: 24),
                // Kode
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KODE GABUNG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.7), letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(group.code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: group.code));
                          _showSuccess('Kode disalin!');
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Text('Anggota Keluarga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
          const SizedBox(height: 16),
          
          ...group.members.map((member) {
            final balance = group.memberBalances[member] ?? 0.0;
            final isCurrentUser = member == userName;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isCurrentUser ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCurrentUser ? AppColors.primary : Colors.grey.shade200,
                    child: Text(
                      member.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: isCurrentUser ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          member == group.adminName 
                              ? (isCurrentUser ? 'Anda (Admin)' : 'Admin') 
                              : (isCurrentUser ? 'Anda (Anggota)' : 'Anggota'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      _formatK(balance),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Transaksi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
              const Icon(Icons.history, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          
          Consumer(
            builder: (context, ref, child) {
              final groupTransactions = ref.watch(transactionsByGroupProvider(group.id));
              return groupTransactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Belum ada riwayat transaksi.', style: TextStyle(color: Colors.grey.shade400)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupTransactions.length,
                    itemBuilder: (context, index) {
                      final t = groupTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          onTap: () => _showTransactionActions(t, group.id),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.add_task_rounded, color: AppColors.primary, size: 20),
                          ),
                          title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(t.date), style: const TextStyle(fontSize: 11)),
                          trailing: Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(t.amount),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String joinedText = newValue.text.replaceAll('.', '');
    double? value = double.tryParse(joinedText);

    if (value == null) {
      return newValue;
    }

    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
