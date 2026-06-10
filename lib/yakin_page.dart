import 'package:flutter/material.dart';
import 'question_page.dart';

class YakinPage extends StatelessWidget {
  const YakinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF6F0), // Soft cream/beige at the top
              Color(0xFFF0DDF7), // Soft lavender at the bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Main confirmation text
                const Text(
                  'Yakin ingin mulai test?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 36),

                // Button Setuju
                _buildButton(
                  context: context,
                  text: 'Yakin banget dong',
                  backgroundColor: const Color(0xFF8E59B3), 
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuestionPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
    
                // Button Batal
                _buildButton(
                  context: context,
                  text: 'Bentar, mau kembali dulu',
                  backgroundColor: const Color(0xFFE5D2EC), // Soft light purple
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
