import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _selectedCategory = '';

  final List<String> _categories = [
    'Diet Vegan',
    'Hemat Energi',
    'Transportasi Hijau',
    'Kelola Sampah',
    'Hemat Air'
  ];

  final List<String> _avatars = [
    // Avataaars style
    'https://api.dicebear.com/9.x/avataaars/png?seed=Felix&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/avataaars/png?seed=Aneka&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/avataaars/png?seed=Jude&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/avataaars/png?seed=Leo&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/avataaars/png?seed=Avery&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/avataaars/png?seed=Brian&backgroundColor=e8f3eb',
    // Fun Emoji style
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=Daisy&backgroundColor=d1f4e0',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=Storm&backgroundColor=d1f4e0',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=Coco&backgroundColor=d1f4e0',
    // Adventurer style
    'https://api.dicebear.com/9.x/adventurer/png?seed=Milo&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Zara&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Nova&backgroundColor=e8f3eb',
    // Lorelei style
    'https://api.dicebear.com/9.x/lorelei/png?seed=Willow&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/lorelei/png?seed=River&backgroundColor=e8f3eb',
    'https://api.dicebear.com/9.x/lorelei/png?seed=Sage&backgroundColor=e8f3eb',
    // Notionists style
    'https://api.dicebear.com/9.x/notionists/png?seed=Fern&backgroundColor=d1f4e0',
    'https://api.dicebear.com/9.x/notionists/png?seed=Ivy&backgroundColor=d1f4e0',
    'https://api.dicebear.com/9.x/notionists/png?seed=Moss&backgroundColor=d1f4e0',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _myId = await AuthService.getUserId();
    try {
      final targetId = widget.userId == 0 ? _myId! : widget.userId;
      final data = await ApiService.getProfil(targetId);
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;

          // Pre-fill controllers
          final profil = data['profil'] as Map<String, dynamic>? ?? {};
          _nameCtrl.text = profil['name']?.toString() ?? '';
          _bioCtrl.text = profil['bio']?.toString() ?? '';
          _selectedCategory = profil['category']?.toString() ?? '';
          if (!_categories.contains(_selectedCategory) &&
              _selectedCategory.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted)
        setState(() {
          _error = e.message;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Gagal memuat profil';
          _loading = false;
        });
    }
  }

  void _showChangeAvatarSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Pilih Foto Profil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: isDark
                            ? AppColors.textOnDark
                            : const Color(0xFF1A4D2E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final url = _avatars[index];
                        return GestureDetector(
                          onTap: () async {
                            Navigator.pop(ctx);
                            setState(() => _loading = true);
                            try {
                              await ApiService.updateProfile({'avatar': url});
                              _load();
                            } catch (e) {
                              setState(() => _loading = false);
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Gagal mengubah foto profil',
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.white)),
                                        backgroundColor: Colors.redAccent));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : const Color(0xFFE8F3EB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFD0E8D7),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: isDark
                                              ? AppColors.primaryGreenMint
                                              : AppColors.primaryGreen)),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(LucideIcons.userCircle,
                                        size: 32, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            bool isSaving = false;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetColor = isDark ? AppColors.surfaceDark : Colors.white;
            final fieldColor =
                isDark ? AppColors.cardDark : const Color(0xFFF0F4F1);
            final primaryTextColor =
                isDark ? AppColors.textOnDark : const Color(0xFF1A4D2E);
            final labelColor =
                isDark ? AppColors.primaryGreenMint : const Color(0xFF2D5A3E);
            final hintColor =
                isDark ? AppColors.textMuted : const Color(0xFF888888);
            final borderColor = isDark ? Colors.white12 : Colors.transparent;

            Future<void> saveProfile() async {
              setModalState(() => isSaving = true);
              try {
                await ApiService.updateProfile({
                  'name': _nameCtrl.text.trim(),
                  'bio': _bioCtrl.text.trim(),
                  'category': _selectedCategory,
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Profil berhasil diperbarui',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.white)),
                      backgroundColor: Color(0xFF1A4D2E)));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal menyimpan profil',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.white)),
                      backgroundColor: Colors.redAccent));
                }
              } finally {
                if (mounted) setModalState(() => isSaving = false);
              }
            }

            return Container(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Edit Profil',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 24),
                    Text('Nama Lengkap',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: primaryTextColor,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        hintStyle: TextStyle(
                            color: hintColor,
                            fontFamily: 'Poppins',
                            fontSize: 14),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.primaryGreenMint
                                    : Theme.of(context).primaryColor,
                                width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Bio Singkat',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: primaryTextColor,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Ceritakan sedikit tentang dirimu...',
                        hintStyle: TextStyle(
                            color: hintColor,
                            fontFamily: 'Poppins',
                            fontSize: 14),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.primaryGreenMint
                                    : Theme.of(context).primaryColor,
                                width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Fokus Utama',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                            fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory.isEmpty
                              ? null
                              : _selectedCategory,
                          isExpanded: true,
                          dropdownColor: fieldColor,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: primaryTextColor,
                              fontWeight: FontWeight.w500),
                          hint: Text('Pilih Fokus',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: hintColor)),
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: labelColor),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: primaryTextColor))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              setModalState(() => _selectedCategory = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Perubahan',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins')),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen)));
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.wifiOff, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Coba Lagi',
                  style: TextStyle(fontFamily: 'Poppins'))),
        ])),
      );
    }

    final profil = _data?['profil'] as Map<String, dynamic>? ?? {};
    final name = profil['name']?.toString() ?? 'Pengguna';
    final bio = profil['bio']?.toString() ?? '';
    final level = profil['level']?.toString() ?? 'Pemula';
    final cat = profil['category']?.toString() ?? '';
    final avatar = profil['avatar']?.toString() ?? '';
    final isMe = _myId == widget.userId || widget.userId == 0;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Dynamic background
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Image
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F301C), // Deep forest green
                    Color(0xFF1A4D2E), // Primary green
                    Color(0xFF2D9653), // Medium green
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Abstract decorative shapes
                  Positioned(
                    top: -50,
                    right: -20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 40,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFB03A)
                            .withOpacity(0.1), // Subtle gold accent
                      ),
                    ),
                  ),
                  // Bottom gradient for smooth transition
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.25)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Container overlapping cover
            Container(
              margin: const EdgeInsets.only(top: 260),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: Column(
                  children: [
                    // Identity Card overlapping container
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // The Card Background
                        Container(
                          margin: const EdgeInsets.only(top: 40),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0
                                          : 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(name,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color ??
                                          const Color(0xFF1A4D2E),
                                      fontFamily: 'Poppins')),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF1A4D2E).withOpacity(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0.3
                                            : 0.06),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.award,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.primaryGreenMint
                                            : const Color(0xFF1A4D2E),
                                        size: 14),
                                    const SizedBox(width: 6),
                                    Text('$level • $cat',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? AppColors.primaryGreenMint
                                                    : const Color(0xFF1A4D2E),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            fontFamily: 'Poppins')),
                                  ],
                                ),
                              ),
                              if (bio.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  bio,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'Poppins',
                                      height: 1.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // The Avatar
                        Positioned(
                          top: 0,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F3EB),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ],
                                  image: avatar.isNotEmpty
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              avatar),
                                          fit: BoxFit.cover)
                                      : null,
                                ),
                                child: avatar.isEmpty
                                    ? Center(
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.color ??
                                                  const Color(0xFF1A4D2E),
                                              fontFamily: 'Poppins'),
                                        ),
                                      )
                                    : null,
                              ),
                              if (isMe)
                                GestureDetector(
                                  onTap: _showChangeAvatarSheet,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 3),
                                    ),
                                    child: const Icon(LucideIcons.camera,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildStats(),

                    const SizedBox(height: 24),
                    _buildImpactChart(),

                    const SizedBox(height: 32),
                    _buildBadges(),

                    const SizedBox(height: 32),
                    _buildPremiumMenu(isMe),
                  ],
                ),
              ),
            ),

            // Top Actions
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    context.canPop()
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(LucideIcons.arrowLeft,
                                  color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                          )
                        : const SizedBox.shrink(),
                    isMe
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(LucideIcons.logOut,
                                  color: Colors.white),
                              onPressed: () async {
                                await AuthService.logout();
                                if (mounted) context.go('/masuk');
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final profil = _data?['profil'] as Map<String, dynamic>? ?? {};
    final points = (profil['reputation_points'] as num? ?? 0).toInt();
    final carbon = (_data?['total_karbon_kg'] as num? ??
            profil['total_carbon_saved'] as num? ??
            0.0)
        .toDouble();
    final tasks = (_data?['tugas_selesai'] as num? ?? 0).toInt();

    return Row(
      children: [
        Expanded(
            child: _StatTile(
                label: 'Total Poin',
                value: '$points',
                icon: LucideIcons.star,
                iconColor: AppColors.accentAmber,
                bgColor: AppColors.accentAmberSoft)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatTile(
                label: 'Total Aksi',
                value: '$tasks',
                icon: LucideIcons.checkCircle2,
                iconColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF))),
        const SizedBox(width: 12),
        Expanded(
            child: _StatTile(
                label: 'CO₂ Hemat',
                value: carbon.toStringAsFixed(1),
                icon: LucideIcons.leaf,
                iconColor: const Color(0xFF4FC87A),
                bgColor: const Color(0xFFE8F3EB))),
      ],
    );
  }

  Widget _buildImpactChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.primaryGreenMint : const Color(0xFF1A4D2E);

    final weeklyImpactList = _data?['weekly_impact'] as List<dynamic>? ?? [];
    final spots = <FlSpot>[];
    double maxImpact = 1.0;
    for (int i = 0; i < 7; i++) {
      double val = (weeklyImpactList.length > i)
          ? (weeklyImpactList[i] as num).toDouble()
          : 0.0;
      if (val > maxImpact) maxImpact = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0 : 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trendingUp, color: primaryTextColor, size: 20),
              const SizedBox(width: 8),
              Text('Dampak 7 Hari Terakhir',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: primaryTextColor)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Sen',
                          'Sel',
                          'Rab',
                          'Kam',
                          'Jum',
                          'Sab',
                          'Min'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()],
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxImpact * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primaryGreenMint,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreenMint
                              .withOpacity(isDark ? 0.5 : 0.3),
                          AppColors.primaryGreenMint.withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    final profil = _data?['profil'] as Map<String, dynamic>? ?? {};
    final badges = profil['badges'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.medal,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    const Color(0xFF1A4D2E),
                size: 20),
            const SizedBox(width: 8),
            Text('Lencana Prestasi',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).textTheme.titleLarge?.color ??
                        const Color(0xFF1A4D2E))),
          ],
        ),
        const SizedBox(height: 16),
        badges.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0
                                  : 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: const Column(
                  children: [
                    Icon(LucideIcons.sprout,
                        color: AppColors.textMuted, size: 40),
                    SizedBox(height: 12),
                    Text('Selesaikan aksi pertamamu untuk mendapatkan lencana!',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                            fontSize: 13),
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
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
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0
                                      : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            badge['icon_url']?.isNotEmpty == true
                                ? badge['icon_url']
                                : '🏅',
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(badge['name'] ?? '',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color ??
                                    const Color(0xFF1A4D2E)),
                            textAlign: TextAlign.center,
                            maxLines: 2),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPremiumMenu(bool isMe) {
    if (!isMe) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0 : 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(LucideIcons.userCircle, 'Informasi Pribadi', true,
              _showEditProfileSheet),
          Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xFFF0F0F0)),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black26
                          : const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(LucideIcons.moon,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.primaryGreenMint
                          : const Color(0xFF1A4D2E),
                      size: 20),
                ),
                title: Text('Mode Gelap',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color ??
                            const Color(0xFF1A4D2E))),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                  activeColor: AppColors.primaryGreen,
                ),
                onTap: () =>
                    themeProvider.toggleTheme(!themeProvider.isDarkMode),
              );
            },
          ),
          Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xFFF0F0F0)),
          _buildMenuTile(LucideIcons.bell, 'Notifikasi', true,
              () => _showMsg('Belum ada notifikasi baru.')),
          Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xFFF0F0F0)),
          _buildMenuTile(LucideIcons.shieldCheck, 'Privasi & Keamanan', true,
              () => context.push('/privasi')),
          Divider(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xFFF0F0F0)),
          _buildMenuTile(LucideIcons.helpCircle, 'Pusat Bantuan', true,
              () => context.push('/bantuan')),
        ],
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      backgroundColor: const Color(0xFF1A4D2E),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _buildMenuTile(
      IconData icon, String title, bool hasArrow, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isDark ? Colors.black26 : const Color(0xFFF5F7F5),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon,
            color:
                isDark ? AppColors.primaryGreenMint : const Color(0xFF1A4D2E),
            size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color ??
                  const Color(0xFF1A4D2E))),
      trailing: hasArrow
          ? Icon(LucideIcons.chevronRight,
              size: 20, color: isDark ? Colors.white30 : Colors.black26)
          : null,
      onTap: onTap,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.iconColor,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0 : 0.02),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black26
                  : bgColor,
              shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 12),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    const Color(0xFF1A4D2E),
                fontFamily: 'Poppins'),
            maxLines: 1),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
