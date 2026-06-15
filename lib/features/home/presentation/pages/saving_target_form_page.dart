import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/models/saving_target_model.dart';
import 'package:tabunganku/providers/saving_target_provider.dart';

class SavingTargetFormPage extends ConsumerStatefulWidget {
  final SavingTargetModel? target;

  const SavingTargetFormPage({super.key, this.target});

  @override
  ConsumerState<SavingTargetFormPage> createState() => _SavingTargetFormPageState();
}

class _SavingTargetFormPageState extends ConsumerState<SavingTargetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  
  // Custom category selection with placeholder
  String _selectedCategory = 'Pilih Kategori';
  final List<String> _categories = [
    'Pilih Kategori',
    'Umum',
    'Pembelian',
    'Darurat',
    'Pendidikan',
    'Pensiun',
    'Kurban'
  ];

  // Validation state variables
  bool _nameHasError = false;
  bool _amountHasError = false;
  bool _categoryHasError = false;

  // Focus tracking state variables
  bool _categoryIsFocused = false;
  bool _dateIsFocused = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target?.name ?? '');
    _amountController = TextEditingController(
      text: widget.target != null 
        ? NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.target!.targetAmount).trim()
        : ''
    );
    if (widget.target != null) {
      _selectedDate = widget.target!.dueDate;
      _selectedCategory = widget.target!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? _toAmount(String val) {
    if (val.isEmpty) return null;
    final clean = val.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean);
  }

  void _saveTarget() async {
    final nameVal = _nameController.text.trim();
    final amountVal = _toAmount(_amountController.text) ?? 0.0;
    final isCategoryInvalid = _selectedCategory == 'Pilih Kategori';

    setState(() {
      _nameHasError = nameVal.isEmpty;
      _amountHasError = amountVal <= 0;
      _categoryHasError = isCategoryInvalid;
    });

    if (_nameHasError || _amountHasError || _categoryHasError) {
      String errorMessage = 'Mohon lengkapi data dengan benar.';
      if (_nameHasError) {
        errorMessage = 'Nama target/barang impian tidak boleh kosong!';
      } else if (_amountHasError) {
        errorMessage = 'Nominal target harus lebih besar dari 0!';
      } else if (_categoryHasError) {
        errorMessage = 'Pilih kategori target terlebih dahulu!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
                ),
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

    final target = SavingTargetModel(
      id: widget.target?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameVal,
      targetAmount: amountVal,
      dueDate: _selectedDate,
      createdAt: widget.target?.createdAt ?? DateTime.now(),
      category: _selectedCategory,
    );

    if (widget.target != null) {
      await ref.read(savingTargetServiceProvider).updateTarget(target);
    } else {
      await ref.read(savingTargetServiceProvider).addTarget(target);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.target != null ? 'Target berhasil diperbarui!' : 'Target baru berhasil ditambahkan!',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    
    // Aesthetic Styling Configs
    final surfaceColor = isDarkMode 
        ? Colors.white.withValues(alpha: 0.03) 
        : Colors.grey.shade100;

    final Color categoryBorderColor;
    final double categoryBorderWidth;
    if (_categoryHasError) {
      categoryBorderColor = Colors.red.shade400;
      categoryBorderWidth = 1.8;
    } else if (_categoryIsFocused) {
      categoryBorderColor = AppColors.primary;
      categoryBorderWidth = 1.8;
    } else {
      categoryBorderColor = isDarkMode 
          ? Colors.white.withValues(alpha: 0.05) 
          : Colors.grey.shade200;
      categoryBorderWidth = 1.2;
    }

    final Color dateBorderColor;
    final double dateBorderWidth;
    if (_dateIsFocused) {
      dateBorderColor = AppColors.primary;
      dateBorderWidth = 1.8;
    } else {
      dateBorderColor = isDarkMode 
          ? Colors.white.withValues(alpha: 0.05) 
          : Colors.grey.shade200;
      dateBorderWidth = 1.2;
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: contentColor, 
            size: 20),
        ),
        title: Text(
          widget.target != null ? 'Ubah Target' : 'Target Baru',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standout Top Premium Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDarkMode ? 0.3 : 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wujudkan Impianmu!',
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tulis target impianmu dan mulailah menabung secara konsisten.',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              HighVisInput(
                controller: _nameController,
                icon: Icons.stars_rounded,
                label: 'Nama Barang / Impian',
                isDarkMode: isDarkMode,
                hintText: 'Misal: Laptop Baru, Motor, HP...',
                hasError: _nameHasError,
                onChanged: (val) {
                  if (_nameHasError && val.trim().isNotEmpty) {
                    setState(() => _nameHasError = false);
                  }
                },
              ),
              const SizedBox(height: 24),

              HighVisInput(
                controller: _amountController,
                icon: Icons.payments_rounded,
                label: 'Nominal Target',
                prefixText: 'Rp',
                isDarkMode: isDarkMode,
                hintText: 'Masukkan Nominal',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RibuanFormatter(),
                ],
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                hasError: _amountHasError,
                onChanged: (val) {
                  if (_amountHasError) {
                    final amount = double.tryParse(val.replaceAll('.', '')) ?? 0.0;
                    if (amount > 0) {
                      setState(() => _amountHasError = false);
                    }
                  }
                },
              ),
              const SizedBox(height: 24),

              // Category Picker with focus & error outlines
              Text(
                'Kategori Target',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() => _categoryIsFocused = hasFocus);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: categoryBorderColor,
                      width: categoryBorderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                            icon: Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold, 
                              color: _selectedCategory == 'Pilih Kategori'
                                  ? (isDarkMode ? Colors.white30 : Colors.black38)
                                  : contentColor, 
                              fontSize: 12
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                  if (val != 'Pilih Kategori') {
                                    _categoryHasError = false;
                                  }
                                });
                              }
                            },
                            items: _categories.map((c) => DropdownMenuItem(
                              value: c, 
                              child: Text(c, overflow: TextOverflow.ellipsis)
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date Picker with active outline
              Text(
                'Target Tanggal Tercapai',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  setState(() => _dateIsFocused = true);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDarkMode
                              ? ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: AppColors.surfaceDark,
                                  onSurface: Colors.white,
                                )
                              : ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.teal.shade900,
                                ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  setState(() => _dateIsFocused = false);
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dateBorderColor,
                      width: dateBorderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold, 
                            color: contentColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down_rounded, color: isDarkMode ? Colors.white24 : Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveTarget,
                  icon: const Icon(Icons.add_task_rounded, size: 20),
                  label: Text(
                    widget.target != null ? 'Simpan Perubahan' : 'Mulai Menabung Sekarang',
                    style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
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
