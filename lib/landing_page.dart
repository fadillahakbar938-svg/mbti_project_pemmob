import 'package:flutter/material.dart';

import 'widgets/auth_background_blobs.dart';
import 'widgets/detective_sheep_logo.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _floatController;
  late AnimationController _bgController;

  late Animation<double> _logoEntry;
  late Animation<double> _titleEntry;
  late Animation<double> _subtitleEntry;
  late Animation<double> _buttonsEntry;
  late Animation<double> _floatAnim;



  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _bgController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _logoEntry = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _titleEntry = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _subtitleEntry = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _buttonsEntry = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema Pastel INFP
    const primaryColor = Color(0xFF8E59B3); // Ungu INFP
    const textColor = Color(0xFF4A3E4D); // Ungu Gelap Lembut untuk Teks
    const subTextColor = Color(0xFF8E7A93); // Abu-abu keunguan untuk Subtitle

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradasi Pastel Lembut yang Bergerak Mandiri
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5E3F7), // Soft Pinkish Purple
                    Color(0xFFFFF3EC), // Warm Soft Peach
                  ],
                ),
              ),
            ),
          ),
          const AuthBackgroundBlobs(),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Animasi maskot domba detektif
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entryController,
                      _floatController,
                    ]),
                    builder: (_, _) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Transform.scale(
                        scale: _logoEntry.value,
                        child: Opacity(
                          opacity: _logoEntry.value.clamp(0.0, 1.0),
                          child: _buildLogo(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Judul dan Deskripsi Aplikasi Baru
                  AnimatedBuilder(
                    animation: _entryController,
                    builder: (_, _) => Opacity(
                      opacity: _titleEntry.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _titleEntry.value) * 20),
                        child: Column(
                          children: [
                            const Text(
                              'MBTI MATCH',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Opacity(
                              opacity: _subtitleEntry.value,
                              child: const Text(
                                'Platform Temukan Kepribadian dan Potensi Dirimu',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Kapsul Fitur Berwarna Pastel Serasi
                  AnimatedBuilder(
                    animation: _entryController,
                    builder: (_, _) => Opacity(
                      opacity: _subtitleEntry.value,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill('🔮 16 Personalities', primaryColor),
                          _pill('🧠 Akurat', primaryColor),
                          _pill('📊 Analisis', primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Kelompok Tombol Navigasi Utama
                  AnimatedBuilder(
                    animation: _entryController,
                    builder: (_, _) => Opacity(
                      opacity: _buttonsEntry.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _buttonsEntry.value) * 40),
                        child: Column(
                          children: [
                            // Tombol MASUK (Warna Utama INFP)
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tombol DAFTAR AKUN BARU (Outline Elegan)
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                ),
                                child: const Text(
                                  'Daftar Akun Baru',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tombol MASUK SEBAGAI GUEST (Paling Bawah)
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Masuk sebagai Guest',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // const Text(
                  //   'Dengan masuk, kamu setuju dengan\nKetentuan Layanan & Kebijakan Privasi',
                  //   style: TextStyle(
                  //     color: subTextColor,
                  //     fontSize: 11,
                  //     height: 1.3,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
            ),
      ),
        ]
    )
    );
  }

  Widget _buildLogo() {
    return const DetectiveSheepLogo(size: 90);
  }

  Widget _pill(String text, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4A3E4D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
