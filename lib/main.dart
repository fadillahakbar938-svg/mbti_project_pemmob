import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'widgets/detective_sheep_logo.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart'; 
import 'cards_page.dart';
import 'profile_page.dart';
import 'result_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan asset maskot terdaftar sebelum UI dibuka.
  await rootBundle.load(DetectiveSheepLogo.assetPath);

  await Supabase.initialize(
    url: 'https://ycskqtrbzmfsugyxpldm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljc2txdHJiem1mc3VneXhwbGRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMjgxNzUsImV4cCI6MjA5NTYwNDE3NX0.yuygyDeXGd4A3r0-rZC5w5B2G6aOq_VY2CkwrKrSCtU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBTI Test App',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(),

      // Halaman pertama yang pertama kali muncul saat aplikasi dibuka
      // NOTE: sementara di-set ke '/profile' agar mudah preview halaman profil.
      // Ubah kembali ke '/' saat selesai.
      initialRoute: '/',

      // Pendaftaran rute navigasi halaman
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Rute tujuan diubah ke DashboardPage yang baru saja dibuat
        '/home': (context) => const DashboardPage(),
        '/cards': (context) => const CardsPage(),
        '/profile': (context) => const ProfilePage(),
        '/result': (context) => const ResultPage(),
      },
    );
  }
}
