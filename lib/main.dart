import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pastikan import ini sesuai dengan lokasi file utils kamu
import 'utils/app_routes.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi GetStorage untuk penyimpanan lokal sementara
  await GetStorage.init();

  // 2. Inisialisasi Supabase
  // Pastikan supabaseUrl & supabaseAnonKey sudah diisi di file constants.dart
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Helper global agar bisa panggil 'supabase' dari mana saja di aplikasi
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Supabase',
      debugShowCheckedModeBanner: false, // Menghilangkan banner DEBUG di pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      // Rute awal saat aplikasi dibuka (Splash Screen)
      initialRoute: AppRoutes.splash,
      // Daftar semua halaman yang didaftarkan di AppRoutes
      getPages: AppRoutes.routes,
    );
  }
}