import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;
  final bool canPop;

  const ExitConfirmationWrapper({super.key, required this.child, this.canPop = false});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (canPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Keluar Aplikasi?'),
              content: const Text('Apakah Anda yakin ingin keluar dari aplikasi MBTI Match?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Tidak', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ya'),
                ),
              ],
            );
          },
        );

        if (shouldPop == true) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
