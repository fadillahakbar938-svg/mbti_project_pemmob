import 'package:flutter/material.dart';

/// Maskot domba detektif (PNG) — landing, login, register.
class DetectiveSheepLogo extends StatelessWidget {
  const DetectiveSheepLogo({
    super.key,
    this.size = 90,
    this.showBadge = true,
  });

  /// Path harus sama dengan entri di pubspec.yaml.
  static const String assetPath = 'assets/images/detective_sheep_mascot.png';

  final double size;
  final bool showBadge;

  /// Panggil sekali saat app start agar logo tidak gagal render pertama kali.
  static Future<void> precache(BuildContext context) {
    return precacheImage(const AssetImage(assetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = showBadge ? size * 0.78 : size;

    final mascot = Image.asset(
      assetPath,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Maskot domba detektif',
      errorBuilder: (context, error, stackTrace) {
        debugPrint('DetectiveSheepLogo gagal memuat: $error');
        return SizedBox(
          width: imageSize,
          height: imageSize,
          child: Center(
            child: Text(
              '🐑',
              style: TextStyle(fontSize: imageSize * 0.45),
            ),
          ),
        );
      },
    );

    if (!showBadge) return mascot;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E59B3).withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: SizedBox(
            width: imageSize,
            height: imageSize,
            child: mascot,
          ),
        ),
      ),
    );
  }
}
