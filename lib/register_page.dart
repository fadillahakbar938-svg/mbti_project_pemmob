import 'package:flutter/material.dart';

import 'services/supabase_service.dart';
import 'widgets/auth_background_blobs.dart';
import 'widgets/detective_sheep_logo.dart';
import 'widgets/exit_confirmation_wrapper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua kolom pendaftaran (Username, Email, Sandi).'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid. Pastikan menggunakan @ dan domain yang benar.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi terlalu pendek. Silakan buat sandi minimal 6 karakter.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sandi dan Konfirmasi Sandi tidak cocok. Mohon ketik ulang dengan teliti.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await SupabaseService.instance.register(
      username: name,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi sukses! Silakan login.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isNavigating = true);
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final errMsg = res.errorMessage ?? 'Registrasi gagal';
      final lowerErr = errMsg.toLowerCase();
      
      final isAlreadyRegistered = lowerErr.contains('user already registered') || lowerErr.contains('user_already_exists');
      
      if (isAlreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email "$email" sudah terdaftar. Silakan gunakan email lain atau langsung Login.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

      } else {
        // Humanize error message
        String humanError = 'Registrasi gagal: ${res.errorMessage}';
        if (lowerErr.contains('password should be at least')) {
          humanError = 'Kata sandi terlalu pendek. Silakan buat sandi minimal 6 karakter.';
        } else if (lowerErr.contains('invalid email')) {
          humanError = 'Format email "$email" tidak valid. Pastikan penulisan alamat email benar.';
        } else if (lowerErr.contains('duplicate key value violates unique constraint') && lowerErr.contains('username')) {
          humanError = 'Username "$name" sudah dipakai orang lain. Silakan pilih username unik yang berbeda.';
        } else if (lowerErr.contains('duplicate key value violates unique constraint') && lowerErr.contains('email')) {
          humanError = 'Email "$email" sudah terdaftar. Silakan gunakan email lain atau langsung Login.';
        } else if (lowerErr.contains('rate limit')) {
          humanError = 'Terlalu banyak percobaan pendaftaran. Sistem sedang sibuk, coba beberapa saat lagi.';
        } else if (lowerErr.contains('network') || lowerErr.contains('connection')) {
          humanError = 'Tidak ada koneksi internet. Pastikan HP Anda terhubung ke internet yang stabil.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(humanError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8E59B3);
    const accentColor = Color(0xFFF5E3F7);

    return ExitConfirmationWrapper(
      canPop: _isNavigating,
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E3F7), Color(0xFFFFF3EC)],
          ),
        ),
        child: Stack(
          children: [
            const AuthBackgroundBlobs(),
            // Wave background dekoratif bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: CustomPaint(
                painter: _WavePainter(accentColor.withOpacity(0.5)),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 80,
                      bottom: 32,
                      left: 24,
                      right: 24,
                    ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const DetectiveSheepLogo(size: 88),
                        const SizedBox(height: 14),
                        const Text(
                          'MBTI MATCH',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4A3E4D),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Buat akun barumu untuk memulai analisis potensi diri',
                          style: TextStyle(
                            color: Color(0xFF8E7A93),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Input Nama Lengkap
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Nama Lengkap',
                          icon: Icons.person_outline,
                          color: primaryColor,
                          validator: (v) =>
                              v!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 14),

                        // Input Alamat Email
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Alamat Email',
                          icon: Icons.email_outlined,
                          color: primaryColor,
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Email tidak valid'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Input Kata Sandi
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Kata Sandi',
                          icon: Icons.lock_outline,
                          color: primaryColor,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF8E7A93),
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) =>
                              v!.length < 6 ? 'Sandi minimal 6 karakter' : null,
                        ),
                        const SizedBox(height: 14),

                        // Input Konfirmasi Kata Sandi
                        _buildTextField(
                          controller: _confirmController,
                          hint: 'Konfirmasi Sandi',
                          icon: Icons.lock_clock,
                          color: primaryColor,
                          obscure: _obscureConfirm,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF8E7A93),
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? 'Sandi tidak cocok'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Tombol Submit
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Daftar Akun',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Navigasi Kembali ke Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(color: Color(0xFF8E7A93)),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                              child: const Text(
                                'Login disini',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    ),
    );
  }


  InputDecoration _inputDecoration(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8E7A93), fontSize: 14),
      prefixIcon: Icon(icon, color: color, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Color(0xFF4A3E4D)),
      decoration: _inputDecoration(
        hint,
        icon,
        color,
      ).copyWith(suffixIcon: suffix),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(size.width * 0.5, h * 0.2, size.width, h * 0.45)
      ..lineTo(size.width, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
