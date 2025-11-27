// lib/screens/home/notes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

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
        title: const Text('Catatan Saya'),
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
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotes,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notes.isEmpty
                ? const Center(child: Text('Belum ada catatan. Buat baru yuk!'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
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
                                        const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.note, color: Colors.teal),
                                ),
                          title: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            note.content,
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