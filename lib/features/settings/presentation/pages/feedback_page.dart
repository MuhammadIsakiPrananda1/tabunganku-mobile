import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabunganku/core/constants/app_version.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  
  int _selectedRating = 5;
  String _selectedCategory = 'Saran Fitur';
  int _charCount = 0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Saran Fitur',
    'Rating & Apresiasi',
    'Lapor Masalah / Bug',
    'Pertanyaan',
    'Lainnya',
  ];

  final Map<int, Map<String, dynamic>> _ratingDetails = {
    1: {'label': 'Sangat Buruk 😞', 'color': Colors.redAccent},
    2: {'label': 'Kurang Puas 🙁', 'color': Colors.orangeAccent},
    3: {'label': 'Cukup Baik 🙂', 'color': Colors.amber},
    4: {'label': 'Bagus! 😊', 'color': Colors.lightGreen},
    5: {'label': 'Luar Biasa! ⭐', 'color': Colors.amber},
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final ratingInfo = _ratingDetails[_selectedRating] ?? {'label': '$_selectedRating/5'};
    final ratingLabel = ratingInfo['label'] as String;
    final starEmojis = '⭐' * _selectedRating;
    final messageText = _messageController.text.trim();

    final subject = Uri.encodeComponent(
      '[TabunganKu Feedback] $_selectedCategory ($_selectedRating/5 ⭐)',
    );

    final body = Uri.encodeComponent(
      'Halo Tim TabunganKu,\n\n'
      'Berikut penilaian dan masukan saya untuk aplikasi TabunganKu:\n\n'
      '⭐ Rating: $starEmojis ($_selectedRating/5 - $ratingLabel)\n'
      '🏷️ Kategori: $_selectedCategory\n\n'
      '💬 Ulasan / Pesan:\n'
      '$messageText\n\n'
      '-----------------------------------------\n'
      'Informasi Aplikasi:\n'
      '- Aplikasi: TabunganKu\n'
      '- Versi: v${AppVersion.version}\n'
      '- Waktu: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}\n'
      '-----------------------------------------',
    );

    final gmailAppUri = Uri.parse(
      'googlegmail:///co?to=Arlianto032@gmail.com&subject=$subject&body=$body',
    );
    final mailtoUri = Uri.parse(
      'mailto:Arlianto032@gmail.com?subject=$subject&body=$body',
    );
    final gmailWebUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=Arlianto032@gmail.com&su=$subject&body=$body',
    );

    bool launched = false;

    try {
      if (await canLaunchUrl(gmailAppUri)) {
        launched = await launchUrl(gmailAppUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (!launched) {
      try {
        if (await canLaunchUrl(mailtoUri)) {
          launched = await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }

    if (!launched) {
      try {
        launched = await launchUrl(gmailWebUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!launched) {
      await Clipboard.setData(
        ClipboardData(
          text: 'Subject: [TabunganKu Feedback] $_selectedCategory ($_selectedRating/5 ⭐)\n\n'
              'Rating: $_selectedRating/5\n'
              'Pesan:\n$messageText',
        ),
      );
      if (!mounted) return;
      showTopToast(
        context,
        'Gagal membuka Gmail. Pesan disalin ke clipboard untuk dikirim manual.',
        isError: true,
      );
    } else {
      showTopToast(context, 'Membuka Gmail. Terima kasih banyak atas masukan Anda!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final ratingInfo = _ratingDetails[_selectedRating] ?? {'label': '$_selectedRating/5', 'color': Colors.amber};
    final ratingLabel = ratingInfo['label'] as String;
    final ratingColor = ratingInfo['color'] as Color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kirim Masukan & Rating',
          style: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [
                              Colors.orange.shade900.withValues(alpha: 0.35),
                              AppColors.surfaceDark,
                            ]
                          : [
                              Colors.orange.shade50,
                              Colors.amber.shade50.withValues(alpha: 0.6),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.orange.shade200.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suaramu Sangat Berarti!',
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bantu kami membuat TabunganKu lebih baik lagi melalui penilaian dan saran Anda.',
                              style: GoogleFonts.quicksand(
                                fontSize: 11.5,
                                color: isDarkMode ? Colors.white60 : Colors.black54,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Rating Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Bagaimana kepuasan Anda?',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey(_selectedRating),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: ratingColor.withValues(alpha: isDarkMode ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ratingLabel,
                            style: GoogleFonts.quicksand(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starNum = index + 1;
                          final isFilled = starNum <= _selectedRating;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedRating = starNum);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedScale(
                                scale: isFilled ? 1.12 : 0.95,
                                duration: const Duration(milliseconds: 160),
                                child: Icon(
                                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: isFilled
                                      ? Colors.amber
                                      : (isDarkMode ? Colors.white24 : Colors.grey.shade300),
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Kategori Masukan
                Text(
                  'Kategori Masukan',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),

                // Input Pesan / Ulasan
                Text(
                  'Ulasan atau Saran',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  maxLength: 500,
                  onChanged: (val) {
                    setState(() => _charCount = val.length);
                  },
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan ulasan, masukan fitur, atau kendala yang kamu alami di sini...',
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 12.5,
                      color: isDarkMode ? Colors.white24 : Colors.black26,
                    ),
                    fillColor: isDarkMode
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.grey.shade50,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorStyle: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Pesan ulasan tidak boleh kosong';
                    }
                    if (val.trim().length < 3) {
                      return 'Pesan ulasan minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '$_charCount / 500',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _charCount >= 450
                            ? Colors.redAccent
                            : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Info destination note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.grey.shade100.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: isDarkMode ? Colors.white38 : Colors.black45,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pesan akan dikirim langsung via aplikasi Gmail ke Arlianto032@gmail.com.',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white38 : Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.mail_outline_rounded,
                            size: 20,
                          ),
                    label: Text(
                      _isSubmitting ? 'Membuka Gmail...' : 'Kirim via Gmail',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
