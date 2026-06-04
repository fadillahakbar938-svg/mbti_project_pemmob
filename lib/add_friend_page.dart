import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'services/supabase_service.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Cache status per userId agar tidak re-fetch terus
  final Map<String, String> _statusCache = {};

  String? get _currentUserId =>
      SupabaseService.instance.currentUser?.id;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await SupabaseService.instance.searchUsers(
        query: trimmed,
        excludeUserId: _currentUserId,
      );

      // Fetch semua status paralel, tidak sequential
      // Jika gagal, default ke 'none' — tidak crash
      final statuses = <String, String>{};
      if (_currentUserId != null) {
        await Future.wait(
          results.map((user) async {
            final uid = user['id'] as String;
            if (_statusCache.containsKey(uid)) {
              statuses[uid] = _statusCache[uid]!;
            } else {
              try {
                final status = await SupabaseService.instance
                    .getFriendRequestStatus(
                  currentUserId: _currentUserId!,
                  otherUserId: uid,
                );
                statuses[uid] = status;
              } catch (_) {
                statuses[uid] = 'none'; // fallback jika gagal
              }
            }
          }),
        );
      } else {
        // Tidak login — semua 'none'
        for (final user in results) {
          statuses[user['id'] as String] = 'none';
        }
      }

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _statusCache.addAll(statuses);
        _isSearching = false;
      });
    } catch (e) {
      print('DEBUG _doSearch ERROR: $e');
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  Future<void> _toggleFriendRequest(String targetUserId) async {
    final currentId = _currentUserId;
    if (currentId == null) return;

    final currentStatus = _statusCache[targetUserId] ?? 'none';

    // Optimistic update
    setState(() {
      _statusCache[targetUserId] =
          currentStatus == 'none' ? 'pending' : 'none';
    });

    try {
      if (currentStatus == 'none') {
        await SupabaseService.instance.sendFriendRequest(
          senderId: currentId,
          receiverId: targetUserId,
        );
      } else if (currentStatus == 'pending') {
        await SupabaseService.instance.cancelFriendRequest(
          senderId: currentId,
          receiverId: targetUserId,
        );
      }
    } catch (_) {
      // Rollback jika gagal
      if (!mounted) return;
      setState(() => _statusCache[targetUserId] = currentStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal, coba lagi.')),
      );
    }
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
              padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(0xFF1E1E1E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find Soul Match',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Find my friend to match',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildBody(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.trim().isEmpty) {
      return _buildIdleState();
    }
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) =>
          _buildUserCard(_searchResults[index]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
          // Debounce sederhana: search setelah user berhenti mengetik
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _doSearch(value);
            }
          });
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                    });
                  },
                )
              : null,
          hintText: 'Search by username or ID',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final username = user['username'] as String? ?? 'Unknown';
    final mbtiType = user['mbti_type'] as String?;
    final profilePic = user['profile_picture'] as String?;
    final status = _statusCache[userId] ?? 'none';

    final hasValidMbti = mbtiType != null &&
        mbtiType.isNotEmpty &&
        mbtiType.toUpperCase() != 'NULL';

    final hasImage =
        profilePic != null && profilePic.isNotEmpty && profilePic != 'default.png';

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0EC),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.network(profilePic, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, size: 32, color: Colors.grey))
                  : const Icon(Icons.person, size: 32, color: Colors.grey),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF555555),
                    ),
                  ),
                  if (hasValidMbti) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mbtiType!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildAddButton(userId, username, status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String userId, String username, String status) {
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';

    // Sudah berteman — tidak bisa add lagi
    if (isAccepted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 14, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text(
              'Friends',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: () async {
          await _toggleFriendRequest(userId);
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  _statusCache[userId] == 'pending'
                      ? 'Friend request sent to $username! 🚀'
                      : 'Friend request cancelled.',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ),
            );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPending ? Colors.grey[300] : _primaryColor,
          foregroundColor:
              isPending ? Colors.grey[700] : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending ? Icons.hourglass_empty_rounded : Icons.add_rounded,
              size: 15,
              color: isPending ? Colors.grey[700] : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isPending ? 'Pending' : 'Add Friend',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.manage_search_rounded,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Search for friends',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Type a username to get started',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No users found',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Try another username or ID',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}