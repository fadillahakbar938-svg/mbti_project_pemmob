import 'package:flutter/material.dart';

import 'custom_bottom_navbar.dart';
import 'yakin_page.dart';
import 'services/supabase_service.dart';

class TestIntroPage extends StatelessWidget {
  const TestIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    void _showStartConfirmation(
      BuildContext context,
    ) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),

            title: const Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Color(0xFF8E59B3),
                ),
                SizedBox(width: 8),
                Text("Mulai Tes?")
              ],
            ),

            content: const Text(
              "Pastikan kamu berada di tempat yang nyaman dan dapat menjawab seluruh pertanyaan dengan jujur.\n\nTes terdiri dari 80 pertanyaan dan membutuhkan sekitar 5 menit.",
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E59B3),
                ),

                onPressed: () {
                  _showStartConfirmation(context);
                },

                child: const Text(
                  "Mulai",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    const bgCream = Color(0xFFFFFBF7);
  const purpleLight = Color(0xFFF3E3FC);
  const purpleMain = Color(0xFF8E59B3);
  const pinkLight = Color(0xFFFCE3EC);
  const blueLight = Color(0xFFE3F4FC);

  const textDark = Color(0xFF2D2132);
  const textMuted = Color(0xFF7D6F83);

    return Scaffold(
      backgroundColor: bgCream,

      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        /// TITLE
        const Text(
          "MBTI Test",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "Discover your personality type",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 24),

        /// HERO CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: purpleLight,
            borderRadius: BorderRadius.circular(24),
          ),

          child: Column(
            children: [

              Container(
                width: 90,
                height: 90,

                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: const Center(
                  child: Text(
                    "🐑",
                    style: TextStyle(
                      fontSize: 46,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Find Your Personality Type",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "80 Questions • ~5 Minutes",
                style: TextStyle(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  _buildInfoChip(
                    Icons.quiz_outlined,
                    "80 Questions",
                  ),

                  const SizedBox(width: 10),

                  _buildInfoChip(
                    Icons.timer_outlined,
                    "~5 Minutes",
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        /// SECTION TITLE
        const Text(
          "4 Dimensions Measured",
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 16),

        /// DIMENSION ROW 1
        Row(
          children: [

            Expanded(
              child: _buildDimensionCard(
                Icons.bolt_rounded,
                "Energy",
                "E vs I",
                purpleLight,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _buildDimensionCard(
                Icons.visibility_outlined,
                "Information",
                "N vs S",
                blueLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        /// DIMENSION ROW 2
        Row(
          children: [

            Expanded(
              child: _buildDimensionCard(
                Icons.balance_rounded,
                "Decision",
                "T vs F",
                const Color(0xFFFDF0D7),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _buildDimensionCard(
                Icons.calendar_month_outlined,
                "Structure",
                "J vs P",
                pinkLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        /// BEFORE START CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                "Before You Start",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 14),

              Row(
                children: [
                  Text("✨"),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Answer honestly and naturally",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Text("🧠"),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "There are no right or wrong answers",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Text("⚡"),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Choose the option that feels most like you",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// START BUTTON
        SizedBox(
          width: double.infinity,
          height: 60,

          child: ElevatedButton(
            onPressed: () {
              final isGuest = SupabaseService.instance.currentUser == null;
              if (isGuest) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Fitur ini memerlukan akun terdaftar. Yuk daftar dulu! 🔮'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF8E59B3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    action: SnackBarAction(
                      label: 'Daftar',
                      textColor: Colors.white,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const YakinPage(),
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: purpleMain,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),

            child: const Text(
              "Start Test",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    ),
  ),
),
      bottomNavigationBar: const CustomBottomNavbar(
        currentIndex: 1,
      ),
    );
  }

  static Widget _buildInfoChip(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 18,
            color: const Color(0xFF8E59B3),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDimensionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 30,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
            ),
          )
        ],
          
      ),
    );
  }
}