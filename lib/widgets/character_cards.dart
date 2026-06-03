import 'package:flutter/material.dart';

import '../card_detail_page.dart';

class _CardTheme {
  final Color background;
  final Color accent;

  const _CardTheme({required this.background, required this.accent});
}

class CharacterCards extends StatelessWidget {
  const CharacterCards({super.key});

  static const Color _emptyBg = Color(0xFFF5EFF7);
  static const Color _textMuted = Color(0xFF7D6F83);

  final List<Map<String, String>> _unlocked = const [
    {'code': 'INFP', 'title': 'Dreamer', 'emoji': '🐑', 'pos': '0'},
    {'code': 'ISTJ', 'title': 'Inspector', 'emoji': '🦉', 'pos': '1'},
    {'code': 'INTP', 'title': 'Thinker', 'emoji': '🐧', 'pos': '10'},
  ];

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
    final unlockedMap = {for (final e in _unlocked) int.parse(e['pos']!): e};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Character Cards',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D2132),
              ),
            ),
            Text(
              '3/16',
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
            widthFactor: 3 / 16,
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
          'Unlock cards by discovering new types!',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            final unlocked = unlockedMap[index];
            if (unlocked != null) {
              return _buildUnlockedCard(context, unlocked);
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
            Hero(
              tag: 'card-$code',
              child: Text(
                data['emoji'] ?? '',
                style: const TextStyle(fontSize: 32),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collection Progress',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text('3 of 16 soul types unlocked · 19% complete'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
