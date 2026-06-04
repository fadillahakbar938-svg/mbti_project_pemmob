import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'soul_match_page.dart';


class MbtiProfile {
  final String type;
  final String title;
  final String emoji;
  final String sticker;
  final String description;
  final List<String> strengths;
  final List<String> growthAreas;
  final String communicationStyle;
  final String teamworkStyle;
  final List<String> activities;
  final List<String> avoidances;

  const MbtiProfile({
    required this.type,
    required this.title,
    required this.emoji,
    required this.sticker,
    required this.description,
    required this.strengths,
    required this.growthAreas,
    required this.communicationStyle,
    required this.teamworkStyle,
    required this.activities,
    required this.avoidances,
  });
}

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _calculatedResult;
  MbtiProfile? _profile;

  // Static MBTI Profiles database
  static const Map<String, MbtiProfile> _profiles = {
    'ISFP': MbtiProfile(
      type: 'ISFP',
      title: 'The Adventurer',
      emoji: '🎨',
      sticker: '🎨',
      description: 'Flexible and charming, you embrace art and creativity with an open, gentle spirit.',
      strengths: ['Charming', 'Sensitive', 'Imaginative', 'Passionate', 'Curious'],
      growthAreas: ['Fiercely independent', 'Easily stressed', 'Self-critical'],
      communicationStyle: 'Gentle and reserved, you communicate through actions, art, and meaningful gestures rather than many words. You are a warm and deep listener.',
      teamworkStyle: 'Flexible and easy-going, you contribute through creativity and quiet dedication. You dislike conflict and bring a peaceful, artistic presence to any team.',
      activities: ['Painting & drawing', 'Playing music', 'Hiking & nature', 'Cooking & baking', 'Photography', 'Dance'],
      avoidances: ['Strict rules and rigid routines', 'Conflict and drama', 'Long-term abstract planning', 'Feeling constrained'],
    ),
    'INFP': MbtiProfile(
      type: 'INFP',
      title: 'The Dreamer',
      emoji: '🐑',
      sticker: '🔮',
      description: 'Quiet, imaginative, and sensitive, you seek to live a life true to your values and inner vision.',
      strengths: ['Empathetic', 'Generous', 'Open-minded', 'Creative', 'Passionate'],
      growthAreas: ['Overly idealistic', 'Self-isolating', 'Easily overwhelmed', 'Self-critical'],
      communicationStyle: 'Warm, thoughtful, and encouraging. You communicate with sincerity and prefer deep, meaningful one-on-one connections.',
      teamworkStyle: 'Cooperative and supportive, you bring harmony and a strong sense of purpose to your team. You value everyone\'s voice.',
      activities: ['Writing & poetry', 'Reading', 'Listening to music', 'Volunteering', 'Creative crafts'],
      avoidances: ['Harsh criticism', 'Cold logic without empathy', 'Large crowd socializing', 'Strict conformity'],
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadResult();
  }

  Future<void> _loadResult() async {
    // 1. Check if arguments are passed (coming directly from the QuestionPage submit)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _calculatedResult = args;
        _profile = _getMbtiProfile(args['mbti_type'] as String? ?? 'ISFP');
        _isLoading = false;
      });
      return;
    }

    // 2. Load latest result from database if no arguments passed (coming from dashboard)
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      final dbResult = await SupabaseService.instance.getLatestResult(user.id);
      if (dbResult != null) {
        setState(() {
          _calculatedResult = _parseDbResult(dbResult);
          _profile = _getMbtiProfile(_calculatedResult!['mbti_type'] as String? ?? 'ISFP');
          _isLoading = false;
        });
        return;
      }
    }

    // 3. Fallback to mock data if everything else fails (so the page never crashes)
    setState(() {
      _calculatedResult = {
        'mbti_type': 'ISFP',
        'e_percent': 25.0,
        'i_percent': 75.0,
        'n_percent': 25.0,
        's_percent': 75.0,
        'f_percent': 75.0,
        't_percent': 25.0,
        'p_percent': 75.0,
        'j_percent': 25.0,
      };
      _profile = _profiles['ISFP'];
      _isLoading = false;
    });
  }

  // Parse result saved in DB to match our display map
  Map<String, dynamic> _parseDbResult(Map<String, dynamic> db) {
    double getPercentage(int a, int b) {
      if (a + b == 0) return 50.0;
      return a / (a + b) * 100;
    }

    final scoreE = (db['score_e'] as num?)?.toInt() ?? 0;
    final scoreI = (db['score_i'] as num?)?.toInt() ?? 0;
    final scoreN = (db['score_n'] as num?)?.toInt() ?? 0;
    final scoreS = (db['score_s'] as num?)?.toInt() ?? 0;
    final scoreT = (db['score_t'] as num?)?.toInt() ?? 0;
    final scoreF = (db['score_f'] as num?)?.toInt() ?? 0;
    final scoreJ = (db['score_j'] as num?)?.toInt() ?? 0;
    final scoreP = (db['score_p'] as num?)?.toInt() ?? 0;

    return {
      'mbti_type': db['mbti_type'] as String? ?? 'ISFP',
      'e_percent': getPercentage(scoreE, scoreI),
      'i_percent': getPercentage(scoreI, scoreE),
      's_percent': getPercentage(scoreS, scoreN),
      'n_percent': getPercentage(scoreN, scoreS),
      'f_percent': getPercentage(scoreF, scoreT),
      't_percent': getPercentage(scoreT, scoreF),
      'p_percent': getPercentage(scoreP, scoreJ),
      'j_percent': getPercentage(scoreJ, scoreP),
    };
  }

  String _getMbtiTitle(String mbti) {
    switch (mbti) {
      case 'INTJ': return 'The Architect';
      case 'INTP': return 'The Logician';
      case 'ENTJ': return 'The Commander';
      case 'ENTP': return 'The Debater';
      case 'INFJ': return 'The Advocate';
      case 'INFP': return 'The Mediator';
      case 'ENFJ': return 'The Protagonist';
      case 'ENFP': return 'The Campaigner';
      case 'ISTJ': return 'The Logistician';
      case 'ISFJ': return 'The Defender';
      case 'ESTJ': return 'The Executive';
      case 'ESFJ': return 'The Consul';
      case 'ISTP': return 'The Virtuoso';
      case 'ISFP': return 'The Adventurer';
      case 'ESTP': return 'The Entrepreneur';
      case 'ESFP': return 'The Entertainer';
      default: return 'The Specialist';
    }
  }

  MbtiProfile _getMbtiProfile(String mbti) {
    if (_profiles.containsKey(mbti)) {
      return _profiles[mbti]!;
    }
    // Dynamic generation fallback for missing types
    return MbtiProfile(
      type: mbti,
      title: _getMbtiTitle(mbti),
      emoji: '🌟',
      sticker: '✨',
      description: 'A unique and insightful profile driven by values, dedication, and clear principles.',
      strengths: ['Loyal', 'Perceptive', 'Practical', 'Analytical', 'Dedicated'],
      growthAreas: ['Struggles with change', 'Overly reserved', 'Avoids risks'],
      communicationStyle: 'Direct and focused. You prefer realistic talks and concrete details over abstract plans.',
      teamworkStyle: 'Reliable and task-oriented. You work quietly and complete your commitments with high standards.',
      activities: ['Reading', 'Technology', 'Outdoor sports', 'Individual research', 'Strategy games'],
      avoidances: ['Unproductive meetings', 'Ambiguity', 'Loud environments', 'Unnecessary conflicts'],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF6F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E59B3)),
          ),
        ),
      );
    }

    final result = _calculatedResult!;
    final profile = _profile!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Soft cream background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF6F0), // Top background
              Color(0xFFF3E8FA), // Bottom background
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top header label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2132)),
                      onPressed: () {
                        // Jika bisa kembali, kembali, jika tidak arahkan ke home
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                    ),
                    const Text(
                      'YOUR PERSONALITY TYPE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF8E59B3),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the row
                  ],
                ),
                const SizedBox(height: 24),

                // Main character circle representation
                _buildCharacterCircle(profile),

                const SizedBox(height: 20),

                // MBTI code
                Text(
                  profile.type,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2132),
                    letterSpacing: -1.0,
                  ),
                ),

                // Subtitle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF8E59B3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '💜',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Score Profile Card
                _buildScoreProfileCard(result, profile),

                const SizedBox(height: 20),

                // Introduction summary card
                _buildDescriptionCard(profile.description),

                const SizedBox(height: 20),

                // Strengths
                _buildPillsCard(
                  icon: const Text('💪', style: TextStyle(fontSize: 20)),
                  title: 'Strengths',
                  pills: profile.strengths,
                  backgroundColor: const Color(0xFFF3E8FA),
                  textColor: const Color(0xFF8E59B3),
                ),

                const SizedBox(height: 20),

                // Growth Areas
                _buildPillsCard(
                  icon: const Text('🌱', style: TextStyle(fontSize: 20)),
                  title: 'Growth Areas',
                  pills: profile.growthAreas,
                  backgroundColor: const Color(0xFFFFF0EC),
                  textColor: const Color(0xFF8A6D65),
                ),

                const SizedBox(height: 20),

                // Communication Style
                _buildDetailStyleCard(
                  icon: const Text('💬', style: TextStyle(fontSize: 20)),
                  title: 'Communication Style',
                  description: profile.communicationStyle,
                ),

                const SizedBox(height: 20),

                // Teamwork Style
                _buildDetailStyleCard(
                  icon: const Text('🤝', style: TextStyle(fontSize: 20)),
                  title: 'Teamwork Style',
                  description: profile.teamworkStyle,
                ),

                const SizedBox(height: 20),

                // Activities You Love
                _buildPillsCard(
                  icon: const Text('✨', style: TextStyle(fontSize: 20)),
                  title: 'Activities You Love',
                  pills: profile.activities,
                  backgroundColor: const Color(0xFFE8F6F1),
                  textColor: const Color(0xFF2FA27C),
                ),

                const SizedBox(height: 20),

                // Avoidances
                _buildPillsCard(
                  icon: const Text('🚫', style: TextStyle(fontSize: 20)),
                  title: 'Avoidances',
                  pills: profile.avoidances,
                  backgroundColor: const Color(0xFFFCE8ED),
                  textColor: const Color(0xFFC92A54),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cute Character Circle representing the ISFP / INFP avatar blob
  Widget _buildCharacterCircle(MbtiProfile profile) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // White circular background
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),

        // Custom drawn Cute Purple Character Blob
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            color: Color(0xFF8E59B3), // Purple creature body
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(52),
              topRight: Radius.circular(52),
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Stack(
            children: [
              // Blush
              Positioned(
                left: 14,
                top: 54,
                child: Container(
                  width: 14,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAEC9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: 54,
                child: Container(
                  width: 14,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAEC9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Eyes
              Positioned(
                left: 28,
                top: 36,
                child: _buildEye(),
              ),
              Positioned(
                right: 28,
                top: 36,
                child: _buildEye(),
              ),

              // Smile
              Positioned(
                left: 0,
                right: 0,
                top: 58,
                child: Center(
                  child: Container(
                    width: 24,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2D2132),
                        width: 3.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top-right sticker indicator (e.g. Paint Palette)
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              profile.sticker,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEye() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFF2D2132),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Score Profile Card containing linear bars
  Widget _buildScoreProfileCard(Map<String, dynamic> result, MbtiProfile profile) {
    double getSafeDouble(dynamic val, double defaultVal) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    final eVal = getSafeDouble(result['e_percent'], 50.0);
    final iVal = getSafeDouble(result['i_percent'], 50.0);
    final sVal = getSafeDouble(result['s_percent'], 50.0);
    final nVal = getSafeDouble(result['n_percent'], 50.0);
    final fVal = getSafeDouble(result['f_percent'], 50.0);
    final tVal = getSafeDouble(result['t_percent'], 50.0);
    final pVal = getSafeDouble(result['p_percent'], 50.0);
    final jVal = getSafeDouble(result['j_percent'], 50.0);

    final Map<String, double> indicators = {
      if (eVal > 0) 'Ekstrover (E)': eVal / 100,
      if (iVal > 0) 'Introver (I)': iVal / 100,
      if (sVal > 0) 'Sensing (S)': sVal / 100,
      if (nVal > 0) 'Intuisi (N)': nVal / 100,
      if (tVal > 0) 'Berpikir (T)': tVal / 100,
      if (fVal > 0) 'Perasa (F)': fVal / 100,
      if (jVal > 0) 'Menilai (J)': jVal / 100,
      if (pVal > 0) 'Menerima (P)': pVal / 100,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const Text(
                    'Score Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2132),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  'mbti_type: ${profile.type}',
                  style: const TextStyle(
                    color: Color(0xFF8E59B3),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bars
          for (final entry in indicators.entries) ...[
            _buildIndicatorRow(entry.key, entry.value),
            const SizedBox(height: 8),
          ],
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
            color: const Color(0xFF8E59B3),
            backgroundColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D2132),
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Pill Tags container card
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
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

  // Detail Paragraph Card (for Styles)
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D2132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindMatchesButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E59B3).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SoulMatchPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E59B3),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Find My Soul Matches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '💕',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
