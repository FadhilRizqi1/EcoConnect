import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'activity_history_screen.dart';

final dashboardRefreshNotifier = ValueNotifier<DateTime?>(null);

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _actions = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = '';
  late TabController _tabController;
  late ConfettiController _confettiController;

  static const _categories = ['Semua', 'Diet Vegan', 'Transportasi Hijau', 'Hemat Energi', 'Kelola Sampah', 'Hemat Air'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadActions();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final cat = _categories[_tabController.index];
        setState(() => _selectedCategory = cat == 'Semua' ? '' : cat);
        _loadActions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadActions() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getActions(kategori: _selectedCategory.isEmpty ? null : _selectedCategory);
      if (mounted) setState(() { _actions = data; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal memuat aksi'; _loading = false; });
    }
  }

  void _openCheckinSheet(Map<String, dynamic> action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => _CheckInSheet(
        action: action,
        onSuccess: (result) {
          _confettiController.play();
          _loadActions();
          dashboardRefreshNotifier.value = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+${result['poin_didapat']} poin! ${result['pesan'] ?? 'Luar biasa!'}',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.primaryGreenMint,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text('Aksi Hijau', style: TextStyle(color: Color(0xFF1A4D2E), fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.history, color: Color(0xFF1A4D2E)),
                tooltip: 'Riwayat Aktivitas',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityHistoryScreen())),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              tabs: _categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.wifiOff, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadActions,
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins')),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                      ),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadActions,
                      color: AppColors.primaryGreen,
                      child: _actions.isEmpty
                          ? const Center(child: Text('Belum ada aksi di kategori ini', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: _actions.length,
                              itemBuilder: (_, i) => _ActionCard(
                                action: _actions[i],
                                onTap: () => _openCheckinSheet(_actions[i]),
                              ).animate().fade(delay: Duration(milliseconds: i * 40)).slideY(begin: 0.05),
                            ),
                    ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 50,
            shouldLoop: false,
            colors: const [Color(0xFF1B6B3A), Color(0xFF4FC87A), Color(0xFFFF8C00), Colors.white, Color(0xFF1A73C8)],
          ),
        ),
      ],
    );
  }
}

