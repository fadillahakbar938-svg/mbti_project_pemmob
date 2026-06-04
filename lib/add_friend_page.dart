import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'services/supabase_service.dart';
import 'widgets/user_profile_popup.dart'; // ← import popup
import 'dart:async';

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
                statuses[uid] = 'none';
              }
            }
          }),
        );
      } else {
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
      debugPrint('DEBUG _doSearch ERROR: $e');
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  final Map<String, DateTime> _requestSentAt = {};

  bool _isOnCooldown(String userId) {
    final sentAt = _requestSentAt[userId];
    if (sentAt == null) return false;
    return DateTime.now().difference(sentAt).inSeconds < 120;
  }

  int _cooldownRemaining(String userId) {
    final sentAt = _requestSentAt[userId];
    if (sentAt == null) return 0;
    final elapsed = DateTime.now().difference(sentAt).inSeconds;
    return (120 - elapsed).clamp(0, 120);
  }

  Future<void> _toggleFriendRequest(String targetUserId) async {
    final currentId = _currentUserId;
    if (currentId == null) return;

    final currentStatus = _statusCache[targetUserId] ?? 'none';

    if (currentStatus == 'none' && _isOnCooldown(targetUserId)) {
      final sisa = _cooldownRemaining(targetUserId);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Harap tunggu $sisa detik sebelum mengirim ulang.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    setState(() {
      _statusCache[targetUserId] =
          currentStatus == 'none' ? 'pending' : 'none';
      if (currentStatus == 'none') {
        _requestSentAt[targetUserId] = DateTime.now();
      }
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
        setState(() => _requestSentAt.remove(targetUserId));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusCache[targetUserId] = currentStatus;
        _requestSentAt.remove(targetUserId);
      });
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
                        'Temukan temanmu di sini',
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
      itemBuilder: (_, index) => _buildUserCard(_searchResults[index]),
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
          hintText: 'Cari berdasarkan username...',
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

  // ── CARD USER ────────────────────────────────────────────
  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final username = user['username'] as String? ?? 'Unknown';
    final mbtiType = user['mbti_type'] as String?;
    final profilePic = user['profile_picture'] as String?;
    final status = _statusCache[userId] ?? 'none';

    final hasValidMbti = mbtiType != null &&
        mbtiType.isNotEmpty &&
        mbtiType.toUpperCase() != 'NULL';

    final hasImage = profilePic != null &&
        profilePic.isNotEmpty &&
        profilePic != 'default.png';

    return GestureDetector(
      // ── Tap card → buka popup profil ──
      onTap: () => showUserProfilePopup(context, user),
      child: Container(
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
                    ? Image.network(
                        profilePic,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, size: 32, color: Colors.grey),
                      )
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
                      const SizedBox(height: 4),
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
                    // Hint tap untuk lihat profil
                    Text(
                      'Ketuk untuk lihat profil',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol tambah teman (terpisah dari onTap card)
              GestureDetector(
                onTap: () {}, // absorb tap agar tidak trigger card tap
                child: _buildAddButton(userId, username, status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(String userId, String username, String status) {
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    final isIncoming = status == 'incoming';
    final onCooldown = isPending && _isOnCooldown(userId);

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
            Icon(Icons.check_circle_outline, size: 14, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text(
              'Berteman',
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

    if (isIncoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E3FC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_rounded,
                size: 14, color: Color(0xFF8E59B3)),
            SizedBox(width: 4),
            Text(
              'Minta diterima',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8E59B3),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onCooldown
            ? null
            : () async {
                await _toggleFriendRequest(userId);
                if (!mounted) return;
                final newStatus = _statusCache[userId];
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        newStatus == 'pending'
                            ? 'Permintaan pertemanan dikirim ke $username! 🚀'
                            : 'Permintaan pertemanan dibatalkan.',
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
          backgroundColor: onCooldown
              ? Colors.grey[200]
              : isPending
                  ? Colors.grey[300]
                  : _primaryColor,
          foregroundColor:
              onCooldown || isPending ? Colors.grey[500] : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              onCooldown
                  ? Icons.hourglass_top_rounded
                  : isPending
                      ? Icons.hourglass_empty_rounded
                      : Icons.add_rounded,
              size: 15,
            ),
            const SizedBox(width: 4),
            onCooldown
                ? _CooldownText(
                    userId: userId,
                    requestSentAt: _requestSentAt,
                  )
                : Text(
                    isPending ? 'Menunggu' : 'Tambah Teman',
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
            Icon(Icons.manage_search_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Cari teman di sini',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketik username untuk mulai mencari',
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
            Icon(Icons.person_search_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Pengguna tidak ditemukan',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba username yang lain',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Countdown widget ──────────────────────────────────────
class _CooldownText extends StatefulWidget {
  final String userId;
  final Map<String, DateTime> requestSentAt;

  const _CooldownText({
    required this.userId,
    required this.requestSentAt,
  });

  @override
  State<_CooldownText> createState() => _CooldownTextState();
}

class _CooldownTextState extends State<_CooldownText> {
  late Timer _timer;
  int _remaining = 120;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_updateRemaining);
    });
  }

  void _updateRemaining() {
    final sentAt = widget.requestSentAt[widget.userId];
    if (sentAt == null) {
      _remaining = 0;
      return;
    }
    final elapsed = DateTime.now().difference(sentAt).inSeconds;
    _remaining = (120 - elapsed).clamp(0, 120);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tunggu ${_remaining}d',
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}