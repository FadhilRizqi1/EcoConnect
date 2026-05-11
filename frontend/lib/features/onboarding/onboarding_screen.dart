import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Onboarding Screen - focused category picking with premium visual treatment.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> _selectedCategories = [];

  IconData _iconFor(String name) {
    return switch (name) {
      'Diet Vegan' => LucideIcons.apple,
      'Hemat Energi' => LucideIcons.zap,
      'Transportasi Hijau' => LucideIcons.bike,
      'Kelola Sampah' => LucideIcons.recycle,
      'Hemat Air' => LucideIcons.droplet,
      _ => LucideIcons.leaf,
    };
  }

  List<Color> _colorsFor(int index) {
    const palettes = [
      [Color(0xFF54D68A), Color(0xFF1B6B3A)],
      [Color(0xFFFFC857), Color(0xFFFF8C00)],
      [Color(0xFF55B8FF), Color(0xFF0D4E8A)],
      [Color(0xFF8FE388), Color(0xFF2D9653)],
      [Color(0xFF6FE7E2), Color(0xFF1A73C8)],
    ];
    return palettes[index % palettes.length];
  }

  void _toggleCategory(String name) {
    setState(() {
      if (_selectedCategories.contains(name)) {
        _selectedCategories.remove(name);
      } else {
        _selectedCategories.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071B12), Color(0xFF173E2B), Color(0xFF0D4E8A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _OnboardingPatternPainter()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.22)),
                          ),
                          child: const Icon(LucideIcons.leaf,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'EcoConnect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/masuk'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Bangun kebiasaan hijau yang terasa personal.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pilih fokusmu, lalu EcoConnect akan menampilkan misi dan komunitas yang paling relevan.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _FeaturePill(
                            icon: LucideIcons.sparkles, label: 'Misi personal'),
                        _FeaturePill(
                            icon: LucideIcons.users, label: 'Forum aktif'),
                        _FeaturePill(
                            icon: LucideIcons.trendingUp,
                            label: 'Dampak terukur'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: AppConstants.kategoriOnboarding.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final cat = AppConstants.kategoriOnboarding[i];
                          final name = cat['nama']!;
                          final description = cat['deskripsi']!;
                          final isSelected = _selectedCategories.contains(name);
                          final colors = _colorsFor(i);

                          return _OnboardingCategoryCard(
                            title: name,
                            description: description,
                            icon: _iconFor(name),
                            colors: colors,
                            isSelected: isSelected,
                            onTap: () => _toggleCategory(name),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _selectedCategories.isNotEmpty
                          ? () =>
                              context.go('/daftar', extra: _selectedCategories)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withOpacity(0.34),
                        foregroundColor: AppColors.primaryGreen,
                        disabledForegroundColor: Colors.white.withOpacity(0.7),
                        minimumSize: const Size(double.infinity, 58),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mulai Perjalanan Hijauku',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(LucideIcons.arrowRight, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _OnboardingCategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.16),
            width: 1.4,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: colors.last.withOpacity(0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.primaryGreen : Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textSecondary
                          : Colors.white.withOpacity(0.62),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.white.withOpacity(0.28),
                ),
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPatternPainter extends CustomPainter {
  const _OnboardingPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (var i = 0; i < 9; i++) {
      final y = size.height * (0.08 + i * 0.12);
      final path = Path()
        ..moveTo(-20, y)
        ..cubicTo(size.width * 0.25, y - 42, size.width * 0.7, y + 42,
            size.width + 20, y - 8);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
