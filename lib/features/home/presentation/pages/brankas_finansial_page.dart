import 'dart:convert';
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
  ConsumerState<BrankasFinansialPage> createState() => _BrankasFinansialPageState();
}

class _BrankasFinansialPageState extends ConsumerState<BrankasFinansialPage> {
  List<Map<String, dynamic>> _vaultItems = [];
  bool _isObscured = true; // Security obscure toggle
  final _brankasFormKey = GlobalKey<FormState>();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Dialogue controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _value1Controller = TextEditingController(); // e.g. Acc Number / Policy ID
  final TextEditingController _value2Controller = TextEditingController(); // e.g. Owner name / CS phone
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = 'Rekening'; // Rekening, Polis, Dokumen, Investasi

  @override
  void initState() {
    super.initState();
    _loadVaultItems();
  }

  Future<void> _loadVaultItems() async {
    try {
      final userId = await _secureStorage.getUserId() ?? 'default_user';
      final raw = await _secureStorage.readSecureData('brankas_finansial_$userId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          setState(() {
            _vaultItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Informasi berhasil disimpan di Brankas Finansial!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF3F51B5),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label berhasil disalin ke clipboard!',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF3F51B5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF7F8FC);
    final accentColor = const Color(0xFF3F51B5); // Deep Indigo

    // Separate categories
    final bankItems = _vaultItems.where((i) => i['category'] == 'Rekening').toList();
    final polisItems = _vaultItems.where((i) => i['category'] == 'Polis').toList();
    final docItems = _vaultItems.where((i) => i['category'] == 'Dokumen').toList();
    final investItems = _vaultItems.where((i) => i['category'] == 'Investasi').toList();

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
              _isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: contentColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          // Security Alert Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.15)),
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
                        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Seluruh nomor rekening, data polis, dan kredensial penting Anda disimpan secara aman hanya pada perangkat Anda.',
                        style: GoogleFonts.quicksand(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white38 : Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Categories Sections
          _buildCategoryGroup('Rekening Bank', bankItems, isDarkMode, contentColor, accentColor, 'Nomor Rekening', 'Atas Nama'),
          _buildCategoryGroup('Polis Asuransi', polisItems, isDarkMode, contentColor, accentColor, 'Nomor Polis', 'Info Detail'),
          _buildCategoryGroup('Portofolio & Broker', investItems, isDarkMode, contentColor, accentColor, 'ID Investasi', 'Detail Akun'),
          _buildCategoryGroup('Dokumen & Lainnya', docItems, isDarkMode, contentColor, accentColor, 'Kode / Kunci', 'Keterangan'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(isDarkMode, accentColor),
        backgroundColor: accentColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCategoryGroup(
    String groupTitle, 
    List<Map<String, dynamic>> items, 
    bool isDarkMode, 
    Color contentColor, 
    Color accentColor,
    String val1Label,
    String val2Label,
  ) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 16),
          child: Text(
            groupTitle,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
              letterSpacing: 1.1,
            ),
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
                  color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: contentColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(id),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Colors.redAccent.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Value 1
                  _buildVaultRow(val1Label, _formatObscured(val1), () => _copyToClipboard(val1Label, val1), isDarkMode),
                  const SizedBox(height: 8),

                  // Value 2 (if present)
                  if (val2.isNotEmpty) ...[
                    _buildVaultRow(val2Label, _formatObscured(val2), () => _copyToClipboard(val2Label, val2), isDarkMode),
                    const SizedBox(height: 8),
                  ],

                  // Notes (if present)
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Catatan: $notes',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildVaultRow(String label, String value, VoidCallback onCopy, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
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
              color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;
        
        AutovalidateMode _autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _brankasFormKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Simpan Informasi Brankas',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

                    // Category selector
                    Text(
                      'Kategori',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
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
                            _selectedCategory == 'Rekening' ? Icons.credit_card_rounded :
                            _selectedCategory == 'Polis' ? Icons.security_rounded :
                            _selectedCategory == 'Investasi' ? Icons.analytics_rounded : Icons.description_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Rekening',
                                    child: Text('Rekening Bank'),
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
                                    _selectedCategory = val ?? 'Rekening';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    RichText(
                      text: TextSpan(
                        text: 'Nama Layanan / Judul',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: contentColor.withOpacity(0.4),
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
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama layanan tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                        hintText: 'Masukkan Nama Layanan / Judul',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.title_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Value 1 (required)
                    RichText(
                      text: TextSpan(
                        text: _selectedCategory == 'Rekening' ? 'Nomor Rekening' :
                        _selectedCategory == 'Polis' ? 'Nomor Polis' :
                        _selectedCategory == 'Investasi' ? 'User ID / Email Broker' : 'Kode / No Dokumen',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: contentColor.withOpacity(0.4),
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
                      keyboardType: _selectedCategory == 'Rekening'
                          ? TextInputType.number
                          : TextInputType.text,
                      inputFormatters: _selectedCategory == 'Rekening'
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kolom ini tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                        errorStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.redAccent),
                        hintText: 'Masukkan Nomor / Detail Kredensial',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          _selectedCategory == 'Rekening' ? Icons.credit_card_rounded :
                          _selectedCategory == 'Polis' ? Icons.security_rounded :
                          _selectedCategory == 'Investasi' ? Icons.analytics_rounded : Icons.description_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Value 2
                    Text(
                      _selectedCategory == 'Rekening' ? 'Atas Nama Rekening (Opsional)' :
                      _selectedCategory == 'Polis' ? 'Info Manfaat / Tertanggung (Opsional)' :
                      _selectedCategory == 'Investasi' ? 'User ID Lainnya (Opsional)' : 'Detail / Keterangan Tambahan',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _value2Controller,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Data Pelengkap',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.info_outline_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    Text(
                      'Catatan Ringkas (Opsional)',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _notesController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Catatan Ringkas',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
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
                            _autoValidate = AutovalidateMode.onUserInteraction;
                          });
                          _addItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Kunci & Simpan di Brankas',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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
