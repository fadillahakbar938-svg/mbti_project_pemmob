import 'package:flutter/material.dart';

import 'widgets/notification_sheet.dart';
import '../services/supabase_service.dart';
import 'custom_bottom_navbar.dart';
import 'soul_match_page.dart';
import 'yakin_page.dart';
import 'match_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _displayName = 'Tamu';
  bool _isGuest = true;
  String? _profilePicture;
  String? _mbtiType;
  String _mbtiNickname = 'Uji dirimu sekarang';
  bool _showProfileMenu = false;
  bool _showNotificationPanel = false;
  Key _notifKey = UniqueKey();

  int totalTests = 0;
  int totalMatches = 0;
  int totalCards = 0;
  int _notificationCount = 0;
  List<Map<String, dynamic>> _recentMatches = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCounts();
  }

  String _greetingForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _loadCounts() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _notificationCount = 0;
        });
      }
      return;
    }

    try {
      final results = await Future.wait([
        SupabaseService.instance.getTotalTests(user.id),
        SupabaseService.instance.getTotalMatches(user.id),
        SupabaseService.instance.getTotalCards(user.id),
        SupabaseService.instance.getIncomingFriendRequests(user.id),
        SupabaseService.instance.getIncomingMatchRequests(user.id),
        SupabaseService.instance.getMatches(user.id),
        SupabaseService.instance.getNotifications(user.id),
      ]);

      if (!mounted) return;
      setState(() {
        totalTests = results[0] as int;
        totalMatches = results[1] as int;
        totalCards = results[2] as int;
        final incomingFriends = results[3] as List<dynamic>;
        final incomingMatches = results[4] as List<dynamic>;
        final matches = results[5] as List<Map<String, dynamic>>;
        final notifications = results[6] as List<dynamic>;
        
        _notificationCount = incomingFriends.length + incomingMatches.length + notifications.length;

        _recentMatches = matches.take(5).toList(); // Ambil 5 saja untuk di dashboard
      });
    } catch (e) {
      debugPrint('Error loading counts: $e');
    }
  }

  Future<void> _loadUserData() async {
    final authUser = SupabaseService.instance.currentUser;
    if (authUser == null) {
      setState(() {
        _isGuest = true;
        _displayName = 'Tamu';
        _profilePicture = null;
        _mbtiType = null;
      });
      return;
    }

    try {
      final profile =
          await SupabaseService.instance.getUserProfile(authUser.id);

      final mbtiRaw = profile?['mbti_type'] as String?;
      final mbti = (mbtiRaw != null &&
              mbtiRaw.isNotEmpty &&
              mbtiRaw.toUpperCase() != 'NULL')
          ? mbtiRaw.toUpperCase()
          : null;

      String? mbtiNickname;
      if (mbti != null) {
        final mbtiProfile =
            await SupabaseService.instance.getMbtiProfile(mbti);
        mbtiNickname = mbtiProfile?['nickname'] as String?;
      }

      final usernameRaw = profile?['username'] as String?;
      final displayName = (usernameRaw != null && usernameRaw.isNotEmpty)
          ? usernameRaw
          : authUser.email?.split('@').first ?? 'Pengguna';

      if (!mounted) return;
      setState(() {
        _isGuest = false;
        _displayName = displayName;
        _profilePicture = profile?['avatar_emoji'] as String?;
        _mbtiType = mbti;
        _mbtiNickname = mbtiNickname ?? 'Uji dirimu sekarang';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isGuest = false;
        _displayName =
            SupabaseService.instance.currentUser?.email?.split('@').first ??
                'Pengguna';
      });
    }
  }

  void _closeAllPanels() {
    if (_showProfileMenu || _showNotificationPanel) {
      setState(() {
        _showProfileMenu = false;
        _showNotificationPanel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: GestureDetector(
          onTap: _closeAllPanels,
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                  iconColor: textDark,
                                  purpleLight: purpleLight,
                                ),
                                const SizedBox(width: 12),
                                _buildProfileAvatarButton(
                                  profilePicture: _profilePicture,
                                  avatarPink: avatarPink,
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_showNotificationPanel) ...[
                          const SizedBox(height: 16),
                          NotificationPanel(
                            key: _notifKey,
                            onChanged: _loadCounts,
                          ),
                        ],
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _isGuest
                              ? _showGuestWarning
                              : () {
                                  if (_mbtiType != null) {
                                    Navigator.pushNamed(context, '/result');
                                  } else {
                                    Navigator.pushNamed(context, '/test_intro');
                                  }
                                },
                          child: _buildMyTypeCard(
                            purpleLight: purpleLight,
                            purpleMain: purpleMain,
                            textDark: textDark,
                            textMuted: textMuted,
                          ),
                        ),
                      ],
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

                // ── Statistik ──
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '💖',
                        _isGuest ? '-' : totalMatches.toString(),
                        'Matches',
                        textDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildStatCard(
                        '📋',
                        totalTests.toString(),
                        'Tes',
                        textDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildStatCard(
                        '🎴',
                        _isGuest ? '-' : totalCards.toString(),
                        'Kartu',
                        textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Tombol aksi ──
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        color: purpleLight,
                        icon: Icons.bolt_rounded,
                        iconColor: purpleMain,
                        title: 'Ambil Tes',
                        subtitle: '80 pertanyaan',
                        textColor: textDark,
                        onTap: _isGuest
                            ? _showGuestWarning
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const YakinPage()),
                                ).then((_) => _loadCounts());
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        color: pinkLight,
                        icon: Icons.favorite_rounded,
                        iconColor: Colors.redAccent,
                        title: 'Soul Match',
                        subtitle: 'Temukan pasanganmu',
                        textColor: textDark,
                        onTap: _isGuest
                            ? _showGuestWarning
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SoulMatchPage()),
                                ).then((_) => _loadCounts());
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Soul Matches list ──
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
                      onTap: _isGuest ? _showGuestWarning : () {
                        // Navigate to matches tab in bottom navbar
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => const SoulMatchPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat semua',
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
                _isGuest
                    ? _buildLockedMatchesPlaceholder()
                    : _recentMatches.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                'Belum ada Match.\nYuk cari Match pertamamu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _recentMatches.map((match) {
                                // Extract data safely
                                final friendData = match['friend'] as Map<String, dynamic>?;
                                final friendUsername = friendData?['username'] as String? ?? 'Si Teman Baru';
                                final friendMbti = match['friend_mbti'] as String? ?? 'N/A';
                                final percentageRaw = match['compatibility_percentage'];
                                final percentage = (percentageRaw is num) ? percentageRaw.toDouble() / 100 : 0.50;
                                
                                // Provide default emojis and descriptions based on MBTI
                                String emoji = '😊';
                                String desc = friendUsername; // Gunakan username asli dari database
                                if (friendMbti == 'INTP') { emoji = '🐧'; }
                                else if (friendMbti == 'INFP') { emoji = '🐑'; }
                                else if (friendMbti == 'ENFJ') { emoji = '🦊'; }
                                else if (friendMbti == 'ESTJ') { emoji = '🦁'; }
                                else if (friendMbti == 'ISFP') { emoji = '🐼'; }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MatchDetailPage(
                                            historyId: match['id'] as int,
                                            supabaseService: SupabaseService.instance,
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildSoulMatchCard(
                                      emoji,
                                      friendMbti,
                                      desc,
                                      percentage,
                                      blueLight,
                                      blueMain,
                                      textDark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom + 72),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildNotificationButton({
    required Color iconColor,
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
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _showNotificationPanel = !_showNotificationPanel;
              if (_showNotificationPanel) {
                _showProfileMenu = false;
                _notifKey = UniqueKey();
              }
            });
          },
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: iconColor,
                  size: 24,
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarButton({
    required String? profilePicture,
    required Color avatarPink,
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
          customBorder: const CircleBorder(),
          onTap: () {
            setState(() {
              _showProfileMenu = !_showProfileMenu;
              if (_showProfileMenu) _showNotificationPanel = false;
            });
          },
          child: Center(
            child: Text(
              profilePicture != null && profilePicture.isNotEmpty 
                ? profilePicture 
                : '👤', 
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    final TextEditingController usernameController =
        TextEditingController(text: _displayName.replaceAll('@', ''));
    String selectedEmoji = _profilePicture ?? '👤';

    const List<String> emojis = [
      '👤','👨','👩','👦','👧','👶','👵','👴','👨‍🦱','👩‍🦱',
      '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯',
      '🦁','🐮','🐷','🐸','🐵','🐔','🐧','🐦','🐤','🐢',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixText: '@',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Avatar Emotikon',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: emojis.length,
                      itemBuilder: (context, index) {
                        final emoji = emojis[index];
                        final isSelected = emoji == selectedEmoji;
                        return InkWell(
                          onTap: () {
                            setStateModal(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.purple.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.purple : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E59B3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final newUsername = usernameController.text.trim();
                        final userId = SupabaseService.instance.currentUser?.id;
                        if (userId != null) {
                          await SupabaseService.instance.updateUserProfile(
                            userId,
                            {
                              if (newUsername.isNotEmpty) 'username': newUsername,
                              'avatar_emoji': selectedEmoji,
                            },
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadUserData();
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
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
      child: Row(
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
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TIPE SAYA',
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
                  _mbtiType ?? 'UNKNOWN',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  _mbtiType == null ? 'Uji dirimu sekarang' : _mbtiNickname,
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
    );
  }

  Widget _buildProfileDropdown({
    required Color menuPink,
    required Color textDark,
  }) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfessionalMenuItem(
            icon: Icons.edit_rounded,
            label: 'Edit Profil',
            textDark: textDark,
            isTop: true,
            onTap: () {
              setState(() => _showProfileMenu = false);
              _showEditProfileSheet();
            },
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          _buildProfessionalMenuItem(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            textDark: Colors.redAccent,
            isBottom: true,
            onTap: () {
              setState(() => _showProfileMenu = false);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalMenuItem({
    required IconData icon,
    required String label,
    required Color textDark,
    bool isTop = false,
    bool isBottom = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(16) : Radius.zero,
        bottom: isBottom ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: textDark, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (!_isGuest) await SupabaseService.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildStatCard(
      String emoji, String count, String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(count,
              style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

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
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

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
          color: cardBg, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child:
                  Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
          ),
          const SizedBox(height: 12),
          Text(mbti,
              style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.1)),
          Text(description,
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: matchPercentage,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(matchPercentage * 100).toInt()}% cocok',
            style: TextStyle(
                color: progressColor,
                fontSize: 11,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

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
          const Text('Fitur Terbatas untuk Tamu',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF2D2132))),
          const SizedBox(height: 4),
          const Text(
            'Silakan selesaikan tes MBTI atau daftar akun baru untuk melihat kecocokan kepribadianmu.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false),
            child: const Text('Masuk / Daftar Sekarang',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF8E59B3))),
          ),
        ],
      ),
    );
  }

  void _showGuestWarning() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Fitur ini memerlukan akun terdaftar. Yuk daftar dulu! 🔮'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF8E59B3),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Daftar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.pushNamed(context, '/register');
          },
        ),
      ),
    );
  }
}