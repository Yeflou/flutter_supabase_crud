// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_routes.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // 1. Beri jeda 2 detik agar logo aplikasi terlihat sejenak
    await Future.delayed(const Duration(seconds: 2));

    // 2. Cek session Supabase (apakah ada user yang tersimpan/sedang login?)
    final session = Supabase.instance.client.auth.currentSession;

    // 3. Arahkan user menggunakan Get.offAllNamed 
    // (offAllNamed menghapus riwayat back button, agar user tidak bisa kembali ke splash screen)
    if (session != null) {
      Get.offAllNamed(AppRoutes.notes); // Ke Home
    } else {
      Get.offAllNamed(AppRoutes.login); // Ke Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple,
              AppColors.pink,
              AppColors.peach,
              AppColors.yellow,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi Sederhana
              Icon(Icons.note_alt_outlined, size: 100, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Supabase Notes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              // Indikator Loading berputar
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}