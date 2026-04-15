import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/models/challenge_model.dart';
import 'package:tabunganku/models/challenge_template_model.dart';
import 'package:tabunganku/models/badge_model.dart';
import 'package:tabunganku/providers/challenge_provider.dart';
import 'package:tabunganku/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ChallengePage extends ConsumerStatefulWidget {
  const ChallengePage({super.key});

  @override
  ConsumerState<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends ConsumerState<ChallengePage> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  'Challenge Menabung',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Modern background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark 
                              ? [AppColors.surfaceDark, const Color(0xFF121212)] 
                              : [AppColors.primary, AppColors.primaryDark],
                          ),
                        ),
                      ),
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -100,
                        left: -50,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),
                      // Cards
                      Positioned(
                        bottom: 24,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                              Container(height: 50, width: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
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
                              Container(height: 50, width: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
                              _buildModernStatItem(
                                icon: Icons.check_circle_rounded,
                                iconColor: Colors.green,
                                value: stats['completed'].toString(),
                                label: 'Selesai',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: isDark ? Colors.white : AppColors.primary,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            children: const [
              _ActiveChallengesTab(),
              _TemplatesTab(),
              _BadgesTab(),
            ],
          ),
        ),
      ),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
  double get minExtent => tabBar.preferredSize.height + 8; // Added spacing

  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
  const _ActiveChallengesTab();

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
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 72,
                        color: isDark ? Colors.grey.shade400 : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Belum Ada Challenge',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pilih challenge pertamamu dan bangun kebiasaan menabung yang seru!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _ChallengeCard(challenge: challenges[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Terjadi kesalahan: $error')),
    );
  }
}


