import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_bottom_navbar.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  static const Color _bgCream = Color(0xFFFFFBF7);
  static const Color _purpleMain = Color(0xFF8E59B3);
  static const Color _textDark = Color(0xFF2D2132);
  static const Color _textMuted = Color(0xFF7D6F83);
  static const Color _searchFill = Color(0xFFFFF8F5);
  static const Color _avatarPlaceholder = Color(0xFFFCE3EC);

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _errorMessage = null;
        _hasSearched = false;
      });
      return;
    }

    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _hasSearched = true;
        _errorMessage = 'Masuk ke akun untuk mencari pengguna lain.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final users = await SupabaseService.instance.searchUsers(
        query: trimmed,
        excludeUserId: currentUser.id,
      );
      if (!mounted) return;
      setState(() {
        _results = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _errorMessage = 'Gagal memuat hasil pencarian. Coba lagi.';
      });
    }
  }

  static String formatPublicId(String userId) {
    final compact = userId.replaceAll('-', '');
    final short = compact.length >= 8 ? compact.substring(0, 8) : compact;
    return 'ID. ${short.toUpperCase()}';
  }

  void _onAddFriend(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permintaan pertemanan ke $username akan segera tersedia.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Soul Match',
                    style: AppTheme.pageTitle(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Temukan teman yang selaras dengan kepribadianmu',
                    style: AppTheme.pageSubtitle(context),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResultsBody()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _searchFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _textDark, width: 1.2),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: AppTheme.searchInput(context),
        decoration: InputDecoration(
          hintText: 'Search by username or ID',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _textMuted.withValues(alpha: 0.9),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildResultsBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _purpleMain),
      );
    }

    if (_errorMessage != null) {
      return _buildHintMessage(_errorMessage!, icon: Icons.lock_outline_rounded);
    }

    if (!_hasSearched) {
      return _buildHintMessage(
        'Ketik username atau ID pengguna untuk mulai mencari teman baru.',
        icon: Icons.people_outline_rounded,
      );
    }

    if (_results.isEmpty) {
      return _buildHintMessage(
        'Tidak ada pengguna yang cocok. Coba kata kunci lain.',
        icon: Icons.search_off_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 88),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final user = _results[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildHintMessage(String message, {required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: _textMuted.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.hintMessage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final id = user['id'] as String? ?? '';
    final username = (user['username'] as String?)?.trim();
    final displayName =
        username != null && username.isNotEmpty ? username : 'Pengguna';
    final profileUrl = user['profile_picture'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(profileUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTheme.cardTitle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPublicId(id),
                  style: AppTheme.cardSubtitle(context),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAddFriendButton(displayName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? profileUrl) {
    final hasUrl =
        profileUrl != null &&
        profileUrl.isNotEmpty &&
        profileUrl != 'default.png';

    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: _avatarPlaceholder,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasUrl
          ? Image.network(
              profileUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          : null,
    );
  }

  Widget _buildAddFriendButton(String username) {
    return Material(
      color: _purpleMain,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _onAddFriend(username),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                'Add Friend',
                style: AppTheme.buttonLabel(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
