import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/supabase_service.dart';

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
  bool _agreeTerms = false;

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
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Ketentuan Layanan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Mengirimkan data pendaftaran ke Supabase tanpa nim dan jurusan
    final res = await SupabaseService.instance.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      nim: '', // Dikosongkan karena input dihapus
      jurusan: 'Umum', // Set default sebagai Umum
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
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8E59B3);
    const accentColor = Color(0xFFF5E3F7);

    return Scaffold(
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
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'MBTI TEST',
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

                        // Checkbox Persetujuan
                        CheckboxListTile(
                          title: const Text(
                            'Saya setuju dengan Ketentuan Layanan & Privasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A3E4D),
                            ),
                          ),
                          value: _agreeTerms,
                          activeColor: primaryColor,
                          checkColor: Colors.white,
                          onChanged: (v) =>
                              setState(() => _agreeTerms = v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 18),

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
          ],
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