class _ChallengeCard extends ConsumerWidget {
  final ChallengeModel challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final progressPercent = challenge.progressPercentage / 100;
    final daysLeft = challenge.daysRemaining;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              theme.cardColor.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // 🏷️ Header Row
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(challenge.difficulty).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getDifficultyLabel(challenge.difficulty),
                      style: TextStyle(
                        color: _getDifficultyColor(challenge.difficulty),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: daysLeft > 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        Text(
                          '$daysLeft hari',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Delete Button
                  InkWell(
                    onTap: () => _showDeleteDialog(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
  
              // 📖 Title & Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
  
              // 📊 Progress Section
              if (challenge.targetAmount != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                  child: Column(
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  formatter.format(challenge.currentProgress),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.primary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 4,
                              children: [
                                Text(
                                  'Target',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  formatter.format(challenge.targetAmount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: theme.textTheme.bodyLarge?.color,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
  
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progressPercent.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progressPercent),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progressPercent * 100).toStringAsFixed(1)}% tercapai',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (progressPercent >= 1.0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 4,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                  Text(
                                    'Selesai!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Hapus Challenge?', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Challenge "${challenge.title}" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
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
                    const SnackBar(
                      content: Text('Challenge berhasil dihapus'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
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

  String _getDifficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'MUDAH';
      case ChallengeDifficulty.medium:
        return 'SEDANG';
      case ChallengeDifficulty.hard:
        return 'SULIT';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}

/// ═══════════════════════════════════
/// 🔍 EXPLORE TEMPLATES TAB
/// ═══════════════════════════════════

class _TemplatesTab extends ConsumerWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(challengeTemplatesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(
          'Pilih Challenge',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mulai perjalanan menabungmu dengan challenge yang cocok!',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(context, '🌟 Challenge Harian', templates.where((t) => t.type == ChallengeType.daily).toList()),
        const SizedBox(height: 4),
        _buildSection(context, '📅 Challenge Mingguan', templates.where((t) => t.type == ChallengeType.weekly).toList()),
        const SizedBox(height: 4),
        _buildSection(context, '🎯 Challenge Bulanan', templates.where((t) => t.type == ChallengeType.monthly).toList()),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<ChallengeTemplateModel> templates) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...templates.map((template) => _TemplateCard(template: template)),
      ],
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final ChallengeTemplateModel template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => _showTemplateDetail(context, ref, theme),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor,
                theme.cardColor.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎨 Template Icon
              if (template.icon != null)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      template.icon!,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              if (template.icon != null) const SizedBox(width: 16),

              // 📝 Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.bodyLarge?.color,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBadge(
                          template.difficultyLabel,
                          _getDifficultyColor(template.difficulty),
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          '${template.points}pts',
                          Colors.amber[700]!,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          '${template.defaultDurationDays}hr',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplateDetail(BuildContext parentContext, WidgetRef ref, ThemeData theme) {
    // Tambahan controller untuk durasi - Dipindah ke luar builder agar tidak ter-reset saat keyboard turun
    final durationController = TextEditingController(text: template.defaultDurationDays.toString());

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentDuration = int.tryParse(durationController.text) ?? template.defaultDurationDays;
            final endDate = DateTime.now().add(Duration(days: currentDuration));
            final isDarkMode = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Title and Icon
                    Row(
                      children: [
                        if (template.icon != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(template.icon, color: AppColors.primary, size: 32),
                          ),
                        if (template.icon != null) const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            template.title,
                            style: TextStyle(
                              fontSize: 20,
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
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tags/Badges
                    Row(
                      children: [
                        _buildBadge(template.difficultyLabel, _getDifficultyColor(template.difficulty)),
                        const SizedBox(width: 8),
                        _buildBadge('${template.points} poin', Colors.amber[700]!),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 📅 SET DURASI SECTION
                    Text(
                      'Target Waktu Pengerjaan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final val = int.tryParse(durationController.text) ?? 1;
                                  if (val > 1) {
                                    setSheetState(() {
                                      durationController.text = (val - 1).toString();
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    suffixText: ' Hari',
                                    suffixStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
                                  ),
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final val = int.tryParse(durationController.text) ?? 0;
                                  setSheetState(() {
                                    durationController.text = (val + 1).toString();
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Akan berakhir pada: ${DateFormat('d MMM yyyy').format(endDate)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (template.tips.isNotEmpty) ...[
                      Text(
                        'Tips Sukses:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...template.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final duration = int.tryParse(durationController.text) ?? template.defaultDurationDays;
                          
                          if (duration < 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Durasi challenge minimal 1 hari!'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          final service = ref.read(challengeServiceProvider);
                          await service.createChallenge(template, customDuration: duration);

                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text('Challenge "${template.title}" dimulai selama $duration hari!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            ref.invalidate(activeChallengesProvider);
                            try {
                              DefaultTabController.of(parentContext).animateTo(0);
                            } catch (_) {}
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Mulai Challenge Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
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
}

/// ═══════════════════════════════════
/// 🏆 BADGE COLLECTION TAB
/// ═══════════════════════════════════

class _BadgesTab extends ConsumerWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(allBadgesProvider);
    final badgeStats = ref.watch(badgeStatsProvider);

    return Column(
      children: [
        // 📈 Stats Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    badgeStats['earned'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Badge Diraih',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Column(
                children: [
                  Text(
                    '${badgeStats['percentage']}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Koleksi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 🎯 Badge Collection Grid
        Expanded(
          child: badgesAsync.when(
            data: (badges) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.78, // Taller cards to accommodate text
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  return _BadgeItem(badge: badges[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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

  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: badge.isEarned ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: badge.isEarned 
          ? theme.cardColor 
          : (theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[200]),
      child: InkWell(
        onTap: () => _showBadgeDetail(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4, // Reduced spacing
            children: [
            // 🎖️ Badge Icon
            Container(
                width: 48, // Reduced from 56
                height: 48, // Reduced from 56
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isEarned 
                      ? _getCategoryColor() 
                      : (theme.brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[400]),
                  boxShadow: badge.isEarned
                      ? [
                          BoxShadow(
                            color: _getCategoryColor().withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: Colors.white,
                  size: 24, // Reduced from 28
                ),
              ),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badge.isEarned ? theme.textTheme.bodyLarge?.color : Colors.grey[600],
                  height: 1.2,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(badge.name, style: const TextStyle(fontSize: 17)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description, style: const TextStyle(fontSize: 13, height: 1.5)),
            const SizedBox(height: 14),
            if (badge.requiredPoints > 0)
              _buildRequirement('🎯 Butuh ${badge.requiredPoints} poin'),
            if (badge.requiredStreak != null)
              _buildRequirement('🔥 Butuh ${badge.requiredStreak} hari streak'),
            if (badge.isEarned) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sudah Diraih!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
            child: const Text('Tutup'),
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
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
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
