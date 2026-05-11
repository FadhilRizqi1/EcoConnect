import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RankHelper {
  final String name;
  final int minPoints;
  final IconData icon;
  final Color color;

  const RankHelper({
    required this.name,
    required this.minPoints,
    required this.icon,
    required this.color,
  });

  static const List<RankHelper> ranks = [
    RankHelper(name: 'Tunas', minPoints: 0, icon: LucideIcons.droplet, color: Color(0xFF8B5A2B)), // Brown/Greenish
    RankHelper(name: 'Bibit', minPoints: 50, icon: LucideIcons.sun, color: Color(0xFF8BC34A)), // Light Green
    RankHelper(name: 'Daun Hijau', minPoints: 150, icon: LucideIcons.leaf, color: Color(0xFF4CAF50)), // Green
    RankHelper(name: 'Pohon', minPoints: 300, icon: LucideIcons.wind, color: Color(0xFF2E7D32)), // Dark Green
    RankHelper(name: 'Pengawal Alam', minPoints: 600, icon: LucideIcons.shield, color: Color(0xFF009688)), // Teal
    RankHelper(name: 'Pelindung Bumi', minPoints: 1200, icon: LucideIcons.globe, color: Color(0xFF1976D2)), // Blue
    RankHelper(name: 'Ksatria Ekologi', minPoints: 2500, icon: LucideIcons.award, color: Color(0xFFB0BEC5)), // Silver
    RankHelper(name: 'Titan Hijau', minPoints: 5000, icon: LucideIcons.crown, color: Color(0xFFFFB03A)), // Gold
  ];

  static RankHelper getRank(int points) {
    for (int i = ranks.length - 1; i >= 0; i--) {
      if (points >= ranks[i].minPoints) {
        return ranks[i];
      }
    }
    return ranks.first;
  }

  static RankHelper? getNextRank(int points) {
    for (int i = 0; i < ranks.length; i++) {
      if (points < ranks[i].minPoints) {
        return ranks[i];
      }
    }
    return null; // Already at max rank
  }

  static double getProgress(int points) {
    final currentRank = getRank(points);
    final nextRank = getNextRank(points);
    
    if (nextRank == null) return 1.0; // Maxed out

    final range = nextRank.minPoints - currentRank.minPoints;
    final currentProgress = points - currentRank.minPoints;
    
    if (range <= 0) return 1.0;
    return currentProgress / range;
  }

  static int getPointsNeeded(int points) {
    final nextRank = getNextRank(points);
    if (nextRank == null) return 0;
    return nextRank.minPoints - points;
  }
}
