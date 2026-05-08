import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

/// Beranda — menampilkan dashboard real dari backend
/// Von Restorff: Amber card untuk misi premium
/// Bento Grid: 3 stat cards
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
          _premiumActions = actions.where((a) => a['is_premium'] == true).toList();
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat data'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('EcoConnect 🌿'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () async {
              await AuthService.logout();
              if (mounted) context.go('/masuk');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryGreen,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : _error != null
                ? ListView(children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)), child: const Text('Coba Lagi')),
                    ])),
                  ])
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      const Text('Dampak Hijaumu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      _buildBentoGrid(),
                      const SizedBox(height: 28),
                      if (_premiumActions.isNotEmpty) ...[
                        const Text('Misi Premium Hari Ini 🔥', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                        const SizedBox(height: 14),
                        _buildVonRestorffCard(_premiumActions.first),
                        const SizedBox(height: 28),
                      ],
                      const Text('Mulai Dari Sini', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      _buildQuickActionRow(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final profil = _profile?['profil'] as Map<String, dynamic>? ?? {};
    final name = profil['name']?.toString() ?? 'Eco Warrior';
    final level = profil['level']?.toString() ?? 'Pemula';

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $name! 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryGreenSoft, borderRadius: BorderRadius.circular(10)),
                child: Text(level, style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
          onPressed: () async {
            final id = await AuthService.getUserId();
            if (id != null && mounted) context.go('/profil/$id');
          },
        ),
      ],
    );
  }

  Widget _buildBentoGrid() {
    final profil = _profile?['profil'] as Map<String, dynamic>? ?? {};
    final carbon = (_profile?['total_karbon_kg'] as num? ?? profil['total_carbon_saved'] as num? ?? 0).toDouble();
    final tasks  = (_profile?['tugas_selesai'] as num? ?? 0).toInt();
    final points = (profil['reputation_points'] as num? ?? 0).toInt();

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _StatCard(
            icon: '🌍',
            title: 'Karbon Dihemat',
            value: '${carbon.toStringAsFixed(1)} kg',
            color: AppColors.primaryGreen,
            large: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _StatCard(
                icon: '✅',
                title: 'Aksi',
                value: '$tasks',
                color: AppColors.primaryBlueMid,
                large: false,
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: '⭐',
                title: 'Poin',
                value: '$points',
                color: AppColors.accentAmber,
                large: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVonRestorffCard(Map<String, dynamic> action) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.amberGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.accentAmber.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏆 Misi Premium', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins')),
                const SizedBox(height: 6),
                Text(action['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text('+${action['points']} Poin • ${action['carbon_value']} kg CO₂', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go('/tugas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accentAmber,
              minimumSize: const Size(72, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Mulai', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow() {
    return Row(
      children: [
        _QuickAction(icon: '✅', label: 'Check-in Aksi', color: AppColors.primaryGreen, onTap: () => context.go('/tugas')),
        const SizedBox(width: 12),
        _QuickAction(icon: '👥', label: 'Komunitas', color: AppColors.primaryBlueMid, onTap: () => context.go('/komunitas')),
        const SizedBox(width: 12),
        _QuickAction(icon: '🏆', label: 'Peringkat', color: AppColors.accentAmber, onTap: () => context.go('/papan-peringkat')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final Color color;
  final bool large;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color, required this.large});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: large ? 150 : 69,
      padding: EdgeInsets.all(large ? 18 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: large
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins'))),
                ]),
                Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
              ],
            )
          : Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
                      Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins'), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
