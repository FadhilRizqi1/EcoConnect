import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// Papan Peringkat — Premium 3D Podium Design
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _users = [];
  bool _loading = true;
  String? _error;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    _myId = await AuthService.getUserId();
    try {
      final data = await ApiService.getLeaderboard();
      if (mounted) setState(() { _users = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat papan peringkat'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 80,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Papan Peringkat',
                style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
              ).animate().fade().slideY(begin: -0.2),
            ),

            // Content
            SliverToBoxAdapter(
              child: _loading
                  ? const SizedBox(height: 400, child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)))
                  : _error != null
                      ? _buildError()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_users.length >= 3) ...[
                                _build3DPodium().animate().fade(duration: const Duration(milliseconds: 600)).slideY(begin: 0.2),
                                const SizedBox(height: 32),
                              ],
                              
                              if (_users.length > 3)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Peringkat Selanjutnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E), fontFamily: 'Poppins'))
                                    .animate().fade(delay: const Duration(milliseconds: 300)),
                                ),
                              const SizedBox(height: 16),
                              
                              ..._users.asMap().entries.skip(_users.length >= 3 ? 3 : 0).map((e) {
                                final delay = 400 + (e.key * 100);
                                return _LeaderboardRow(
                                  rank: e.key + 1,
                                  user: e.value,
                                  isMe: (e.value['id'] == _myId),
                                ).animate().fade(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
                              }),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(LucideIcons.wifiOff, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPodium() {
    // Array order: Rank 2 (Left), Rank 1 (Center), Rank 3 (Right)
    final order = [1, 0, 2]; 
    final heights = [190.0, 140.0, 110.0];
    final colors = [
      const Color(0xFFFFB03A), // Gold
      const Color(0xFFE0E0E0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: order.map((i) {
          if (i >= _users.length) return const Expanded(child: SizedBox());
          final user = _users[i];
          final isMe = user['id'] == _myId;
          final isFirst = i == 0;

          return Expanded(
            child: GestureDetector(
              onTap: () => context.push('/profil/${user['id']}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar & Crown
                    Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: isFirst ? 72 : 56,
                          height: isFirst ? 72 : 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: colors[i], width: 3),
                            boxShadow: [BoxShadow(color: colors[i].withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
                            image: user['avatar'] != null && user['avatar'].toString().isNotEmpty
                                ? DecorationImage(image: CachedNetworkImageProvider(user['avatar']), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (user['avatar'] == null || user['avatar'].toString().isEmpty) ? Center(
                            child: Text(
                              ((user['name'] as String?) ?? '?')[0].toUpperCase(),
                              style: TextStyle(fontSize: isFirst ? 28 : 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E)),
                            ),
                          ) : null,
                        ),
                        if (isFirst)
                          Positioned(
                            top: -24,
                            child: const Icon(LucideIcons.crown, color: Color(0xFFFFB03A), size: 36)
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .moveY(begin: -4, end: 4, duration: const Duration(seconds: 2)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Name & Points
                    Text(
                      (user['name'] as String?)?.split(' ').first ?? '?',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E),
                        fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: isFirst ? 14 : 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF1A4D2E).withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${user['reputation_points']} pts',
                        style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E), fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 3D Podium Block
                    Container(
                      height: heights[i],
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [colors[i], colors[i].withOpacity(0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          // Inner top highlight for 3D bevel effect
                          BoxShadow(color: Colors.white.withOpacity(0.4), offset: const Offset(0, 2), blurRadius: 2, spreadRadius: 0),
                          // Drop shadow
                          BoxShadow(color: colors[i].withOpacity(0.3), offset: const Offset(0, 10), blurRadius: 20),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
                            ),
                          ),
                        ],
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
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;
  final bool isMe;
  
  const _LeaderboardRow({required this.rank, required this.user, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profil/${user['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4FC87A).withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isMe ? Border.all(color: const Color(0xFF4FC87A), width: 1.5) : Border.all(color: Colors.transparent),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF4FC87A) : const Color(0xFF1A4D2E).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isMe ? Colors.white : (Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E)), fontFamily: 'Poppins'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF1A4D2E).withOpacity(0.1), width: 2),
                image: user['avatar'] != null && user['avatar'].toString().isNotEmpty
                    ? DecorationImage(image: CachedNetworkImageProvider(user['avatar']), fit: BoxFit.cover)
                    : null,
              ),
              child: (user['avatar'] == null || user['avatar'].toString().isEmpty) ? Center(
                child: Text(
                  ((user['name'] as String?) ?? '?')[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E), fontSize: 16),
                ),
              ) : null,
            ),
            const SizedBox(width: 14),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user['name']}${isMe ? ' (Kamu)' : ''}',
                  style: TextStyle(fontWeight: isMe ? FontWeight.w800 : FontWeight.w600, fontSize: 14, fontFamily: 'Poppins', color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(user['level'] ?? 'Pemula', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF1A4D2E).withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(LucideIcons.star, color: AppColors.accentAmber, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${user['reputation_points']}',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Poppins', color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A4D2E)),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
