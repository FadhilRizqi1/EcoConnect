import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/rank_helper.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class PremiumProgressMenu extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const PremiumProgressMenu({super.key, required this.userProfile});

  @override
  State<PremiumProgressMenu> createState() => _PremiumProgressMenuState();
}

class _PremiumProgressMenuState extends State<PremiumProgressMenu> {
  List<dynamic> _topUsers = [];
  bool _loading = true;
  String? _error;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _myId = await AuthService.getUserId();
      final data = await ApiService.getLeaderboard();
      if (mounted) {
        setState(() {
          // Hanya ambil Top 3 atau Top 5 untuk mini leaderboard
          _topUsers = data.take(4).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat papan peringkat';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark
        ? const Color(0xFF1A2E20).withOpacity(0.97)
        : Colors.white.withOpacity(0.97);
    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4D2E).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        // Drag Handle
                        Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A4D2E).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progres & Peringkat',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ).animate().fade().slideX(begin: -0.1),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC87A).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(LucideIcons.x, color: Theme.of(context).textTheme.titleLarge?.color),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ).animate().fade().scale(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress Card
                        _buildProgressCard().animate().fade(delay: const Duration(milliseconds: 100)).slideY(begin: 0.1),
                        const SizedBox(height: 32),
                        // Daftar Semua Peringkat
                        _buildRanksHorizontalList().animate().fade(delay: const Duration(milliseconds: 150)),
                        const SizedBox(height: 32),
                        // Mini Leaderboard Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Eco Warriors',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ).animate().fade(delay: const Duration(milliseconds: 200)),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.go('/papan-peringkat');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentAmber,
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 13),
                              ),
                              child: const Text('Lihat Semua'),
                            ).animate().fade(delay: const Duration(milliseconds: 200)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: _loading
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                          ),
                        )
                      : _error != null
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final user = _topUsers[index];
                                  final isMe = user['id'] == _myId;
                                  return _buildLeaderboardRow(index + 1, user, isMe)
                                      .animate()
                                      .fade(delay: Duration(milliseconds: 250 + (index * 100)))
                                      .slideX(begin: 0.1);
                                },
                                childCount: _topUsers.length,
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final profil = widget.userProfile['profil'] as Map<String, dynamic>? ?? {};
    final level = profil['level']?.toString() ?? 'Tunas';
    final points = (profil['reputation_points'] as num? ?? 0).toInt();
    final tasks = (widget.userProfile['tugas_selesai'] as num? ?? 0).toInt();

    final rank = RankHelper.getRank(points);
    final nextRank = RankHelper.getNextRank(points);
    final progress = RankHelper.getProgress(points);
    final pointsNeeded = RankHelper.getPointsNeeded(points);
    final nextLevel = nextRank?.name ?? 'Max';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4D2E), Color(0xFF0F301C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4D2E).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background abstract shape
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: rank.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: rank.color.withOpacity(0.5), width: 1.5),
                    ),
                    child: Center(
                      child: Icon(rank.icon, color: rank.color, size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentAmber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.star, color: AppColors.accentAmber, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$points Poin',
                                    style: const TextStyle(
                                      color: AppColors.accentAmber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC87A).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.checkCircle, color: Color(0xFF4FC87A), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$tasks Aksi',
                                    style: const TextStyle(
                                      color: Color(0xFF4FC87A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
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
              ),
              const SizedBox(height: 24),
              // Progress Bar Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perjalanan Level',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                  ),
                  if (pointsNeeded > 0)
                    Flexible(
                      child: Text(
                        '$pointsNeeded pts ke $nextLevel',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC87A)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRanksHorizontalList() {
    final ranks = RankHelper.ranks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Peringkat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: ranks.length,
            itemBuilder: (context, index) {
              final rank = ranks[index];
              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // FIX: Explicit white in light mode — cardColor from fromSeed
                  // may be a tonal surface indistinguishable from the sheet background.
                  color: isDark ? const Color(0xFF1E3325) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rank.color.withOpacity(isDark ? 0.2 : 0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: rank.color.withOpacity(isDark ? 0.05 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(rank.icon, color: rank.color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      rank.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${rank.minPoints} pts',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, Map<String, dynamic> user, bool isMe) {
    // Top 3 colors
    final isTop3 = rank <= 3;
    final rankColor = rank == 1
        ? const Color(0xFFFFB03A)
        : rank == 2
            ? const Color(0xFF9E9E9E)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : const Color(0xFF1A4D2E).withOpacity(0.1);

    final isDarkRow = Theme.of(context).brightness == Brightness.dark;
    final rowBg = isMe
        ? const Color(0xFF4FC87A).withOpacity(0.1)
        : (isDarkRow ? const Color(0xFF1E3325) : Colors.white);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(20),
        border: isMe
            ? Border.all(color: const Color(0xFF4FC87A), width: 1.5)
            : Border.all(color: const Color(0xFF1A4D2E).withOpacity(isDarkRow ? 0.15 : 0.05)),
        boxShadow: [
          if (isTop3 && !isMe)
            BoxShadow(color: rankColor.withOpacity(isDarkRow ? 0.05 : 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Rank Indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop3 ? rankColor.withOpacity(0.15) : rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTop3
                  ? Icon(LucideIcons.crown, color: rankColor, size: 16)
                  : Text(
                      '$rank',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1A4D2E), fontFamily: 'Poppins'),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: isTop3 ? rankColor : const Color(0xFF1A4D2E).withOpacity(0.1), width: 2),
              image: user['avatar'] != null && user['avatar'].toString().isNotEmpty
                  ? DecorationImage(image: CachedNetworkImageProvider(user['avatar']), fit: BoxFit.cover)
                  : null,
            ),
            child: (user['avatar'] == null || user['avatar'].toString().isEmpty)
                ? Center(
                    child: Text(
                      ((user['name'] as String?) ?? '?')[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A4D2E), fontSize: 14),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user['name']}${isMe ? ' (Kamu)' : ''}',
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    // FIX: was hardcoded to dark green — invisible on dark backgrounds
                    color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user['level'] ?? 'Pemula',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTop3 ? rankColor.withOpacity(0.1) : const Color(0xFF1A4D2E).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.star, color: isTop3 ? rankColor : const Color(0xFF1A4D2E), size: 12),
                const SizedBox(width: 4),
                Text(
                  '${user['reputation_points']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: isTop3 ? rankColor : const Color(0xFF1A4D2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
