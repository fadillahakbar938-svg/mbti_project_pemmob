import 'package:flutter/material.dart';
import 'package:mbti_project_pemmob/services/supabase_service.dart';

class MatchDetailPage extends StatefulWidget {
  final int historyId;
  final SupabaseService supabaseService;

  const MatchDetailPage({
    super.key,
    required this.historyId,
    required this.supabaseService,
  });

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  Map<String, dynamic>? _matchData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatchDetail();
  }

  Future<void> _loadMatchDetail() async {
    try {
      final data = await widget.supabaseService.getMatchDetail(widget.historyId);
      if (data == null) {
        setState(() {
          _error = 'Data tidak ditemukan';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _matchData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan saat memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildAvatar(Map<String, dynamic> user, String mbti, {bool isRight = false}) {
    final hasProfilePic = user['profile_picture'] != null && user['profile_picture'].toString().isNotEmpty;
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            image: hasProfilePic
                ? DecorationImage(
                    image: NetworkImage(user['profile_picture']),
                    fit: BoxFit.cover,
                  )
                : null,
            color: hasProfilePic ? null : Colors.white24,
          ),
          child: !hasProfilePic
              ? const Icon(Icons.person, size: 40, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          user['username'] ?? 'User',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            mbti,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String content, IconData icon, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: TextStyle(color: Colors.grey[800], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _matchData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Match')),
        body: Center(child: Text(_error ?? 'Data tidak ditemukan')),
      );
    }

    final user = _matchData!['user'];
    final friend = _matchData!['friend'];
    final userMbti = _matchData!['user_mbti'];
    final friendMbti = _matchData!['friend_mbti'];
    final compat = _matchData!['compatibility'] as Map<String, dynamic>? ?? {};

    final int percentage = compat['compatibility_percentage'] ?? 50;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kecocokan Profil'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6C63FF), Color(0xFF8A82FF)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildAvatar(user, userMbti)),
                      
                      // Match Icon / Score
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage >= 80 ? Colors.greenAccent :
                                percentage >= 60 ? Colors.yellowAccent :
                                Colors.orangeAccent
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Cocok',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      Expanded(child: _buildAvatar(friend, friendMbti, isRight: true)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Card
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Ringkasan Hubungan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            compat['summary'] ?? '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Detail Analisis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildCategoryCard(
                    'Komunikasi',
                    compat['communication_match'] ?? '-',
                    Icons.chat_bubble_outline,
                    Colors.blue,
                  ),
                  _buildCategoryCard(
                    'Kerja Sama Tim',
                    compat['teamwork_match'] ?? '-',
                    Icons.handshake_outlined,
                    Colors.teal,
                  ),
                  _buildCategoryCard(
                    'Gaya Berpikir',
                    compat['thinking_style_match'] ?? '-',
                    Icons.psychology_outlined,
                    Colors.purple,
                  ),
                  _buildCategoryCard(
                    'Pengambilan Keputusan',
                    compat['decision_making_match'] ?? '-',
                    Icons.balance_outlined,
                    Colors.indigo,
                  ),
                  _buildCategoryCard(
                    'Ritme Aktivitas',
                    compat['activity_rhythm_match'] ?? '-',
                    Icons.schedule_outlined,
                    Colors.orange,
                  ),
                  _buildCategoryCard(
                    'Potensi Konflik',
                    compat['conflict_potential'] ?? '-',
                    Icons.warning_amber_rounded,
                    Colors.red,
                  ),
                  _buildCategoryCard(
                    'Hal yang Dihindari',
                    compat['avoidances'] ?? '-',
                    Icons.do_not_disturb_alt_outlined,
                    Colors.redAccent,
                  ),
                  _buildCategoryCard(
                    'Saran Pertemanan',
                    compat['friendship_advice'] ?? '-',
                    Icons.lightbulb_outline,
                    Colors.yellow.shade800,
                  ),
                  _buildCategoryCard(
                    'Aktivitas Cocok',
                    compat['suitable_activities'] ?? '-',
                    Icons.celebration_outlined,
                    Colors.pink,
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
