import 'dart:io';
import 'dart:typed_data'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // ==============================
  // 1. AUTHENTICATION (Login/Register)
  // ==============================

  Future<AuthResponse> signUp(String email, String password, String username) async {
    // Mendaftar user baru
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Jika sukses daftar, langsung buat data profil awal
    if (response.user != null) {
      await updateProfile(username: username);
    }
    
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  // ==============================
  // 2. PROFILE FEATURES
  // ==============================

  // Mengambil data profile user yang sedang login
  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      // Jika profil belum ada, return null
      return null;
    }
  }

  // Update atau Buat Profile baru
  Future<void> updateProfile({required String username, String? avatarUrl}) async {
    final user = currentUser;
    if (user == null) return;

    final updates = {
      'id': user.id,
      'username': username,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }

    // Upsert: Jika ada di-update, jika tidak ada dibuat baru
    await _supabase.from('profiles').upsert(updates);
  }

  // ==============================
  // 3. NOTES FEATURES (CRUD)
  // ==============================

  // CREATE: Tambah Catatan
  Future<void> addNote(Note note) async {
    await _supabase.from('notes').insert(note.toJson());
  }

  // READ: Ambil Semua Catatan User Ini
  Future<List<Note>> getNotes() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await _supabase
        .from('notes')
        .select()
        .eq('user_id', user.id) // Filter hanya punya user sendiri
        .order('created_at', ascending: false); // Urutkan dari yang terbaru

    // Ubah data JSON menjadi List of Note Objects
    return (data as List).map((e) => Note.fromJson(e)).toList();
  }

  // UPDATE: Edit Catatan
  Future<void> updateNote(Note note) async {
    await _supabase
        .from('notes')
        .update({
          'title': note.title,
          'content': note.content,
          'image_url': note.imageUrl,
        })
        .eq('id', note.id!); // Cari berdasarkan ID catatan
  }

  // DELETE: Hapus Catatan
  Future<void> deleteNote(int id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }

  // ==============================
  // 4. STORAGE (Upload Gambar)
  // ==============================

  // Upload untuk Mobile (Android/iOS) menggunakan File
  Future<String> uploadImage(File file, String bucket, String path) async {
    await _supabase.storage.from(bucket).upload(path, file);
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  // Upload untuk Web menggunakan Bytes (Uint8List)
  Future<String> uploadImageBytes(Uint8List bytes, String bucket, String path) async {
    await _supabase.storage.from(bucket).uploadBinary(path, bytes);
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
}