import 'package:flutter/material.dart';

import 'custom_bottom_navbar.dart';
import 'widgets/character_cards.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFFFFBF7);
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kartu Karakter',
          style: TextStyle(color: Color(0xFF2D2132)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D2132)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              const CharacterCards(),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 72),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 3),
    );
  }
}
