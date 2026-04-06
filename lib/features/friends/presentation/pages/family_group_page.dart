import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
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
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isDarkMode ? Colors.red.shade900 : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isDarkMode ? AppColors.primaryDark : Colors.teal.shade700,
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
        final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    width: 48, height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Grup Keluarga',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beri nama grup untuk keluarga kamu.',
                  style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _createGroupController,
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tabungan Liburan Keluarga',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.grey),
                    prefixIcon: Icon(Icons.group, color: isDarkMode ? AppColors.primary : AppColors.primary),
                    filled: true,
                    fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
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

  Future<void> _showAddFamilyTransaction(FamilyGroupModel group, {TransactionModel? existingTx}) async {
    final groupId = group.id;

    final amountController = TextEditingController(
      text: existingTx != null ? _formatNumberWithDots(existingTx.amount) : '',
    );
    final customCategoryController = TextEditingController(
      text: existingTx != null && !['Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat'].contains(existingTx.category) 
          ? existingTx.category : '',
    );
    
    String selectedCategory = existingTx?.category ?? 'Tabungan';
    TransactionType selectedType = existingTx?.type ?? TransactionType.income;
    final userName = ref.read(userNameProvider);
    
    // If it's a custom category, set dropdown to 'Lainnya'
    if (existingTx != null && !['Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat'].contains(existingTx.category)) {
      selectedCategory = 'Lainnya';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    existingTx != null ? 'Edit Nominal' : 'Tambah Transaksi', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)
                  ),
                ),
                if (existingTx != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      existingTx.category, 
                      style: TextStyle(color: isDarkMode ? AppColors.primary : Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                
                // Transaction Type Selector (Hanya tampil saat TAMBAH BARU)
                if (existingTx == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedType = TransactionType.income),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == TransactionType.income 
                                  ? (isDarkMode ? Colors.green.withValues(alpha: 0.1) : Colors.green.shade50) 
                                  : (isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selectedType == TransactionType.income ? Colors.green.shade200.withValues(alpha: 0.5) : Colors.transparent),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: selectedType == TransactionType.income ? Colors.green : (isDarkMode ? Colors.white24 : Colors.grey)),
                                const SizedBox(height: 4),
                                Text('Pemasukan', style: TextStyle(fontWeight: FontWeight.bold, color: selectedType == TransactionType.income ? (isDarkMode ? Colors.greenAccent : Colors.green.shade700) : (isDarkMode ? Colors.white24 : Colors.grey))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedType = TransactionType.expense),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedType == TransactionType.expense 
                                  ? (isDarkMode ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50) 
                                  : (isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selectedType == TransactionType.expense ? Colors.red.shade200.withValues(alpha: 0.5) : Colors.transparent),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.remove_circle_outline_rounded, color: selectedType == TransactionType.expense ? Colors.red : (isDarkMode ? Colors.white24 : Colors.grey)),
                                const SizedBox(height: 4),
                                Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, color: selectedType == TransactionType.expense ? (isDarkMode ? Colors.redAccent : Colors.red.shade700) : (isDarkMode ? Colors.white24 : Colors.grey))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Nominal Input
                TextFormField(
                  controller: amountController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: -1, color: isDarkMode ? Colors.white : Colors.black),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Input Nominal Baru',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white38 : Colors.grey),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: isDarkMode ? Colors.white38 : Colors.grey.shade600)),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDarkMode ? AppColors.primary : Colors.teal, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDarkMode ? Colors.white10 : Colors.teal.shade200, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDarkMode ? AppColors.primary : Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                if (existingTx == null) ...[
                  Text('Pilih Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    items: [
                      'Tabungan', 'Belanja Bulanan', 'Listrik & Air', 'Pendidikan', 
                      'Kesehatan', 'Cicilan & Hutang', 'Transportasi', 'Kebutuhan Anak', 
                      'Dana Darurat', 'Hiburan & Liburan', 'Renovasi Rumah', 'Sosial & Zakat', 
                      'Lainnya'
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
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
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                    ),
                  ),
                  ],
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
                      
                      final title = "${selectedType == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'} dari $userName";

                      if (existingTx != null) {
                        // Update
                        final updatedTx = existingTx.copyWith(
                          amount: amount,
                          category: finalCategory,
                          title: title,
                          description: finalCategory,
                          type: selectedType,
                        );
                        await ref.read(transactionServiceProvider).updateTransaction(updatedTx);
                        if (context.mounted) Navigator.pop(context);
                        _showSuccess('Transaksi berhasil diperbarui!');
                      } else {
                        // Add
                        final tx = TransactionModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: finalCategory,
                          amount: amount,
                          type: selectedType,
                          date: DateTime.now(),
                          category: finalCategory,
                          groupId: groupId,
                          creatorName: userName,
                        );
                        await ref.read(transactionServiceProvider).addTransaction(tx);
                        if (context.mounted) Navigator.pop(context);
                        _showSuccess('Transaksi berhasil dicatat!');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: existingTx != null 
                          ? (isDarkMode ? Colors.teal.shade900.withValues(alpha: 0.5) : Colors.teal.shade700) 
                          : (isDarkMode ? AppColors.primary : AppColors.primaryDark),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(existingTx != null ? 'Simpan Perubahan' : 'Simpan Transaksi', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  String _formatNumberWithDots(double value) {
    final rounded = value.round();
    return rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  void _showTransactionActions(TransactionModel transaction, FamilyGroupModel group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDarkMode ? Colors.white10 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Aksi Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
            const SizedBox(height: 24),
            
            Consumer(
              builder: (context, ref, child) {
                final currentUserName = ref.watch(userNameProvider);
                // Allow edit/delete if owner OR if legacy (no creatorName)
                final isOwner = transaction.creatorName == null || transaction.creatorName == currentUserName;
                
                if (!isOwner) {
                  return Column(
                    children: [
                      Icon(Icons.lock_person_rounded, size: 48, color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Hanya ${transaction.creatorName ?? "pemilik"} yang bisa mengelola transaksi ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey.shade500, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(backgroundColor: isDarkMode ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFFE3F2FD), child: const Icon(Icons.edit_rounded, color: Colors.blue)),
                      title: Text('Edit Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                      subtitle: Text('Ubah nominal atau kategori', style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black54)),
                      onTap: () {
                        Navigator.pop(context);
                         _showAddFamilyTransaction(group, existingTx: transaction);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: CircleAvatar(backgroundColor: isDarkMode ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFFEBEE), child: const Icon(Icons.delete_forever_rounded, color: Colors.red)),
                      title: const Text('Hapus Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      subtitle: Text('Data akan dihapus permanen', style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black54)),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDeleteTransaction(transaction);
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}

  void _confirmDeleteTransaction(TransactionModel transaction) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        title: Text('Hapus Transaksi?', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        content: Text('Data tabungan ini akan dihapus dan saldo grup akan otomatis menyesuaikan.', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
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
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '';
    
    if (absAmount >= 1000000) {
      return '$sign${(absAmount / 1000000).toStringAsFixed(1).replaceAll('.0', '')} JT';
    } else if (absAmount >= 1000) {
      return '$sign${(absAmount / 1000).toStringAsFixed(1).replaceAll('.0', '')} K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    final groupId = ref.watch(userGroupIdProvider);
    final groupAsync = ref.watch(familyGroupStreamProvider);

    // Watch the global sync provider to ensure cloud state stays updated
    ref.watch(familyBalanceSyncProvider);

    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Keluarga', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : AppColors.primaryDark,
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
              Text('Menghubungkan ke Cloud...', style: TextStyle(color: Colors.grey)),
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
                    color: Colors.red.withValues(alpha: 0.05),
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
          ? groupAsync.when(
              data: (group) => group != null ? _buildSmartFab(group) : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            )
          : null,
    );
  }

  Widget _buildSmartFab(FamilyGroupModel group) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
      height: 56,
      width: _isFabExtended ? 190 : 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary : AppColors.primaryDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.4),
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
          onTap: () => _showAddFamilyTransaction(group),
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
                              'Tambah Transaksi',
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
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    
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
                color: (isDarkMode ? AppColors.primary : AppColors.primaryLight).withValues(alpha: isDarkMode ? 0.2 : 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.family_restroom, size: 64, color: isDarkMode ? AppColors.primary : AppColors.primaryDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tabungan Keluarga',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName.isEmpty
                ? 'Halo! Silakan atur nama Anda terlebih dahulu untuk mulai menabung bersama.'
                : 'Halo, $userName!\nGabung dengan keluarga kamu atau buat grup baru sekarang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white38 : Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 48),
          
          // Container Buat Baru
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Buat Keluarga Baru'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? AppColors.primary : AppColors.primary,
                    side: BorderSide(color: isDarkMode ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary, width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: _handleCreate,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: isDarkMode ? Colors.white10 : Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ATAU', 
                        style: TextStyle(
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade500, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12
                        )),
                    ),
                    Expanded(child: Divider(color: isDarkMode ? Colors.white10 : Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _joinCodeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2, color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Ketik Kode',
                    hintStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, letterSpacing: 0, color: isDarkMode ? Colors.white12 : Colors.grey.shade400),
                    filled: true,
                    fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppColors.primary : AppColors.primaryDark,
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

    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark || (ref.watch(themeProvider) == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    
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
                color: isDarkMode ? Colors.orange.withValues(alpha: 0.1) : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDarkMode ? Colors.orange.withValues(alpha: 0.2) : Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_problem_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sinkronisasi Nama', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.orange : Colors.orange.shade900)),
                        Text('Gunakan nama "$userName" di grup ini?', style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.orange.withValues(alpha: 0.7) : Colors.orange.shade800)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      _showSuccess('Memperbarui nama di grup...');
                      await ref.read(familyGroupServiceProvider).trySyncMemberName(userName);
                    },
                    child: Text('Sinkron', style: TextStyle(color: isDarkMode ? Colors.orange : null)),
                  )
                ],
              ),
            ),
          
          // Header Group Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: group.totalGroupSavings >= 0 
                    ? [AppColors.primaryDark, AppColors.primary]
                    : [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (group.totalGroupSavings >= 0 ? AppColors.primary : Colors.red).withValues(alpha: 0.3), 
                  blurRadius: 20, offset: const Offset(0, 10)
                )
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
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                      onPressed: () async {
                         // Konfirmasi Keluar
                         final act = await showDialog(context: context, builder: (c) => AlertDialog(
                           backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                           title: Text('Keluar Grup?', style: TextStyle(color: isDarkMode ? Colors.white : AppColors.primaryDark)),
                           content: Text('Kamu akan menghapus aksesmu dari grup ini secara lokal.', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
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
                Text('TOTAL SALDO BERSAMA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 8),
                Text(
                  formatCurrency.format(group.totalGroupSavings),
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                    letterSpacing: -1
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stats Row
                Consumer(
                  builder: (context, ref, child) {
                    final groupTransactions = ref.watch(transactionsByGroupProvider(group.id));
                    final totalIn = groupTransactions
                        .where((t) => t.type == TransactionType.income)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final totalOut = groupTransactions
                        .where((t) => t.type == TransactionType.expense)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 14),
                                    const SizedBox(width: 4),
                                    const Text('Pemasukan', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatK(totalIn)}', 
                                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 14),
                                    const SizedBox(width: 4),
                                    const Text('Pengeluaran', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatK(totalOut)}', 
                                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                // Kode
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KODE GABUNG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(group.code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
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
          
          Text('Anggota Keluarga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
          const SizedBox(height: 16),
          
          ...group.members.map((member) {
            final balance = group.memberBalances[member] ?? 0.0;
            final isCurrentUser = member == userName;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? AppColors.primary.withValues(alpha: isDarkMode ? 0.2 : 0.05) 
                    : (isDarkMode ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isCurrentUser 
                    ? AppColors.primary.withValues(alpha: 0.2) 
                    : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  // Avatar: tampilkan foto dari Firestore jika ada
                  Builder(builder: (context) {
                    final photoUrl = group.memberPhotos[member];
                    return Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isCurrentUser
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: ClipOval(
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Builder(
                                builder: (context) {
                                  if (photoUrl.startsWith('http')) {
                                    return Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: isCurrentUser
                                            ? AppColors.primary
                                            : (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.grey.shade200),
                                        child: Center(
                                          child: Text(
                                            member.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : (isDarkMode
                                                      ? Colors.white70
                                                      : Colors.grey.shade700),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Image.file(
                                      File(photoUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: isCurrentUser
                                            ? AppColors.primary
                                            : (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.grey.shade200),
                                        child: Center(
                                          child: Text(
                                            member.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : (isDarkMode
                                                      ? Colors.white70
                                                      : Colors.grey.shade700),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )
                            : Container(
                                color: isCurrentUser
                                    ? AppColors.primary
                                    : (isDarkMode
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.grey.shade200),
                                child: Center(
                                  child: Text(
                                    member.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : (isDarkMode
                                              ? Colors.white70
                                              : Colors.grey.shade700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        Text(
                          member == group.adminName 
                              ? (isCurrentUser ? 'Anda (Admin)' : 'Admin') 
                              : (isCurrentUser ? 'Anda (Anggota)' : 'Anggota'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDarkMode ? Colors.white24 : Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (balance >= 0 ? AppColors.primary : Colors.red).withValues(alpha: isDarkMode ? 0.2 : 0.1), 
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text(
                      _formatK(balance),
                      style: TextStyle(
                        color: balance >= 0 ? (isDarkMode ? Colors.greenAccent.shade200 : AppColors.primary) : (isDarkMode ? Colors.redAccent.shade100 : Colors.red.shade700), 
                        fontWeight: FontWeight.bold, fontSize: 13
                      ),
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
              Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.primaryDark)),
              Icon(Icons.history, color: isDarkMode ? Colors.white24 : Colors.grey, size: 20),
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
                          onTap: () => _showTransactionActions(t, group),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: t.type == TransactionType.income 
                                ? Colors.green.withValues(alpha: isDarkMode ? 0.2 : 0.1) 
                                : Colors.red.withValues(alpha: isDarkMode ? 0.2 : 0.1),
                            child: Icon(
                              t.type == TransactionType.income ? Icons.add_rounded : Icons.remove_rounded, 
                              color: t.type == TransactionType.income ? Colors.green : Colors.red, 
                              size: 20
                            ),
                          ),
                          title: Text(t.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
                          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(t.date), style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white24 : Colors.black54)),
                          trailing: Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(t.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: t.type == TransactionType.income ? (isDarkMode ? Colors.greenAccent.shade200 : Colors.green.shade700) : (isDarkMode ? Colors.redAccent.shade100 : Colors.red.shade700), 
                              fontSize: 14
                            ),
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
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Clean characters for processing
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    // Format with dots
    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    // Robust cursor positioning:
    // 1. Find how many digits were before the cursor in the new unformatted text
    int numDigitsBefore = newValue.selection.end - newValue.text.substring(0, newValue.selection.end).replaceAll(RegExp(r'[0-9]'), '').length;
    
    // 2. Find the index in the formatted text that has the same count of digits before it
    int newSelectionIndex = 0;
    int digitsCount = 0;
    while (digitsCount < numDigitsBefore && newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitsCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
