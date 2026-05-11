import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/communities/communities_screen.dart';
import '../../features/communities/community_chat_screen.dart';
import '../../features/profile/privacy_screen.dart';
import '../../features/profile/help_center_screen.dart';
import '../../widgets/main_shell.dart';

/// EcoConnect Router — GoRouter with auth redirect
/// Jakob's Law: consistent navigation patterns users already know
final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final loc = state.matchedLocation;
    final isAuthRoute = loc.startsWith('/masuk') ||
        loc.startsWith('/daftar') ||
        loc.startsWith('/onboarding') ||
        loc.startsWith('/splash');

    if (!isLoggedIn && !isAuthRoute) return '/onboarding';
    if (isLoggedIn && isAuthRoute) return '/beranda';
    return null;
  },
  routes: [
    // Splash
    GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),

    // Onboarding & Auth
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/masuk', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/daftar',
        builder: (_, state) =>
            RegisterScreen(initialCategories: state.extra as List<String>?)),

    // Main shell with bottom nav (4 tabs: Beranda, Tugas, Komunitas, Peringkat)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/beranda', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/tugas', builder: (_, __) => const TasksScreen()),
        GoRoute(
            path: '/komunitas', builder: (_, __) => const CommunitiesScreen()),
        GoRoute(
            path: '/papan-peringkat',
            builder: (_, __) => const LeaderboardScreen()),
        GoRoute(
            path: '/profil',
            builder: (_, __) => const ProfileScreen(userId: 0)),
        GoRoute(
          path: '/profil/:id',
          builder: (_, state) =>
              ProfileScreen(userId: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),

    // Chat Screen (No Bottom Nav / FAB)
    GoRoute(
      path: '/komunitas/:id',
      builder: (_, state) => CommunityChatScreen(
          communityId: int.parse(state.pathParameters['id']!)),
    ),

    // Sub-screens
    GoRoute(path: '/privasi', builder: (_, __) => const PrivacyScreen()),
    GoRoute(path: '/bantuan', builder: (_, __) => const HelpCenterScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
  ),
);

/// Splash screen sementara menunggu pengecekan sesi
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/onboarding');
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
            colors: [Color(0xFF071B12), Color(0xFF1B6B3A), Color(0xFF0D4E8A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _SplashPatternPainter()),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 118,
                      height: 118,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(34),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.28)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.24),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_app.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          LucideIcons.leaf,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'EcoConnect',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Misi kecil, dampak nyata, komunitas yang bergerak bersama.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _SplashChip(
                            icon: LucideIcons.target, label: 'Misi harian'),
                        _SplashChip(
                            icon: LucideIcons.users, label: 'Komunitas'),
                        _SplashChip(
                            icon: LucideIcons.barChart2, label: 'Dampak'),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.82),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Menyiapkan ruang hijaumu...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        fontSize: 12,
                        fontFamily: 'Poppins',
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

class _SplashChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SplashChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
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

class _SplashPatternPainter extends CustomPainter {
  const _SplashPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = -2; i < 7; i++) {
      final start = Offset(size.width * -0.1, size.height * (0.12 + i * 0.16));
      final end = Offset(size.width * 1.1, size.height * (0.03 + i * 0.16));
      canvas.drawLine(start, end, linePaint);
    }

    final leafPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void drawLeaf(Offset center, double scale, double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, -30 * scale)
        ..cubicTo(
            36 * scale, -12 * scale, 34 * scale, 24 * scale, 0, 34 * scale)
        ..cubicTo(
            -34 * scale, 24 * scale, -36 * scale, -12 * scale, 0, -30 * scale);
      canvas.drawPath(path, leafPaint);
      canvas.drawLine(Offset(0, -22 * scale), Offset(0, 24 * scale), leafPaint);
      canvas.restore();
    }

    drawLeaf(Offset(size.width * 0.16, size.height * 0.17), 0.9, -0.45);
    drawLeaf(Offset(size.width * 0.85, size.height * 0.31), 0.72, 0.52);
    drawLeaf(Offset(size.width * 0.18, size.height * 0.78), 0.58, 0.36);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
