import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/shopping_item_model.dart';
import 'package:tabunganku/providers/shopping_item_provider.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';
import 'package:tabunganku/core/constants/transaction_categories.dart';
import 'package:tabunganku/services/image_upload_service.dart';

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
        child: SingleChildScrollView(
          child: ShoppingFormSheet(item: item),
        ),
      ),
    );
  }

  @override
  ConsumerState<ShoppingFormSheet> createState() => _ShoppingFormSheetState();
}

class _ShoppingFormSheetState extends ConsumerState<ShoppingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController; // Total Price
  late TextEditingController _pricePerUnitController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _categoryController;
  
  String? _imagePath;
  String? _imageUrl;
  bool _isOnline = false;
  bool _isUploading = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.item?.name ?? '');
    
    _quantityController = TextEditingController(
        text: widget.item != null ? widget.item!.quantity.toString().replaceAll(RegExp(r'\.0$'), '') : '');
    _unitController = TextEditingController(
        text: widget.item?.unit ?? '');
    
    // Hitung harga per unit jika sedang mengedit
    String initialPriceStr = '';
    if (widget.item != null) {
      final pricePerUnit = (widget.item!.estimatedPrice / widget.item!.quantity).toInt();
      initialPriceStr = pricePerUnit.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
    }
    
    _pricePerUnitController = TextEditingController(text: initialPriceStr);
    
    _priceController = TextEditingController(
        text: widget.item != null
            ? widget.item!.estimatedPrice.toInt().toString()
            : '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _imagePath = widget.item?.imagePath;
    _imageUrl = widget.item?.url;
    _isOnline = widget.item?.isOnline ?? false;

    // Tambah listener untuk kalkulasi total otomatis
    _pricePerUnitController.addListener(_calculateTotalPrice);
    _quantityController.addListener(_calculateTotalPrice);

    // Format harga jika ada saat edit
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
    _pricePerUnitController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _calculateTotalPrice() {
    final qtyStr = _quantityController.text.replaceAll(',', '.');
    final priceStr = _pricePerUnitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    final qty = qtyStr.isEmpty ? 1.0 : (double.tryParse(qtyStr) ?? 0.0);
    final pricePerUnit = double.tryParse(priceStr) ?? 0.0;
    
    final total = qty * pricePerUnit;
    
    setState(() {
      if (total > 0) {
        final formattedTotal = _RibuanSeparatorInputFormatter().formatEditUpdate(
          const TextEditingValue(text: ''),
          TextEditingValue(
              text: total.toInt().toString(), selection: const TextSelection.collapsed(offset: 0)),
        ).text;
        
        _priceController.text = formattedTotal;
      } else {
        _priceController.text = '';
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      ref.read(securityProvider.notifier).setExternalOperation(true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(pickedFile.path);
        final permanentPath = p.join(appDir.path, fileName);

        await File(pickedFile.path).copy(permanentPath);

        setState(() {
          _imagePath = permanentPath;
          _isUploading = true;
        });

        // Coba unggah ke Awan kustom
        try {
          final uploadService = ref.read(imageUploadServiceProvider);
          final uploadedUrl = await uploadService.uploadImage(File(permanentPath));
          if (uploadedUrl != null) {
            setState(() {
              _imageUrl = uploadedUrl;
              _isOnline = true;
            });
          } else {
            // Gagal atau tidak diset, gunakan penyimpanan lokal
            setState(() {
              _imageUrl = null;
              _isOnline = false;
            });
          }
        } catch (e) {
          debugPrint('[ShoppingFormSheet] Error uploading image: $e');
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }
  }

  void _showImageSourceSheet() {
    final theme = Theme.of(context);
    final isDarkMode = ref.read(themeProvider) == ThemeMode.dark ||
        (ref.read(themeProvider) == ThemeMode.system &&
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
            Text(
              'Pilih Sumber Foto',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
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
              ? Colors.white.withOpacity(0.05)
              : Colors.teal.shade50.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.teal.shade50,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.teal.shade900,
              ),
            ),
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

      final finalCategory = _categoryController.text.trim().isEmpty 
          ? 'Belanja' 
          : _categoryController.text.trim();

      final newItem = ShoppingItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        estimatedPrice: price,
        quantity: double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1,
        unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        category: finalCategory,
        imagePath: _imagePath,
        url: _imageUrl,
        isOnline: _isOnline,
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
            content: Text(
              widget.item == null
                  ? 'Rencana belanja ditambahkan!'
                  : 'Rencana belanja diperbarui!',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.item == null ? 'Bikin Rencana' : 'Ubah Rencana',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (_priceController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${_priceController.text}',
                      style: GoogleFonts.quicksand(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Picker (Compact & Smart)
                    GestureDetector(
                      onTap: _isUploading ? null : _showImageSourceSheet,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.02)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: _isUploading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Mengunggah gambar ke cloud...',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              )
                            : _imagePath != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: _isOnline && _imageUrl != null
                                            ? Image.network(
                                                _imageUrl!,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, progress) {
                                                  if (progress == null) return child;
                                                  return const Center(
                                                    child: CircularProgressIndicator(color: AppColors.primary),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Image.file(
                                                      File(_imagePath!),
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                            : Image.file(
                                                File(_imagePath!),
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      // Status Badge Cloud/Local
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _isOnline ? Colors.blueAccent.withOpacity(0.9) : Colors.amber.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _isOnline ? Icons.cloud_done_rounded : Icons.smartphone_rounded,
                                                color: Colors.white,
                                                size: 10,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _isOnline ? 'CLOUD SERVER' : 'MEMORI LOKAL',
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _imagePath = null;
                                            _imageUrl = null;
                                            _isOnline = false;
                                          }),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_a_photo_rounded,
                                          color: AppColors.primary, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Tambah Foto Barang',
                                        style: GoogleFonts.quicksand(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Nama Barang', isDarkMode, isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Masukkan nama barang',
                      icon: Icons.shopping_bag_outlined,
                      isDarkMode: isDarkMode,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Harga/Unit', isDarkMode, isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pricePerUnitController,
                      hint: 'Masukkan harga',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _RibuanSeparatorInputFormatter(),
                      ],
                      isDarkMode: isDarkMode,
                      prefixText: 'Rp',
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Jumlah', isDarkMode, isRequired: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _quantityController,
                      hint: 'Masukkan jumlah',
                      icon: Icons.onetwothree_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isDarkMode: isDarkMode,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Satuan (Unit)', isDarkMode),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _unitController,
                      hint: 'Masukkan satuan (contoh: pcs)',
                      icon: Icons.straighten_rounded,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Kategori', isDarkMode),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _categoryController,
                      hint: 'Masukkan kategori',
                      icon: Icons.label_outline_rounded,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 24),

                    // Estimasi Tampilan Total
                    if (_priceController.text.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ESTIMASI TOTAL', 
                              style: GoogleFonts.quicksand(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold, 
                                color: isDarkMode ? Colors.white38 : Colors.black38,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final totalEstimated = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                                return Text(
                                  _formatRupiah(totalEstimated), 
                                  style: GoogleFonts.quicksand(
                                    fontSize: 15, 
                                    fontWeight: FontWeight.bold, 
                                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              child: Text(
                                'Batal', 
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isUploading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.item == null ? 'Simpan Rencana' : 'Simpan Perubahan',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDarkMode, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
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
    bool readOnly = false,
  }) {
    final fillColor = isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade200;

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      style: GoogleFonts.quicksand(
        fontWeight: FontWeight.bold, 
        fontSize: 13, 
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.quicksand(
          fontSize: 12, 
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white30 : Colors.black38,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              if (prefixText != null) ...[
                const SizedBox(width: 6),
                Text(
                  prefixText,
                  style: GoogleFonts.quicksand(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
