import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textOnDark : const Color(0xFF1A4D2E);
    final bodyColor = isDark ? AppColors.textMuted : AppColors.textSecondary;
    final cardColor =
        isDark ? Theme.of(context).cardColor : const Color(0xFFF8FAF9);
    final borderColor = isDark ? Colors.white10 : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Privasi & Keamanan',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(LucideIcons.shieldCheck,
              size: 64, color: AppColors.primaryGreen),
          const SizedBox(height: 24),
          Text(
            'Keamanan Akun Anda',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
                fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Kami menggunakan enkripsi tingkat lanjut untuk melindungi data pribadi dan aktivitas ramah lingkungan Anda.',
            style: TextStyle(
                fontSize: 14,
                color: bodyColor,
                fontFamily: 'Poppins',
                height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebijakan Privasi',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor)),
                const SizedBox(height: 12),
                Text(
                  'Data Anda hanya digunakan untuk keperluan aplikasi EcoConnect. Kami tidak pernah membagikan data Anda kepada pihak ketiga mana pun tanpa persetujuan Anda.\n\nSistem kami telah dilengkapi dengan pelindung enkripsi mutakhir sehingga poin karbon, riwayat tugas, dan aktivitas komunitas Anda aman bersama kami.',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: bodyColor,
                      height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
