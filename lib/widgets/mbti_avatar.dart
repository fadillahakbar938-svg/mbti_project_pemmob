import 'package:flutter/material.dart';

class MbtiAvatar extends StatelessWidget {
  final String? mbtiCode;
  final double size;

  const MbtiAvatar({super.key, required this.mbtiCode, this.size = 48.0});

  bool _isValidMbti(String? code) {
    if (code == null) return false;
    const validCodes = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP'
    ];
    return validCodes.contains(code.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _isValidMbti(mbtiCode);
    final String imagePath = isValid 
        ? 'assets/images/${mbtiCode!.toUpperCase()}.png'
        : 'assets/images/detective_sheep_mascot.png';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/detective_sheep_mascot.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            );
          },
        ),
      ),
    );
  }
}
