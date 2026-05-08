import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Onboarding Screen — Hick's Law: max 5 categories to choose from
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('🌿', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text(
                  'Selamat datang di\nEcoConnect!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih fokus ramah lingkunganmu:',
                  style: TextStyle(color: Colors.white60, fontSize: 15, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 24),

                // Hick's Law: 5 options max, clear and scannable
                Expanded(
                  child: ListView.separated(
                    itemCount: AppConstants.kategoriOnboarding.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final cat = AppConstants.kategoriOnboarding[i];
                      final isSelected = _selectedCategory == cat['nama'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat['nama']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen.withOpacity(0.3)
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGreenMint : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(cat['emoji']!, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat['nama']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppColors.primaryGreenMint : Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      cat['deskripsi']!,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Poppins'),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primaryGreenMint),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                // Fitts's Law: Large CTA at the bottom, thumb-reachable
                ElevatedButton(
                  onPressed: _selectedCategory != null
                      ? () => context.go('/daftar', extra: _selectedCategory)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenMint,
                    foregroundColor: AppColors.backgroundDark,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'Mulai Perjalanan Hijauku 🌱',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/masuk'),
                    child: const Text(
                      'Sudah punya akun? Masuk',
                      style: TextStyle(color: Colors.white60, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
