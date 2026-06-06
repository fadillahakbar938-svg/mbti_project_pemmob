import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets/mbti_avatar.dart';


class MbtiProfile {
  final String type;
  final String nickname;
  final String shortDescription;
  final List<String> strengths;
  final List<String> weaknesses;
  final String communicationStyle;
  final String teamworkStyle;
  final String decisionStyle;
  final String thinkingStyle;
  final String activityStyle;
  final List<String> careers;
  final List<String> activities;
  final List<String> avoidances;

  const MbtiProfile({
    required this.type,
    required this.nickname,
    required this.shortDescription,
    required this.strengths,
    required this.weaknesses,
    required this.communicationStyle,
    required this.teamworkStyle,
    required this.decisionStyle,
    required this.thinkingStyle,
    required this.activityStyle,
    required this.careers,
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

  // Static MBTI Profiles database fallback
  static const Map<String, MbtiProfile> _profiles = {
    'ISFP': MbtiProfile(
      type: 'ISFP',
      nickname: 'The Adventurer',
      shortDescription: 'Flexible and charming, you embrace art and creativity with an open, gentle spirit.',
      strengths: ['Charming', 'Sensitive', 'Imaginative', 'Passionate', 'Curious'],
      weaknesses: ['Fiercely independent', 'Easily stressed', 'Self-critical'],
      communicationStyle: 'Gentle and reserved, you communicate through actions, art, and meaningful gestures rather than many words. You are a warm and deep listener.',
      teamworkStyle: 'Flexible and easy-going, you contribute through creativity and quiet dedication. You dislike conflict and bring a peaceful, artistic presence to any team.',
      decisionStyle: 'Value-driven and spontaneous. You prefer keeping options open rather than committing early.',
      thinkingStyle: 'Focused on the present and tangible facts. You learn by doing rather than theorizing.',
      activityStyle: 'Energetic but requires solitary downtime to recharge.',
      careers: ['Artist', 'Designer', 'Musician', 'Counselor', 'Veterinarian'],
      activities: ['Painting & drawing', 'Playing music', 'Hiking & nature', 'Cooking & baking', 'Photography', 'Dance'],
      avoidances: ['Strict rules and rigid routines', 'Conflict and drama', 'Long-term abstract planning', 'Feeling constrained'],
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadResult();
  }

  Future<void> _loadResult() async {
    Map<String, dynamic>? resultData;

    // 1. Check if arguments are passed (coming directly from the QuestionPage submit)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      resultData = args;
    } else {
      // 2. Load latest result from database if no arguments passed
      final user = SupabaseService.instance.currentUser;
      if (user != null) {
        final dbResult = await SupabaseService.instance.getLatestResult(user.id);
        if (dbResult != null) {
          resultData = _parseDbResult(dbResult);
        }
      }
    }

    // 3. Fallback to mock data if everything else fails
    if (resultData == null) {
      resultData = {
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
    }

    final mbtiType = resultData['mbti_type'] as String? ?? 'ISFP';
    final dbProfile = await SupabaseService.instance.getMbtiProfile(mbtiType);

    if (mounted) {
      setState(() {
        _calculatedResult = resultData;
        _profile = _parseMbtiProfile(dbProfile, mbtiType);
        _isLoading = false;
      });
    }
  }

  MbtiProfile _parseMbtiProfile(Map<String, dynamic>? dbProfile, String fallbackMbti) {
    if (dbProfile == null) {
      return _getMbtiProfile(fallbackMbti); // fallback to hardcoded
    }

    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String) return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return [];
    }

    return MbtiProfile(
      type: dbProfile['mbti_type'] as String? ?? fallbackMbti,
      nickname: (dbProfile['nickname'] as String? ?? 'The Specialist').replaceAll(RegExp(r'[❤🤍💕♡♥❤️]'), '').trim(),
      shortDescription: dbProfile['short_description'] as String? ?? '',
      strengths: parseList(dbProfile['strengths']),
      weaknesses: parseList(dbProfile['weaknesses']),
      communicationStyle: dbProfile['communication_style'] as String? ?? '',
      teamworkStyle: dbProfile['teamwork_style'] as String? ?? '',
      decisionStyle: dbProfile['decision_style'] as String? ?? '',
      thinkingStyle: dbProfile['thinking_style'] as String? ?? '',
      activityStyle: dbProfile['activity_style'] as String? ?? '',
      careers: parseList(dbProfile['careers']),
      activities: parseList(dbProfile['activities']),
      avoidances: parseList(dbProfile['avoidances']),
    );
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
      nickname: _getMbtiTitle(mbti),
      shortDescription: 'A unique and insightful profile driven by values, dedication, and clear principles.',
      strengths: ['Loyal', 'Perceptive', 'Practical', 'Analytical', 'Dedicated'],
      weaknesses: ['Struggles with change', 'Overly reserved', 'Avoids risks'],
      communicationStyle: 'Direct and focused. You prefer realistic talks and concrete details over abstract plans.',
      teamworkStyle: 'Reliable and task-oriented. You work quietly and complete your commitments with high standards.',
      decisionStyle: 'Logical and structured.',
      thinkingStyle: 'Analytical and detail-oriented.',
      activityStyle: 'Organized and methodical.',
      careers: ['Specialist', 'Analyst', 'Engineer'],
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
                      profile.nickname,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF8E59B3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Score Profile Card
                _buildScoreProfileCard(result, profile),

                const SizedBox(height: 20),

                // Introduction summary card
                if (profile.shortDescription.isNotEmpty) ...[
                  _buildDescriptionCard(profile.shortDescription),
                  const SizedBox(height: 20),
                ],

                // Strengths
                if (profile.strengths.isNotEmpty) ...[
                  _buildPillsCard(
                    icon: const Text('💪', style: TextStyle(fontSize: 20)),
                    title: 'Strengths',
                    pills: profile.strengths,
                    backgroundColor: const Color(0xFFF3E8FA),
                    textColor: const Color(0xFF8E59B3),
                  ),
                  const SizedBox(height: 20),
                ],

                // Weaknesses
                if (profile.weaknesses.isNotEmpty) ...[
                  _buildPillsCard(
                    icon: const Text('🌱', style: TextStyle(fontSize: 20)),
                    title: 'Weaknesses',
                    pills: profile.weaknesses,
                    backgroundColor: const Color(0xFFFFF0EC),
                    textColor: const Color(0xFF8A6D65),
                  ),
                  const SizedBox(height: 20),
                ],

                // Communication Style
                if (profile.communicationStyle.isNotEmpty) ...[
                  _buildDetailStyleCard(
                    icon: const Text('💬', style: TextStyle(fontSize: 20)),
                    title: 'Communication Style',
                    description: profile.communicationStyle,
                  ),
                  const SizedBox(height: 20),
                ],

                // Teamwork Style
                if (profile.teamworkStyle.isNotEmpty) ...[
                  _buildDetailStyleCard(
                    icon: const Text('🤝', style: TextStyle(fontSize: 20)),
                    title: 'Teamwork Style',
                    description: profile.teamworkStyle,
                  ),
                  const SizedBox(height: 20),
                ],

                // Decision Style
                if (profile.decisionStyle.isNotEmpty) ...[
                  _buildDetailStyleCard(
                    icon: const Text('⚖️', style: TextStyle(fontSize: 20)),
                    title: 'Decision Style',
                    description: profile.decisionStyle,
                  ),
                  const SizedBox(height: 20),
                ],

                // Thinking Style
                if (profile.thinkingStyle.isNotEmpty) ...[
                  _buildDetailStyleCard(
                    icon: const Text('🧠', style: TextStyle(fontSize: 20)),
                    title: 'Thinking Style',
                    description: profile.thinkingStyle,
                  ),
                  const SizedBox(height: 20),
                ],

                // Activity Style
                if (profile.activityStyle.isNotEmpty) ...[
                  _buildDetailStyleCard(
                    icon: const Text('⚡', style: TextStyle(fontSize: 20)),
                    title: 'Activity Style',
                    description: profile.activityStyle,
                  ),
                  const SizedBox(height: 20),
                ],

                // Careers
                if (profile.careers.isNotEmpty) ...[
                  _buildPillsCard(
                    icon: const Text('💼', style: TextStyle(fontSize: 20)),
                    title: 'Careers',
                    pills: profile.careers,
                    backgroundColor: const Color(0xFFE8F4FA),
                    textColor: const Color(0xFF2A84C9),
                  ),
                  const SizedBox(height: 20),
                ],

                // Activities You Love
                if (profile.activities.isNotEmpty) ...[
                  _buildPillsCard(
                    icon: const Text('✨', style: TextStyle(fontSize: 20)),
                    title: 'Activities You Love',
                    pills: profile.activities,
                    backgroundColor: const Color(0xFFE8F6F1),
                    textColor: const Color(0xFF2FA27C),
                  ),
                  const SizedBox(height: 20),
                ],

                // Avoidances
                if (profile.avoidances.isNotEmpty) ...[
                  _buildPillsCard(
                    icon: const Text('🚫', style: TextStyle(fontSize: 20)),
                    title: 'Avoidances',
                    pills: profile.avoidances,
                    backgroundColor: const Color(0xFFFCE8ED),
                    textColor: const Color(0xFFC92A54),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile avatar using the MBTI character images
  Widget _buildCharacterCircle(MbtiProfile profile) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: MbtiAvatar(
        mbtiCode: profile.type,
        size: 160,
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Text(
                  '${(val * 100).round()}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return LinearProgressIndicator(
                value: val,
                minHeight: 8,
                color: const Color(0xFF8E59B3),
                backgroundColor: Colors.grey[200],
              );
            },
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

}
