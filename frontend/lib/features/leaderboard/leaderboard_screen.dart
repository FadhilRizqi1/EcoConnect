import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// Papan Peringkat — fetch real dari /api/papan-peringkat
/// Social Capital: highlight Top 3 secara visual
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Papan Peringkat')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)), child: const Text('Coba Lagi')),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      // Top 3 podium
                      if (_users.length >= 3) _buildPodium(),
                      const SizedBox(height: 20),
                      if (_users.length > 3)
                        const Text('Peringkat Selanjutnya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins')),
                      const SizedBox(height: 10),
                      ..._users.asMap().entries.skip(_users.length >= 3 ? 3 : 0).map((e) {
                        return _LeaderboardRow(
                          rank: e.key + 1,
                          user: e.value,
                          isMe: (e.value['id'] == _myId),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPodium() {
    final colors = [AppColors.accentAmber, Colors.grey.shade400, Colors.brown.shade300];
    final medals = ['🥇', '🥈', '🥉'];
    final order = [1, 0, 2]; // display: 2nd, 1st, 3rd (podium style)

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('🏆 Top 3 Eco-Warriors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 15)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: order.map((i) {
              if (i >= _users.length) return const Expanded(child: SizedBox());
              final user = _users[i];
              final isMe = user['id'] == _myId;
              final heights = [100.0, 120.0, 80.0];
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(medals[i], style: TextStyle(fontSize: i == 0 ? 30 : 24)),
                    const SizedBox(height: 4),
                    Text(
                      (user['name'] as String?)?.split(' ').first ?? '?',
                      style: TextStyle(
                        color: isMe ? AppColors.accentAmberLight : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user['reputation_points']} poin',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: heights[i],
                      decoration: BoxDecoration(
                        color: colors[i].withOpacity(0.9),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text('#${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryGreenSoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppColors.primaryGreenMint, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isMe ? AppColors.primaryGreen : AppColors.textMuted, fontFamily: 'Poppins'),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreenSoft,
            child: Text(
              ((user['name'] as String?) ?? '?')[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user['name']}${isMe ? ' (Kamu)' : ''}',
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(user['level'] ?? 'Pemula', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
              ],
            ),
          ),
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${user['reputation_points']}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  color: isMe ? AppColors.primaryGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
