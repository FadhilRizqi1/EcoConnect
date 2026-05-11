import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final List<String>? initialCategories;
  const RegisterScreen({super.key, this.initialCategories});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  List<String> _selectedCategories = [];
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  IconData _iconFor(String name) {
    return switch (name) {
      'Diet Vegan' => LucideIcons.apple,
      'Hemat Energi' => LucideIcons.zap,
      'Transportasi Hijau' => LucideIcons.bike,
      'Kelola Sampah' => LucideIcons.recycle,
      'Hemat Air' => LucideIcons.droplet,
      _ => LucideIcons.leaf,
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategories != null) {
      _selectedCategories.addAll(widget.initialCategories!);
    }
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.daftar(
        nama: name,
        email: email,
        password: password,
        kategori: _selectedCategories.join(', '),
      );
      await AuthService.saveToken(data['token']);
      final userId = data['user']['id'];
      await AuthService.saveUserId(
          userId is int ? userId : int.parse(userId.toString()));
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.darkGradient),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 24,
                              spreadRadius: -5)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_rounded,
                                    color: Colors.white),
                                onPressed: () => context.go('/masuk'),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const Spacer(),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.22)),
                                ),
                                child: const Icon(LucideIcons.leaf,
                                    color: Colors.white, size: 23),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Buat Akun\nEco-Warrior!',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  height: 1.2)),
                          const SizedBox(height: 8),
                          const Text(
                              'Bergabunglah dan selamatkan bumi bersama kami',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                  fontSize: 13)),
                          const SizedBox(height: 28),

                          _buildField(
                              controller: _nameCtrl,
                              label: 'Nama Lengkap',
                              icon: LucideIcons.user),
                          const SizedBox(height: 14),
                          _buildField(
                              controller: _emailCtrl,
                              label: 'Email',
                              icon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passwordCtrl,
                            label: 'Kata Sandi (min. 6 karakter)',
                            icon: LucideIcons.lock,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),

                          const SizedBox(height: 22),
                          const Text('Fokus Hijaumu (pilih satu atau lebih)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins')),
                          const SizedBox(height: 10),

                          // Multi-select kategori
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                AppConstants.kategoriOnboarding.map((cat) {
                              final isSelected =
                                  _selectedCategories.contains(cat['nama']);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCategories.remove(cat['nama']);
                                    } else {
                                      _selectedCategories.add(cat['nama']!);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4))
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _iconFor(cat['nama']!),
                                        size: 17,
                                        color: isSelected
                                            ? AppColors.primaryGreen
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat['nama']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : Colors.white,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontSize: 13))),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryGreen,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: AppColors.primaryGreen,
                                        strokeWidth: 2.5))
                                : const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Daftar & Mulai Misi',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Poppins')),
                                        SizedBox(width: 8),
                                        Icon(LucideIcons.arrowRight, size: 20),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go('/masuk'),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Sudah punya akun? ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontFamily: 'Poppins',
                                      fontSize: 13),
                                  children: const [
                                    TextSpan(
                                      text: 'Masuk di sini',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscure = false,
      Widget? suffix,
      TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
