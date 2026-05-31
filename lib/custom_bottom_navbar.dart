import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'question_page.dart';
// import 'match_page.dart';
// import 'cards_page.dart';
// import 'profile_page.dart';

class CustomBottomNavbar extends StatelessWidget {

  final int currentIndex;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {

    const purpleMain = Color(0xFF8E59B3);

    return BottomNavigationBar(

      currentIndex: currentIndex,

      type: BottomNavigationBarType.fixed,

      selectedItemColor: purpleMain,
      unselectedItemColor: Colors.grey,

      onTap: (index) {

        if(index == currentIndex) return;

        Widget page;

        switch(index){

          case 0:
            page = const DashboardPage();
            break;

          case 1:
            page = const QuestionPage();
            break;

          // case 2:
          //   page = const MatchPage();
          //   break;

          // case 3:
          //   page = const CardsPage();
          //   break;

          // case 4:
          //   page = const ProfilePage();
          //   break;

          default:
            page = const DashboardPage();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'Test',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Match',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.style_outlined),
          label: 'Cards',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}