// groups_screen.dart — Legacy screen, digantikan oleh communities_screen.dart
// Dipertahankan agar tidak ada dead routes, tapi redirect ke komunitas baru
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect ke halaman komunitas baru
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/komunitas'));
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );
  }
}
