import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

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

class FriendMbtiProfile {
  final List<String> strengths;
  final List<String> growthAreas;

  const FriendMbtiProfile({
    required this.strengths,
    required this.growthAreas,
  });
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
  FriendMbtiProfile? _profileData;

  static const Map<String, FriendMbtiProfile> _profiles = {
    'ISFP': FriendMbtiProfile(
      strengths: ['Menawan', 'Sensitif', 'Imajinatif', 'Bersemangat', 'Penasaran'],
      growthAreas: ['Sangat Mandiri', 'Mudah Stres', 'Kritis pada Diri Sendiri'],
    ),
    'INFP': FriendMbtiProfile(
      strengths: ['Empatis', 'Murah Hati', 'Berpikiran Terbuka', 'Kreatif', 'Bersemangat'],
      growthAreas: ['Terlalu Idealistis', 'Suka Mengisolasi Diri', 'Mudah Kewalahan', 'Kritis pada Diri Sendiri'],
    ),
  };

  FriendMbtiProfile _getMbtiProfile(String mbti) {
    if (_profiles.containsKey(mbti)) return _profiles[mbti]!;
    return const FriendMbtiProfile(
      strengths: ['Setia', 'Peka', 'Praktis', 'Analitis', 'Berdedikasi'],
      growthAreas: ['Kesulitan dengan Perubahan', 'Terlalu Tertutup', 'Menghindari Risiko'],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    try {
      // 1. Ambil dari tabel `users` untuk joined date dan nama asli
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

      if (!mounted) return;
      setState(() {
        _loading = false;
        
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
        
        // Data Tambahan (Kelebihan & Kekurangan)
        _profileData = _getMbtiProfile(mbti);
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
    final fromDb = profile?['full_name'] ??
        profile?['name'] ??
        profile?['nama'] ??
        profile?['username'];
    if (fromDb != null && fromDb.toString().trim().isNotEmpty) {
      return fromDb.toString().trim();
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
                      onPressed: _requestMatch,
                      icon: const Icon(Icons.favorite_rounded, size: 18),
                      label: const Text('Minta Match Ulang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
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
                    if (_profileData != null) ...[
                      _buildPillsCard(
                        icon: const Text('💪', style: TextStyle(fontSize: 20)),
                        title: 'Kelebihan (Strengths)',
                        pills: _profileData!.strengths,
                        backgroundColor: const Color(0xFFF3E8FA),
                        textColor: const Color(0xFF8E59B3),
                      ),
                      const SizedBox(height: 12),
                      _buildPillsCard(
                        icon: const Text('🌱', style: TextStyle(fontSize: 20)),
                        title: 'Area Pertumbuhan',
                        pills: _profileData!.growthAreas,
                        backgroundColor: const Color(0xFFFFF0EC),
                        textColor: const Color(0xFF8A6D65),
                      ),
                      const SizedBox(height: 12),
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
    final url = widget.friendProfilePic;
    final hasImage = url != null && url.isNotEmpty && url != 'default.png';

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, size: 42, color: Colors.grey),
            )
          : const Icon(Icons.person, size: 42, color: Colors.grey),
    );
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
          const SnackBar(content: Text('Permintaan match ulang berhasil dikirim!')),
        );
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
