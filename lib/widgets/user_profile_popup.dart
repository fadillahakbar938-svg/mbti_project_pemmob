import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

import '../widgets/mbti_avatar.dart';

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
    final mbti = hasValidMbti ? mbtiRaw.toUpperCase() : null;

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
  }) {
    return Row(
      children: [
        // Avatar besar
        MbtiAvatar(mbtiCode: mbti, size: 80),
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
          _buildIndicatorRow('Ekstrovert', pct(scoreE, scoreI)),
          const SizedBox(height: 8),
          _buildIndicatorRow('Introvert', pct(scoreI, scoreE)),
          const SizedBox(height: 16),
          
          _buildIndicatorRow('Sensing', pct(scoreS, scoreN)),
          const SizedBox(height: 8),
          _buildIndicatorRow('Intuition', pct(scoreN, scoreS)),
          const SizedBox(height: 16),
          
          _buildIndicatorRow('Thinking', pct(scoreT, scoreF)),
          const SizedBox(height: 8),
          _buildIndicatorRow('Feeling', pct(scoreF, scoreT)),
          const SizedBox(height: 16),
          
          _buildIndicatorRow('Judging', pct(scoreJ, scoreP)),
          const SizedBox(height: 8),
          _buildIndicatorRow('Perceiving', pct(scoreP, scoreJ)),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600)),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _purple),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            color: _purple,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  List<String> _parseList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    if (val is String) {
      return val.split(RegExp(r'[,|]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Widget _buildMbtiDescSection() {
    final profile = _mbtiProfile!;

    final kekuatan = _parseList(profile['strengths']);
    final kelemahan = _parseList(profile['weaknesses']);
    final komunikasi = profile['communication_style'] as String?;
    final tim = profile['teamwork_style'] as String?;
    final keputusan = profile['decision_style'] as String?;
    final berpikir = profile['thinking_style'] as String?;
    final aktivitasGaya = profile['activity_style'] as String?;
    final karier = _parseList(profile['careers']);
    final aktivitas = _parseList(profile['activities']);
    final hindari = _parseList(profile['avoidances']);

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
        if (kekuatan.isNotEmpty) ...[
          _buildPillsCard(
            icon: const Text('💪', style: TextStyle(fontSize: 20)),
            title: 'Kelebihan',
            pills: kekuatan,
            backgroundColor: const Color(0xFFF3E8FA),
            textColor: const Color(0xFF8E59B3),
          ),
          const SizedBox(height: 12),
        ],
        if (kelemahan.isNotEmpty) ...[
          _buildPillsCard(
            icon: const Text('🌱', style: TextStyle(fontSize: 20)),
            title: 'Area Pertumbuhan',
            pills: kelemahan,
            backgroundColor: const Color(0xFFFFF0EC),
            textColor: const Color(0xFF8A6D65),
          ),
          const SizedBox(height: 12),
        ],
        if (komunikasi != null && komunikasi.isNotEmpty) ...[
          _buildDetailStyleCard(
            icon: const Text('💬', style: TextStyle(fontSize: 20)),
            title: 'Gaya Komunikasi',
            description: komunikasi,
          ),
          const SizedBox(height: 12),
        ],
        if (tim != null && tim.isNotEmpty) ...[
          _buildDetailStyleCard(
            icon: const Text('🤝', style: TextStyle(fontSize: 20)),
            title: 'Gaya Kerja Sama Tim',
            description: tim,
          ),
          const SizedBox(height: 12),
        ],
        if (keputusan != null && keputusan.isNotEmpty) ...[
          _buildDetailStyleCard(
            icon: const Text('⚖️', style: TextStyle(fontSize: 20)),
            title: 'Gaya Pengambilan Keputusan',
            description: keputusan,
          ),
          const SizedBox(height: 12),
        ],
        if (berpikir != null && berpikir.isNotEmpty) ...[
          _buildDetailStyleCard(
            icon: const Text('🧠', style: TextStyle(fontSize: 20)),
            title: 'Gaya Berpikir',
            description: berpikir,
          ),
          const SizedBox(height: 12),
        ],
        if (aktivitasGaya != null && aktivitasGaya.isNotEmpty) ...[
          _buildDetailStyleCard(
            icon: const Text('⚡', style: TextStyle(fontSize: 20)),
            title: 'Gaya Aktivitas',
            description: aktivitasGaya,
          ),
          const SizedBox(height: 12),
        ],
        if (karier.isNotEmpty) ...[
          _buildPillsCard(
            icon: const Text('💼', style: TextStyle(fontSize: 20)),
            title: 'Karier yang Cocok',
            pills: karier,
            backgroundColor: const Color(0xFFE8F4FA),
            textColor: const Color(0xFF2A84C9),
          ),
          const SizedBox(height: 12),
        ],
        if (aktivitas.isNotEmpty) ...[
          _buildPillsCard(
            icon: const Text('✨', style: TextStyle(fontSize: 20)),
            title: 'Aktivitas yang Disukai',
            pills: aktivitas,
            backgroundColor: const Color(0xFFE8F6F1),
            textColor: const Color(0xFF2FA27C),
          ),
          const SizedBox(height: 12),
        ],
        if (hindari.isNotEmpty) ...[
          _buildPillsCard(
            icon: const Text('🚫', style: TextStyle(fontSize: 20)),
            title: 'Hal yang Dihindari',
            pills: hindari,
            backgroundColor: const Color(0xFFFCE8ED),
            textColor: const Color(0xFFC92A54),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildDetailStyleCard({
    required Widget icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7D6F83),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillsCard({
    required Widget icon,
    required String title,
    required List<String> pills,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pills.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}