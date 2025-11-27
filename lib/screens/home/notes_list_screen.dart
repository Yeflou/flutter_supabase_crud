// lib/screens/home/notes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/constants.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  // 1. Ambil data catatan dari Supabase
  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _supabaseService.getNotes();
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat catatan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Fungsi Hapus Catatan
  Future<void> _deleteNote(int id) async {
    // Tampilkan dialog konfirmasi dulu
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), 
            child: const Text('Batal')
          ),
          TextButton(
            onPressed: () => Get.back(result: true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabaseService.deleteNote(id);
        _fetchNotes(); // Refresh list setelah hapus
        Get.snackbar('Sukses', 'Catatan dihapus');
      } catch (e) {
        Get.snackbar('Error', 'Gagal menghapus: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorPurple,
        foregroundColor: Colors.white,
        actions: [
          // Tombol ke Profil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      // Tombol Tambah Catatan (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Tunggu hasil dari halaman tambah, kalau ada perubahan (true), refresh list
          final result = await Get.toNamed(AppRoutes.noteForm);
          if (result == true) {
            _fetchNotes();
          }
        },
        backgroundColor: colorPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotes,
        color: colorPurple,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: colorPurple))
            : _notes.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada catatan. Buat baru yuk!',
                      style: TextStyle(color: textMedium, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      // Rotasi warna border untuk setiap catatan
                      final borderColor = noteColors[index % noteColors.length];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: borderColor,
                            width: 3,
                          ),
                        ),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          // Tampilkan gambar kecil (thumbnail) jika ada
                          leading: note.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    note.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        Icon(Icons.broken_image, color: textDark),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: borderColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.note, color: borderColor),
                                ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            note.content,
                            style: TextStyle(color: textMedium),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(note.id!),
                          ),
                          onTap: () async {
                            // Edit Catatan: Kirim data note saat ini ke form
                            final result = await Get.toNamed(
                              AppRoutes.noteForm, 
                              arguments: note, // Mengirim objek Note lewat arguments
                            );
                            if (result == true) {
                              _fetchNotes();
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}