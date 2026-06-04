import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'test_intro_page.dart';
import 'soul_match_page.dart';
import 'cards_page.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavbar({super.key, required this.currentIndex});

  static const Color _purpleMain = Color(0xFF8E59B3);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _purpleMain,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (index) {
          if (index == currentIndex) return;

          Widget page;

          switch (index) {
            case 0:
              page = const DashboardPage();
              break;

            case 1:
              page = const TestIntroPage();
              break;

            case 2:
              page = const SoulMatchPage();
              break;

            case 3:
              page = const CardsPage();
              break;

            default:
              page = const DashboardPage();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Tes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Cocok',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            label: 'Kartu',
          ),
        ],
      ),
    );
  }
}
