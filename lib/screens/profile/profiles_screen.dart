import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_input_field.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _usernameController = TextEditingController();
  
  bool _isLoading = true;
  String? _avatarUrl;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 1. Ambil data profil dari Supabase
  Future<void> _loadProfile() async {
    try {
      final data = await _supabaseService.getProfile();
      if (data != null) {
        final profile = Profile.fromJson(data);
        setState(() {
          _usernameController.text = profile.username;
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Simpan perubahan Username
  Future<void> _updateProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      Get.snackbar('Error', 'Username tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabaseService.updateProfile(username: username);
      Get.snackbar('Sukses', 'Profil berhasil diperbarui', 
        backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal update: $e', 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. Logika Upload Foto (Paling Rumit)
  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    // Buka galeri foto
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Kompres ukuran agar tidak terlalu besar
    );

    if (imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final userId = _supabaseService.currentUser!.id;
      // Nama file unik berdasarkan waktu upload
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String newImageUrl;

      // Cek apakah dijalankan di Web atau HP (Android/iOS)
      if (kIsWeb) {
        // Untuk Web: Gunakan Bytes
        final bytes = await imageFile.readAsBytes();
        newImageUrl = await _supabaseService.uploadImageBytes(bytes, 'avatars', fileName);
      } else {
        // Untuk HP: Gunakan File Path
        final file = File(imageFile.path);
        newImageUrl = await _supabaseService.uploadImage(file, 'avatars', fileName);
      }

      // Simpan URL gambar baru ke tabel Profile
      await _supabaseService.updateProfile(
        username: _usernameController.text,
        avatarUrl: newImageUrl,
      );

      // Update tampilan
      setState(() {
        _avatarUrl = newImageUrl;
      });
      
      Get.snackbar('Sukses', 'Foto profil diperbarui!');

    } catch (e) {
      Get.snackbar('Error', 'Gagal upload gambar: $e', 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 4. Logout
  Future<void> _signOut() async {
    await _supabaseService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple,
              AppColors.pink,
              AppColors.peach,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // TAMPILAN AVATAR
                    GestureDetector(
                      onTap: _uploadAvatar, // Klik gambar untuk ganti foto
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.purple,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Ketuk foto untuk mengubah', 
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 12)),
                    
                    const SizedBox(height: 30),

                    // INPUT USERNAME
                    CustomInputField(
                      controller: _usernameController,
                      labelText: 'Username',
                    ),
                    
                    const SizedBox(height: 20),

                    // TOMBOL UPDATE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    // TOMBOL LOGOUT
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Keluar (Logout)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}