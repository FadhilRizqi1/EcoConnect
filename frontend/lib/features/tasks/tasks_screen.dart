import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

/// Global notifier — Tasks screen broadcasts this after a successful check-in
/// so Dashboard can listen and auto-refresh its stats. (Fix #2)
final dashboardRefreshNotifier = ValueNotifier<DateTime?>(null);

/// Layar Tugas — fetch dari /api/actions, check-in via showModalBottomSheet
/// Fitts's Law: tombol besar di bawah
/// Peak-End Rule: konfeti setelah check-in berhasil
/// Von Restorff: kartu amber untuk aksi premium
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
      final data = await ApiService.getActions(
        kategori: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
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
      builder: (sheetCtx) => _CheckInSheet(
        action: action,
        onSuccess: (result) {
          _confettiController.play();
          _loadActions();
          // Broadcast refresh event so Dashboard can update its stats
          dashboardRefreshNotifier.value = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 +${result['poin_didapat']} poin! ${result['pesan'] ?? 'Luar biasa!'}',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
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
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Aksi Hijau'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              tabs: _categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadActions, style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)), child: const Text('Coba Lagi')),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadActions,
                      child: _actions.isEmpty
                          ? const Center(child: Text('Belum ada aksi di kategori ini 🌱', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                              itemCount: _actions.length,
                              itemBuilder: (_, i) => _ActionCard(
                                action: _actions[i],
                                onTap: () => _openCheckinSheet(_actions[i]),
                              ),
                            ),
                    ),
        ),

        // Peak-End Rule: konfeti dari atas
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            shouldLoop: false,
            colors: const [Color(0xFF1B6B3A), Color(0xFF4FC87A), Color(0xFFFF8C00), Colors.white, Color(0xFF1A73C8)],
          ),
        ),
      ],
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPremium = action['is_premium'] == true;
    final categoryEmoji = _getEmoji(action['category'] ?? '');
    final points = action['points'] ?? 0;
    final carbon = (action['carbon_value'] as num?)?.toDouble() ?? 0.0;
    final unit = action['unit'] ?? 'kali';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: isPremium ? AppColors.amberGradient : null,
          color: isPremium ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isPremium ? AppColors.accentAmber : Colors.black).withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPremium ? Colors.white.withOpacity(0.25) : AppColors.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(categoryEmoji, style: const TextStyle(fontSize: 24))),
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
                            action['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              color: isPremium ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('PREMIUM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins', letterSpacing: 0.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action['description'] ?? '',
                      style: TextStyle(fontSize: 12, color: isPremium ? Colors.white70 : AppColors.textSecondary, fontFamily: 'Poppins'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _Badge(label: '+$points poin', isPremium: isPremium, icon: '⭐'),
                        _Badge(label: '${carbon.toStringAsFixed(2)} kg CO₂/$unit', isPremium: isPremium, icon: '🌱'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isPremium ? Colors.white70 : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String cat) => const {
    'Diet Vegan': '🥗',
    'Hemat Energi': '⚡',
    'Transportasi Hijau': '🚲',
    'Kelola Sampah': '♻️',
    'Hemat Air': '💧',
  }[cat] ?? '🌿';
}

class _Badge extends StatelessWidget {
  final String label;
  final bool isPremium;
  final String icon;
  const _Badge({required this.label, required this.isPremium, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPremium ? Colors.white.withOpacity(0.2) : AppColors.primaryGreenSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$icon $label',
        style: TextStyle(fontSize: 10, color: isPremium ? Colors.white : AppColors.primaryGreen, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    );
  }
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
  final _inputCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawVal = double.tryParse(_inputCtrl.text.replaceAll(',', '.'));
    if (rawVal == null || rawVal <= 0) {
      setState(() => _error = 'Masukkan angka yang valid (lebih dari 0)');
      return;
    }

    setState(() { _submitting = true; _error = null; });

    try {
      final result = await ApiService.checkIn(
        actionId: widget.action['id'],
        inputValue: rawVal,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // tutup sheet
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
    final inputVal = double.tryParse(_inputCtrl.text.replaceAll(',', '.')) ?? 1.0;
    final estimasiPoin = (points * inputVal).round();
    final estimasiKarbon = carbon * inputVal;

    // Fix 1: Wrap in SingleChildScrollView so keyboard never overflows
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // viewInsets.bottom pushes the sheet up when keyboard appears
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: isPremium ? AppColors.amberGradient : null,
                          color: isPremium ? null : AppColors.primaryGreenSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text(_getEmoji(action['category'] ?? ''), style: const TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(action['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary)),
                            Text(action['category'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Berapa $unit yang kamu lakukan?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _inputCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    autofocus: false,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      suffixText: unit,
                      suffixStyle: const TextStyle(fontSize: 16, color: AppColors.textMuted, fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: AppColors.primaryGreenSoft,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Estimasi real-time
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryGreenSoft, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          Text('⭐ $estimasiPoin', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, fontFamily: 'Poppins')),
                          const Text('Poin didapat', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        ]),
                        Container(width: 1, height: 36, color: AppColors.primaryGreenMint),
                        Column(children: [
                          Text('🌍 ${estimasiKarbon.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, fontFamily: 'Poppins')),
                          const Text('CO₂ dihemat', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Catatan opsional (Postel's Law)
                  TextField(
                    controller: _notesCtrl,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Catatan opsional... (misal: rute Sudirman)',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 13),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      backgroundColor: isPremium ? AppColors.accentAmber : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: isPremium ? 4 : 0,
                    ),
                    child: _submitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('✅ Konfirmasi Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(String cat) => const {
    'Diet Vegan': '🥗',
    'Hemat Energi': '⚡',
    'Transportasi Hijau': '🚲',
    'Kelola Sampah': '♻️',
    'Hemat Air': '💧',
  }[cat] ?? '🌿';
}
