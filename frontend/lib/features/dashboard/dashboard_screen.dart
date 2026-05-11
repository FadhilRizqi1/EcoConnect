import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../tasks/tasks_screen.dart' show dashboardRefreshNotifier;

/// Beranda — Premium Bento Box Dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _premiumActions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    dashboardRefreshNotifier.addListener(_onCheckinCompleted);
  }

  void _onCheckinCompleted() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    dashboardRefreshNotifier.removeListener(_onCheckinCompleted);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) { context.go('/masuk'); return; }

      final results = await Future.wait([
        ApiService.getProfil(userId),
        ApiService.getActions(),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final actions = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _profile = profile;
          
          final userCategoryStr = profile['profil']?['category']?.toString() ?? '';
          final userCategories = userCategoryStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          var allPremium = actions.where((a) => a['is_premium'] == true).toList();
          
          if (userCategories.isNotEmpty) {
            final matched = allPremium.where((a) => userCategories.contains(a['category'])).toList();
            final others = allPremium.where((a) => !userCategories.contains(a['category'])).toList();
            _premiumActions = [...matched, ...others];
          } else {
            _premiumActions = allPremium;
          }
          
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e, stack) {
      print('Dashboard error: $e\n$stack');
      if (mounted) setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5), // Light Mint background
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // Premium Header
            SliverAppBar(
              expandedHeight: 80,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'EcoConnect',
                style: TextStyle(color: Color(0xFF1A4D2E), fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
              ).animate().fade().slideY(begin: -0.2),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.logOut, color: Color(0xFF1A4D2E), size: 20),
                    tooltip: 'Keluar',
                    onPressed: () async {
                      await AuthService.logout();
                      if (mounted) context.go('/masuk');
                    },
                  ),
                ).animate().fade().scale(),
              ],
            ),

            // Body Content
            SliverToBoxAdapter(
              child: _loading
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                    )
                  : _error != null
                      ? _buildError()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // padding bottom for fab
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcomeHeader().animate().fade().slideX(),
                              const SizedBox(height: 32),
                              
                              const Text('Dampak Hijaumu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))).animate().fade(),
                              const SizedBox(height: 16),
                              _buildBentoGrid().animate().fade().scale(delay: const Duration(milliseconds: 100)),
                              
                              const SizedBox(height: 32),
                              
                              if (_premiumActions.isNotEmpty) ...[
                                const Text('Misi Premium Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))).animate().fade(),
                                const SizedBox(height: 16),
                                _buildVonRestorffCard(_premiumActions.first).animate().fade().slideY(delay: const Duration(milliseconds: 200)),
                                const SizedBox(height: 32),
                              ],
                              
                              const Text('Komunitas Diikuti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))).animate().fade(),
                              const SizedBox(height: 16),
                              _buildJoinedCommunities().animate().fade().slideX(delay: const Duration(milliseconds: 250)),
                              const SizedBox(height: 32),
                              
                              const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))).animate().fade(),
                              const SizedBox(height: 16),
                              _buildRecentActivity().animate().fade().slideY(delay: const Duration(milliseconds: 300)),
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
        mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final profil = _profile?['profil'] as Map<String, dynamic>? ?? {};
    final name = profil['name']?.toString() ?? 'Eco Warrior';
    final level = profil['level']?.toString() ?? 'Pemula';
    final points = (profil['reputation_points'] as num? ?? 0).toInt();

    // Calculate level progress
    double progress = 0.0;
    String nextLevel = 'Max';
    int pointsNeeded = 0;
    
    if (points < 100) {
      progress = points / 100;
      nextLevel = 'Pejuang Hijau';
      pointsNeeded = 100 - points;
    } else if (points < 500) {
      progress = (points - 100) / 400;
      nextLevel = 'Penjaga Alam';
      pointsNeeded = 500 - points;
    } else if (points < 1000) {
      progress = (points - 500) / 500;
      nextLevel = 'Pahlawan Bumi';
      pointsNeeded = 1000 - points;
    } else {
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bento style radius
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4FC87A), Color(0xFF1A4D2E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF4FC87A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Icon(LucideIcons.leaf, color: Colors.white, size: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $name!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1A4D2E).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                      child: Text(level, style: const TextStyle(fontSize: 11, color: Color(0xFF1A4D2E), fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Level Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progres Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: const Color(0xFF1A4D2E).withOpacity(0.7))),
              if (pointsNeeded > 0)
                Text('$pointsNeeded poin ke $nextLevel', style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1A4D2E).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC87A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid() {
    final profil = _profile?['profil'] as Map<String, dynamic>? ?? {};
    final carbon = (_profile?['total_karbon_kg'] as num? ?? profil['total_carbon_saved'] as num? ?? 0).toDouble();
    final tasks  = (_profile?['tugas_selesai'] as num? ?? 0).toInt();
    final points = (profil['reputation_points'] as num? ?? 0).toInt();

    return Row(
      children: [
        // Large Left Card (Carbon)
        Expanded(
          flex: 5,
          child: _StatCard(
            icon: LucideIcons.globe,
            title: 'Karbon Dihemat',
            value: '${carbon.toStringAsFixed(1)} kg',
            color: const Color(0xFF1A4D2E), // Deep Green
            large: true,
            tooltip: 'Total estimasi karbon dioksida yang berhasil dicegah berkat aksimu.',
          ),
        ),
        const SizedBox(width: 16),
        // Two Small Right Cards
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _StatCard(
                icon: LucideIcons.checkCircle,
                title: 'Total Aksi',
                value: '$tasks',
                color: const Color(0xFF1A73C8), // Trust Blue
                large: false,
                tooltip: 'Total aksi ramah lingkungan yang sudah kamu check-in.',
              ),
              const SizedBox(height: 16),
              _StatCard(
                icon: LucideIcons.star,
                title: 'Poin',
                value: '$points',
                color: AppColors.accentAmber,
                large: false,
                tooltip: 'Poin reputasi dari kontribusimu.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVonRestorffCard(Map<String, dynamic> action) {
    // Glassmorphism Premium Card
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB03A), AppColors.accentAmber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.accentAmber.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.flame, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text('PREMIUM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Poppins', letterSpacing: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(action['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Poppins', height: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.award, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('+${action['points']} Poin', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          const Icon(LucideIcons.wind, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('${action['carbon_value']} kg', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.play, color: AppColors.accentAmber),
                    onPressed: () => context.go('/tugas'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedCommunities() {
    final joined = _profile?['joined_communities'] as List<dynamic>? ?? [];

    if (joined.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A4D2E).withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1A4D2E).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(LucideIcons.users, color: Color(0xFF1A4D2E)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Belum Ada Komunitas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))),
                  const SizedBox(height: 4),
                  const Text('Ayo gabung komunitas!', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go('/komunitas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4D2E), 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Cari', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: joined.length,
        itemBuilder: (context, index) {
          final c = joined[index];
          return GestureDetector(
            onTap: () => context.go('/komunitas/${c['id']}'),
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF4FC87A).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.leaf, color: Color(0xFF4FC87A), size: 16),
                      ),
                      Row(
                        children: [
                          const Icon(LucideIcons.users, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${c['member_count']} Anggota', style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))),
                      const SizedBox(height: 4),
                      Text(c['category'], style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recent = _profile?['recent_activity'] as List<dynamic>? ?? [];

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: const Color(0xFF1A4D2E).withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(LucideIcons.inbox, color: Color(0xFF1A4D2E))),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Belum ada aktivitas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))),
                  SizedBox(height: 4),
                  Text('Tap tombol tengah untuk check-in aksi pertamamu!', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recent.map<Widget>((log) {
        final title = log['title']?.toString() ?? 'Aksi Hijau';
        final category = log['category']?.toString() ?? '';
        final points = (log['points_earned'] ?? log['impact_points'] ?? 0) as num;
        
        final iconData = {
          'Diet Vegan': LucideIcons.apple, 
          'Hemat Energi': LucideIcons.zap,
          'Transportasi Hijau': LucideIcons.bike, 
          'Kelola Sampah': LucideIcons.recycle, 
          'Hemat Air': LucideIcons.droplet,
        }[category] ?? LucideIcons.leaf;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4D2E).withOpacity(0.06), 
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Center(child: Icon(iconData, color: const Color(0xFF1A4D2E), size: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A4D2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(category, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC87A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('+${points.toInt()} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A4D2E), fontFamily: 'Poppins')),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool large;
  final String? tooltip;

  const _StatCard({super.key, required this.icon, required this.title, required this.value, required this.color, required this.large, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      triggerMode: TooltipTriggerMode.tap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D2E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12),
      child: Container(
        // Menyesuaikan tinggi agar card besar (184) dan dua card kecil (84*2 + jarak 16) persis sama (184 = 184)
        height: large ? 184 : 84,
        padding: EdgeInsets.all(large ? 20 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: large
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      Row(
                        children: [
                          if (tooltip != null) Icon(LucideIcons.info, color: color.withOpacity(0.4), size: 16),
                          const SizedBox(width: 6),
                          Icon(LucideIcons.arrowUpRight, color: color.withOpacity(0.3), size: 20),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins', height: 1.1)),
                      const SizedBox(height: 4),
                      Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins', height: 1.1)),
                        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (tooltip != null)
                    Icon(LucideIcons.info, color: color.withOpacity(0.3), size: 14),
                ],
              ),
      ),
    );
  }
}
