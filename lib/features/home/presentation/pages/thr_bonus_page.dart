import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/models/thr_bonus_model.dart';
import 'package:tabunganku/providers/thr_bonus_provider.dart';

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = digits.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ThrBonusPage extends ConsumerStatefulWidget {
  const ThrBonusPage({super.key});

  @override
  ConsumerState<ThrBonusPage> createState() => _ThrBonusPageState();
}

class _ThrBonusPageState extends ConsumerState<ThrBonusPage> {
  int _selectedViewTab = 0; // 0: Pos Anggaran, 1: Checklist Penerima
  String _selectedCategoryFilter = 'Semua';

  final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final NumberFormat _rawFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  IconData _getCategoryIcon(int iconCode) {
    if (iconCode == Icons.volunteer_activism_rounded.codePoint) {
      return Icons.volunteer_activism_rounded;
    } else if (iconCode == Icons.card_giftcard_rounded.codePoint) {
      return Icons.card_giftcard_rounded;
    } else if (iconCode == Icons.directions_car_filled_rounded.codePoint) {
      return Icons.directions_car_filled_rounded;
    } else if (iconCode == Icons.shopping_bag_rounded.codePoint) {
      return Icons.shopping_bag_rounded;
    } else if (iconCode == Icons.savings_rounded.codePoint) {
      return Icons.savings_rounded;
    } else if (iconCode == Icons.shield_rounded.codePoint) {
      return Icons.shield_rounded;
    } else if (iconCode == Icons.flight_takeoff_rounded.codePoint) {
      return Icons.flight_takeoff_rounded;
    } else if (iconCode == Icons.trending_up_rounded.codePoint) {
      return Icons.trending_up_rounded;
    } else if (iconCode == Icons.money_off_rounded.codePoint) {
      return Icons.money_off_rounded;
    } else if (iconCode == Icons.celebration_rounded.codePoint) {
      return Icons.celebration_rounded;
    } else if (iconCode == Icons.school_rounded.codePoint) {
      return Icons.school_rounded;
    } else if (iconCode == Icons.health_and_safety_rounded.codePoint) {
      return Icons.health_and_safety_rounded;
    } else if (iconCode == Icons.star_rounded.codePoint) {
      return Icons.star_rounded;
    }
    return Icons.category_rounded;
  }

  // --- BOTTOM SHEETS & MODALS ---

