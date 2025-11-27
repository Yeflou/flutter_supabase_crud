// lib/screens/home/note_form_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/note_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Variabel untuk menangani Edit Mode
  Note? _existingNote; 
  
  // Variabel untuk Gambar
  XFile? _imageFile; // File gambar yang baru dipilih dari galeri
  String? _existingImageUrl; // URL gambar lama (jika sedang edit)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cek apakah ada data yang dikirim dari halaman List (artinya ini mode EDIT)
    if (Get.arguments is Note) {
      _existingNote = Get.arguments as Note;
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
      _existingImageUrl = _existingNote!.imageUrl;
    }
  }

  // Fungsi Pilih Gambar dari Galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // Fungsi Simpan (Create / Update)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      String? imageUrlToSave = _existingImageUrl;

      // 1. Jika user memilih gambar baru, upload dulu
      if (_imageFile != null) {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          imageUrlToSave = await _supabaseService.uploadImageBytes(bytes, 'notes-images', fileName);
        } else {
          imageUrlToSave = await _supabaseService.uploadImage(File(_imageFile!.path), 'notes-images', fileName);
        }
      }

      // 2. Siapkan Objek Note
      final note = Note(
        id: _existingNote?.id, // Kalau null berarti baru, kalau ada isinya berarti update
        userId: user.id,
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: imageUrlToSave,
      );

      // 3. Cek Mode: Tambah atau Edit
      if (_existingNote == null) {
        // Mode Tambah
        await _supabaseService.addNote(note);
        Get.snackbar('Sukses', 'Catatan berhasil ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Mode Edit
        await _supabaseService.updateNote(note);
        Get.snackbar('Sukses', 'Catatan berhasil diperbarui', backgroundColor: Colors.blue, colorText: Colors.white);
      }

      // 4. Kembali ke halaman list dengan sinyal "true" (agar list di-refresh)
      Get.back(result: true);

    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingNote == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- BAGIAN GAMBAR ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      // A. Menampilkan gambar baru yang dipilih (Preview Local)
                      ? (kIsWeb 
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover) 
                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                      : _existingImageUrl != null
                          // B. Menampilkan gambar lama dari internet (Edit Mode)
                          ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                          // C. Placeholder jika tidak ada gambar
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                Text('Ketuk untuk tambah gambar'),
                              ],
                            ),
                ),
              ),
              
              const SizedBox(height: 16),

              // --- INPUT JUDUL ---
              CustomInputField(
                controller: _titleController,
                labelText: 'Judul',
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),

              const SizedBox(height: 16),

              // --- INPUT ISI ---
              CustomInputField(
                controller: _contentController,
                labelText: 'Isi Catatan',
                maxLines: 5, // Kotak lebih besar
                validator: (value) => value!.isEmpty ? 'Isi catatan tidak boleh kosong' : null,
              ),

              const SizedBox(height: 24),

              // --- TOMBOL SIMPAN ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Catatan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}