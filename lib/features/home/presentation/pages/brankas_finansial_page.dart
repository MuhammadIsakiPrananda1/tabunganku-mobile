/// Page: BrankasFinansialPage
///
/// Brankas finansial dan ringkasan portofolio aset.
library;

import 'dart:convert';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/security/secure_storage_service.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';

class BrankasFinansialPage extends ConsumerStatefulWidget {
  const BrankasFinansialPage({super.key});

  @override
  ConsumerState<BrankasFinansialPage> createState() =>
      _BrankasFinansialPageState();
}

class _BrankasFinansialPageState extends ConsumerState<BrankasFinansialPage> {
  List<Map<String, dynamic>> _vaultItems = [];
  bool _isObscured = true;
  String _activeFilter = 'Semua';
  final _brankasFormKey = GlobalKey<FormState>();
  final SecureStorageService _secureStorage = SecureStorageService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _value1Controller = TextEditingController();
  final TextEditingController _value2Controller = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = 'Bank';

  @override
  void initState() {
    super.initState();
    _loadVaultItems();
  }

  Future<void> _loadVaultItems() async {
    try {
      final userId = await _secureStorage.getUserId() ?? 'default_user';
      final raw =
          await _secureStorage.readSecureData('brankas_finansial_$userId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          setState(() {
            _vaultItems =
                decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading vault items: $e');
    }
  }

  Future<void> _saveVaultItems() async {
    try {
      final userId = await _secureStorage.getUserId() ?? 'default_user';
      final raw = jsonEncode(_vaultItems);
      await _secureStorage.writeSecureData('brankas_finansial_$userId', raw);
    } catch (e) {
      debugPrint('Error saving vault items: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _value1Controller.dispose();
    _value2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (!_brankasFormKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final val1 = _value1Controller.text.trim();
    final val2 = _value2Controller.text.trim();
    final notes = _notesController.text.trim();

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': _selectedCategory,
      'title': title,
      'val1': val1,
      'val2': val2,
      'notes': notes,
    };

    setState(() {
      _vaultItems.add(newItem);
    });
    _saveVaultItems();

    _titleController.clear();
    _value1Controller.clear();
    _value2Controller.clear();
    _notesController.clear();

    if (mounted) {
      Navigator.pop(context);
      showTopToast(
          context, 'Informasi berhasil disimpan di Brankas Finansial!');
    }
  }

  void _deleteItem(String id) {
    setState(() {
      _vaultItems.removeWhere((item) => item['id'] == id);
    });
    _saveVaultItems();
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    showTopToast(context, '$label berhasil disalin ke clipboard!');
  }

  String _formatObscured(String value) {
    if (!_isObscured) return value;
    if (value.length <= 4) return '••••';
    return '${value.substring(0, 2)}••••${value.substring(value.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor =
        isDarkMode ? AppColors.backgroundDark : const Color(0xFFF7F8FC);
    final accentColor = const Color(0xFF3F51B5);

    // Kategori pemisahan item secara terstruktur
    final bankItems = _vaultItems
        .where((i) => i['category'] == 'Bank' || i['category'] == 'Rekening')
        .toList();
    final ewalletItems = _vaultItems
        .where((i) => i['category'] == 'EWallet' || i['category'] == 'E-Wallet')
        .toList();
    final polisItems =
        _vaultItems.where((i) => i['category'] == 'Polis').toList();
    final investItems =
        _vaultItems.where((i) => i['category'] == 'Investasi').toList();
    final docItems =
        _vaultItems.where((i) => i['category'] == 'Dokumen').toList();

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: contentColor, size: 20),
        ),
        title: Text(
          'Brankas Finansial',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            icon: Icon(
              _isObscured
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: contentColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          // Banner Keamanan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.gpp_good_rounded, color: accentColor, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penyimpanan Lokal Terenkripsi',
                        style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: contentColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Seluruh nomor rekening bank, akun e-wallet, data polis, & kredensial tersimpan aman hanya pada perangkat Anda.',
                        style: GoogleFonts.quicksand(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white38
                              : Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Kategori (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                    'Semua', _vaultItems.length, isDarkMode, accentColor),
                _buildFilterChip('Bank', bankItems.length, isDarkMode,
                    const Color(0xFF3F51B5)),
                _buildFilterChip('E-Wallet', ewalletItems.length, isDarkMode,
                    const Color(0xFF10B981)),
                _buildFilterChip('Polis', polisItems.length, isDarkMode,
                    const Color(0xFF8B5CF6)),
                _buildFilterChip('Investasi', investItems.length, isDarkMode,
                    const Color(0xFFF59E0B)),
                _buildFilterChip('Dokumen', docItems.length, isDarkMode,
                    const Color(0xFF6B7280)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tampilan Berdasarkan Filter Terpilih
          if (_activeFilter == 'Semua' || _activeFilter == 'Bank')
            _buildCategoryGroup(
              'REKENING BANK',
              bankItems,
              isDarkMode,
              contentColor,
              const Color(0xFF3F51B5),
              Icons.account_balance_rounded,
              'Nomor Rekening',
              'Atas Nama Rekening',
              'BANK',
            ),

          if (_activeFilter == 'Semua' || _activeFilter == 'E-Wallet')
            _buildCategoryGroup(
              'E-WALLET & DOMPET DIGITAL',
              ewalletItems,
              isDarkMode,
              contentColor,
              const Color(0xFF10B981),
              Icons.account_balance_wallet_rounded,
              'Nomor HP / ID E-Wallet',
              'Nama Pemilik Akun',
              'E-WALLET',
            ),

          if (_activeFilter == 'Semua' || _activeFilter == 'Polis')
            _buildCategoryGroup(
              'POLIS ASURANSI',
              polisItems,
              isDarkMode,
              contentColor,
              const Color(0xFF8B5CF6),
              Icons.security_rounded,
              'Nomor Polis',
              'Info Detail / Tertanggung',
              'POLIS',
            ),

          if (_activeFilter == 'Semua' || _activeFilter == 'Investasi')
            _buildCategoryGroup(
              'PORTOFOLIO & BROKER',
              investItems,
              isDarkMode,
              contentColor,
              const Color(0xFFF59E0B),
              Icons.analytics_rounded,
              'ID Akun / User ID',
              'Detail Portofolio',
              'INVESTASI',
            ),

          if (_activeFilter == 'Semua' || _activeFilter == 'Dokumen')
            _buildCategoryGroup(
              'DOKUMEN & LAINNYA',
              docItems,
              isDarkMode,
              contentColor,
              const Color(0xFF6B7280),
              Icons.description_rounded,
              'Kode / No. Dokumen',
              'Keterangan Tambahan',
              'DOKUMEN',
            ),

          if (_vaultItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_off_rounded,
                        size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'Brankas Masih Kosong',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: contentColor.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tekan tombol + di bawah untuk menyimpan informasi rekening atau e-wallet',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white38 : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(isDarkMode, accentColor),
        backgroundColor: accentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Tambah Informasi',
          style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, int count, bool isDarkMode, Color categoryColor) {
    final isSelected = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text('$label ($count)'),
        labelStyle: GoogleFonts.quicksand(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? Colors.white
              : (isDarkMode ? Colors.white70 : Colors.black87),
        ),
        selectedColor: categoryColor,
        backgroundColor:
            isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? categoryColor
                : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
          ),
        ),
        onSelected: (_) {
          setState(() {
            _activeFilter = label;
          });
        },
      ),
    );
  }

  Widget _buildCategoryGroup(
    String groupTitle,
    List<Map<String, dynamic>> items,
    bool isDarkMode,
    Color contentColor,
    Color categoryColor,
    IconData categoryIcon,
    String val1Label,
    String val2Label,
    String badgeTag,
  ) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 16),
          child: Row(
            children: [
              Icon(categoryIcon, size: 16, color: categoryColor),
              const SizedBox(width: 8),
              Text(
                groupTitle,
                style: GoogleFonts.quicksand(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: categoryColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) {
          final id = item['id'] as String;
          final title = item['title'] as String;
          final val1 = item['val1'] as String;
          final val2 = item['val2'] as String;
          final notes = item['notes'] as String;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                    blurRadius: 10,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeTag,
                              style: GoogleFonts.quicksand(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: categoryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: contentColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(id),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Colors.redAccent.withValues(alpha: 0.6),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildVaultRow(val1Label, _formatObscured(val1),
                      () => _copyToClipboard(val1Label, val1), isDarkMode),
                  const SizedBox(height: 8),
                  if (val2.isNotEmpty) ...[
                    _buildVaultRow(val2Label, _formatObscured(val2),
                        () => _copyToClipboard(val2Label, val2), isDarkMode),
                    const SizedBox(height: 8),
                  ],
                  if (notes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 13,
                              color: isDarkMode ? Colors.white38 : Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notes,
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVaultRow(
      String label, String displayValue, VoidCallback onCopy, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayValue,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.copy_rounded, size: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.background;

        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _brankasFormKey,
                  autovalidateMode: autoValidate,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Simpan Informasi Brankas',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: contentColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pilih Kategori',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: contentColor.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedCategory == 'Bank'
                                  ? Icons.account_balance_rounded
                                  : _selectedCategory == 'EWallet'
                                      ? Icons.account_balance_wallet_rounded
                                      : _selectedCategory == 'Polis'
                                          ? Icons.security_rounded
                                          : _selectedCategory == 'Investasi'
                                              ? Icons.analytics_rounded
                                              : Icons.description_rounded,
                              color: _selectedCategory == 'Bank'
                                  ? const Color(0xFF3F51B5)
                                  : _selectedCategory == 'EWallet'
                                      ? const Color(0xFF10B981)
                                      : _selectedCategory == 'Polis'
                                          ? const Color(0xFF8B5CF6)
                                          : _selectedCategory == 'Investasi'
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF6B7280),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: isDarkMode
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: contentColor,
                                      fontSize: 13),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Bank',
                                      child: Text(
                                          'Rekening Bank (BCA, Mandiri, BRI, DLL)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'EWallet',
                                      child: Text(
                                          'E-Wallet (GoPay, OVO, DANA, DLL)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Polis',
                                      child: Text('Polis Asuransi'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Investasi',
                                      child: Text('Portofolio / Broker'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Dokumen',
                                      child: Text('Dokumen / Lainnya'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    setModalState(() {
                                      _selectedCategory = val ?? 'Bank';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: 'Nama Layanan / Akun',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: contentColor.withValues(alpha: 0.5),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: contentColor),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama layanan tidak boleh kosong';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          errorStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              color: Colors.redAccent),
                          hintText: _selectedCategory == 'Bank'
                              ? 'Masukkan Nama Bank atau Nama Akun'
                              : _selectedCategory == 'EWallet'
                                  ? 'Masukkan Nama E-Wallet atau Nama Akun'
                                  : _selectedCategory == 'Polis'
                                      ? 'Masukkan Nama Asuransi atau Nama Akun'
                                      : _selectedCategory == 'Investasi'
                                          ? 'Masukkan Nama Investasi atau Nama Akun'
                                          : 'Masukkan Nama Dokumen atau Nama Akun',
                          hintStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                              fontSize: 12.5),
                          prefixIcon: Icon(
                            Icons.title_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: _selectedCategory == 'Bank'
                              ? 'Nomor Rekening'
                              : _selectedCategory == 'EWallet'
                                  ? 'Nomor HP / ID E-Wallet'
                                  : _selectedCategory == 'Polis'
                                      ? 'Nomor Polis'
                                      : _selectedCategory == 'Investasi'
                                          ? 'User ID / Email Broker'
                                          : 'Kode / No Dokumen',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: contentColor.withValues(alpha: 0.5),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _value1Controller,
                        keyboardType: (_selectedCategory == 'Bank' ||
                                _selectedCategory == 'EWallet')
                            ? TextInputType.number
                            : TextInputType.text,
                        inputFormatters: (_selectedCategory == 'Bank' ||
                                _selectedCategory == 'EWallet')
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : null,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: contentColor),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kolom ini tidak boleh kosong';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                          errorStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              color: Colors.redAccent),
                          hintText: _selectedCategory == 'Bank'
                              ? 'Masukkan Nomor Rekening'
                              : _selectedCategory == 'EWallet'
                                  ? 'Masukkan No HP (cth: 08123456789)'
                                  : 'Masukkan Nomor / Detail Kredensial',
                          hintStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                              fontSize: 12.5),
                          prefixIcon: Icon(
                            _selectedCategory == 'Bank'
                                ? Icons.credit_card_rounded
                                : _selectedCategory == 'EWallet'
                                    ? Icons.phone_android_rounded
                                    : _selectedCategory == 'Polis'
                                        ? Icons.security_rounded
                                        : _selectedCategory == 'Investasi'
                                            ? Icons.analytics_rounded
                                            : Icons.description_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategory == 'Bank'
                            ? 'Atas Nama Rekening (Opsional)'
                            : _selectedCategory == 'EWallet'
                                ? 'Nama Pemilik Akun E-Wallet (Opsional)'
                                : _selectedCategory == 'Polis'
                                    ? 'Info Manfaat / Tertanggung (Opsional)'
                                    : _selectedCategory == 'Investasi'
                                        ? 'User ID Lainnya (Opsional)'
                                        : 'Detail / Keterangan Tambahan',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: contentColor.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _value2Controller,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: contentColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          hintText: 'Masukkan Data Pelengkap',
                          hintStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                              fontSize: 12.5),
                          prefixIcon: Icon(
                            Icons.info_outline_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Catatan Ringkas (Opsional)',
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: contentColor.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _notesController,
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: contentColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          hintText: 'Masukkan Catatan Ringkas',
                          hintStyle: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                              fontSize: 12.5),
                          prefixIcon: Icon(
                            Icons.sticky_note_2_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              autoValidate = AutovalidateMode.onUserInteraction;
                            });
                            _addItem();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Kunci & Simpan di Brankas',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

