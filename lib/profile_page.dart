import 'package:flutter/material.dart';

import 'custom_bottom_navbar.dart';
import 'services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  static const Map<String, String> _mbtiTaglines = {
    'INTJ': 'The Architect',
    'INTP': 'The Thinker',
    'ENTJ': 'The Commander',
    'ENTP': 'The Debater',
    'INFJ': 'The Advocate',
    'INFP': 'The Dreamer',
    'ENFJ': 'The Protagonist',
    'ENFP': 'The Campaigner',
    'ISTJ': 'The Inspector',
    'ISFJ': 'The Protector',
    'ESTJ': 'The Executive',
    'ESFJ': 'The Consul',
    'ISTP': 'The Virtuoso',
    'ISFP': 'The Adventurer',
    'ESTP': 'The Entrepreneur',
    'ESFP': 'The Entertainer',
  };

  static const Map<String, String> _mbtiQuotes = {
    'INFP':
        '"Seseorang yang idealis, setia pada prinsip, dan selalu melihat potensi kebaikan pada orang lain."',
    'INTP':
        '"Analitis, ingin tahu, dan senang mengeksplorasi ide-ide baru."',
    'ISTJ':
        '"Praktis, dapat diandalkan, dan menghargai ketertiban serta tradisi."',
  };

  bool _loading = true;
  bool _isGuest = true;
  String _name = 'Guest User';
  String _username = '@guest';
  String _joinedText = '';
  String _mbtiLabel = 'UNKNOWN';
  String _tagline = 'Belum ada tipe';
  String _quote =
      'Selesaikan tes MBTI untuk melihat ringkasan kepribadianmu.';
  String? _profilePictureUrl;
  Map<String, double> _indicators = const {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authUser = SupabaseService.instance.currentUser;
    if (authUser == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    try {
      final profile =
          await SupabaseService.instance.getUserProfile(authUser.id);

      Map<String, dynamic>? result;
      try {
        result = await SupabaseService.instance.getLatestResult(authUser.id);
      } catch (_) {
        result = null;
      }

      final usernameRaw = profile?['username'] as String?;
      final username = usernameRaw != null && usernameRaw.isNotEmpty
          ? (usernameRaw.startsWith('@') ? usernameRaw : '@$usernameRaw')
          : '@user';

      final mbti = (profile?['mbti_type'] as String?)?.toUpperCase();
      final mbtiLabel = mbti != null && mbti.isNotEmpty ? mbti : 'UNKNOWN';

      if (!mounted) return;
      setState(() {
        _loading = false;
        _isGuest = false;
        _name = _resolveDisplayName(profile, authUser.email);
        _username = username;
        _joinedText = _formatJoinedDate(profile?['created_at']);
        _mbtiLabel = mbtiLabel;
        _tagline = _mbtiTaglines[mbtiLabel] ?? 'Personality Type';
        _quote = _mbtiQuotes[mbtiLabel] ??
            (mbtiLabel != 'UNKNOWN'
                ? 'Kamu adalah tipe $mbtiLabel.'
                : _quote);
        _profilePictureUrl = profile?['profile_picture'] as String?;
        _indicators = _indicatorsFromResult(result);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isGuest = false;
        _name = authUser.email?.split('@').first ?? 'User';
        _username = '@user';
      });
    }
  }

  String _resolveDisplayName(
    Map<String, dynamic>? profile,
    String? email,
  ) {
    final fromDb = profile?['full_name'] ??
        profile?['name'] ??
        profile?['nama'] ??
        profile?['username'];
    if (fromDb != null && fromDb.toString().trim().isNotEmpty) {
      return fromDb.toString().trim();
    }
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  String _formatJoinedDate(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString());
      return 'Joined ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Map<String, double> _indicatorsFromResult(Map<String, dynamic>? result) {
    if (result == null) return const {};

    double pct(dynamic value) {
      if (value == null) return 0;
      final n = (value as num).toDouble();
      return (n > 1 ? n / 100 : n).clamp(0.0, 1.0);
    }

    final hasPercents = result.containsKey('e_percent') ||
        result.containsKey('i_percent');

    if (hasPercents) {
      return {
        'Introverted (I)': pct(result['i_percent']),
        'Extroverted (E)': pct(result['e_percent']),
        'Intuitive (N)': pct(result['n_percent']),
        'Sensing (S)': pct(result['s_percent']),
      };
    }

    final e = (result['score_e'] as num?)?.toInt() ?? 0;
    final i = (result['score_i'] as num?)?.toInt() ?? 0;
    final n = (result['score_n'] as num?)?.toInt() ?? 0;
    final s = (result['score_s'] as num?)?.toInt() ?? 0;
    final ei = e + i;
    final sn = n + s;

    if (ei == 0 && sn == 0) return const {};

    return {
      if (ei > 0) ...{
        'Introverted (I)': i / ei,
        'Extroverted (E)': e / ei,
      },
      if (sn > 0) ...{
        'Intuitive (N)': n / sn,
        'Sensing (S)': s / sn,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: _primaryColor),
          ),
        ),
      );
    }

    final subtitleLine = [
      _username,
      if (_joinedText.isNotEmpty) _joinedText,
    ].join(' · ');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      Text(
                        'Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: _primaryColor),
                          onPressed: () {},
                          tooltip: 'Edit profile',
                        ),
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
                ],
              ),
            ),
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
                              'Personality Snapshot',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_indicators.isEmpty)
                              Text(
                                _isGuest
                                    ? 'Masuk untuk melihat hasil tes.'
                                    : 'Belum ada hasil tes. Kerjakan tes MBTI dulu.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              )
                            else
                              for (final entry in _indicators.entries) ...[
                                _buildIndicatorRow(entry.key, entry.value),
                                const SizedBox(height: 8),
                              ],
                            const SizedBox(height: 12),
                            Text(
                              _quote,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: _primaryColor,
                            ),
                            title: const Text('History / Riwayat Tes'),
                            subtitle: const Text('Lihat hasil tes sebelumnya'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.favorite,
                              color: _primaryColor,
                            ),
                            title: const Text(
                              'Compatibility / Kecocokan Teman',
                            ),
                            subtitle: Text(
                              _mbtiLabel != 'UNKNOWN'
                                  ? 'Lihat tipe yang cocok dengan $_mbtiLabel'
                                  : 'Selesaikan tes untuk melihat kecocokan',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.settings,
                              color: _primaryColor,
                            ),
                            title: const Text('Settings / Pengaturan'),
                            subtitle: const Text(
                              'Akun, notifikasi, dan keluar',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
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
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 4),
    );
  }

  Widget _buildAvatar() {
    final url = _profilePictureUrl;
    final hasImage =
        url != null && url.isNotEmpty && url != 'default.png';

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
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                size: 42,
                color: Colors.grey,
              ),
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
              style: const TextStyle(fontSize: 13),
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
}
