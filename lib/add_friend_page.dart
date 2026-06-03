import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';

class FriendSuggestion {
  final String username;
  final String friendId;
  final String? avatarUrl;
  bool isRequestSent;

  FriendSuggestion({
    required this.username,
    required this.friendId,
    this.avatarUrl,
    this.isRequestSent = false,
  });
}

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  String _searchQuery = "";

  // Mock data as seen in the user's screenshot
  final List<FriendSuggestion> _suggestions = [
    FriendSuggestion(username: "AndriAw_", friendId: "278910G5"),
    FriendSuggestion(username: "AndriKFC_", friendId: "278910G5"),
    FriendSuggestion(username: "AndriLabaik_", friendId: "278910G5"),
    FriendSuggestion(username: "AndriMCD_", friendId: "278910G5"),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter suggestions based on search query
    final filteredSuggestions = _suggestions.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.username.toLowerCase().contains(query) ||
          user.friendId.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Soft cream/beige background
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area (Back button & Title)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 24.0, 8.0),
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

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 24),

                    // List of Suggestion Cards
                    if (filteredSuggestions.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredSuggestions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildFriendSuggestionCard(filteredSuggestions[index]);
                        },
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar matching the flow
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 2,
      ),
    );
  }

  // Search bar styled specifically for the Add Friend UI
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF1E1E1E), // Slightly darker thin border as in the screenshot
          width: 1.5,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 12.0),
            child: Icon(
              Icons.search_rounded,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
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

  // Friend Suggestion Card layout
  Widget _buildFriendSuggestionCard(FriendSuggestion user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Avatar
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0EC), // Soft pink/beige background placeholder
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: user.avatarUrl != null
                    ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 20),

            // Friend details & Add button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID. ${user.friendId}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // "+ Add Friend" Button
                  _buildAddButton(user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(FriendSuggestion user) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            user.isRequestSent = !user.isRequestSent;
          });

          // Show a beautiful premium feedback snackbar
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user.isRequestSent
                    ? 'Friend request sent to ${user.username}! 🚀'
                    : 'Friend request cancelled for ${user.username}.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF8E59B3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: user.isRequestSent ? Colors.grey[300] : const Color(0xFF8E59B3),
          foregroundColor: user.isRequestSent ? Colors.grey[700] : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              user.isRequestSent ? Icons.done_rounded : Icons.add_rounded,
              size: 16,
              color: user.isRequestSent ? Colors.grey[700] : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              user.isRequestSent ? 'Pending' : 'Add Friend',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try typing another username or ID',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
