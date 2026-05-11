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

    return Scaffold(
      body: child,
      // Fitts's Law: Core action (Check-in) is prominent and easy to reach.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.accentAmber, Color(0xFFFFB03A)], // Amber Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentAmber.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
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
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.3),
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
    final color = isActive ? const Color(0xFF1A4D2E) : const Color(0xFF9E9E9E); // Deep Green vs Soft Grey
    
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
            color: isActive ? const Color(0xFF1A4D2E).withOpacity(0.08) : Colors.transparent,
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
