import 'package:flutter/material.dart';

/// Lingkaran dekoratif pastel (sama seperti landing page).
class AuthBackgroundBlobs extends StatelessWidget {
  const AuthBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E59B3).withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFAECF4).withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
