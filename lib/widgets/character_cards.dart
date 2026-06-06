import 'package:flutter/material.dart';

import '../card_detail_page.dart';

import '../services/supabase_service.dart';

class _CardTheme {
  final Color background;
  final Color accent;

  const _CardTheme({required this.background, required this.accent});
}

class CharacterCards extends StatefulWidget {
  const CharacterCards({super.key});

  @override
  State<CharacterCards> createState() => _CharacterCardsState();
}

class _CharacterCardsState extends State<CharacterCards> {
  static const Color _emptyBg = Color(0xFFF5EFF7);
  static const Color _textMuted = Color(0xFF7D6F83);

  bool _isLoading = true;
  Set<String> _unlockedTypes = {};

  final List<Map<String, String>> _allTypes = [
    {'code': 'INTJ', 'title': 'Architect', 'emoji': '♟️'},
    {'code': 'INTP', 'title': 'Logician', 'emoji': '🐧'},
    {'code': 'ENTJ', 'title': 'Commander', 'emoji': '🦅'},
    {'code': 'ENTP', 'title': 'Debater', 'emoji': '🦊'},
    {'code': 'INFJ', 'title': 'Advocate', 'emoji': '🕊️'},
    {'code': 'INFP', 'title': 'Mediator', 'emoji': '🐑'},
    {'code': 'ENFJ', 'title': 'Protagonist', 'emoji': '🐕'},
    {'code': 'ENFP', 'title': 'Campaigner', 'emoji': '🐬'},
    {'code': 'ISTJ', 'title': 'Logistician', 'emoji': '🦉'},
    {'code': 'ISFJ', 'title': 'Defender', 'emoji': '🐢'},
    {'code': 'ESTJ', 'title': 'Executive', 'emoji': '🦁'},
    {'code': 'ESFJ', 'title': 'Consul', 'emoji': '🐘'},
    {'code': 'ISTP', 'title': 'Virtuoso', 'emoji': '🛠️'},
    {'code': 'ISFP', 'title': 'Adventurer', 'emoji': '🎨'},
    {'code': 'ESTP', 'title': 'Entrepreneur', 'emoji': '🚀'},
    {'code': 'ESFP', 'title': 'Entertainer', 'emoji': '🦚'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUnlockedCards();
  }

  Future<void> _loadUnlockedCards() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final Set<String> unlocked = {};

    try {
      final myResult = await SupabaseService.instance.getLatestResult(userId);
      if (myResult != null && myResult['mbti_type'] != null) {
        unlocked.add((myResult['mbti_type'] as String).toUpperCase());
      }

      final matches = await SupabaseService.instance.getMatches(userId);
      for (var match in matches) {
        final friendMbti = match['friend_mbti'] as String?;
        if (friendMbti != null && friendMbti.isNotEmpty && friendMbti.toUpperCase() != 'NULL') {
          unlocked.add(friendMbti.toUpperCase());
        }
      }
    } catch (_) {
      // ignore
    }

    if (mounted) {
      setState(() {
        _unlockedTypes = unlocked;
        _isLoading = false;
      });
    }
  }



  _CardTheme _themeFor(String code) {
    switch (code) {
      case 'INFP':
        return const _CardTheme(
          background: Color(0xFFF3E8FC),
          accent: Color(0xFF8E59B3),
        );
      case 'ISTJ':
        return const _CardTheme(
          background: Color(0xFFE8F5EC),
          accent: Color(0xFF3D9A5F),
        );
      case 'INTP':
        return const _CardTheme(
          background: Color(0xFFE3F0FC),
          accent: Color(0xFF4A90E2),
        );
      default:
        return const _CardTheme(
          background: Color(0xFFF3E8FC),
          accent: Color(0xFF8E59B3),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF8E59B3)),
        ),
      );
    }

    final int unlockedCount = _unlockedTypes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kartu Karakter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2132),
              ),
            ),
            Text(
              '$unlockedCount/16',
              style: TextStyle(
                color: Colors.purple.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E3FC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: unlockedCount / 16,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8E59B3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Buka kartu dengan menemukan tipe MBTI baru!',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            final typeData = _allTypes[index];
            final code = typeData['code']!;
            if (_unlockedTypes.contains(code)) {
              return _buildUnlockedCard(context, typeData);
            }
            return _buildPlaceholderCard();
          },
        ),
        const SizedBox(height: 20),
        _buildProgressCard(context),
      ],
    );
  }

  BoxDecoration _cardDecoration({required Color background}) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(decoration: _cardDecoration(background: _emptyBg));
  }

  Widget _buildUnlockedCard(BuildContext context, Map<String, String> data) {
    final code = data['code'] ?? '';
    final theme = _themeFor(code);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CardDetailPage(
              code: code,
              title: data['title'] ?? '',
              emoji: data['emoji'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        decoration: _cardDecoration(background: theme.background),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Hero(
                tag: 'card-$code',
                child: Image.asset(
                  'assets/images/$code.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              code,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: theme.accent,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data['title'] ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFDEDD0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: Color(0xFFEE9F36)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progres Koleksi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text('${_unlockedTypes.length} dari 16 tipe soul terbuka · ${((_unlockedTypes.length / 16) * 100).toInt()}% selesai'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
