// group_detail_screen.dart — Legacy screen, digantikan oleh community_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class GroupDetailScreen extends StatelessWidget {
  final int groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.go('/komunitas/$groupId'));
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );
  }
}
