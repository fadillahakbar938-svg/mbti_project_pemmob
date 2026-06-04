import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

/// Menampilkan popup profil lengkap seorang user
/// Dipanggil saat card di AddFriendPage di-tap
Future<void> showUserProfilePopup(
  BuildContext context,
  Map<String, dynamic> user,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => UserProfilePopup(user: user),
  );
}

class UserProfilePopup extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfilePopup({super.key, required this.user});

  @override
  State<UserProfilePopup> createState() => _UserProfilePopupState();
}

class _UserProfilePopupState extends State<UserProfilePopup>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF8E59B3);
  static const Color _purpleLight = Color(0xFFF3E3FC);
  static const Color _cream = Color(0xFFFFFBF7);
  static const Color _textDark = Color(0xFF2D2132);
  static const Color _textMuted = Color(0xFF7D6F83);

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _loadingResult = true;
  Map<String, dynamic>? _latestResult;
  Map<String, dynamic>? _mbtiProfile;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
    _loadUserResult();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserResult() async {
    final userId = widget.user['id'] as String?;
    if (userId == null) {
      setState(() => _loadingResult = false);
      return;
    }

    try {
      final result =
          await SupabaseService.instance.getLatestResult(userId);

      Map<String, dynamic>? mbtiProfile;
      if (result != null) {
        final mbtiType = result['mbti_type'] as String?;
        if (mbtiType != null && mbtiType.isNotEmpty) {
          mbtiProfile =
              await SupabaseService.instance.getMbtiProfile(mbtiType);
        }
      }

      if (!mounted) return;
      setState(() {
        _latestResult = result;
        _mbtiProfile = mbtiProfile;
        _loadingResult = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingResult = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.user['username'] as String? ?? 'Pengguna';
    final mbtiRaw = widget.user['mbti_type'] as String?;
    final hasValidMbti = mbtiRaw != null &&
        mbtiRaw.isNotEmpty &&
        mbtiRaw.toUpperCase() != 'NULL';
    final mbti = hasValidMbti ? mbtiRaw!.toUpperCase() : null;
    final profilePic = widget.user['profile_picture'] as String?;
    final hasImage = profilePic != null &&
        profilePic.isNotEmpty &&
        profilePic != 'default.png';

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.1,
          ),
          decoration: const BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header: Avatar + Nama + MBTI ──
                      _buildHeader(
                        username: username,
                        mbti: mbti,
                        hasImage: hasImage,
                        profilePic: profilePic,
                      ),
                      const SizedBox(height: 24),

                      // ── MBTI Badge + Nickname ──
                      if (mbti != null) ...[
                        _buildMbtiBadge(mbti),
                        const SizedBox(height: 20),
                      ],

                      // ── Hasil Tes Terakhir ──
                      _buildResultSection(),
                      const SizedBox(height: 20),

                      // ── Deskripsi singkat dari mbti_profiles ──
                      if (_mbtiProfile != null) ...[
                        _buildMbtiDescSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader({
    required String username,
    required String? mbti,
    required bool hasImage,
    required String? profilePic,
  }) {
    return Row(
      children: [
        // Avatar besar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _purpleLight,
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.network(
                  profilePic!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _avatarFallback(),
                )
              : _avatarFallback(),
        ),
        const SizedBox(width: 20),

        // Nama + MBTI tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              if (mbti != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mbti,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Belum tes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: _purpleLight,
      child: const Icon(Icons.person_rounded, size: 40, color: _purple),
    );
  }

  // ── MBTI BADGE + NICKNAME ────────────────────────────────
  Widget _buildMbtiBadge(String mbti) {
    final nickname = _mbtiProfile?['nickname'] as String?;
    final shortDesc = _mbtiProfile?['short_description'] as String?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E8FA), Color(0xFFEAD5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mbti,
                style: const TextStyle(
                  color: _purple,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              if (nickname != null)
                Flexible(
                  child: Text(
                    '— $nickname',
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (shortDesc != null) ...[
            const SizedBox(height: 8),
            Text(
              shortDesc,
              style: const TextStyle(
                color: _textDark,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── HASIL TES TERAKHIR ───────────────────────────────────
  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hasil Tes Terakhir',
          style: TextStyle(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingResult)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: _purple),
            ),
          )
        else if (_latestResult == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 32, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  'Belum pernah mengikuti tes',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          _buildDimensionBars(),
      ],
    );
  }

  Widget _buildDimensionBars() {
    final r = _latestResult!;

    int scoreE = (r['score_e'] as num?)?.toInt() ?? 0;
    int scoreI = (r['score_i'] as num?)?.toInt() ?? 0;
    int scoreS = (r['score_s'] as num?)?.toInt() ?? 0;
    int scoreN = (r['score_n'] as num?)?.toInt() ?? 0;
    int scoreT = (r['score_t'] as num?)?.toInt() ?? 0;
    int scoreF = (r['score_f'] as num?)?.toInt() ?? 0;
    int scoreJ = (r['score_j'] as num?)?.toInt() ?? 0;
    int scoreP = (r['score_p'] as num?)?.toInt() ?? 0;

    double pct(int a, int b) =>
        (a + b) == 0 ? 0.5 : a / (a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDimBar(
            leftLabel: 'Ekstrovert',
            rightLabel: 'Introvert',
            leftCode: 'E',
            rightCode: 'I',
            leftValue: pct(scoreE, scoreI),
          ),
          const SizedBox(height: 14),
          _buildDimBar(
            leftLabel: 'Sensing',
            rightLabel: 'Intuition',
            leftCode: 'S',
            rightCode: 'N',
            leftValue: pct(scoreS, scoreN),
          ),
          const SizedBox(height: 14),
          _buildDimBar(
            leftLabel: 'Thinking',
            rightLabel: 'Feeling',
            leftCode: 'T',
            rightCode: 'F',
            leftValue: pct(scoreT, scoreF),
          ),
          const SizedBox(height: 14),
          _buildDimBar(
            leftLabel: 'Judging',
            rightLabel: 'Perceiving',
            leftCode: 'J',
            rightCode: 'P',
            leftValue: pct(scoreJ, scoreP),
          ),
        ],
      ),
    );
  }

  Widget _buildDimBar({
  required String leftLabel,
  required String rightLabel,
  required String leftCode,
  required String rightCode,
  required double leftValue, // 0.0 → 1.0
}) {
  final leftPct = (leftValue * 100).round();
  final rightPct = 100 - leftPct;
  final leftWins = leftValue >= 0.5;
  // Pemenang: kalau kiri menang, fill dari kiri sebesar leftValue
  // Kalau kanan menang, fill dari kanan sebesar (1 - leftValue)
  final fillFactor = leftWins ? leftValue : (1 - leftValue);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: leftWins ? _purple : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(leftCode,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w900,
                      color: leftWins ? Colors.white : Colors.grey,
                    )),
                ),
              ),
              const SizedBox(width: 6),
              Text('$leftLabel $leftPct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: leftWins ? FontWeight.w800 : FontWeight.w500,
                  color: leftWins ? _textDark : _textMuted,
                )),
            ],
          ),
          Row(
            children: [
              Text('$rightPct% $rightLabel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: !leftWins ? FontWeight.w800 : FontWeight.w500,
                  color: !leftWins ? _textDark : _textMuted,
                )),
              const SizedBox(width: 6),
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: !leftWins ? _purple : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(rightCode,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w900,
                      color: !leftWins ? Colors.white : Colors.grey,
                    )),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Background track
            Container(
              height: 10,
              color: Colors.grey[100],
            ),
            // Fill — dari kiri jika leftWins, dari kanan jika rightWins
            Align(
              alignment: leftWins
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: fillFactor,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
  Widget _buildMbtiDescSection() {
    final profile = _mbtiProfile!;

    final kekuatan = profile['strengths'] as String?;
    final kelemahan = profile['weaknesses'] as String?;
    final komunikasi = profile['communication_style'] as String?;
    final karier = profile['careers'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kepribadian',
          style: TextStyle(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (kekuatan != null)
          _buildInfoTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB938),
            title: 'Kekuatan',
            content: kekuatan,
          ),
        if (kelemahan != null) ...[
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF6B6B),
            title: 'Tantangan',
            content: kelemahan,
          ),
        ],
        if (komunikasi != null) ...[
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: const Color(0xFF4A90E2),
            title: 'Gaya Komunikasi',
            content: komunikasi,
          ),
        ],
        if (karier != null) ...[
          const SizedBox(height: 10),
          _buildInfoTile(
            icon: Icons.work_outline_rounded,
            iconColor: const Color(0xFF27AE60),
            title: 'Karier yang Cocok',
            content: karier,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}