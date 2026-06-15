import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabunganku/core/services/permission_service.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/services/ocr_service.dart';
import 'package:tabunganku/features/settings/presentation/providers/security_provider.dart';

class ScanReceiptPage extends ConsumerStatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  ConsumerState<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends ConsumerState<ScanReceiptPage> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  
  File? _image;
  bool _isScanning = false;
  bool _titleHasError = false;
  
  // Scanned Data
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String _detectedTitle = '';
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  // Tips for scanning
  final List<Map<String, dynamic>> _scanTips = [
    {'icon': Icons.wb_sunny_rounded, 'title': 'Cahaya Terang', 'subtitle': 'Hindari bayangan'},
    {'icon': Icons.center_focus_strong_rounded, 'title': 'Fokus & Jelas', 'subtitle': 'Pastikan teks terbaca'},
    {'icon': Icons.crop_free_rounded, 'title': 'Seluruh Bukti', 'subtitle': 'Potret hingga tepi'},
  ];

  @override
  void dispose() {
    _ocrService.dispose();
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // SET external operation to true to prevent appraisal lockout
      ref.read(securityProvider.notifier).setExternalOperation(true);

      // Check permissions based on source
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await PermissionService.requestPermission(
          context,
          permission: Permission.camera,
          title: 'Kamera',
          description: 'Aplikasi membutuhkan akses kamera untuk memindai teks pada struk belanja Anda secara otomatis.',
          icon: Icons.camera_alt_rounded,
        );
      } else {
        // For Gallery
        // On Android 13+ (SDK 33+), we should check for photos permission
        // PermissionHandler handles the platform specifics
        hasPermission = await PermissionService.requestPermission(
          context,
          permission: Permission.photos,
          title: 'Galeri',
          description: 'Aplikasi membutuhkan akses galeri untuk mengambil foto atau screenshot struk belanja yang ingin Anda pindai.',
          icon: Icons.photo_library_rounded,
        );
      }

      if (!hasPermission) return;
      
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
        });

        final result = await _ocrService.scanReceipt(_image!);

        setState(() {
          _amount = result['amount'];
          _type = result['type'];
          _detectedTitle = result['brandName'] ?? '';
          
          _amountController.text = _formatDigitsWithDots(_amount.toStringAsFixed(0));
          _titleController.text = _detectedTitle;
          _isScanning = false;
        });
      }
    } finally {
      // UNSET external operation after image picking is done
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }
  }

  Future<void> _saveTransaction() async {
    final titleVal = _titleController.text.trim();
    setState(() {
      _titleHasError = titleVal.isEmpty;
    });

    if (_titleHasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Keterangan / nama toko tidak boleh kosong!',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus lebih dari 0')));
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleVal,
      description: _noteController.text.trim().isEmpty ? 'Bukti Transaksi' : _noteController.text.trim(),
      amount: amount,
      type: _type,
      date: DateTime.now(),
      category: _type == TransactionType.income ? 'Pemasukan' : 'Lainnya',
      groupId: null, // Personal history only
    );

    await ref.read(transactionServiceProvider).addTransaction(transaction);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaksi berhasil dicatat ke Tabungan Pribadi'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Scan Bukti Transaksi',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: contentColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Area
              GestureDetector(
                onTap: () => _isScanning ? null : _showPickerOptions(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_image!, fit: BoxFit.cover),
                              if (_isScanning) _buildScanningEffect(isDarkMode),
                            ],
                          ),
                        )
                      : _buildPlaceholder(isDarkMode),
                ),
              ),
              if (_image == null) ...[
                const SizedBox(height: 20),
                _buildScanningTips(isDarkMode),
              ],
              const SizedBox(height: 20),
              
              if (_image != null && !_isScanning) ...[
                // Extraction Result Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HASIL SCAN AI', 
                            style: GoogleFonts.quicksand(
                              fontSize: 9, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.5, 
                              color: isDarkMode ? Colors.white38 : Colors.black45,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 10, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'CONFIRMED', 
                                  style: GoogleFonts.quicksand(
                                    fontSize: 8, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Title Input (Auto-filled)
                      _buildHighVisInput(
                        controller: _titleController,
                        icon: Icons.storefront_rounded,
                        label: 'Keterangan / Toko',
                        isDarkMode: isDarkMode,
                        hintText: 'Contoh: Supermarket, Kopi, dll...',
                        hasError: _titleHasError,
                        onChanged: (val) {
                          if (_titleHasError && val.trim().isNotEmpty) {
                            setState(() => _titleHasError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Type Selector
                      Row(
                        children: [
                          Expanded(
                            child: _typeButton(
                              label: 'Pemasukan',
                              isSelected: _type == TransactionType.income,
                              color: Colors.green,
                              isDarkMode: isDarkMode,
                              onTap: () => setState(() => _type = TransactionType.income),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _typeButton(
                              label: 'Pengeluaran',
                              isSelected: _type == TransactionType.expense,
                              isDarkMode: isDarkMode,
                              color: Colors.red,
                              onTap: () => setState(() => _type = TransactionType.expense),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Amount Input
                      _buildHighVisInput(
                        controller: _amountController,
                        icon: Icons.payments_rounded,
                        label: 'Nominal Transaksi',
                        isDarkMode: isDarkMode,
                        hintText: 'Masukkan Nominal',
                        prefixText: 'Rp',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanSeparatorInputFormatter(),
                        ],
                        style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.bold, color: contentColor),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow(isDarkMode),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan Transaksi', 
                      style: GoogleFonts.quicksand(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _image = null;
                      _amountController.clear();
                      _titleController.clear();
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(
                      'Abaikan & Scan Ulang', 
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton({
    required String label,
    required bool isSelected,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: isDarkMode ? 0.12 : 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.8) : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              color: isSelected ? color : (isDarkMode ? Colors.white38 : Colors.black54),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.document_scanner_rounded, size: 28, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'Pindai Bukti Transaksi',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Ambil foto struk atau screenshot untuk pencatatan otomatis',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              color: isDarkMode ? Colors.white38 : Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningEffect(bool isDarkMode) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MEMINDAI DOKUMEN...',
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mesin AI sedang membaca struk Anda',
              style: GoogleFonts.quicksand(
                color: Colors.white60,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningTips(bool isDarkMode) {
    final titleColor = isDarkMode ? Colors.white70 : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.02) : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'PETUNJUK PEMINDAIAN',
                style: GoogleFonts.quicksand(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDarkMode ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._scanTips.map((tip) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(tip['icon'] as IconData, size: 14, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${tip['title']}: ',
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          TextSpan(
                            text: tip['subtitle'] as String,
                            style: GoogleFonts.quicksand(
                              fontSize: 9,
                              color: isDarkMode ? Colors.white38 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan nominal dan judul sudah sesuai dengan bukti transfer kamu.',
              style: GoogleFonts.quicksand(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.orange.shade200 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighVisInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required bool isDarkMode,
    String? prefixText,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    TextStyle? style,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return HighVisInput(
      controller: controller,
      icon: icon,
      label: label,
      isDarkMode: isDarkMode,
      prefixText: prefixText,
      hintText: hintText,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      style: style,
      hasError: hasError,
      onChanged: onChanged,
    );
  }

  Color actsAsSurface(bool isDarkMode) => isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;

  void _showPickerOptions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Sumber Dokumen',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 28, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Ambil Foto',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded, size: 28, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih dari Galeri',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: contentColor,
                              ),
                            ),
                          ],
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
    );
  }

  String _formatDigitsWithDots(String digitsText) {
    if (digitsText.isEmpty) return '';
    final digits = digitsText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
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
            .substring(0, newValue.selection.end)
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

class HighVisInput extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final String? prefixText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const HighVisInput({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    this.prefixText,
    this.hintText,
    this.inputFormatters,
    this.keyboardType,
    this.style,
    this.hasError = false,
    this.onChanged,
  });

  @override
  State<HighVisInput> createState() => _HighVisInputState();
}

class _HighVisInputState extends State<HighVisInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentColor = widget.isDarkMode ? Colors.white : AppColors.primaryDark;
    final surfaceColor = widget.isDarkMode ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100;

    final Color borderColor;
    final double borderWidth;
    if (widget.hasError) {
      borderColor = Colors.red.shade400;
      borderWidth = 1.5;
    } else if (_isFocused) {
      borderColor = AppColors.primary;
      borderWidth = 1.8;
    } else {
      borderColor = widget.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
      borderWidth = 1.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 20),
              if (widget.prefixText != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.prefixText!,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ],
              SizedBox(width: widget.prefixText != null ? 4 : 8),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType ?? TextInputType.text,
                  inputFormatters: widget.inputFormatters,
                  style: widget.style ?? GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: contentColor,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white30 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
