import 'package:flutter/material.dart';

import 'custom_bottom_navbar.dart';
import 'match_page.dart';
import 'question_page.dart';
import 'widgets/notification_sheet.dart';
import '../services/supabase_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _displayName = 'Guest User';
  bool _isGuest = true;
  String? _profilePicture;
  String? _mbtiType;
  bool _showProfileMenu = false;
  bool _showNotificationPanel = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  String _greetingForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  void _checkUserStatus() {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      setState(() {
        _isGuest = false;
        // Prioritaskan username dari tabel users, lalu full_name, lalu email local-part.
        _displayName =
            user.userMetadata?['username'] ??
            user.userMetadata?['nama'] ??
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User';

        // Load profile picture jika ada
        _profilePicture = user.userMetadata?['profile_picture'] as String?;

        // Load MBTI type jika ada
        _mbtiType = user.userMetadata?['mbti_type'] as String?;
      });
    } else {
      setState(() {
        _isGuest = true;
        _displayName = 'Guest User';
        _profilePicture = null;
        _mbtiType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Kode Warna Tema Pastel INFP sesuai Desain Referensi
    const bgCream = Color(0xFFFFFBF7);
    const purpleLight = Color(0xFFF3E3FC);
    const purpleMain = Color(0xFF8E59B3);
    const pinkLight = Color(0xFFFCE3EC);
    const blueLight = Color(0xFFE3F4FC);
    const blueMain = Color(0xFF4A90E2);
    const textDark = Color(0xFF2D2132);
    const textMuted = Color(0xFF7D6F83);
    const menuPink = Color(0xFFFDE2E4);
    const avatarPink = Color(0xFFFCE3EC);

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + MY TYPE + menu pink mengambang (seperti desain referensi)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greetingForTimeOfDay(),
                                  style: const TextStyle(
                                    color: textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _displayName,
                                  style: const TextStyle(
                                    color: textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildNotificationButton(
                                context,
                                textDark,
                                purpleLight: purpleLight,
                              ),
                              const SizedBox(width: 12),
                              _buildProfileAvatarButton(
                                profilePicture: _profilePicture,
                                avatarPink: avatarPink,
                                onTap: () {
                                  setState(() {
                                    _showProfileMenu = !_showProfileMenu;
                                    if (_showProfileMenu) {
                                      _showNotificationPanel = false;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMyTypeCard(
                        purpleLight: purpleLight,
                        purpleMain: purpleMain,
                        textDark: textDark,
                        textMuted: textMuted,
                      ),
                    ],
                  ),
                  if (_showNotificationPanel)
                    Positioned(
                      top: 52,
                      left: 0,
                      right: 0,
                      child: const NotificationPanel(),
                    ),
                  if (_showProfileMenu)
                    Positioned(
                      top: 48,
                      right: 0,
                      child: Material(
                        elevation: 12,
                        shadowColor: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        child: _buildProfileDropdown(
                          menuPink: menuPink,
                          textDark: textDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // ================= BARISAN STATISTIK ANGKA (Matches, Tests, Cards) =================
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '💖',
                      _isGuest ? '-' : '24',
                      'Matches',
                      textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatCard(
                      '📋',
                      _isGuest ? '0' : '5',
                      'Tests',
                      textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildStatCard(
                      '🎴',
                      _isGuest ? '-' : '10',
                      'Cards',
                      textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ================= DUA TOMBOL AKSI BESAR (Take Test & Soul Match) =================
              Row(
                children: [
                  // Tombol Ungu Pastel Lembut: Take Test
                  Expanded(
                    child: _buildActionCard(
                      color: purpleLight,
                      icon: Icons.bolt_rounded,
                      iconColor: purpleMain,
                      title: 'Take Test',
                      subtitle: '25 questions',
                      textColor: textDark,
                      onTap: _isGuest
                          ? _showGuestWarning
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QuestionPage(),
                                ),
                              );
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Pink Pastel Lembut: Soul Match
                  Expanded(
                    child: _buildActionCard(
                      color: pinkLight,
                      icon: Icons.favorite_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Soul Match',
                      subtitle: 'Find your pair',
                      textColor: textDark,
                      onTap: _isGuest
                          ? _showGuestWarning
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MatchPage(),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ================= DAFTAR REKOMENDASI/SOUL MATCHES =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Soul Matches',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isGuest ? _showGuestWarning : () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: purpleMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Konten Kondisional Horizontal List (Terkunci dengan gembok jika Guest)
              _isGuest
                  ? _buildLockedMatchesPlaceholder()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildSoulMatchCard(
                            '🐧',
                            'INTP',
                            'The Thinker',
                            0.97,
                            blueLight,
                            blueMain,
                            textDark,
                          ),
                          const SizedBox(width: 16),
                          _buildSoulMatchCard(
                            '🐑',
                            'INFP',
                            'The Dreamer',
                            0.70,
                            purpleLight,
                            purpleMain,
                            textDark,
                          ),
                          const SizedBox(width: 16),
                          _buildSoulMatchCard(
                            '🦊',
                            'ENFJ',
                            'The Protagonist',
                            0.85,
                            pinkLight,
                            Colors.redAccent,
                            textDark,
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom + 72,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    Color iconColor, {
    required Color purpleLight,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: purpleLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showNotificationPanel = !_showNotificationPanel;
              if (_showNotificationPanel) _showProfileMenu = false;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Icon(
              Icons.notifications_none_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarButton({
    required String? profilePicture,
    required Color avatarPink,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: avatarPink,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: profilePicture != null && profilePicture.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profilePicture,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildUwuAvatarFace(),
                    ),
                  )
                : _buildUwuAvatarFace(),
          ),
        ),
      ),
    );
  }

  Widget _buildUwuAvatarFace() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF7EC8E3),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(painter: _UwuFacePainter()),
    );
  }

  Widget _buildMyTypeCard({
    required Color purpleLight,
    required Color purpleMain,
    required Color textDark,
    required Color textMuted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: purpleLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🐑', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'MY TYPE',
                              style: TextStyle(
                                color: purpleMain,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _mbtiType == null ? 'UNKNOWN' : _mbtiType!,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            _mbtiType == null
                                ? 'Uji dirimu sekarang'
                                : 'The Dreamer',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: textMuted.withValues(alpha: 0.6),
                      size: 20,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown({
    required Color menuPink,
    required Color textDark,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: menuPink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileMenuRow(
            icon: Icons.account_circle_outlined,
            label: 'Lihat Profile',
            textDark: textDark,
            onTap: () {
              setState(() => _showProfileMenu = false);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const SizedBox(height: 12),
          _buildProfileMenuRow(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            textDark: textDark,
            onTap: () {
              setState(() => _showProfileMenu = false);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuRow({
    required IconData icon,
    required String label,
    required Color textDark,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Icon(icon, color: textDark, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    if (!_isGuest) {
      await SupabaseService.instance.signOut();
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // Widget Pembantu: Komponen Kartu Mini Statistik Angka Tengah
  Widget _buildStatCard(
    String emoji,
    String count,
    String label,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pembantu: Komponen Dua Tombol Utama (Take Test / Soul Match)
  Widget _buildActionCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pembantu: Komponen List Horizontal Kartu "Soul Matches" di Bagian Bawah
  Widget _buildSoulMatchCard(
    String emoji,
    String mbti,
    String description,
    double matchPercentage,
    Color cardBg,
    Color progressColor,
    Color textColor,
  ) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mbti,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: matchPercentage,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(matchPercentage * 100).toInt()}% match',
            style: TextStyle(
              color: progressColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // Informasi Kosong / Tempat Penampung Gembok Jika User Masuk Sebagai Guest
  Widget _buildLockedMatchesPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          const Text(
            'Fitur Terbatas untuk Guest',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2132),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Silakan selesaikan tes pertama Anda atau daftarkan akun baru untuk melihat kecocokan kepribadian dengan orang lain.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
            child: const Text(
              'Login / Register Sekarang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E59B3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Peringatan Jika Tamu (Guest) Mencoba Mengakses Fitur Terkunci
  void _showGuestWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Fitur ini memerlukan akun terdaftar. Yuk daftar dulu! 🔮',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF8E59B3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Daftar',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/register'),
        ),
      ),
    );
  }
}

class _UwuFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D2132)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Mata tertutup (garis melengkung)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.32, h * 0.38),
        width: w * 0.18,
        height: h * 0.1,
      ),
      0,
      3.14,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.68, h * 0.38),
        width: w * 0.18,
        height: h * 0.1,
      ),
      0,
      3.14,
      false,
      paint,
    );

    // Mulut bergelombang
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.28, h * 0.62);
    mouthPath.quadraticBezierTo(w * 0.4, h * 0.72, w * 0.5, h * 0.58);
    mouthPath.quadraticBezierTo(w * 0.6, h * 0.44, w * 0.72, h * 0.62);
    canvas.drawPath(mouthPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
