// lib/models/note_model.dart

class Note {
  final int? id; // Bisa null karena saat baru dibuat, ID belum ada (auto-increment dari DB)
  final String userId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
  });

  // Mengubah data JSON (dari Supabase) menjadi Object Flutter
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'] ?? '', // Pastikan nama kolom sesuai di Supabase (user_id)
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      // Mengubah format tanggal string dari database menjadi format DateTime Flutter
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  // Mengubah Object Flutter menjadi JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      // Kita tidak mengirim 'id' ke sini karena ID dibuat otomatis oleh database
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      // 'created_at' juga biasanya otomatis diisi database (default now())
    };
  }
}