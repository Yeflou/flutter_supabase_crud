// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangkap input teks
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _signIn() async {
    // 1. Cek validasi form (apakah email/pass kosong?)
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Panggil service login
      await _supabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // 3. Jika sukses, pindah ke halaman Notes
      Get.offAllNamed(AppRoutes.notes);
      
    } on AuthException catch (e) {
      // Error khusus dari Supabase (misal: password salah)
      Get.snackbar('Login Gagal', e.message, 
        backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      // Error umum lainnya
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                
                // Input Email
                CustomInputField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !GetUtils.isEmail(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Input Password
                CustomInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Tombol Login
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Masuk'),
                        ),
                      ),
                
                const SizedBox(height: 16),
                
                // Link ke Register
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}