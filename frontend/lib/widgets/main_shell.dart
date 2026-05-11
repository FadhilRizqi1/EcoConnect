import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// MainShell: Phase 1 - Premium Center-Docked Navigation Cradle
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // Re-indexed to 4 tabs as per Phase 1 constraint
  static const _leftTabs = [
    _TabItem(icon: LucideIcons.home, label: 'Beranda', path: '/beranda'),
    _TabItem(icon: LucideIcons.users, label: 'Komunitas', path: '/komunitas'),
  ];

  static const _rightTabs = [
    _TabItem(icon: LucideIcons.trophy, label: 'Peringkat', path: '/papan-peringkat'),
    _TabItem(icon: LucideIcons.user, label: 'Profil', path: '/profil'),
  ];

  int _currentIndex(BuildContext context, List<_TabItem> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].path == '/profil' && location.startsWith('/profil')) return i;
      if (location.startsWith(tabs[i].path) && tabs[i].path != '/profil') return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final leftIndex = _currentIndex(context, _leftTabs);
    final rightIndex = _currentIndex(context, _rightTabs);
    final isFabActive = GoRouterState.of(context).matchedLocation.startsWith('/tugas');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true, // This allows the body to flow underneath the BottomAppBar, filling the notch area
      body: child,
      // Fitts's Law: Core action (Check-in) is prominent and easy to reach.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC87A), Color(0xFF1A4D2E)], // Dominant Premium Green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFB03A).withOpacity(0.9), // Orange 'lis' (border)
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB03A).withOpacity(0.4), // Orange 'cahaya' (glow)
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 0), // Centered glow for uniform light
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.go('/tugas'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          splashColor: Colors.white.withOpacity(0.3),
          child: isFabActive 
            ? const Icon(LucideIcons.check, color: Colors.white, size: 28)
            // Pulse Lottie Animation via external URL
            : Lottie.network(
                'https://lottie.host/e06b9b3e-e610-449e-bba1-38ec91efec58/WcQzE2L3s5.json', // Pulse/Action effect
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(LucideIcons.zap, color: Colors.white, size: 28),
              ),
        ),
      ),
      
      // Glassmorphism-inspired Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        // FIX: Explicit white in light mode — cardColor in Material 3 fromSeed
        // can be a tonal surface nearly identical to the scaffold background.
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.05),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 68, // Ditambah sedikit agar tidak ada vertical overflow
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side tabs
              Expanded(
                child: Row(
                  children: List.generate(_leftTabs.length, (i) => _buildTabItem(context, _leftTabs[i], i == leftIndex)),
                ),
              ),
              
              // Cradle gap
              const SizedBox(width: 48),
              
              // Right side tabs
              Expanded(
                child: Row(
                  children: List.generate(_rightTabs.length, (i) => _buildTabItem(context, _rightTabs[i], i == rightIndex)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, _TabItem tab, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryGreenMint : const Color(0xFF1A4D2E);
    final inactiveColor = isDark ? AppColors.textMuted : const Color(0xFF9E9E9E);
    final color = isActive ? activeColor : inactiveColor;
    
    return Expanded(
      child: InkWell(
        onTap: () => context.go(tab.path),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 4), // Dihapus horizontal padding agar fit
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(isDark ? 0.15 : 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tab.icon,
                color: color,
                size: isActive ? 24 : 22,
              ),
              const SizedBox(height: 4),
              Flexible( // Flexible agar teks panjang (jika ada) terpotong dengan aman
                child: Text(
                  tab.label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;
  const _TabItem({required this.icon, required this.label, required this.path});
}
