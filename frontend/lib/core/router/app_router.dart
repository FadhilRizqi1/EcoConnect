import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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
    GoRoute(path: '/masuk',      builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/daftar',     builder: (_, state) => RegisterScreen(initialCategories: state.extra as List<String>?)),

    // Main shell with bottom nav (4 tabs: Beranda, Tugas, Komunitas, Peringkat)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/beranda',         builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/tugas',           builder: (_, __) => const TasksScreen()),
        GoRoute(path: '/komunitas',       builder: (_, __) => const CommunitiesScreen()),
        GoRoute(path: '/papan-peringkat', builder: (_, __) => const LeaderboardScreen()),
        GoRoute(path: '/profil',          builder: (_, __) => const ProfileScreen(userId: 0)),
        GoRoute(
          path: '/profil/:id',
          builder: (_, state) => ProfileScreen(userId: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),

    // Chat Screen (No Bottom Nav / FAB)
    GoRoute(
      path: '/komunitas/:id',
      builder: (_, state) => CommunityChatScreen(communityId: int.parse(state.pathParameters['id']!)),
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
            colors: [Color(0xFF1B6B3A), Color(0xFF1A73C8)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌿', style: TextStyle(fontSize: 80)),
              SizedBox(height: 20),
              Text(
                'EcoConnect',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bersama untuk bumi yang lebih baik',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