// ── Action Card ─────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  static IconData _iconFor(String cat) => {
    'Diet Vegan': LucideIcons.apple,
    'Hemat Energi': LucideIcons.zap,
    'Transportasi Hijau': LucideIcons.bike,
    'Kelola Sampah': LucideIcons.recycle,
    'Hemat Air': LucideIcons.droplet,
  }[cat] ?? LucideIcons.leaf;

  @override
  Widget build(BuildContext context) {
    final isPremium = action['is_premium'] == true;
    final points = action['points'] ?? 0;
    final carbon = (action['carbon_value'] as num?)?.toDouble() ?? 0.0;
    final unit = action['unit'] ?? 'kali';
    final cat = action['category'] ?? '';
    final icon = _iconFor(cat);

    if (isPremium) {
      // ── PREMIUM CARD ─────────────────────────────────────────────
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1200), Color(0xFF4A2800), Color(0xFFCC6D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.accentAmber.withOpacity(0.45), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 10)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Golden icon container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.accentAmber.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.accentAmber.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.flame, color: AppColors.accentAmber, size: 12),
                                SizedBox(width: 5),
                                Text('PREMIUM MISSION', style: TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.w800, fontSize: 9, fontFamily: 'Poppins', letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(action['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, fontFamily: 'Poppins', height: 1.2)),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(action['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins', height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _PremiumBadge(icon: LucideIcons.star, label: '+$points Poin'),
                    const SizedBox(width: 10),
                    _PremiumBadge(icon: LucideIcons.wind, label: '${carbon.toStringAsFixed(2)} kg CO₂/$unit'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── REGULAR CARD ─────────────────────────────────────────────────
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF0F4F1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: AppColors.primaryGreenSoft, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action['title'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins', color: Color(0xFF1A2E1E))),
                    const SizedBox(height: 4),
                    Text(action['description'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _RegularBadge(icon: LucideIcons.award, label: '+$points pts'),
                        _RegularBadge(icon: LucideIcons.leaf, label: '${carbon.toStringAsFixed(2)} kg/$unit'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PremiumBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppColors.accentAmber, size: 12),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
    ]),
  );
}

class _RegularBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RegularBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.primaryGreenSoft, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppColors.primaryGreen, size: 11),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Check-in Bottom Sheet ─────────────────────────────────────────────────────

class _CheckInSheet extends StatefulWidget {
  final Map<String, dynamic> action;
  final Function(Map<String, dynamic>) onSuccess;
  const _CheckInSheet({required this.action, required this.onSuccess});
  @override
  State<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<_CheckInSheet> {
  double _inputValue = 1.0;
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  static IconData _iconFor(String cat) => {
    'Diet Vegan': LucideIcons.apple,
    'Hemat Energi': LucideIcons.zap,
    'Transportasi Hijau': LucideIcons.bike,
    'Kelola Sampah': LucideIcons.recycle,
    'Hemat Air': LucideIcons.droplet,
  }[cat] ?? LucideIcons.leaf;

  Future<void> _submit() async {
    if (_inputValue <= 0) {
      setState(() => _error = 'Jumlah harus lebih dari 0');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final result = await ApiService.checkIn(
        actionId: widget.action['id'],
        inputValue: _inputValue,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess(result);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _submitting = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Gagal mengirim check-in'; _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final isPremium = action['is_premium'] == true;
    final unit = action['unit'] ?? 'kali';
    final points = action['points'] ?? 0;
    final carbon = (action['carbon_value'] as num?)?.toDouble() ?? 0.0;
    final cat = action['category']?.toString() ?? '';
    final estimasiPoin = (points * _inputValue).round();
    final estimasiKarbon = carbon * _inputValue;

    final headerGradient = isPremium
        ? const LinearGradient(colors: [Color(0xFF1A1200), Color(0xFFCC6D00)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFF1A4D2E), Color(0xFF2D9653)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    final accentColor = isPremium ? AppColors.accentAmber : AppColors.primaryGreen;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colored header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(gradient: headerGradient, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                        child: Icon(_iconFor(cat), color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isPremium)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.accentAmber.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                                child: const Text('★ PREMIUM MISSION', style: TextStyle(color: AppColors.accentAmber, fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'Poppins', letterSpacing: 1)),
                              ),
                            Text(action['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, fontFamily: 'Poppins', height: 1.2)),
                            const SizedBox(height: 4),
                            Text(cat, style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Berapa $unit yang kamu lakukan?', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A2E1E))),
                  const SizedBox(height: 14),

                  // Stepper input (Fitts's Law)
                  Row(
                    children: [
                      _StepButton(icon: LucideIcons.minus, color: accentColor, onTap: () => setState(() => _inputValue = (_inputValue - 1).clamp(1, 9999))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _inputValue % 1 == 0 ? _inputValue.toInt().toString() : _inputValue.toStringAsFixed(1),
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accentColor, fontFamily: 'Poppins'),
                                textAlign: TextAlign.center,
                              ),
                              Text(unit, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StepButton(icon: LucideIcons.plus, color: accentColor, onTap: () => setState(() => _inputValue += 1)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Real-time estimate
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _EstimateCol(icon: LucideIcons.star, label: 'Poin Didapat', value: '+$estimasiPoin', color: AppColors.accentAmber)),
                        Container(width: 1, height: 40, color: accentColor.withOpacity(0.2)),
                        Expanded(child: _EstimateCol(icon: LucideIcons.wind, label: 'CO₂ Dihemat', value: '${estimasiKarbon.toStringAsFixed(2)} kg', color: const Color(0xFF1A73C8))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesCtrl,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF1A1A1A)),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Catatan (opsional) — contoh: "Naik sepeda ke kantor"',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF4F7F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentColor, width: 1.5)),
                      prefixIcon: Icon(LucideIcons.messageSquare, size: 18, color: AppColors.textMuted),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontSize: 13)),
                  ],

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: isPremium ? 6 : 2,
                    ),
                   child: _submitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.checkCircle, size: 20),
                                SizedBox(width: 10),
                                Text('Konfirmasi Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Icon(icon, color: color, size: 22),
    ),
  );
}

class _EstimateCol extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _EstimateCol({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
    ],
  );
}
