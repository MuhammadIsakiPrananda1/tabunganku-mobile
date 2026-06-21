import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabunganku/models/challenge_model.dart';
import 'package:tabunganku/models/challenge_template_model.dart';
import 'package:tabunganku/models/badge_model.dart';
import 'package:tabunganku/providers/challenge_provider.dart';
import 'package:tabunganku/providers/transaction_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ChallengePage extends ConsumerStatefulWidget {
  const ChallengePage({super.key});

  @override
  ConsumerState<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends ConsumerState<ChallengePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = ref.watch(challengeStatsProvider);
    final streak = ref.watch(currentStreakProvider);
    final points = ref.watch(totalPointsProvider);

    final contentColor = isDark ? Colors.white : AppColors.primaryDark;
    
    // Page Theme: Mint Green Accent & Pure Dark/Light backgrounds
    final pageBgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9);
    final accentColor = isDark ? const Color(0xFF2ECC71) : const Color(0xFF27AE60);

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
          'Challenge Menabung',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _buildStatsCard(streak, points, stats, isDark, accentColor),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: accentColor,
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : AppColors.primaryDark,
                  unselectedLabelColor: Colors.grey.shade500,
                  labelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: const [
                    Tab(text: 'Aktif'),
                    Tab(text: 'Jelajahi'),
                    Tab(text: 'Badge'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _ActiveChallengesTab(accentColor: accentColor, tabController: _tabController),
            _TemplatesTab(accentColor: accentColor, tabController: _tabController),
            _BadgesTab(accentColor: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      AsyncValue<int> streak, AsyncValue<int> points, Map<String, dynamic> stats, bool isDark, Color accentColor) {
    final hexBg = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: hexBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModernStatItem(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            value: streak.when(
              data: (s) => s.toString(),
              loading: () => '-',
              error: (_, __) => '0',
            ),
            label: 'Streak',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildModernStatItem(
            icon: Icons.stars_rounded,
            iconColor: Colors.amber,
            value: points.when(
              data: (p) => p.toString(),
              loading: () => '-',
              error: (_, __) => '0',
            ),
            label: 'Poin',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildModernStatItem(
            icon: Icons.check_circle_rounded,
            iconColor: accentColor,
            value: stats['completed'].toString(),
            label: 'Selesai',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
    );
  }

  Widget _buildModernStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.quicksand(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.quicksand(
            color: (isDark ? Colors.white : AppColors.primaryDark).withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8;

  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _ActiveChallengesTab extends ConsumerWidget {
  final Color accentColor;
  final TabController tabController;
  const _ActiveChallengesTab({required this.accentColor, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeChallenges = ref.watch(activeChallengesProvider);
    final isDark = theme.brightness == Brightness.dark;

    return activeChallenges.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.08),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 60,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Challenge',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih challenge pertamamu dan bangun kebiasaan menabung yang seru!',
                    style: GoogleFonts.quicksand(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      tabController.animateTo(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Pilih Challenge',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _buildChallengeCard(context, ref, challenges[index]);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
      error: (error, _) => Center(child: Text('Terjadi kesalahan: $error')),
    );
  }

  Widget _buildChallengeCard(
      BuildContext context, WidgetRef ref, ChallengeModel challenge) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressPercent = challenge.progressPercentage / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: progressPercent,
                      strokeWidth: 4,
                      backgroundColor: accentColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressPercent < 0.3 ? Colors.red : (progressPercent < 0.7 ? Colors.orange : accentColor)
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getTemplateIcon(challenge.title),
                        color: accentColor, size: 18),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 12,
                            color: isDark ? Colors.white24 : Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.daysRemaining} hari lagi',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•',
                            style: TextStyle(
                                color: isDark ? Colors.white12 : Colors.grey.shade300)),
                        const SizedBox(width: 8),
                        Icon(Icons.stars_rounded,
                            size: 12,
                            color: Colors.amber.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.id.hashCode % 50 + 10} Poin',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: progressPercent < 0.3 ? Colors.red : (progressPercent < 0.7 ? Colors.orange : accentColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context, ref, challenge),
                    child: Icon(Icons.delete_outline_rounded,
                        color: isDark ? Colors.white24 : Colors.red.withOpacity(0.4),
                        size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTemplateIcon(String title) {
    if (title.contains('Kopi')) return Icons.coffee_rounded;
    if (title.contains('Jajan')) return Icons.no_meals_rounded;
    if (title.contains('Hemat') || title.contains('Tabung')) return Icons.savings_rounded;
    if (title.contains('Zero')) return Icons.lock_outline_rounded;
    if (title.contains('Weekend')) return Icons.weekend_rounded;
    return Icons.emoji_events_rounded;
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, ChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Text('Hapus Challenge?',
                style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Challenge "${challenge.title}" akan dihapus. Semua progres di dalamnya akan hilang.',
          style: GoogleFonts.quicksand(fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = ref.read(challengeServiceProvider);
                await service.deleteChallenge(challenge.id);
                ref.invalidate(activeChallengesProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Challenge berhasil dihapus',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TemplatesTab extends ConsumerWidget {
  final Color accentColor;
  final TabController tabController;
  const _TemplatesTab({required this.accentColor, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(challengeTemplatesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Text(
          'Pilih Challenge',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Mulai perjalanan menabungmu dengan challenge yang cocok!',
          style: GoogleFonts.quicksand(
            color: Colors.grey[600],
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildSection(context, '🌟 Challenge Harian',
            templates.where((t) => t.type == ChallengeType.daily).toList()),
        const SizedBox(height: 8),
        _buildSection(context, '📅 Challenge Mingguan',
            templates.where((t) => t.type == ChallengeType.weekly).toList()),
        const SizedBox(height: 8),
        _buildSection(context, '🎯 Challenge Bulanan',
            templates.where((t) => t.type == ChallengeType.monthly).toList()),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title,
      List<ChallengeTemplateModel> templates) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        ...templates.map((template) => _TemplateCard(template: template, accentColor: accentColor, tabController: tabController)),
      ],
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final ChallengeTemplateModel template;
  final Color accentColor;
  final TabController tabController;

  const _TemplateCard({required this.template, required this.accentColor, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showTemplateDetail(context, ref, theme),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(template.icon ?? Icons.emoji_events_rounded,
                      color: accentColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniBadge(template.difficultyLabel,
                              _getDifficultyColor(template.difficulty)),
                          const SizedBox(width: 8),
                          _buildMiniBadge(
                              '${template.points} pts', Colors.amber.shade700),
                          const SizedBox(width: 8),
                          _buildMiniBadge(
                              '${template.defaultDurationDays} Hari',
                              accentColor,
                              icon: Icons.timer_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.quicksand(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
    }
  }

  void _showTemplateDetail(
      BuildContext parentContext, WidgetRef ref, ThemeData theme) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final endDate = DateTime.now().add(Duration(days: template.defaultDurationDays));
        final isDarkMode = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (template.icon != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(template.icon, color: accentColor, size: 24),
                      ),
                    if (template.icon != null) const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        template.title,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  template.description,
                  style: GoogleFonts.quicksand(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildBadge(template.difficultyLabel,
                        _getDifficultyColor(template.difficulty)),
                    const SizedBox(width: 8),
                    _buildBadge(
                        '${template.points} Poin', Colors.amber[700]!),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  'Target Waktu Pengerjaan:',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.03) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, color: accentColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${template.defaultDurationDays} Hari${template.defaultDurationDays == 7 ? " (1 Minggu)" : template.defaultDurationDays == 30 ? " (1 Bulan)" : ""}',
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Akan berakhir pada: ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}',
                            style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (template.tips.isNotEmpty) ...[
                  Text(
                    'Tips Sukses:',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...template.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.quicksand(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final duration = template.defaultDurationDays;

                      Navigator.pop(context);
                      final service = ref.read(challengeServiceProvider);
                      await service.createChallenge(template,
                          customDuration: duration);

                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Challenge "${template.title}" dimulai selama $duration hari!',
                              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: accentColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        ref.invalidate(activeChallengesProvider);
                        tabController.animateTo(0);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Mulai Challenge Sekarang',
                        style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BadgesTab extends ConsumerWidget {
  final Color accentColor;
  const _BadgesTab({required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(allBadgesProvider);
    final badgeStats = ref.watch(badgeStatsProvider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    badgeStats['earned'].toString(),
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Badge Diraih',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
              ),
              Column(
                children: [
                  Text(
                    '${badgeStats['percentage']}%',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Koleksi',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: badgesAsync.when(
            data: (badges) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  return _BadgeItem(badge: badges[index], accentColor: accentColor);
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: GoogleFonts.quicksand(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final Color accentColor;

  const _BadgeItem({required this.badge, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: badge.isEarned
            ? (isDark ? AppColors.surfaceDark : Colors.white)
            : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.isEarned
              ? accentColor.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
          width: badge.isEarned ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showBadgeDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badge.isEarned
                        ? _getCategoryColor()
                        : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badge.isEarned
                        ? (isDark ? Colors.white : AppColors.primaryDark)
                        : Colors.grey[500],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(badge.name,
                  style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description,
                style: GoogleFonts.quicksand(fontSize: 13, height: 1.4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (badge.requiredPoints > 0)
              _buildRequirement('🎯 Butuh ${badge.requiredPoints} poin'),
            if (badge.requiredStreak != null)
              _buildRequirement('🔥 Butuh ${badge.requiredStreak} hari streak'),
            if (badge.isEarned) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sudah Diraih!',
                      style: GoogleFonts.quicksand(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 12, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (badge.category) {
      case BadgeCategory.streak:
        return Colors.orange;
      case BadgeCategory.challenge:
        return Colors.blue;
      case BadgeCategory.saving:
        return Colors.green;
      case BadgeCategory.special:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon() {
    switch (badge.category) {
      case BadgeCategory.streak:
        return Icons.local_fire_department_rounded;
      case BadgeCategory.challenge:
        return Icons.emoji_events_rounded;
      case BadgeCategory.saving:
        return Icons.savings_rounded;
      case BadgeCategory.special:
        return Icons.stars_rounded;
    }
  }
}
