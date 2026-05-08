import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

/// Layar daftar komunitas — mengambil data dari /api/communities
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Komunitas Hijau')),
      body: Column(
        children: [
          // Filter kategori (Hick's Law)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _FilterChip(label: 'Semua', selected: _selectedCategory.isEmpty, onTap: () => _setCategory('')),
                ...AppConstants.kategoriOnboarding.map((k) =>
                  _FilterChip(label: '${k['emoji']} ${k['nama']}', selected: _selectedCategory == k['nama'], onTap: () => _setCategory(k['nama']!)),
                ),
              ],
            ),
          ),

          // Isi
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _error != null
                    ? _ErrorView(message: _error!, onRetry: _loadCommunities)
                    : _communities.isEmpty
                        ? const _EmptyView()
                        : RefreshIndicator(
                            onRefresh: _loadCommunities,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _communities.length,
                              itemBuilder: (_, i) => _CommunityCard(
                                community: _communities[i],
                                onTap: () => context.go('/komunitas/${_communities[i]['id']}'),
                              ),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.textMuted.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;
  final VoidCallback onTap;
  const _CommunityCard({required this.community, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryEmoji = _getEmoji(community['category'] ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: AppColors.primaryGreenSoft, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(categoryEmoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(community['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(community['description'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins'), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.primaryGreenMint),
                        const SizedBox(width: 4),
                        Text('${community['member_count']} anggota', style: const TextStyle(fontSize: 11, color: AppColors.primaryGreenMint, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String category) {
    const map = {
      'Diet Vegan': '🥗',
      'Hemat Energi': '⚡',
      'Transportasi Hijau': '🚲',
      'Kelola Sampah': '♻️',
      'Hemat Air': '💧',
    };
    return map[category] ?? '🌿';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('🌱', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text('Belum ada komunitas di kategori ini', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)), child: const Text('Coba Lagi')),
      ],
    ),
  );
}
