import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:tabunganku/models/transaction_model.dart';
import 'package:tabunganku/providers/transaction_provider.dart';

class HutangJariyahPage extends ConsumerStatefulWidget {
  const HutangJariyahPage({super.key});

  @override
  ConsumerState<HutangJariyahPage> createState() => _HutangJariyahPageState();
}

class _HutangJariyahPageState extends ConsumerState<HutangJariyahPage> {
  List<Map<String, dynamic>> _commitments = [];

  // Controllers for Add Pledge
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _frequency = 'Bulanan'; // Bulanan, Mingguan, Tahunan, Sekali
  final _pledgeFormKey = GlobalKey<FormState>();
  
  // Controllers for Log Donation
  final TextEditingController _donationAmountController = TextEditingController();
  final _donationFormKey = GlobalKey<FormState>();
  bool _syncWithTransactions = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recipientController.dispose();
    _amountController.dispose();
    _donationAmountController.dispose();
    super.dispose();
  }

  void _addPledge() {
    if (!_pledgeFormKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final recipient = _recipientController.text.trim();
    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    final newPledge = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'recipient': recipient,
      'amount': amount,
      'frequency': _frequency,
      'startDate': DateTime.now().toIso8601String(),
      'status': 'Aktif',
      'payments': <Map<String, dynamic>>[],
    };

    setState(() {
      _commitments.insert(0, newPledge);
    });

    _titleController.clear();
    _recipientController.clear();
    _amountController.clear();
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Komitmen Jariyah baru berhasil didaftarkan!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6B8E23),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _logPayment(String commitmentId) async {
    if (!_donationFormKey.currentState!.validate()) return;
    final amountText = _donationAmountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    final index = _commitments.indexWhere((c) => c['id'] == commitmentId);
    if (index == -1) return;

    final paymentLog = {
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };

    setState(() {
      final payments = List<Map<String, dynamic>>.from(_commitments[index]['payments'] as List);
      payments.insert(0, paymentLog);
      _commitments[index]['payments'] = payments;
      
      // If Single frequency, check if target has been fulfilled to update status
      if (_commitments[index]['frequency'] == 'Sekali') {
        double totalPaid = payments.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
        double target = (_commitments[index]['amount'] as num).toDouble();
        if (totalPaid >= target) {
          _commitments[index]['status'] = 'Selesai';
        }
      }
    });

    if (_syncWithTransactions) {
      final title = _commitments[index]['title'] as String;
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '[Jariyah] $title',
        description: 'Sedekah/wakaf berkelanjutan untuk ${_commitments[index]['recipient']}',
        amount: amount,
        type: TransactionType.expense,
        date: DateTime.now(),
        category: 'Sosial & Zakat',
      );
      await ref.read(addTransactionProvider)(transaction);
    }

    _donationAmountController.clear();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sedekah jariyah berhasil dicatat!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8FBC8F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleStatus(String id) {
    final index = _commitments.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    setState(() {
      final currentStatus = _commitments[index]['status'] as String;
      _commitments[index]['status'] = currentStatus == 'Aktif' ? 'Selesai' : 'Aktif';
    });
  }

  void _deletePledge(String id) {
    setState(() {
      _commitments.removeWhere((c) => c['id'] == id);
    });
  }

  double get _totalDonated {
    double total = 0.0;
    for (var comp in _commitments) {
      final payments = comp['payments'] as List;
      for (var pay in payments) {
        total += (pay['amount'] as num).toDouble();
      }
    }
    return total;
  }

  int get _activeCount {
    return _commitments.where((c) => c['status'] == 'Aktif').length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFFBFDFB);
    final accentColor = const Color(0xFF6B8E23); // Olive Green
    final goldColor = const Color(0xFFC5A059);

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
          'Hutang Jariyah',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Dashboard Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF3B4F1A), const Color(0xFF233010)]
                      : [const Color(0xFFF1F7E8), const Color(0xFFD4E6BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Sedekah Jariyah',
                          style: GoogleFonts.quicksand(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? goldColor : accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalDonated),
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.volunteer_activism_rounded, size: 13, color: isDarkMode ? Colors.white60 : Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              '$_activeCount Program Aktif Sedang Berlangsung',
                              style: GoogleFonts.quicksand(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_rounded, color: isDarkMode ? goldColor : accentColor, size: 36),
                  ),
                ],
              ),
            ),
          ),

          // Header & Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Komitmen Jariyah',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPledgeDialog(isDarkMode, accentColor),
                  icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  label: Text('Pledge Baru', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // List Pledges
          Expanded(
            child: _commitments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handshake_outlined, size: 48, color: isDarkMode ? Colors.white12 : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada komitmen sedekah jariyah.',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _commitments.length,
                    itemBuilder: (context, index) {
                      final item = _commitments[index];
                      final id = item['id'] as String;
                      final title = item['title'] as String;
                      final recipient = item['recipient'] as String;
                      final amount = (item['amount'] as num).toDouble();
                      final frequency = item['frequency'] as String;
                      final status = item['status'] as String;
                      final payments = item['payments'] as List;

                      double totalPaid = payments.fold(0.0, (sum, pay) => sum + (pay['amount'] as num).toDouble());
                      final isActive = status == 'Aktif';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
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
                              // Top status row
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive 
                                            ? accentColor.withOpacity(0.1) 
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$frequency • $status',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isActive ? accentColor : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _toggleStatus(id),
                                          borderRadius: BorderRadius.circular(100),
                                          child: Icon(
                                            isActive ? Icons.check_circle_outline_rounded : Icons.replay_rounded,
                                            size: 18,
                                            color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        InkWell(
                                          onTap: () => _deletePledge(id),
                                          borderRadius: BorderRadius.circular(100),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Colors.redAccent.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Content details
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: contentColor,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Penerima: $recipient',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Target Pledge vs Total Paid
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              frequency == 'Sekali' ? 'Target Total' : 'Target per Periode',
                                              style: GoogleFonts.quicksand(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
                                              style: GoogleFonts.quicksand(fontSize: 11.5, fontWeight: FontWeight.bold, color: contentColor),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Total Disalurkan',
                                              style: GoogleFonts.quicksand(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalPaid),
                                              style: GoogleFonts.quicksand(fontSize: 11.5, fontWeight: FontWeight.bold, color: accentColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (frequency == 'Sekali') ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: LinearProgressIndicator(
                                          value: (totalPaid / amount).clamp(0.0, 1.0),
                                          backgroundColor: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade100,
                                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              Divider(height: 1, color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade50),

                              // Bottom action row / payments view
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${payments.length} Kali Donasi',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                                      ),
                                    ),
                                    if (isActive)
                                      ElevatedButton.icon(
                                        onPressed: () => _showLogDonationDialog(id, isDarkMode, accentColor),
                                        icon: const Icon(Icons.favorite_outline_rounded, size: 12, color: Colors.white),
                                        label: Text('Bayar Jariyah', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddPledgeDialog(bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;
        
        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: _pledgeFormKey,
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
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Daftar Jariyah / Sedekah Rutin',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                  ),
                  const SizedBox(height: 20),

                  // Title input
                  RichText(
                    text: TextSpan(
                      text: 'Nama Program Jariyah',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama program tidak boleh kosong';
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
                      hintText: 'Masukkan Nama Program Jariyah',
                      hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                      prefixIcon: Icon(
                        Icons.volunteer_activism_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recipient
                  RichText(
                    text: TextSpan(
                      text: 'Lembaga / Penerima Manfaat',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _recipientController,
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penerima tidak boleh kosong';
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
                      hintText: 'Masukkan Nama Penerima / Lembaga',
                      hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                      prefixIcon: Icon(
                        Icons.account_balance_rounded,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Target Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Nominal Target',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_RibuanFormatter()],
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                              validator: (value) {
                                final raw = (value ?? '').replaceAll('.', '');
                                final amount = double.tryParse(raw) ?? 0.0;
                                if (raw.isEmpty || amount <= 0) {
                                  return 'Nominal harus lebih dari 0';
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
                                hintText: 'Nominal Target',
                                hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 11),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.only(left: 14, right: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rp',
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Frequency Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frekuensi Bayar',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event_repeat_rounded, color: accentColor, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _frequency,
                                        isExpanded: true,
                                        dropdownColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: contentColor, fontSize: 13),
                                        items: ['Bulanan', 'Mingguan', 'Tahunan', 'Sekali'].map((f) {
                                          return DropdownMenuItem<String>(
                                            value: f,
                                            child: Text(f),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setModalState(() {
                                            _frequency = val ?? 'Bulanan';
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        _addPledge();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan Komitmen Jariyah',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  void _showLogDonationDialog(String commitmentId, bool isDarkMode, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
        final inputBg = isDarkMode ? Colors.white.withOpacity(0.04) : AppColors.background;
        
        AutovalidateMode autoValidate = AutovalidateMode.disabled;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Form(
                key: _donationFormKey,
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
                          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Catat Pembayaran Sedekah Jariyah',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

                    RichText(
                      text: TextSpan(
                        text: 'Nominal yang Disalurkan',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _donationAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanFormatter()],
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        final raw = (value ?? '').replaceAll('.', '');
                        final amount = double.tryParse(raw) ?? 0.0;
                        if (raw.isEmpty || amount <= 0) {
                          return 'Nominal harus lebih dari 0';
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
                        hintText: 'Masukkan Nominal Pembayaran',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rp',
                                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    CheckboxListTile(
                      value: _syncWithTransactions,
                      activeColor: accentColor,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Potong dari Saldo & Catat Transaksi Utama',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 12, color: contentColor),
                      ),
                      subtitle: Text(
                        'Pencatatan ini akan langsung didaftarkan ke pengeluaran bulanan dompet utama sebagai amal jariyah.',
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 9.5, color: Colors.grey),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          _syncWithTransactions = val ?? true;
                        });
                      },
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
                          _logPayment(commitmentId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Konfirmasi Penyaluran',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
