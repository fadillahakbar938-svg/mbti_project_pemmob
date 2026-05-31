import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart'; // Memastikan dashboard_page sudah terimport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBTI Test App',
      debugShowCheckedModeBanner: false,

      // Tema global aplikasi biar serasi dengan warna pastel pink/ungu (INFP)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E59B3),
          primary: const Color(0xFF8E59B3),
          background: const Color(0xFFFFF3EC),
        ),
      ),

      // Halaman pertama yang pertama kali muncul saat aplikasi dibuka
      initialRoute: '/',

      // Pendaftaran rute navigasi halaman
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Rute tujuan diubah ke DashboardPage yang baru saja dibuat
        '/home': (context) => const DashboardPage(),
      },
    );
  }
}
