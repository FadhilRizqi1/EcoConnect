import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _selectedCategory;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.daftar(
        nama: name,
        email: email,
        password: password,
        kategori: _selectedCategory ?? '',
      );
      await AuthService.saveToken(data['token']);
      final userId = data['user']['id'];
      await AuthService.saveUserId(userId is int ? userId : int.parse(userId.toString()));
      if (mounted) context.go('/beranda');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal terhubung ke server');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => context.go('/masuk'),
                ),
                const SizedBox(height: 8),
                const Text('🌱', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                const Text('Buat Akun\nEco-Warrior!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins', height: 1.2)),
                const SizedBox(height: 6),
                const Text('Bergabunglah dan selamatkan bumi bersama kami', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 13)),
                const SizedBox(height: 32),

                _buildField(controller: _nameCtrl,  label: 'Nama Lengkap', icon: Icons.person_rounded),
                const SizedBox(height: 14),
                _buildField(controller: _emailCtrl, label: 'Email', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordCtrl,
                  label: 'Kata Sandi (min. 6 karakter)',
                  icon: Icons.lock_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                const SizedBox(height: 22),
                const Text('Fokus Hijaumu (pilih 1)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                const SizedBox(height: 10),

                // Hick's Law: max 5 kategori
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.kategoriOnboarding.map((cat) {
                    final isSelected = _selectedCategory == cat['nama'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['nama']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${cat['emoji']} ${cat['nama']}',
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryGreen : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13))),
                    ]),
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2.5))
                      : const Text('Daftar & Mulai Misi 🌿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/masuk'),
                    child: const Text('Sudah punya akun? Masuk', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required IconData icon, bool obscure = false, Widget? suffix, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
      ),
    );
  }
}
