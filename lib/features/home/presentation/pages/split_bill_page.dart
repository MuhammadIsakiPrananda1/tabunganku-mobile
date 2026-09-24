/// Page: SplitBillPage
///
/// Pembagi tagihan bersama teman secara adil.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/core/widgets/high_vis_input.dart';

// ── Formatter ─────────────────────────────────────────────────────────────────
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

// ── Model ─────────────────────────────────────────────────────────────────────
class _BillItem {
  final String name;
  final double price;
  const _BillItem({required this.name, required this.price});
}

// ── Page ─────────────────────────────────────────────────────────────────────
class SplitBillPage extends ConsumerStatefulWidget {
  const SplitBillPage({super.key});

  @override
  ConsumerState<SplitBillPage> createState() => _SplitBillPageState();
}

class _SplitBillPageState extends ConsumerState<SplitBillPage> {
  final _billCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController();
  final _tipCtrl = TextEditingController();
  final _itemNameCtrl = TextEditingController();
  final _itemPriceCtrl = TextEditingController();

  final List<_BillItem> _items = [];
  final _fmt = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _billCtrl.dispose();
    _peopleCtrl.dispose();
    _tipCtrl.dispose();
    _itemNameCtrl.dispose();
    _itemPriceCtrl.dispose();
    super.dispose();
  }

  double get _billAmount =>
      double.tryParse(_billCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  int get _people =>
      (int.tryParse(_peopleCtrl.text) ?? 0).clamp(0, 99);
  double get _tipPercent => double.tryParse(_tipCtrl.text) ?? 0;
  double get _itemsTotal => _items.fold(0.0, (s, e) => s + e.price);
  double get _subtotal => _billAmount + _itemsTotal;
  double get _tipAmount => _subtotal * (_tipPercent / 100);
  double get _grandTotal => _subtotal + _tipAmount;
  double get _perPerson => _people > 0 ? _grandTotal / _people : 0;

  void _addItem() {
    final name = _itemNameCtrl.text.trim();
    final price = double.tryParse(
            _itemPriceCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    if (name.isEmpty || price <= 0) return;
    setState(() {
      _items.add(_BillItem(name: name, price: price));
      _itemNameCtrl.clear();
      _itemPriceCtrl.clear();
    });
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _billCtrl.clear();
      _peopleCtrl.clear();
      _tipCtrl.clear();
      _items.clear();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final pageBg = isDark ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final txtClr = isDark ? Colors.white : AppColors.primaryDark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: txtClr, size: 20),
        ),
        title: Text(
          'Split Bill',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: txtClr,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset Semua',
            icon: Icon(Icons.refresh_rounded,
                color: txtClr.withValues(alpha: 0.5), size: 20),
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Header ────────────────────────────────────────────
              _buildSummaryHeader(isDark, cardBg, borderCol, txtClr),
              const SizedBox(height: 24),

              // ── Total Tagihan ─────────────────────────────────────────────
              _buildSectionLabel('TOTAL TAGIHAN', txtClr),
              const SizedBox(height: 8),
              HighVisInput(
                controller: _billCtrl,
                icon: Icons.receipt_long_rounded,
                label: '',
                isDarkMode: isDark,
                prefixText: 'Rp',
                hintText: 'Masukkan total tagihan',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [_RibuanFormatter()],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── Jumlah Orang ──────────────────────────────────────────────
              _buildSectionLabel('JUMLAH ORANG', txtClr),
              const SizedBox(height: 8),
              HighVisInput(
                controller: _peopleCtrl,
                icon: Icons.group_rounded,
                label: '',
                isDarkMode: isDark,
                hintText: 'Masukkan jumlah orang',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                suffix: Text(
                  'Orang',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tip ───────────────────────────────────────────────────────
              _buildSectionLabel('TIP', txtClr),
              const SizedBox(height: 8),
              HighVisInput(
                controller: _tipCtrl,
                icon: Icons.percent_rounded,
                label: '',
                isDarkMode: isDark,
                hintText: 'Masukkan persentase tip',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                suffix: Text(
                  '%',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Item Tagihan ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _buildSectionLabel('ITEM TAGIHAN', txtClr)),
                  if (_items.isNotEmpty)
                    Text(
                      '${_items.length} item · ${_fmt.format(_itemsTotal)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.08 : 0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama item
                    _buildInputLabel('NAMA ITEM', isDark),
                    const SizedBox(height: 6),
                    HighVisInput(
                      controller: _itemNameCtrl,
                      icon: Icons.label_rounded,
                      label: '',
                      isDarkMode: isDark,
                      hintText: 'Masukkan nama item (contoh: Nasi Goreng)',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),

                    // Harga
                    _buildInputLabel('HARGA', isDark),
                    const SizedBox(height: 6),
                    HighVisInput(
                      controller: _itemPriceCtrl,
                      icon: Icons.payments_rounded,
                      label: '',
                      isDarkMode: isDark,
                      hintText: 'Masukkan harga item',
                      prefixText: 'Rp',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanFormatter()],
                    ),
                    const SizedBox(height: 16),

                    // Tombol Tambah
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Tambah Item',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    // Daftar item
                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(height: 1, color: borderCol),
                      const SizedBox(height: 10),
                      ...List.generate(_items.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _items[i].name,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: txtClr,
                                  ),
                                ),
                              ),
                              Text(
                                _fmt.format(_items[i].price),
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _items.removeAt(i));
                                  HapticFeedback.lightImpact();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color:
                                      isDark ? Colors.white38 : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Header ─────────────────────────────────────────────────────────
  Widget _buildSummaryHeader(
      bool isDark, Color cardBg, Color borderCol, Color txtClr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 16,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BAYAR PER ORANG',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmt.format(_perPerson),
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: txtClr,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _people > 0 ? '$_people Orang' : '- Orang',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _grandTotal > 0
                ? 'dari total ${_fmt.format(_grandTotal)}'
                : 'Masukkan tagihan untuk menghitung',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCell('SUBTOTAL', _fmt.format(_subtotal),
                  _subtotal > 0 ? AppColors.primary : Colors.grey),
              Container(
                width: 1,
                height: 32,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _statCell(
                  'TIP ${_tipPercent.toStringAsFixed(0)}%',
                  _fmt.format(_tipAmount),
                  _tipAmount > 0 ? Colors.orange : Colors.grey),
              Container(
                width: 1,
                height: 32,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _statCell('GRAND TOTAL', _fmt.format(_grandTotal),
                  _grandTotal > 0 ? Colors.green : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color txtClr) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: txtClr.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.quicksand(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }
}

