import 'dart:async';
import 'package:flutter/material.dart';
import 'match_detail_page.dart';
import 'services/supabase_service.dart';
import 'widgets/mbti_avatar.dart';

class MatchLoadingPage extends StatefulWidget {
  final int historyId;
  final String myMbti;
  final String? myAvatarEmoji;
  final String friendMbti;
  final String? friendAvatarEmoji;
  final String friendName;

  const MatchLoadingPage({
    super.key,
    required this.historyId,
    required this.myMbti,
    this.myAvatarEmoji,
    required this.friendMbti,
    this.friendAvatarEmoji,
    required this.friendName,
  });

  @override
  State<MatchLoadingPage> createState() => _MatchLoadingPageState();
}

class _MatchLoadingPageState extends State<MatchLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _leftAvatarSlide;
  late Animation<Offset> _rightAvatarSlide;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutBack,
      ),
    );

    _leftAvatarSlide = Tween<Offset>(
      begin: const Offset(-2.0, 0),
      end: const Offset(0.2, 0),
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _rightAvatarSlide = Tween<Offset>(
      begin: const Offset(2.0, 0),
      end: const Offset(-0.2, 0),
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.repeat(reverse: true);

    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailPage(
              historyId: widget.historyId,
              supabaseService: SupabaseService.instance,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8E59B3);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse background for connection
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.15),
                        ),
                      ),
                    );
                  },
                ),
                
                // Avatars moving towards each other
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _leftAvatarSlide,
                      child: _buildAvatarCard(widget.myMbti, widget.myAvatarEmoji),
                    ),
                    const SizedBox(width: 20),
                    SlideTransition(
                      position: _rightAvatarSlide,
                      child: _buildAvatarCard(widget.friendMbti, widget.friendAvatarEmoji),
                    ),
                  ],
                ),
                
                // Heart icon appearing in the middle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Menganalisis Kecocokan...\nAnda & ${widget.friendName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A3E4D),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(String mbti, String? emoji) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: MbtiAvatar(mbtiCode: emoji, size: 80),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF8E59B3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            mbti,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
