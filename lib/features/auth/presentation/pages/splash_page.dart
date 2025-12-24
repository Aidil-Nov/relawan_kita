import 'dart:async'; // Untuk Timer
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
  @override
  void initState() {
    super.initState();
    // Timer: Tunggu 3 detik, lalu pindah ke halaman Login
    Timer(const Duration(seconds: 3), () {
      // pushReplacementNamed artinya pengguna tidak bisa kembali ke Splash Screen (tombol back mati)
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Gradient Biru (Khas Pemerintah/Terpercaya)
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Logo Animasi (Icon Besar)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: const Icon(
                Icons.volunteer_activism, 
                size: 80, 
                color: Colors.blueAccent
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 2. Nama Aplikasi
            const Text(
              "RelawanKita",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 3. Tagline E-Gov
            const Text(
              "Satu Data, Satu Aksi, Untuk Negeri",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 60),

            // 4. Loading Indicator Kecil
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}