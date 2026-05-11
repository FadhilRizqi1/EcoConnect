import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

/// Komunitas Hijau — Premium Network Imagery & Authentic Social Experience
class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  List<dynamic> _communities = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getCommunities(
        kategori: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      if (mounted) setState(() { _communities = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat komunitas'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Komunitas Hijau',
              style: TextStyle(color: Color(0xFF1A4D2E), fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
            ).animate().fade().slideY(begin: -0.2),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    _FilterChip(
                      label: 'Semua', 
                      icon: LucideIcons.layers, 
                      selected: _selectedCategory.isEmpty, 
                      onTap: () => _setCategory('')
                    ),
                    ...AppConstants.kategoriOnboarding.map((k) {
                      final catName = k['nama']!;
                      return _FilterChip(
                        label: catName, 
                        icon: _getIconForCategory(catName), 
                        selected: _selectedCategory == catName, 
                        onTap: () => _setCategory(catName)
                      );
                    }),
                  ],
                ),
              ).animate().fade(delay: const Duration(milliseconds: 200)).slideX(),
            ),
          ),

          // Content List
          SliverToBoxAdapter(
            child: _loading
                ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)))
                : _error != null
                    ? _buildError()
                    : _communities.isEmpty
                        ? const _EmptyView()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            child: Column(
                              children: _communities.asMap().entries.map((e) {
                                final delay = e.key * 100;
                                return _CommunityCard(
                                  community: e.value,
                                  onTap: () => context.go('/komunitas/${e.value['id']}'),
                                  onJoin: () => _toggleJoin(e.value['id']),
                                ).animate().fade(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _setCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _loadCommunities();
  }

  Future<void> _toggleJoin(int id) async {
    try {
      final res = await ApiService.toggleJoinCommunity(id);
      final isJoined = res['is_joined'];
      setState(() {
        final index = _communities.indexWhere((c) => c['id'] == id);
        if (index != -1) {
          _communities[index]['is_joined'] = isJoined;
          if (isJoined) {
            _communities[index]['member_count'] = (_communities[index]['member_count'] ?? 0) + 1;
          } else {
            _communities[index]['member_count'] = (_communities[index]['member_count'] ?? 1) - 1;
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['pesan'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)), backgroundColor: const Color(0xFF1A4D2E), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
    }
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
            onPressed: _loadCommunities,
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  
  const _FilterChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A4D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? [BoxShadow(color: const Color(0xFF1A4D2E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : const Color(0xFF1A4D2E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF1A4D2E),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  const _CommunityCard({required this.community, required this.onTap, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final String category = community['category'] ?? '';
    final String bgUrl = _getNetworkImageForCategory(category);
    // Authentic data: Default to 0 if null, no fake inflations
    final int memberCount = community['member_count'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dynamic Premium Network Image
              CachedNetworkImage(
                imageUrl: bgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: const Color(0xFFE8F0EA)),
                errorWidget: (context, url, error) => Container(color: const Color(0xFFE8F0EA)),
              ),
              
              // Dark Gradient Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Category Badge
                    Align(
                      alignment: Alignment.topRight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getIconForCategory(category), color: Colors.white, size: 12),
                                const SizedBox(width: 6),
                                Text(
                                  category,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom: Title & Member Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.users, color: Colors.white70, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '$memberCount Anggota Resmi', // Authentic member count
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: onJoin,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: community['is_joined'] == true ? Colors.transparent : AppColors.primaryGreen,
                                  border: community['is_joined'] == true ? Border.all(color: Colors.white.withOpacity(0.5)) : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  community['is_joined'] == true ? 'Tergabung' : 'Gabung',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A4D2E).withOpacity(0.06), shape: BoxShape.circle),
          child: const Icon(LucideIcons.leaf, size: 48, color: Color(0xFF1A4D2E)),
        ).animate().fade().scale(),
        const SizedBox(height: 24),
        const Text('Belum ada komunitas', style: TextStyle(color: Color(0xFF1A4D2E), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        const Text('Jadilah yang pertama untuk bergabung\natau membuat komunitas baru!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
      ],
    ),
  );
}

// Helper methods for Premium Design Assets

IconData _getIconForCategory(String category) {
  const map = {
    'Diet Vegan': LucideIcons.apple,
    'Hemat Energi': LucideIcons.zap,
    'Transportasi Hijau': LucideIcons.bike,
    'Kelola Sampah': LucideIcons.recycle,
    'Hemat Air': LucideIcons.droplet,
  };
  return map[category] ?? LucideIcons.leaf;
}

String _getNetworkImageForCategory(String category) {
  const map = {
    'Diet Vegan': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1080&auto=format&fit=crop', // Salad/Fresh food
    'Hemat Energi': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=1080&auto=format&fit=crop', // Lightbulbs/Energy
    'Transportasi Hijau': 'https://images.unsplash.com/photo-1519003300449-424ad0405076?q=80&w=1080&auto=format&fit=crop', // Bicycles in nature
    'Kelola Sampah': 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?q=80&w=1080&auto=format&fit=crop', // Recycling/Nature
    'Hemat Air': 'https://images.unsplash.com/photo-1437622368342-7a3d73a34c8f?q=80&w=1080&auto=format&fit=crop', // Clean water/river
  };
  return map[category] ?? 'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=1080&auto=format&fit=crop'; // Default forest
}
