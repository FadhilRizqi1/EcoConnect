import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

/// Layar Riwayat Aktivitas — Semua check-in historis pengguna
/// Miller's Law: 30 item per halaman
/// Hick's Law: filter per kategori via chip baris atas
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<dynamic> _allLogs = [];
  List<dynamic> _filteredLogs = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';
  int _totalPoin = 0;
  double _totalKarbon = 0;
  int _totalCheckins = 0;

  static const _categories = ['Semua', 'Diet Vegan', 'Transportasi Hijau', 'Hemat Energi', 'Kelola Sampah', 'Hemat Air'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getRiwayat();
      final logs = data['riwayat'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _allLogs = logs;
          _totalPoin = (data['total_poin'] as num? ?? 0).toInt();
          _totalKarbon = (data['total_karbon'] as num? ?? 0).toDouble();
          _totalCheckins = (data['total_checkins'] as num? ?? 0).toInt();
          _applyFilter(_selectedFilter);
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat riwayat'; _loading = false; });
    }
  }

  void _applyFilter(String cat) {
    _selectedFilter = cat;
    if (cat == 'Semua') {
      _filteredLogs = List.from(_allLogs);
    } else {
      _filteredLogs = _allLogs.where((l) => l['category'] == cat).toList();
    }
  }

  IconData _iconFor(String cat) => {
    'Diet Vegan': LucideIcons.apple,
    'Hemat Energi': LucideIcons.zap,
    'Transportasi Hijau': LucideIcons.bike,
    'Kelola Sampah': LucideIcons.recycle,
    'Hemat Air': LucideIcons.droplet,
  }[cat] ?? LucideIcons.leaf;

  Color _colorFor(String cat) => {
    'Diet Vegan': const Color(0xFF4CAF50),
    'Hemat Energi': const Color(0xFFFF8C00),
    'Transportasi Hijau': const Color(0xFF1A73C8),
    'Kelola Sampah': const Color(0xFF7B61FF),
    'Hemat Air': const Color(0xFF00BCD4),
  }[cat] ?? AppColors.primaryGreen;

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("d MMM yyyy · HH:mm", 'id').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1A4D2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Aktivitas',
          style: TextStyle(color: Color(0xFF1A4D2E), fontWeight: FontWeight.w800, fontFamily: 'Poppins', fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF1A4D2E), size: 20),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primaryGreen,
                  child: CustomScrollView(
                    slivers: [
                      // Summary stats
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: _buildSummaryHeader(),
                        ).animate().fade().slideY(begin: -0.1),
                      ),
                      // Filter chips
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                          child: _buildFilterChips(),
                        ).animate().fade(delay: 100.ms),
                      ),
                      // Section label
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                '${_filteredLogs.length} Aktivitas',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Poppins'),
                              ),
                              if (_selectedFilter != 'Semua') ...[
                                const SizedBox(width: 6),
                                Text('· $_selectedFilter', style: TextStyle(fontSize: 13, color: _colorFor(_selectedFilter), fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Log list
                      _filteredLogs.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmpty(),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => _buildLogItem(_filteredLogs[i], i),
                                  childCount: _filteredLogs.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4D2E), Color(0xFF2D9653)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A4D2E).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.barChart2, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Ringkasan Dampakmu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _SummaryTile(icon: LucideIcons.checkCircle, label: 'Check-in', value: '$_totalCheckins×')),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              Expanded(child: _SummaryTile(icon: LucideIcons.star, label: 'Total Poin', value: '$_totalPoin')),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              Expanded(child: _SummaryTile(icon: LucideIcons.wind, label: 'CO₂ Hemat', value: '${_totalKarbon.toStringAsFixed(1)}kg')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedFilter == cat;
          return GestureDetector(
            onTap: () => setState(() => _applyFilter(cat)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A4D2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                border: Border.all(color: isSelected ? const Color(0xFF1A4D2E) : Colors.transparent),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log, int index) {
    final cat = log['category']?.toString() ?? '';
    final isPremium = log['is_premium'] == true;
    final points = (log['points_earned'] as num? ?? 0).toInt();
    final carbon = (log['carbon_saved'] as num? ?? 0).toDouble();
    final notes = log['notes']?.toString() ?? '';
    final inputVal = (log['input_value'] as num? ?? 0).toDouble();
    final unit = log['unit']?.toString() ?? '';
    final catColor = _colorFor(cat);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPremium ? Border.all(color: AppColors.accentAmber.withOpacity(0.4), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPremium ? AppColors.accentAmber.withOpacity(0.12) : catColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(_iconFor(cat), color: isPremium ? AppColors.accentAmber : catColor, size: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log['title']?.toString() ?? 'Aksi Hijau',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A2E1E)),
                        ),
                      ),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accentAmber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: const Text('★ PREMIUM', style: TextStyle(fontSize: 9, color: AppColors.accentAmber, fontWeight: FontWeight.w800, fontFamily: 'Poppins', letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${inputVal % 1 == 0 ? inputVal.toInt() : inputVal} $unit · ${_formatDate(log['created_at']?.toString())}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniStat(icon: LucideIcons.star, label: '+$points pts', color: AppColors.accentAmber),
                      const SizedBox(width: 8),
                      _MiniStat(icon: LucideIcons.wind, label: '${carbon.toStringAsFixed(2)} kg CO₂', color: const Color(0xFF1A73C8)),
                    ],
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.messageSquare, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notes,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins', fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: index * 30)).slideY(begin: 0.05);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryGreenSoft, shape: BoxShape.circle),
            child: const Icon(LucideIcons.inbox, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Semua' ? 'Belum ada aktivitas' : 'Belum ada aktivitas $_selectedFilter',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A4D2E), fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          const Text('Lakukan check-in pertamamu!', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.wifiOff, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins')),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'Poppins')),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniStat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
