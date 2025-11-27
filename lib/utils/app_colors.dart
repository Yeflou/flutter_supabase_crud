// lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Warna utama aplikasi
  static const Color purple = Color(0xFFCB9DF0);
  static const Color pink = Color(0xFFF0C1E1);
  static const Color peach = Color(0xFFFDDBBB);
  static const Color yellow = Color(0xFFFFF9BF);

  // Warna untuk teks (agar kontras dan mudah dibaca)
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF6B6B6B);

  // Warna untuk background
  static const Color backgroundLight = Color(0xFFFFFEF9);
  
  // List warna untuk catatan (untuk rotasi warna)
  static final List<Color> noteColors = [
    purple,
    pink,
    peach,
    yellow,
  ];

  // Fungsi untuk mendapatkan warna catatan berdasarkan index
  static Color getNoteColor(int index) {
    return noteColors[index % noteColors.length];
  }

  // Fungsi untuk menentukan warna teks yang kontras
  static Color getContrastText(Color backgroundColor) {
    // Hitung brightness dari background
    final brightness = backgroundColor.computeLuminance();
    // Jika background terang, gunakan teks gelap
    // Jika background gelap, gunakan teks terang
    return brightness > 0.5 ? textDark : Colors.white;
  }
}