  void _showEditTotalThrSheet(BuildContext context, double currentTotal) {
    final ctrl = TextEditingController(
      text: currentTotal > 0 ? _rawFmt.format(currentTotal).trim() : '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Total Nominal Dana THR / Bonus',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                    ),
                  ),
                  Text(
                    'Masukkan jumlah dana bersih yang kamu terima',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  HighVisInput(
                    controller: ctrl,
                    label: 'Nominal Dana (Rp)',
                    hintText: 'Contoh: 10.000.000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [_RibuanFormatter()],
                    icon: Icons.account_balance_wallet_rounded,
                    isDarkMode: isDark,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pilihan Cepat:',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      2000000.0,
                      5000000.0,
                      10000000.0,
                      15000000.0,
                      20000000.0,
                    ].map((val) {
                      final label = 'Rp ${(val / 1000000).toStringAsFixed(0)} Jt';
                      return InkWell(
                        onTap: () {
                          ctrl.text = _rawFmt.format(val).trim();
                          setSheetState(() {});
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final raw =
                            ctrl.text.replaceAll(RegExp(r'[^\d]'), '');
                        final amt = double.tryParse(raw) ?? 0.0;
                        ref
                            .read(thrBonusProvider.notifier)
                            .updateTotalThr(amt);
                        Navigator.pop(ctx);
                        showTopToast(context, 'Total THR berhasil diperbarui');
                      },
                      child: Text(
                        'Simpan Nominal',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryDetailSheet(
      BuildContext context, ThrCategory cat, double totalThr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;
    final catColor = Color(cat.colorValue);

    double currentPercent = cat.percentage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final allocatedAmt = totalThr * (currentPercent / 100);

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat.iconCode),
                          color: catColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: GoogleFonts.quicksand(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: txtColor,
                              ),
                            ),
                            if (cat.notes.isNotEmpty)
                              Text(
                                cat.notes,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (cat.id.startsWith('custom_'))
                        IconButton(
                          tooltip: 'Hapus Pos',
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                          onPressed: () {
                            ref
                                .read(thrBonusProvider.notifier)
                                .removeCategory(cat.id);
                            Navigator.pop(ctx);
                            showTopToast(context, 'Pos berhasil dihapus');
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: catColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Estimasi Dana Alokasi (${currentPercent.toStringAsFixed(0)}%)',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFmt.format(allocatedAmt),
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                        if (cat.actualSpent > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Sudah terpakai: ${_currencyFmt.format(cat.actualSpent)} (Sisa: ${_currencyFmt.format(allocatedAmt - cat.actualSpent)})',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: cat.actualSpent > allocatedAmt
                                  ? Colors.redAccent
                                  : (isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sesuaikan Persentase:',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_circle_outline_rounded,
                                size: 22),
                            color: catColor,
                            onPressed: currentPercent > 0
                                ? () {
                                    setSheetState(() {
                                      currentPercent =
                                          (currentPercent - 5).clamp(0.0, 100.0);
                                    });
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${currentPercent.toStringAsFixed(0)}%',
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                size: 22),
                            color: catColor,
                            onPressed: currentPercent < 100
                                ? () {
                                    setSheetState(() {
                                      currentPercent =
                                          (currentPercent + 5).clamp(0.0, 100.0);
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: currentPercent.clamp(0.0, 100.0),
                    min: 0.0,
                    max: 100.0,
                    divisions: 20,
                    activeColor: catColor,
                    inactiveColor: catColor.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setSheetState(() {
                        currentPercent = val;
                      });
                    },
                  ),
                  Wrap(
                    spacing: 6,
                    children: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0].map((p) {
                      final isSelected = (currentPercent - p).abs() < 1;
                      return ChoiceChip(
                        label: Text('${p.toStringAsFixed(0)}%',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : txtColor,
                            )),
                        selected: isSelected,
                        selectedColor: catColor,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.shade200,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) {
                            setSheetState(() {
                              currentPercent = p;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: catColor.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.receipt_long_rounded,
                              size: 16, color: catColor),
                          label: Text(
                            'Catat Realisasi',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: catColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showActualSpentDialog(context, cat);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: catColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            ref
                                .read(thrBonusProvider.notifier)
                                .updateCategoryPercentage(
                                    cat.id, currentPercent);
                            Navigator.pop(ctx);
                            showTopToast(context, 'Alokasi berhasil disimpan');
                          },
                          child: Text(
                            'Simpan Alokasi',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddRecipientDialog(
      BuildContext context, String categoryId, String categoryTitle) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tambah Rincian / Penerima',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                ),
              ),
              Text(
                'Kategori: $categoryTitle',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              HighVisInput(
                controller: nameCtrl,
                label: 'Nama Rincian / Penerima',
                hintText: 'Misal: Ponakan, Orang Tua, Servis Mobil...',
                icon: Icons.person_outline_rounded,
                isDarkMode: isDark,
              ),
              const SizedBox(height: 12),
              HighVisInput(
                controller: amountCtrl,
                label: 'Estimasi Nominal (Rp)',
                hintText: 'Contoh: 250.000',
                keyboardType: TextInputType.number,
                inputFormatters: [_RibuanFormatter()],
                icon: Icons.attach_money_rounded,
                isDarkMode: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final raw =
                        amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
                    final amt = double.tryParse(raw) ?? 0.0;
                    if (name.isEmpty) {
                      showTopToast(context, 'Nama rincian tidak boleh kosong');
                      return;
                    }
                    ref
                        .read(thrBonusProvider.notifier)
                        .addRecipient(categoryId, name, amt);
                    Navigator.pop(ctx);
                    showTopToast(context, 'Rincian berhasil ditambahkan');
                  },
                  child: Text(
                    'Simpan Rincian',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActualSpentDialog(BuildContext context, ThrCategory category) {
    final spentCtrl = TextEditingController(
      text: category.actualSpent > 0
          ? _rawFmt.format(category.actualSpent).trim()
          : '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Catat Realisasi Pengeluaran',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                ),
              ),
              Text(
                'Kategori: ${category.name}',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              HighVisInput(
                controller: spentCtrl,
                label: 'Total Dana Terpakai (Rp)',
                hintText: 'Contoh: 1.500.000',
                keyboardType: TextInputType.number,
                inputFormatters: [_RibuanFormatter()],
                icon: Icons.receipt_long_rounded,
                isDarkMode: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final raw =
                        spentCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
                    final amt = double.tryParse(raw) ?? 0.0;
                    ref
                        .read(thrBonusProvider.notifier)
                        .updateCategoryActualSpent(category.id, amt);
                    Navigator.pop(ctx);
                    showTopToast(context, 'Realisasi berhasil diperbarui');
                  },
                  child: Text(
                    'Simpan Realisasi',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final percentCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tambah Pos Anggaran Baru',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                ),
              ),
              const SizedBox(height: 18),
              HighVisInput(
                controller: titleCtrl,
                label: 'Nama Pos Anggaran',
                hintText: 'Misal: Sedekah Khusus, Servis Mobil...',
                icon: Icons.category_rounded,
                isDarkMode: isDark,
              ),
              const SizedBox(height: 12),
              HighVisInput(
                controller: percentCtrl,
                label: 'Persentase Alokasi (%)',
                hintText: 'Contoh: 10',
                keyboardType: TextInputType.number,
                icon: Icons.percent_rounded,
                isDarkMode: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final name = titleCtrl.text.trim();
                    final pct = double.tryParse(percentCtrl.text) ?? 0.0;
                    if (name.isEmpty) {
                      showTopToast(context, 'Nama kategori tidak boleh kosong');
                      return;
                    }
                    final newCat = ThrCategory(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      iconCode: Icons.star_rounded.codePoint,
                      colorValue: 0xFF9C27B0,
                      percentage: pct,
                    );
                    ref.read(thrBonusProvider.notifier).addCategory(newCat);
                    Navigator.pop(ctx);
                    showTopToast(context, 'Pos baru berhasil ditambahkan');
                  },
                  child: Text(
                    'Tambah Pos',
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTipsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tips Cerdas Kelola THR',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTipItem(
                '1. Dahulukan Zakat & Kewajiban (10%)',
                'Tunaikan zakat fitrah, infaq, atau kewajiban lainnya di awal agar hati tenang.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                '2. Pisahkan Angpau & Sajian (30-40%)',
                'Gunakan amplop atau pos terpisah agar uang bagi-bagi tidak tercampur dengan kebutuhan pokok.',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                '3. Simpan Minimal 20-30% untuk Masa Depan',
                'Alokasikan untuk tabungan atau investasi agar THR tidak langsung habis pasca libur panjang.',
                isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Mengerti',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipItem(String title, String desc, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    final thrModel = ref.watch(thrBonusProvider);
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system &&
            theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor =
        isDarkMode ? const Color(0xFF0F1413) : const Color(0xFFF6FAF9);

    final totalPercent = thrModel.totalAllocatedPercent;
    final isPercentExact = (totalPercent - 100.0).abs() < 0.1;

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
          'Alokasi THR & Bonus',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Panduan Alokasi',
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.primary),
            onPressed: () => _showTipsSheet(context),
          ),
          IconButton(
            tooltip: 'Reset Standar',
            icon: Icon(Icons.refresh_rounded, color: contentColor),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor:
                      isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text('Reset Alokasi?',
                      style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold, color: contentColor)),
                  content: Text(
                      'Semua rincian penerima dan perubahan persentase akan dikembalikan ke setelan awal.',
                      style: GoogleFonts.quicksand(
                          color: isDarkMode ? Colors.white70 : Colors.black87)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Batal',
                          style: GoogleFonts.quicksand(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Reset',
                          style: GoogleFonts.quicksand(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (confirm == true) {
                ref.read(thrBonusProvider.notifier).resetToDefault();
                showTopToast(context, 'Alokasi berhasil direset ke standar');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Neo-Fintech Vault Card (Card Utama yang keren & premium)
            _buildVaultHeroCard(
              context,
              isDarkMode,
              thrModel,
              totalPercent,
              isPercentExact,
            ),
            const SizedBox(height: 16),

            // 2. Event Preset Capsules (Pilihan Acara yang ringkas)
            _buildEventPresetsRow(isDarkMode, thrModel),
            const SizedBox(height: 16),

            // 3. Segmented View Switcher (Anggaran vs Checklist)
            _buildViewSegmentedControl(isDarkMode),
            const SizedBox(height: 16),

            // 4. Content berdasarkan Tab yang dipilih
            if (_selectedViewTab == 0)
              _buildTabPosAlokasi(
                context,
                thrModel,
                isDarkMode,
                contentColor,
              )
            else
              _buildTabRincianChecklist(
                context,
                thrModel,
                isDarkMode,
                contentColor,
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- NEO-FINTECH HERO CARD ---

  Widget _buildVaultHeroCard(
    BuildContext context,
    bool isDark,
    ThrBonusModel model,
    double totalPercent,
    bool isPercentExact,
  ) {
    final remainingAllocationPct = 100.0 - totalPercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0C2B25), Color(0xFF061714)]
              : const [Color(0xFF00BFA5), Color(0xFF00897B)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? const Color(0xFF64FFDA).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withValues(alpha: isDark ? 0.25 : 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar on Card: Badge & Edit Trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 13, color: Color(0xFF64FFDA)),
                    const SizedBox(width: 5),
                    Text(
                      'DOMPET ALOKASI THR',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showEditTotalThrSheet(context, model.totalThr),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Ubah',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big Glowing Amount
          InkWell(
            onTap: () => _showEditTotalThrSheet(context, model.totalThr),
            borderRadius: BorderRadius.circular(8),
            child: Text(
              model.totalThr > 0
                  ? _currencyFmt.format(model.totalThr)
                  : 'Rp 0',
              style: GoogleFonts.quicksand(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            model.totalThr > 0
                ? 'Total dana siap dialokasikan untuk ${model.eventType}'
                : 'Ketuk untuk memasukkan total dana THR kamu',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Multi-color Segmented Allocation Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: model.categories.isEmpty || model.totalAllocatedPercent == 0
                  ? Container(color: Colors.white24)
                  : Row(
                      children: model.categories.map((c) {
                        final flexVal = (c.percentage * 10).round();
                        if (flexVal <= 0) return const SizedBox.shrink();
                        return Expanded(
                          flex: flexVal,
                          child: Container(
                            color: Color(c.colorValue),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Status Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPercentExact
                      ? Colors.green.withValues(alpha: 0.25)
                      : (totalPercent < 100
                          ? Colors.orange.withValues(alpha: 0.25)
                          : Colors.red.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPercentExact
                        ? Colors.greenAccent.withValues(alpha: 0.4)
                        : (totalPercent < 100
                            ? Colors.orangeAccent.withValues(alpha: 0.4)
                            : Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPercentExact
                          ? Icons.check_circle_rounded
                          : (totalPercent < 100
                              ? Icons.pie_chart_outline_rounded
                              : Icons.warning_amber_rounded),
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isPercentExact
                          ? 'Alokasi Pas (100%)'
                          : (totalPercent < 100
                              ? 'Sisa ${remainingAllocationPct.toStringAsFixed(0)}% belum dialokasi'
                              : 'Kelebihan alokasi +${(totalPercent - 100).toStringAsFixed(0)}%'),
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${totalPercent.toStringAsFixed(0)}% / 100%',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Glass Metrics: Dialokasi, Tabungan, Realisasi
          Row(
            children: [
              Expanded(
                child: _buildVaultGlassCell(
                  label: 'DIALOKASI',
                  value: _currencyFmt.format(model.totalAllocatedAmount),
                  color: const Color(0xFF64FFDA),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVaultGlassCell(
                  label: 'TABUNGAN',
                  value: _currencyFmt.format(model.savingsAndInvestAmount),
                  color: const Color(0xFF81C784),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVaultGlassCell(
                  label: 'REALISASI',
                  value: _currencyFmt.format(model.totalSpent),
                  color: const Color(0xFFFF8A80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultGlassCell({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EVENT PRESET CAPSULES ---

  Widget _buildEventPresetsRow(bool isDark, ThrBonusModel model) {
    final presets = [
      {'name': 'Idul Fitri', 'icon': Icons.mosque_rounded},
      {'name': 'Natal & Tahun Baru', 'icon': Icons.celebration_rounded},
      {'name': 'Bonus Tahunan', 'icon': Icons.trending_up_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: presets.map((p) {
          final name = p['name'] as String;
          final icon = p['icon'] as IconData;
          final isSelected = model.eventType == name;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  ref.read(thrBonusProvider.notifier).selectPreset(name);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? const Color(0xFF1E2422)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- VIEW SEGMENTED CONTROL ---

  Widget _buildViewSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2220) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedViewTab = 0),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedViewTab == 0
                      ? (isDark ? const Color(0xFF283430) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedViewTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_rounded,
                      size: 15,
                      color: _selectedViewTab == 0
                          ? AppColors.primary
                          : (isDark ? Colors.white60 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pos Anggaran',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedViewTab == 0
                            ? (_selectedViewTab == 0 && !isDark
                                ? AppColors.primaryDark
                                : Colors.white)
                            : (isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedViewTab = 1),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedViewTab == 1
                      ? (isDark ? const Color(0xFF283430) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedViewTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 16,
                      color: _selectedViewTab == 1
                          ? AppColors.primary
                          : (isDark ? Colors.white60 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Checklist Penerima',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedViewTab == 1
                            ? (_selectedViewTab == 1 && !isDark
                                ? AppColors.primaryDark
                                : Colors.white)
                            : (isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
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

  // --- TAB 1: POS ANGGARAN (DENGAN LIVE STEPPER CEPAT) ---

  Widget _buildTabPosAlokasi(
    BuildContext context,
    ThrBonusModel model,
    bool isDark,
    Color textClr,
  ) {
    final cardBg = isDark ? const Color(0xFF1A211F) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pos Alokasi (${model.categories.length})',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textClr,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: Text(
                'Tambah Pos',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Category Cards with Direct Stepper Control
        ...model.categories.map((cat) {
          final catColor = Color(cat.colorValue);
          final allocated = cat.allocatedAmount(model.totalThr);
          final progress = allocated > 0
              ? (cat.actualSpent / allocated).clamp(0.0, 1.0)
              : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : catColor.withValues(alpha: 0.15),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    _showCategoryDetailSheet(context, cat, model.totalThr),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Soft glowing icon container
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getCategoryIcon(cat.iconCode),
                              color: catColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and Amount
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textClr,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currencyFmt.format(allocated),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: catColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Live quick steppers [-] 25% [+]
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: cat.percentage > 0
                                    ? () {
                                        final newP = (cat.percentage - 5)
                                            .clamp(0.0, 100.0);
                                        ref
                                            .read(thrBonusProvider.notifier)
                                            .updateCategoryPercentage(
                                                cat.id, newP);
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(
                                        alpha: cat.percentage > 0 ? 0.12 : 0.04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 15,
                                    color: cat.percentage > 0
                                        ? catColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '${cat.percentage.toStringAsFixed(0)}%',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: catColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: cat.percentage < 100
                                    ? () {
                                        final newP = (cat.percentage + 5)
                                            .clamp(0.0, 100.0);
                                        ref
                                            .read(thrBonusProvider.notifier)
                                            .updateCategoryPercentage(
                                                cat.id, newP);
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(
                                        alpha: cat.percentage < 100 ? 0.12 : 0.04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 15,
                                    color: cat.percentage < 100
                                        ? catColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bottom miniature spent progress bar
                      if (cat.actualSpent > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Realisasi Pengeluaran',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${_currencyFmt.format(cat.actualSpent)} / ${_currencyFmt.format(allocated)}',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: cat.actualSpent > allocated
                                    ? Colors.redAccent
                                    : catColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cat.actualSpent > allocated
                                  ? Colors.redAccent
                                  : catColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- TAB 2: CHECKLIST PENERIMA (TRACKER BERSIH & MODERN) ---

  Widget _buildTabRincianChecklist(
    BuildContext context,
    ThrBonusModel model,
    bool isDark,
    Color textClr,
  ) {
    final cardBg = isDark ? const Color(0xFF1A211F) : Colors.white;

    final allRecipientsWithCat = <Map<String, dynamic>>[];
    for (final cat in model.categories) {
      for (final rec in cat.recipients) {
        allRecipientsWithCat.add({
          'categoryId': cat.id,
          'categoryName': cat.name,
          'categoryColor': Color(cat.colorValue),
          'recipient': rec,
        });
      }
    }

    final filtered = _selectedCategoryFilter == 'Semua'
        ? allRecipientsWithCat
        : allRecipientsWithCat
            .where((item) => item['categoryName'] == _selectedCategoryFilter)
            .toList();

    final totalGivenCount = allRecipientsWithCat
        .where((i) => (i['recipient'] as ThrRecipientItem).isGiven)
        .length;
    final totalItemCount = allRecipientsWithCat.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalGivenCount dari $totalItemCount Checklist Selesai',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textClr,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalItemCount > 0
                            ? (totalGivenCount / totalItemCount)
                            : 0.0,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Filter Categories Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              'Semua',
              ...model.categories.map((c) => c.name),
            ].map((catName) {
              final isSelected = _selectedCategoryFilter == catName;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    catName,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2422)
                      : Colors.grey.shade200,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onSelected: (val) {
                    setState(() {
                      _selectedCategoryFilter = catName;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Checklist Items List
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.checklist_rtl_rounded,
                    size: 40,
                    color: isDark ? Colors.white24 : Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Belum ada daftar penerima / belanja',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tambahkan rincian penerima angpau atau kebutuhan belanja',
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        else
          ...filtered.map((item) {
            final catId = item['categoryId'] as String;
            final catColor = item['categoryColor'] as Color;
            final catName = item['categoryName'] as String;
            final rec = item['recipient'] as ThrRecipientItem;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      ref
                          .read(thrBonusProvider.notifier)
                          .toggleRecipientGiven(catId, rec.id);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      rec.isGiven
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: rec.isGiven ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.name,
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration:
                                rec.isGiven ? TextDecoration.lineThrough : null,
                            color: rec.isGiven
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                catName,
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currencyFmt.format(rec.amount),
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: rec.isGiven ? Colors.grey : textClr,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey),
                    onPressed: () {
                      ref
                          .read(thrBonusProvider.notifier)
                          .deleteRecipient(catId, rec.id);
                    },
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 12),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: Text(
              'Tambah Penerima / Rincian',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _showSelectCategoryForRecipientDialog(context, model);
            },
          ),
        ),
      ],
    );
  }

  void _showSelectCategoryForRecipientDialog(
      BuildContext context, ThrBonusModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final txtColor = isDark ? Colors.white : AppColors.primaryDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Pos Kategori',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                ),
              ),
              Text(
                'Rincian ini akan dialokasikan ke pos mana?',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),
              ...model.categories.map((cat) {
                final color = Color(cat.colorValue);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getCategoryIcon(cat.iconCode),
                        color: color, size: 20),
                  ),
                  title: Text(
                    cat.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                    ),
                  ),
                  subtitle: Text(
                    '${cat.percentage.toStringAsFixed(0)}% (${_currencyFmt.format(cat.allocatedAmount(model.totalThr))})',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddRecipientDialog(context, cat.id, cat.name);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
