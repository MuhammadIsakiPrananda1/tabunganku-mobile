import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  
  // Scanned Data
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  
  @override
  void dispose() {
    _ocrService.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // SET external operation to true to prevent appraisal lockout
      ref.read(securityProvider.notifier).setExternalOperation(true);
      
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
          _amountController.text = _formatDigitsWithDots(_amount.toStringAsFixed(0));
          _isScanning = false;
        });
      }
    } finally {
      // UNSET external operation after image picking is done
      ref.read(securityProvider.notifier).setExternalOperation(false);
    }
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal harus lebih dari 0')));
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Transfer',
      description: 'Transfer',
      amount: amount,
      type: _type,
      date: DateTime.now(),
      category: 'Transfer',
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Scan Bukti Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Area
              GestureDetector(
                onTap: () => _showPickerOptions(),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_image!, fit: BoxFit.cover),
                              if (_isScanning)
                                Container(
                                  color: Colors.black45,
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: AppColors.primary),
                                        SizedBox(height: 16),
                                        Text('Sedang Memindai...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text('Tap untuk upload bukti transfer', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            const Text('(Pemasukan maupun Pengeluaran)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              
              if (_image != null && !_isScanning) ...[
                // Extraction Result Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HASIL SCAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      // Type Selector
                      Row(
                        children: [
                          Expanded(
                            child: _typeButton(
                              label: 'Pemasukan',
                              isSelected: _type == TransactionType.income,
                              color: Colors.green,
                              onTap: () => setState(() => _type = TransactionType.income),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _typeButton(
                              label: 'Pengeluaran',
                              isSelected: _type == TransactionType.expense,
                              color: Colors.red,
                              onTap: () => setState(() => _type = TransactionType.expense),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Amount Input
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RibuanSeparatorInputFormatter(),
                        ],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Nominal Transfer',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cek kembali nominal dan jenis transaksi sebelum menyimpan.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action Buttons
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text('Simpan ke Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _image = null;
                    _amountController.clear();
                  }),
                  child: const Text('Batal & Scan Ulang', style: TextStyle(color: Colors.red)),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Upload Bukti Transfer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
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
