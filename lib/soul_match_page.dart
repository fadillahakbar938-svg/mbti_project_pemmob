import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'add_friend_page.dart';
import 'services/supabase_service.dart';

class SoulMatchPage extends StatefulWidget {
  const SoulMatchPage({super.key});

  @override
  State<SoulMatchPage> createState() => _SoulMatchPageState();
}

class _SoulMatchPageState extends State<SoulMatchPage> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  int _activeTabSegment = 1; // 0=Friends, 1=Matched
  String _searchQuery = '';

  // MY TYPE data
  bool _loadingMyType = true;
  String _myMbti = 'UNKNOWN';
  String _myNickname = 'Personality Type';

  // Friends & Matches data
  bool _loadingList = true;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) {
      setState(() {
        _loadingMyType = false;
        _loadingList = false;
      });
      return;
    }

    // Load paralel
    await Future.wait([
      _loadMyType(userId),
      _loadFriendsAndMatches(userId),
    ]);
  }

  Future<void> _loadMyType(String userId) async {
    try {
      final profile =
          await SupabaseService.instance.getUserProfile(userId);
      final mbtiRaw = profile?['mbti_type'] as String?;
      final mbti = (mbtiRaw != null &&
              mbtiRaw.isNotEmpty &&
              mbtiRaw.toUpperCase() != 'NULL')
          ? mbtiRaw.toUpperCase()
          : null;

      String nickname = 'Personality Type';
      if (mbti != null) {
        final mbtiProfile =
            await SupabaseService.instance.getMbtiProfile(mbti);
        nickname = mbtiProfile?['nickname'] as String? ?? 'Personality Type';
      }

      if (!mounted) return;
      setState(() {
        _myMbti = mbti ?? 'UNKNOWN';
        _myNickname = nickname;
        _loadingMyType = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMyType = false);
    }
  }

  Future<void> _loadFriendsAndMatches(String userId) async {
    try {
      final friends =
          await SupabaseService.instance.getFriends(userId);
      final matches =
          await SupabaseService.instance.getMatches(userId);

      if (!mounted) return;
      setState(() {
        _friends = friends;
        _matches = matches;
        _loadingList = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingList = false);
    }
  }

  /// Ambil data user lawan dari row friend_requests
  Map<String, dynamic>? _getFriendUser(
      Map<String, dynamic> row, String currentUserId) {
    final sender = row['sender'] as Map<String, dynamic>?;
    final receiver = row['receiver'] as Map<String, dynamic>?;
    if (sender == null || receiver == null) return null;
    return sender['id'] == currentUserId ? receiver : sender;
  }

  List<Map<String, dynamic>> get _filteredFriends {
    final q = _searchQuery.toLowerCase();
    final userId = SupabaseService.instance.currentUser?.id ?? '';
    return _friends.where((row) {
      final user = _getFriendUser(row, userId);
      if (user == null) return false;
      final username = (user['username'] as String? ?? '').toLowerCase();
      final mbti = (user['mbti_type'] as String? ?? '').toLowerCase();
      return username.contains(q) || mbti.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredMatches {
    final q = _searchQuery.toLowerCase();
    return _matches.where((row) {
      final friend = row['friend'] as Map<String, dynamic>?;
      if (friend == null) return false;
      final username = (friend['username'] as String? ?? '').toLowerCase();
      final mbti = (friend['mbti_type'] as String? ?? '').toLowerCase();
      return username.contains(q) || mbti.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soul Match',
                        style: TextStyle(
                          fontSize: 32,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your most compatible types',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _buildAddFriendsButton(),
                ],
              ),
            ),

            // ── Scrollable body ──
            Expanded(
              child: RefreshIndicator(
                color: _primaryColor,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildMyTypeCard(),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildPillTabSelector(),
                      const SizedBox(height: 20),
                      _buildTabContent(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildAddFriendsButton() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFriendPage()),
            );
            // Refresh setelah kembali dari add friend
            _loadFriendsAndMatches(
                SupabaseService.instance.currentUser!.id);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Add friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyTypeCard() {
    if (_loadingMyType) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E8FA), Color(0xFFEAD5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    'https://api.dicebear.com/7.x/adventurer/png?seed=$_myMbti',
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.face_retouching_natural_rounded,
                      color: _primaryColor,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: const Text(
                      'MY TYPE',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _myMbti,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Color(0xFF1E1E1E),
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _myNickname,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2DCD5), width: 1.5),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child:
                Icon(Icons.search_rounded, color: Colors.grey[600], size: 24),
          ),
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPillTabSelector() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFE8DF),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabPill(
              title: 'Friends',
              count: _friends.length,
              isSelected: _activeTabSegment == 0,
              onTap: () => setState(() => _activeTabSegment = 0),
            ),
            _buildTabPill(
              title: 'Matched',
              count: _matches.length,
              isSelected: _activeTabSegment == 1,
              onTap: () => setState(() => _activeTabSegment = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_loadingList) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    if (_activeTabSegment == 0) {
      // Friends tab
      if (_filteredFriends.isEmpty) {
        return _buildEmptyState(
          icon: Icons.people_outline_rounded,
          title: _searchQuery.isEmpty
              ? 'Belum ada teman'
              : 'Teman tidak ditemukan',
          subtitle: _searchQuery.isEmpty
              ? 'Tambah teman lewat tombol "Add friends" di atas'
              : 'Coba cari dengan nama lain',
        );
      }
      final userId = SupabaseService.instance.currentUser?.id ?? '';
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredFriends.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final user = _getFriendUser(_filteredFriends[i], userId);
          if (user == null) return const SizedBox.shrink();
          return _buildFriendCard(user);
        },
      );
    } else {
      // Matched tab
      if (_filteredMatches.isEmpty) {
        return _buildEmptyState(
          icon: Icons.favorite_border_rounded,
          title: _searchQuery.isEmpty
              ? 'Belum ada match'
              : 'Match tidak ditemukan',
          subtitle: _searchQuery.isEmpty
              ? 'Lakukan tes kompatibilitas dengan temanmu'
              : 'Coba cari dengan nama lain',
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredMatches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _buildMatchCard(_filteredMatches[i]),
      );
    }
  }

  Widget _buildFriendCard(Map<String, dynamic> user) {
    final username = user['username'] as String? ?? 'Unknown';
    final mbtiRaw = user['mbti_type'] as String?;
    final hasValidMbti = mbtiRaw != null &&
        mbtiRaw.isNotEmpty &&
        mbtiRaw.toUpperCase() != 'NULL';
    final profilePic = user['profile_picture'] as String?;
    final hasImage = profilePic != null &&
        profilePic.isNotEmpty &&
        profilePic != 'default.png';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0EC),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.network(profilePic, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, size: 28, color: Colors.grey))
                  : const Icon(Icons.person, size: 28, color: Colors.grey),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF555555),
                    ),
                  ),
                  if (hasValidMbti) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mbtiRaw!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Tombol match (future)
            TextButton(
              onPressed: () {
                // TODO: navigasi ke halaman match dengan teman ini
              },
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
              child: const Text(
                'Match',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> row) {
    final friend = row['friend'] as Map<String, dynamic>?;
    if (friend == null) return const SizedBox.shrink();

    final username = friend['username'] as String? ?? 'Unknown';
    final mbtiRaw = friend['mbti_type'] as String?;
    final hasValidMbti = mbtiRaw != null &&
        mbtiRaw.isNotEmpty &&
        mbtiRaw.toUpperCase() != 'NULL';
    final profilePic = friend['profile_picture'] as String?;
    final hasImage = profilePic != null &&
        profilePic.isNotEmpty &&
        profilePic != 'default.png';
    final compatibility =
        (row['compatibility_percentage'] as num?)?.toInt() ?? 0;
    final compatValue = compatibility / 100.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + MBTI
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0EC),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.network(profilePic, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.grey))
                          : const Icon(Icons.person,
                              size: 36, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    if (hasValidMbti)
                      Text(
                        mbtiRaw!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        row['summary'] as String? ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Radial score
                _buildRadialScore(compatValue),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: compatValue,
                minHeight: 10,
                backgroundColor: const Color(0xFFF1EDE6),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF903636)),
              ),
            ),
            const SizedBox(height: 16),

            // Detail button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: navigasi ke detail match
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Detail Match',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadialScore(double value) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF903636), width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        '${(value * 100).toInt()}%',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}