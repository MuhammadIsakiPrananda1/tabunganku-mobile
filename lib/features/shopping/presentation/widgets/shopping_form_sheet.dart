import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/shopping_item_model.dart';
import 'package:tabunganku/providers/shopping_item_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';

class ShoppingFormSheet extends ConsumerStatefulWidget {
  final ShoppingItem? item;

  const ShoppingFormSheet({super.key, this.item});

  static Future<void> show(BuildContext context, {ShoppingItem? item}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ShoppingFormSheet(item: item),
      ),
    );
  }

  @override
  ConsumerState<ShoppingFormSheet> createState() => _ShoppingFormSheetState();
}

class _ShoppingFormSheetState extends ConsumerState<ShoppingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _customCategoryController;
  late String _selectedCategory;
  String? _selectedGroup;
  bool _isCustomCategory = false;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories =
      AppCategories.expenseCategories.map((c) => c.label).toList();
  final Map<String, List<TransactionCategory>> _groupedCategories = {};

  @override
  void initState() {
    super.initState();

    // Group categories
    for (var cat in AppCategories.expenseCategories) {
      _groupedCategories.putIfAbsent(cat.group, () => []).add(cat);
    }

    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
        text: widget.item != null
            ? widget.item!.estimatedPrice.toInt().toString()
            : '');
    _customCategoryController = TextEditingController();

    final initialCat = widget.item?.category ?? 'Belanja Bulanan';
    final isKnown = _categories.contains(initialCat) &&
        initialCat != AppCategories.otherLabel;

    if (isKnown) {
      _selectedCategory = initialCat;
      _isCustomCategory = false;
      _selectedGroup = AppCategories.expenseCategories.firstWhere((c) => c.label == initialCat).group;
    } else {
      _selectedCategory = AppCategories.otherLabel;
      _isCustomCategory = true;
      _customCategoryController.text =
          initialCat == AppCategories.otherLabel ? '' : initialCat;
      _selectedGroup = AppCategories.expenseCategories.firstWhere((c) => c.label == AppCategories.otherLabel).group;
    }
    _imagePath = widget.item?.imagePath;

    // Trigger formatting if price exists
    if (_priceController.text.isNotEmpty) {
      final val = _priceController.text;
      _priceController.value =
          _RibuanSeparatorInputFormatter().formatEditUpdate(
        const TextEditingValue(text: ''),
        TextEditingValue(
            text: val, selection: TextSelection.collapsed(offset: val.length)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // SET external operation to true to prevent appraisal lockout
      ref.read(securityProvider.notifier).setExternalOperation(true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        // Simpan gambar secara permanen ke direktori dokumen aplikasi
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(pickedFile.path);
        final permanentPath = p.join(appDir.path, fileName);

        await File(pickedFile.path).copy(permanentPath);

        setState(() {
          _imagePath = permanentPath;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      // UNSET external operation after image picking is done
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }
  }

  void _showImageSourceSheet() {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text('Pilih Sumber Foto',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black87)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.teal.shade50.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.teal.shade50,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.teal.shade900,
                )),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final cleanAmount =
          _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(cleanAmount) ?? 0;

      final finalCategory = (_selectedCategory == AppCategories.otherLabel &&
              _customCategoryController.text.trim().isNotEmpty)
          ? _customCategoryController.text.trim()
          : _selectedCategory;

      final newItem = ShoppingItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        estimatedPrice: price,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        category: finalCategory,
        imagePath: _imagePath,
        isBought: widget.item?.isBought ?? false,
      );

      if (widget.item == null) {
        await ref.read(shoppingItemServiceProvider).addItem(newItem);
      } else {
        await ref.read(shoppingItemServiceProvider).updateItem(newItem);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null
                ? 'Rencana belanja ditambahkan'
                : 'Rencana belanja diperbarui'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.item == null ? 'Tambah Rencana Baru' : 'Edit Rencana',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Photo Picker Preview
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: _imagePath != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(_imagePath!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _imagePath = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              color: isDarkMode ? Colors.white24 : Colors.grey,
                              size: 32),
                          const SizedBox(height: 8),
                          Text('TAMBAH FOTO BARANG',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Apa yang akan dibeli?', isDarkMode, isRequired: true),
            _buildTextField(
              controller: _nameController,
              hint: 'Misal: Kopi Kenangan, Beras Ramos...',
              icon: Icons.shopping_bag_outlined,
              isDarkMode: isDarkMode,
              validator: (v) => v!.isEmpty ? 'Nama barang harus diisi' : null,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Estimasi Harga', isDarkMode,
                          isRequired: true),
                      _buildTextField(
                        controller: _priceController,
                        hint: '0',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanSeparatorInputFormatter(),
                        ],
                        isDarkMode: isDarkMode,
                        prefixText: 'Rp',
                        validator: (v) =>
                            v!.isEmpty ? 'Harga harus diisi' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Category Section (Grouped)
            // Category Section (Grouped Dropdowns)
            const SizedBox(height: 24),
            _buildLabel('Pilih Kategori', isDarkMode),
            const SizedBox(height: 8),
            // Group Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGroup,
              dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Grup Kategori',
                filled: true,
                fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
                labelStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
              ),
              items: _groupedCategories.keys.map((group) => DropdownMenuItem(
                value: group,
                child: Text(group, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedGroup = val;
                    _selectedCategory = _groupedCategories[val]!.first.label;
                    _isCustomCategory = _selectedCategory == AppCategories.otherLabel;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Kategori Barang',
                filled: true,
                fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: Icon(
                  AppCategories.expenseCategories.firstWhere((c) => c.label == _selectedCategory).icon,
                  color: AppColors.primary,
                ),
                labelStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
              ),
              items: _groupedCategories[_selectedGroup]!.map((cat) => DropdownMenuItem(
                value: cat.label,
                child: Text(cat.label, style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                    _isCustomCategory = val == AppCategories.otherLabel;
                  });
                }
              },
            ),
            if (_isCustomCategory) ...[
              const SizedBox(height: 20),
              _buildLabel('Kategori Kustom', isDarkMode, isRequired: true),
              _buildTextField(
                controller: _customCategoryController,
                hint: 'Misal: Bengkel, Skincare...',
                icon: Icons.label_important_outline_rounded,
                isDarkMode: isDarkMode,
                validator: (v) =>
                    (_selectedCategory == AppCategories.otherLabel &&
                            v!.isEmpty)
                        ? 'Kategori kustom harus diisi'
                        : null,
              ),
            ],
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: Text(
                    widget.item == null ? 'Simpan Rencana' : 'Simpan Perubahan',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDarkMode, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white30 : Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required bool isDarkMode,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: isDarkMode ? Colors.white12 : Colors.black26, fontSize: 14),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            Icon(icon,
                color: isDarkMode ? Colors.white24 : Colors.grey, size: 20),
            if (prefixText != null) ...[
              const SizedBox(width: 8),
              Text(
                prefixText,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(width: 8),
          ],
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _RibuanSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    int numDigitsBefore = newValue.selection.end -
        newValue.text
            .substring(
                0, math.min(newValue.selection.end, newValue.text.length))
            .replaceAll(RegExp(r'[0-9]'), '')
            .length;
    int newSelectionIndex = 0;
    int digitsCount = 0;
    while (
        digitsCount < numDigitsBefore && newSelectionIndex < formatted.length) {
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
