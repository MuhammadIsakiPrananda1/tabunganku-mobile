import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class KontakDaruratFinansialPage extends ConsumerStatefulWidget {
  const KontakDaruratFinansialPage({super.key});

  @override
  ConsumerState<KontakDaruratFinansialPage> createState() => _KontakDaruratFinansialPageState();
}

class _KontakDaruratFinansialPageState extends ConsumerState<KontakDaruratFinansialPage> {
  List<Map<String, dynamic>> _customContacts = [];
  final _formKey = GlobalKey<FormState>();

final TextEditingController _instController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _prepopulatedCS = [
    {
      'inst': 'Halo BCA (Bank BCA)',
      'phone': '1500888',
      'email': 'halobca@bca.co.id',
      'desc': 'Pemblokiran kartu ATM/kredit & laporan penipuan transaksi.',
      'type': 'Bank'
    },
    {
      'inst': 'Mandiri Call (Bank Mandiri)',
      'phone': '14000',
      'email': 'mandiricare@bankmandiri.co.id',
      'desc': 'Layanan keluhan nasabah, kartu hilang, & internet banking.',
      'type': 'Bank'
    },
    {
      'inst': 'BNI Call (Bank BNI)',
      'phone': '1500046',
      'email': 'bnicall@bni.co.id',
      'desc': 'CS darurat 24 jam BNI, info rekening, & pemblokiran.',
      'type': 'Bank'
    },
    {
      'inst': 'BRI Care (Bank BRI)',
      'phone': '1500017',
      'email': 'callbri@bri.co.id',
      'desc': 'Layanan perbankan BRI, aduan ATM tertelan & disable kartu.',
      'type': 'Bank'
    },
    {
      'inst': 'GoPay Customer Service',
      'phone': '02150849000',
      'email': 'customerservice@gojek.com',
      'desc': 'Aduan akun GoPay diretas, pemulihan saldo, & transaksi gagal.',
      'type': 'E-Wallet'
    },
    {
      'inst': 'OVO CS Hotline',
      'phone': '1500696',
      'email': 'cs@ovo.id',
      'desc': 'Bantuan limit saldo OVO Premier, cashback gagal, & topup error.',
      'type': 'E-Wallet'
    },
    {
      'inst': 'Bibit Reksadana CS',
      'phone': '02150864230',
      'email': 'support@bibit.id',
      'desc': 'Kendala penarikan dana reksadana & registrasi KTP Bibit.',
      'type': 'Broker'
    },
    {
      'inst': 'Ajaib Sekuritas CS',
      'phone': '02150906000',
      'email': 'support@ajaib.co.id',
      'desc': 'Layanan saham & reksadana Ajaib, RDN Mandiri/BCA terblokir.',
      'type': 'Broker'
    },
    {
      'inst': 'Prudential Customer Care',
      'phone': '1500085',
      'email': 'customer.idn@prudential.co.id',
      'desc': 'Info klaim asuransi kesehatan, polis lapsing, & nilai tunai.',
      'type': 'Asuransi'
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _instController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addCustomCS() {
    if (!_formKey.currentState!.validate()) return;

    final inst = _instController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final note = _noteController.text.trim();

    final newContact = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'inst': inst,
      'phone': phone,
      'email': email,
      'desc': note,
      'type': 'Custom'
    };

    setState(() {
      _customContacts.insert(0, newContact);
    });

    _instController.clear();
    _phoneController.clear();
    _emailController.clear();
    _noteController.clear();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kontak darurat baru berhasil didaftarkan!',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteCustomCS(String id) {
    setState(() {
      _customContacts.removeWhere((c) => c['id'] == id);
    });
  }

  void _performCopy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label berhasil disalin ke clipboard!',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
        ),
        backgroundColor: const Color(0xFFE53935),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _performCopy('Nomor Telepon CS', phone);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _performCopy('Email CS', email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark ||
        (ref.watch(themeProvider) == ThemeMode.system && theme.brightness == Brightness.dark);
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final pageBgColor = isDarkMode ? AppColors.backgroundDark : const Color(0xFFFFF9F9);
    final accentColor = const Color(0xFFE53935);

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
          'Kontak Darurat Finansial',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: contentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.report_problem_rounded, color: accentColor, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aksi Cepat Blokir & Keluhan',
                        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: contentColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Daftar kontak cs bank, broker, asuransi terpercaya untuk pemblokiran darurat kartu kredit/debit atau laporan penipuan transaksi.',
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

if (_customContacts.isNotEmpty) ...[
            _buildSectionHeader('Kontak Darurat Pribadi Anda', isDarkMode),
            const SizedBox(height: 8),
            ..._customContacts.map((c) => _buildContactCard(c, isDarkMode, contentColor, accentColor, isCustom: true)),
            const SizedBox(height: 20),
          ],

_buildSectionHeader('Layanan Pengaduan Resmi Finansial', isDarkMode),
          const SizedBox(height: 8),
          ..._prepopulatedCS.map((c) => _buildContactCard(c, isDarkMode, contentColor, accentColor, isCustom: false)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCSDialog(isDarkMode, accentColor),
        backgroundColor: accentColor,
        icon: const Icon(Icons.add_call, color: Colors.white, size: 18),
        label: Text(
          'Tambah Kontak',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.5),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> c, bool isDarkMode, Color contentColor, Color accentColor, {required bool isCustom}) {
    final inst = c['inst'] as String;
    final phone = c['phone'] as String;
    final email = c['email'] as String;
    final desc = c['desc'] as String;
    final type = c['type'] as String;

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.quicksand(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
                if (isCustom)
                  IconButton(
                    onPressed: () => _deleteCustomCS(c['id'] as String),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Colors.redAccent.withOpacity(0.6),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              inst,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: contentColor,
              ),
            ),
            const SizedBox(height: 4),
            if (desc.isNotEmpty)
              Text(
                desc,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white30 : Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.grey.shade50),
            const SizedBox(height: 10),

Row(
              children: [

                Expanded(
                  child: InkWell(
                    onTap: () => _makePhoneCall(phone),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, color: accentColor, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(width: 12),

                  Expanded(
                    child: InkWell(
                      onTap: () => _sendEmail(email),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.shade100,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.grey, size: 14),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Email CS',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCSDialog(bool isDarkMode, Color accentColor) {
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
                  key: _formKey,
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
                      'Tambah Kontak Finansial Penting',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15, color: contentColor),
                    ),
                    const SizedBox(height: 20),

RichText(
                      text: TextSpan(
                        text: 'Nama Instansi / Kontak',
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
                      controller: _instController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama instansi tidak boleh kosong';
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
                        hintText: 'Masukkan Nama Instansi / Kontak',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.business_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

RichText(
                      text: TextSpan(
                        text: 'Nomor Telepon CS',
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
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
                        hintText: 'Masukkan Nomor Telepon',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.phone_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

Text(
                      'Email CS (Opsional)',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Alamat Email',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.email_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

Text(
                      'Catatan / Penjelasan Ringkas (Opsional)',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 10, color: contentColor.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _noteController,
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13, color: contentColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: 'Masukkan Catatan / Penjelasan Ringkas',
                        hintStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.note_alt_rounded,
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
                          _addCustomCS();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Simpan Kontak Darurat',
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
