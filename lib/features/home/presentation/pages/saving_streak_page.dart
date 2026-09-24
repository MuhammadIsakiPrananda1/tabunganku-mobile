/// Page: SavingStreakPage
///
/// Menampilkan streak harian menabung, statistik konsistensi,
/// aktivitas mingguan, dan milestone pencapaian dengan desain minimalis TabunganKu.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:tabunganku/core/widgets/top_toast.dart';
import 'package:tabunganku/providers/saving_streak_provider.dart';

class SavingStreakPage extends ConsumerStatefulWidget {
  const SavingStreakPage({super.key});

  @override
  ConsumerState<SavingStreakPage> createState() => _SavingStreakPageState();
}

class _SavingStreakPageState extends ConsumerState<SavingStreakPage> {
  Future<void> _recordToday() async {
    HapticFeedback.lightImpact();
    final streakNotifier = ref.read(savingStreakProvider.notifier);
    final recorded = await streakNotifier.recordSavingActivity();
    if (!mounted) return;

    if (recorded) {
      final current = ref.read(savingStreakProvider).currentStreak;
      showTopToast(context, 'Aktivitas hari ini dicatat! Streak ke-$current hari.');
    } else {
      showTopToast(context, 'Aktivitas menabung hari ini sudah tercatat.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(savingStreakProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final pageBg = isDarkMode ? AppColors.backgroundDark : const Color(0xFFF9FAFB);
    final cardBg = isDarkMode ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDarkMode ? Colors.white10 : Colors.grey.shade200;
    final contentColor = isDarkMode ? Colors.white : AppColors.primaryDark;
    final subColor = isDarkMode ? Colors.white54 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: contentColor, size: 18),
        ),
        title: Text(
          'Streak Menabung',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: contentColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Card: Konsistensi Menabung
              _buildHeroCard(streak, isDarkMode, cardBg, borderCol, contentColor, subColor),
              const SizedBox(height: 14),

              // 2. Tombol Aksi Utama
              _buildRecordButton(streak, isDarkMode),
              const SizedBox(height: 18),

              // 3. Ringkasan Statistik
              _buildStatsRow(streak, isDarkMode, cardBg, borderCol, contentColor, subColor),
              const SizedBox(height: 18),

              // 4. Aktivitas 7 Hari Terakhir
              _buildWeeklyActivityCard(streak, isDarkMode, cardBg, borderCol, contentColor, subColor),
              const SizedBox(height: 18),

              // 5. Milestone & Badge Pencapaian
              _buildMilestonesCard(streak, isDarkMode, cardBg, borderCol, contentColor, subColor),
              const SizedBox(height: 18),

              // 6. Tips Ringkas Finansial
              _buildTipsBanner(isDarkMode),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Hero Card ────────────────────────────────────────────────────────────

  Widget _buildHeroCard(
    SavingStreakState streak,
    bool isDarkMode,
    Color cardBg,
    Color borderCol,
    Color contentColor,
    Color subColor,
  ) {
    final hasSavedToday = streak.hasSavedToday;
    final currentBadge = streak.currentBadge;
    final nextBadge = streak.nextBadge;
    final progress = streak.progressToNextBadge;

    final statusText = hasSavedToday ? 'Tercatat Hari Ini' : 'Belum Dicatat';
    final statusColor = hasSavedToday ? AppColors.primary : Colors.amber.shade800;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header baris atas dengan Expanded agar tidak overflow
          Row(
            children: [
              Expanded(
                child: Text(
                  'KONSISTENSI MENABUNG',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasSavedToday ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 11,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Angka Streak Utama
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${streak.currentStreak}',
                            style: GoogleFonts.quicksand(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hari Berurutan',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: contentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentBadge != null
                          ? 'Level ${currentBadge.name}'
                          : 'Mulai bangun kebiasaan menabung',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress ke level berikutnya
          if (nextBadge != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Target: ${nextBadge.name}',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${streak.currentStreak}/${nextBadge.requiredDays} hari',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDarkMode ? Colors.white12 : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Luar biasa! Kamu telah mencapai level Legenda.',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 2. Tombol Catat Hari Ini ────────────────────────────────────────────────

  Widget _buildRecordButton(SavingStreakState streak, bool isDarkMode) {
    final alreadyDone = streak.hasSavedToday;

    if (alreadyDone) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Hari Ini Sudah Dicatat',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _recordToday,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.add_task_rounded, size: 18),
        label: Text(
          'Catat Menabung Hari Ini',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── 3. Statistik Row ────────────────────────────────────────────────────────

  Widget _buildStatsRow(
    SavingStreakState streak,
    bool isDarkMode,
    Color cardBg,
    Color borderCol,
    Color contentColor,
    Color subColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'REKOR TERPANJANG',
            value: '${streak.longestStreak}',
            unit: 'Hari',
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber.shade700,
            cardBg: cardBg,
            borderCol: borderCol,
            contentColor: contentColor,
            subColor: subColor,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'TOTAL HARI NABUNG',
            value: '${streak.totalSavingDays}',
            unit: 'Hari',
            icon: Icons.calendar_month_outlined,
            iconColor: AppColors.primary,
            cardBg: cardBg,
            borderCol: borderCol,
            contentColor: contentColor,
            subColor: subColor,
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color borderCol,
    required Color contentColor,
    required Color subColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: iconColor, size: 15),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Aktivitas 7 Hari Terakhir ────────────────────────────────────────────

  Widget _buildWeeklyActivityCard(
    SavingStreakState streak,
    bool isDarkMode,
    Color cardBg,
    Color borderCol,
    Color contentColor,
    Color subColor,
  ) {
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AKTIVITAS 7 HARI TERAKHIR',
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),

          // Baris 7 hari responsif dengan Expanded
          Row(
            children: List.generate(7, (i) {
              final day = today.subtract(Duration(days: 6 - i));
              final dayOnly = DateTime(day.year, day.month, day.day);
              final hasActivity = streak.recentDays.any((d) =>
                  d.year == dayOnly.year &&
                  d.month == dayOnly.month &&
                  d.day == dayOnly.day);
              final isToday = i == 6;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hasActivity
                            ? AppColors.primary
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(9),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: hasActivity
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : Text(
                                '${day.day}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white38 : Colors.grey.shade400,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _shortDayName(day.weekday),
                      style: GoogleFonts.quicksand(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isToday ? AppColors.primary : subColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 14),
          // Legend fleksibel dengan Wrap agar tidak overflow
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tercatat menabung',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Belum tercatat',
                    style: GoogleFonts.quicksand(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Milestone & Badge Pencapaian ─────────────────────────────────────────

  Widget _buildMilestonesCard(
    SavingStreakState streak,
    bool isDarkMode,
    Color cardBg,
    Color borderCol,
    Color contentColor,
    Color subColor,
  ) {
    final earnedCount = streak.badges.where((b) => b.isEarned).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'LEVEL & PENCAPAIAN',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$earnedCount/${streak.badges.length} Tercapai',
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daftar Level Badge Minimalis
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: streak.badges.length,
            separatorBuilder: (_, __) => Divider(
              color: isDarkMode ? Colors.white10 : Colors.grey.shade100,
              height: 14,
            ),
            itemBuilder: (context, index) {
              final badge = streak.badges[index];
              final earned = badge.isEarned;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: earned
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Icon(
                          earned ? Icons.verified_rounded : Icons.lock_outline_rounded,
                          size: 16,
                          color: earned
                              ? AppColors.primary
                              : (isDarkMode ? Colors.white24 : Colors.grey.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: earned
                                  ? contentColor
                                  : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${badge.requiredDays} hari berurutan',
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: earned
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        earned
                            ? 'Tercapai'
                            : '${streak.currentStreak}/${badge.requiredDays} hr',
                        style: GoogleFonts.quicksand(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: earned
                              ? AppColors.primary
                              : (isDarkMode ? Colors.white38 : Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 6. Tips Finansial Ringkas ────────────────────────────────────────────────

  Widget _buildTipsBanner(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDarkMode ? 0.2 : 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Konsistensi lebih bermakna daripada nominal besar. Menabung sedikit setiap hari secara teratur membentuk kebiasaan finansial yang kokoh.',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDayName(int weekday) {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return names[weekday - 1];
  }
}
