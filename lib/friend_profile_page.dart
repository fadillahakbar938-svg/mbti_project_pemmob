import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets/mbti_avatar.dart';


class FriendProfilePage extends StatefulWidget {
  final String friendId;
  final String friendUsername;
  final String friendMbti;
  final String? friendProfilePic;

  const FriendProfilePage({
    super.key,
    required this.friendId,
    required this.friendUsername,
    required this.friendMbti,
    this.friendProfilePic,
  });

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  bool _loading = true;
  String _name = 'User';
  String _joinedText = '';
  String _mbtiLabel = 'UNKNOWN';
  String _tagline = 'Tipe Kepribadian';
  String _quote = 'Menunggu data...';
  Map<String, double> _indicators = const {};
  String _matchStatus = 'none';
  String _myMbti = 'UNKNOWN';

  Map<String, dynamic>? _dbProfile;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    try {
      // 1. Ambil dari tabel `users`
      final profile = await SupabaseService.instance.getUserProfile(widget.friendId);
      
      // 2. Ambil hasil tes terbaru dari tabel `results`
      Map<String, dynamic>? result;
      try {
        result = await SupabaseService.instance.getLatestResult(widget.friendId);
      } catch (_) {
        result = null;
      }

      // 3. Baca mbti_type 
      final mbti = widget.friendMbti.isNotEmpty && widget.friendMbti.toUpperCase() != 'NULL' 
          ? widget.friendMbti.toUpperCase() 
          : 'UNKNOWN';

      // 4. Ambil nickname & short_description dari `mbti_profiles`
      Map<String, dynamic>? mbtiProfile;
      if (mbti != 'UNKNOWN') {
        mbtiProfile = await SupabaseService.instance.getMbtiProfile(mbti);
      }

      // 5. Cek status match
      String matchStatus = 'none';
      String myMbtiType = 'UNKNOWN';
      final myId = SupabaseService.instance.currentUser?.id;
      if (myId != null) {
        matchStatus = await SupabaseService.instance.getMatchRequestStatus(
          currentUserId: myId,
          otherUserId: widget.friendId,
        );
        final myProfile = await SupabaseService.instance.getUserProfile(myId);
        final rawMyMbti = myProfile?['mbti_type'] as String?;
        if (rawMyMbti != null && rawMyMbti.isNotEmpty && rawMyMbti.toUpperCase() != 'NULL') {
          myMbtiType = rawMyMbti.toUpperCase();
        }
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _matchStatus = matchStatus;
        _myMbti = myMbtiType;
        
        // Data pengguna
        _name = _resolveDisplayName(profile, widget.friendUsername);
        _joinedText = _formatJoinedDate(profile?['created_at']);
        _mbtiLabel = mbti;

        // Data MBTI Profil
        _tagline = mbtiProfile?['nickname'] ?? 'Tipe Kepribadian';
        _quote = mbtiProfile?['short_description'] ?? 
            (mbti != 'UNKNOWN' ? 'Seorang yang unik dan berprinsip.' : 'Belum melakukan tes MBTI.');

        // Hasil Indikator
        _indicators = _indicatorsFromResult(result);
        
        // Data Lengkap dari Database
        _dbProfile = mbtiProfile;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _name = widget.friendUsername;
      });
    }
  }

  String _resolveDisplayName(Map<String, dynamic>? profile, String fallbackUsername) {
    final username = profile?['username'];
    if (username != null && username.toString().trim().isNotEmpty) {
      return username.toString().trim();
    }
    return fallbackUsername;
  }

  String _formatJoinedDate(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString());
      return 'Bergabung ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Map<String, double> _indicatorsFromResult(Map<String, dynamic>? result) {
    if (result == null) return const {};

    final e = (result['score_e'] as num?)?.toInt() ?? 0;
    final i = (result['score_i'] as num?)?.toInt() ?? 0;
    final s = (result['score_s'] as num?)?.toInt() ?? 0;
    final n = (result['score_n'] as num?)?.toInt() ?? 0;
    final t = (result['score_t'] as num?)?.toInt() ?? 0;
    final f = (result['score_f'] as num?)?.toInt() ?? 0;
    final j = (result['score_j'] as num?)?.toInt() ?? 0;
    final p = (result['score_p'] as num?)?.toInt() ?? 0;

    final ei = e + i;
    final sn = s + n;
    final tf = t + f;
    final jp = j + p;

    if (ei == 0 && sn == 0 && tf == 0 && jp == 0) return const {};

    return {
      if (ei > 0) ...{
        'Ekstrover (E)': e / ei,
        'Introver (I)': i / ei,
      },
      if (sn > 0) ...{
        'Sensing (S)': s / sn,
        'Intuisi (N)': n / sn,
      },
      if (tf > 0) ...{
        'Berpikir (T)': t / tf,
        'Perasa (F)': f / tf,
      },
      if (jp > 0) ...{
        'Menilai (J)': j / jp,
        'Menerima (P)': p / jp,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF6F0),
        body: SafeArea(
          child: Center(child: CircularProgressIndicator(color: _primaryColor)),
        ),
      );
    }

    final subtitleLine = [
      '@${widget.friendUsername.replaceAll('@', '')}',
      if (_joinedText.isNotEmpty) _joinedText,
    ].join(' · ');

    String buttonText = 'Minta Match';
    VoidCallback? onPressed = _requestMatch;

    if (_myMbti == 'UNKNOWN' || _mbtiLabel == 'UNKNOWN') {
      buttonText = 'Minta Match';
      onPressed = () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_myMbti == 'UNKNOWN' 
              ? 'Anda harus menyelesaikan tes MBTI terlebih dahulu!' 
              : 'Teman ini belum menyelesaikan tes MBTI!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      };
    } else if (_matchStatus == 'pending') {
      buttonText = 'Menunggu Balasan...';
      onPressed = null;
    } else if (_matchStatus == 'incoming') {
      buttonText = 'Cek Tab Match untuk Menerima';
      onPressed = null;
    } else if (_matchStatus == 'accepted') {
      buttonText = 'Minta Match Ulang';
      onPressed = _requestMatch;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header gradient ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3E6F5), Color(0xFFFFF3EC)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2132)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Profil Teman',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF2D2132)),
                        onSelected: _handleMenuAction,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'unfriend',
                            child: Text('Hapus Teman'),
                          ),
                          const PopupMenuItem(
                            value: 'delete_match',
                            child: Text('Hapus Riwayat Match'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitleLine,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _mbtiLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _tagline,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.favorite_rounded, size: 18),
                      label: Text(buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body scrollable ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Kepribadian',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_indicators.isEmpty)
                              Text(
                                'Belum ada data nilai tes.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              )
                            else
                                for (final entry in _indicators.entries) ...[
                                  _buildIndicatorRow(entry.key, entry.value),
                                  const SizedBox(height: 8),
                                ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FA).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _quote,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_dbProfile != null) ...[
                      if (_parseList(_dbProfile!['strengths']).isNotEmpty) ...[
                        _buildPillsCard(
                          icon: const Text('💪', style: TextStyle(fontSize: 20)),
                          title: 'Kelebihan (Strengths)',
                          pills: _parseList(_dbProfile!['strengths']),
                          backgroundColor: const Color(0xFFF3E8FA),
                          textColor: const Color(0xFF8E59B3),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_parseList(_dbProfile!['weaknesses']).isNotEmpty) ...[
                        _buildPillsCard(
                          icon: const Text('🌱', style: TextStyle(fontSize: 20)),
                          title: 'Area Pertumbuhan',
                          pills: _parseList(_dbProfile!['weaknesses']),
                          backgroundColor: const Color(0xFFFFF0EC),
                          textColor: const Color(0xFF8A6D65),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((_dbProfile!['communication_style'] as String? ?? '').isNotEmpty) ...[
                        _buildDetailStyleCard(
                          icon: const Text('💬', style: TextStyle(fontSize: 20)),
                          title: 'Gaya Komunikasi',
                          description: _dbProfile!['communication_style'] as String,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((_dbProfile!['teamwork_style'] as String? ?? '').isNotEmpty) ...[
                        _buildDetailStyleCard(
                          icon: const Text('🤝', style: TextStyle(fontSize: 20)),
                          title: 'Gaya Kerja Sama Tim',
                          description: _dbProfile!['teamwork_style'] as String,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((_dbProfile!['decision_style'] as String? ?? '').isNotEmpty) ...[
                        _buildDetailStyleCard(
                          icon: const Text('⚖️', style: TextStyle(fontSize: 20)),
                          title: 'Gaya Pengambilan Keputusan',
                          description: _dbProfile!['decision_style'] as String,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((_dbProfile!['thinking_style'] as String? ?? '').isNotEmpty) ...[
                        _buildDetailStyleCard(
                          icon: const Text('🧠', style: TextStyle(fontSize: 20)),
                          title: 'Gaya Berpikir',
                          description: _dbProfile!['thinking_style'] as String,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((_dbProfile!['activity_style'] as String? ?? '').isNotEmpty) ...[
                        _buildDetailStyleCard(
                          icon: const Text('⚡', style: TextStyle(fontSize: 20)),
                          title: 'Gaya Aktivitas',
                          description: _dbProfile!['activity_style'] as String,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_parseList(_dbProfile!['careers']).isNotEmpty) ...[
                        _buildPillsCard(
                          icon: const Text('💼', style: TextStyle(fontSize: 20)),
                          title: 'Karir',
                          pills: _parseList(_dbProfile!['careers']),
                          backgroundColor: const Color(0xFFE8F4FA),
                          textColor: const Color(0xFF2A84C9),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_parseList(_dbProfile!['activities']).isNotEmpty) ...[
                        _buildPillsCard(
                          icon: const Text('✨', style: TextStyle(fontSize: 20)),
                          title: 'Aktivitas yang Disukai',
                          pills: _parseList(_dbProfile!['activities']),
                          backgroundColor: const Color(0xFFE8F6F1),
                          textColor: const Color(0xFF2FA27C),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_parseList(_dbProfile!['avoidances']).isNotEmpty) ...[
                        _buildPillsCard(
                          icon: const Text('🚫', style: TextStyle(fontSize: 20)),
                          title: 'Hal yang Dihindari',
                          pills: _parseList(_dbProfile!['avoidances']),
                          backgroundColor: const Color(0xFFFCE8ED),
                          textColor: const Color(0xFFC92A54),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return MbtiAvatar(mbtiCode: widget.friendProfilePic, size: 74);
  }

  Widget _buildIndicatorRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: _primaryColor,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  List<String> _parseList(dynamic val) {
    if (val is List) return val.map((e) => e.toString()).toList();
    if (val is String) return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return [];
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillsCard({
    required Widget icon, required String title, required List<String> pills,
    required Color backgroundColor, required Color textColor,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: pills.map((tag) {
              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _requestMatch() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.instance.sendMatchRequest(
        senderId: userId,
        receiverId: widget.friendId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_matchStatus == 'accepted' ? 'Permintaan match ulang berhasil dikirim!' : 'Permintaan match berhasil dikirim!')),
        );
        setState(() {
          _matchStatus = 'pending';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim: $e')),
        );
      }
    }
  }

  Future<void> _handleMenuAction(String action) async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;

    try {
      if (action == 'unfriend') {
        await SupabaseService.instance.removeFriend(
          currentUserId: userId,
          friendId: widget.friendId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teman berhasil dihapus.')),
          );
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      } else if (action == 'delete_match') {
        await SupabaseService.instance.deleteMatchHistory(
          currentUserId: userId,
          friendId: widget.friendId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Riwayat match berhasil dihapus.')),
          );
          Navigator.pop(context); // Kembali agar daftar ter-refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}
