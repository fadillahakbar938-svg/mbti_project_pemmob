import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'add_friend_page.dart';

/// Model representing a matched user profile
class MatchUser {
  final String username;
  final String mbtiType;
  final String title;
  final String description;
  final double matchPercentage; // e.g., 0.97 for 97%
  final double compatibilityScore; // e.g., 0.95 for the progress bar
  final String? avatarUrl;

  const MatchUser({
    required this.username,
    required this.mbtiType,
    required this.title,
    required this.description,
    required this.matchPercentage,
    required this.compatibilityScore,
    this.avatarUrl,
  });
}

class SoulMatchPage extends StatefulWidget {
  const SoulMatchPage({Key? key}) : super(key: key);

  @override
  State<SoulMatchPage> createState() => _SoulMatchPageState();
}

class _SoulMatchPageState extends State<SoulMatchPage> {
  // Tab selector active index (0 for Friends, 1 for Matched)
  int _activeTabSegment = 1; 

 
  String _searchQuery = "";

 
  final List<MatchUser> _allMatches = const [
    MatchUser(
      username: "AndriAw_",
      mbtiType: "ENTJ",
      title: "The Commander",
      description: "Heart-centered visions align perfectly",
      matchPercentage: 0.97,
      compatibilityScore: 0.95,
    ),
    MatchUser(
      username: "masFadhil20_",
      mbtiType: "INFJ",
      title: "The Counselor",
      description: "Heart-centered visions align perfectly",
      matchPercentage: 0.97,
      compatibilityScore: 0.95,
    ),
    MatchUser(
      username: "tehTirr10_",
      mbtiType: "ENFP",
      title: "The Campaigner",
      description: "Heart-centered visions align perfectly",
      matchPercentage: 0.97,
      compatibilityScore: 0.95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    
    final filteredMatches = _allMatches.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.username.toLowerCase().contains(query) ||
          user.mbtiType.toLowerCase().contains(query) ||
          user.title.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), 
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
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
                          // fontWeight: FontWeight.bold
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
                  // Add Friends Button
                  _buildAddFriendsButton(),
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

                    // "MY TYPE" Card
                    _buildMyTypeCard(),

                    const SizedBox(height: 20),

                    // Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 16),

                    // Custom Segmented Pill Tab Selector (Friends / Matched)
                    _buildPillTabSelector(),

                    const SizedBox(height: 20),

                    // List of Match Cards
                    if (filteredMatches.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMatches.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildMatchUserCard(filteredMatches[index]);
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

      // Bottom Navigation Bar
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 2,
      ),
    );
  }

  // "+ Add friends" Button Custom Style
  Widget _buildAddFriendsButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8E59B3), // Purple
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E59B3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddFriendPage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
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

  // "MY TYPE" Card
  Widget _buildMyTypeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3E8FA),
            Color(0xFFEAD5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left Avatar
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://api.dicebear.com/7.x/adventurer/png?seed=Luna', // Placeholder avatar lucu
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.face_retouching_natural_rounded,
                      color: Color(0xFF8E59B3),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Middle Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pill status "MY TYPE"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: const Text(
                      'MY TYPE',
                      style: TextStyle(
                        color: Color(0xFF8E59B3),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'INFP',
                    style: TextStyle(
                      fontSize: 32,
                      // fontWeight: FontWeight.black,
                      color: Color(0xFF1E1E1E),
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The Dreamer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Right Chevron Button
            IconButton(
              onPressed: () {
                // Aksi navigasi ke detail tipe saya
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rounded Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE2DCD5),
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

  // Custom Segmented Pill Tab Selector (Friends / Matched)
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
              title: "Friends",
              isSelected: _activeTabSegment == 0,
              onTap: () {
                setState(() {
                  _activeTabSegment = 0;
                });
              },
            ),
            _buildTabPill(
              title: "Matched",
              isSelected: _activeTabSegment == 1,
              onTap: () {
                setState(() {
                  _activeTabSegment = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8E59B3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  
  Widget _buildMatchUserCard(MatchUser user) {
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
        child: Column(
          children: [
            // Top Section (Avatar, Text, Radial percentage)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + MBTI Badge
                Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0EC), // Warna krem/merah muda lembut
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null
                            ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.mbtiType,
                      style: const TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.extrabold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Name & description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ring Score Percent (97%)
                _buildRadialScore(user.matchPercentage),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar (Kecocokan visual)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: user.compatibilityScore,
                minHeight: 12,
                backgroundColor: const Color(0xFFF1EDE6),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF903636), // Warna merah kecokelatan tebal dari gambar Anda
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Detail Match Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi detail kecocokan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E59B3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Detail Match',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ring/Circle score indicator
  Widget _buildRadialScore(double percentage) {
    final int percentValue = (percentage * 100).toInt();
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF903636),
          width: 3.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$percentValue%',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1E1E),
        ),
      ),
    );
  }

  // Tampilan dikosongin ketika gada pencarian
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No matches found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching for another MBTI or username',
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
