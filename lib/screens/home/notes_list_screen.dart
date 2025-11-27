// lib/screens/home/notes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';

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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: AppColors.purple.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada catatan. Buat baru yuk!',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      // Ambil warna dari palette berdasarkan index (rotasi warna)
                      final cardColor = AppColors.getNoteColor(index);
                      final textColor = AppColors.getContrastText(cardColor);
                      
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: cardColor,
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
                                        Icon(Icons.broken_image, color: textColor),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: textColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.note, color: textColor),
                                ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            note.content,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade700),
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