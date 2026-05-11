import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pusat Bantuan', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, ada yang bisa kami bantu?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                SizedBox(height: 12),
                Text('Temukan jawaban dari pertanyaan yang sering diajukan atau hubungi tim kami.', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins', height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Topik Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF1A4D2E))),
          const SizedBox(height: 16),
          
          _buildFaqTile('Bagaimana cara mendapatkan lencana?'),
          _buildFaqTile('Apa itu poin karbon (kg CO₂)?'),
          _buildFaqTile('Bagaimana cara bergabung dengan komunitas?'),
          _buildFaqTile('Lupa kata sandi?'),
          
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.mail, size: 20),
            label: const Text('Hubungi Customer Support', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8F3EB),
              foregroundColor: const Color(0xFF1A4D2E),
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A4D2E))),
        iconColor: AppColors.primaryGreen,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: const [
          Text('Penjelasan terperinci mengenai topik ini akan ditampilkan di sini. EcoConnect senantiasa berkomitmen untuk memberikan pengalaman terbaik untuk Anda.', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
