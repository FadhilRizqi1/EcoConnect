import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// Profil — menampilkan data real dari /api/profil/:id
/// Social Capital: poin, level, badges
class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _data;
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
      final data = await ApiService.getProfil(widget.userId);
      if (mounted) setState(() { _data = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat profil'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (_myId == widget.userId)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await AuthService.logout();
                if (mounted) context.go('/masuk');
              },
            ),
        ],
      ),
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
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildStats(),
                      const SizedBox(height: 24),
                      _buildBadges(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final profil = _data?['profil'] as Map<String, dynamic>? ?? {};
    final name  = profil['name']?.toString() ?? 'Pengguna';
    final level = profil['level']?.toString() ?? 'Pemula';
    final cat   = profil['category']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins'),
            )),
          ),
          const SizedBox(height: 14),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: Text(level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins')),
          ),
          if (cat.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Fokus: $cat', style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Poppins')),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    final profil  = _data?['profil'] as Map<String, dynamic>? ?? {};
    final points  = (profil['reputation_points'] as num? ?? 0).toInt();
    final carbon  = (_data?['total_karbon_kg'] as num? ?? profil['total_carbon_saved'] as num? ?? 0.0).toDouble();
    final tasks   = (_data?['tugas_selesai'] as num? ?? 0).toInt();

    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Poin', value: '$points', icon: '⭐', color: AppColors.accentAmber)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: 'Aksi', value: '$tasks', icon: '✅', color: AppColors.primaryBlueMid)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: 'kg CO₂', value: carbon.toStringAsFixed(1), icon: '🌍', color: AppColors.primaryGreen)),
      ],
    );
  }

  Widget _buildBadges() {
    final profil = _data?['profil'] as Map<String, dynamic>? ?? {};
    final badges = profil['badges'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lencana Prestasi 🏅', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        badges.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Text('Selesaikan aksi pertamamu untuk mendapatkan lencana! 🌱', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13), textAlign: TextAlign.center),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (_, i) {
                  final badge = badges[i];
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(badge['icon_url']?.isNotEmpty == true ? badge['icon_url'] : '🏅', style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(badge['name'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: AppColors.textPrimary), textAlign: TextAlign.center, maxLines: 2),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
      ]),
    );
  }
}
