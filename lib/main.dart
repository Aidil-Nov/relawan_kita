import 'package:flutter/material.dart';
import 'package:relawan_kita/features/auth/presentation/pages/splash_page.dart';
import 'core/theme/app_theme.dart'; // Import file tema tadi
// --- IMPORT HALAMAN YANG SUDAH KITA BUAT ---
// PENTING: Ganti 'relawankita' dengan nama project Anda jika berbeda
import 'package:relawan_kita/features/auth/presentation/pages/login_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/register_page.dart';
import 'package:relawan_kita/features/home/presentation/pages/home_page.dart';
import 'package:relawan_kita/features/auth/presentation/pages/forgot_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RelawanKita',
      debugShowCheckedModeBanner: false,

      // ... (ThemeData biarkan saja seperti sebelumnya) ...
      theme: AppTheme.lightTheme,

      // --- PERUBAHAN DI SINI ---

      // 1. Ubah Initial Route ke '/' (Splash Screen)
      initialRoute: '/',

      // 2. Daftarkan Rute Splash Screen
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) =>
            const ForgotPasswordPage(), // <-- TAMBAHKAN INI
        '/home': (context) => const HomePage(),
      },
    );
  }
}
