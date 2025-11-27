// lib/models/profile_model.dart

class Profile {
  final String id;
  final String username;
  final String? avatarUrl; // Tanda tanya (?) berarti boleh kosong (null)

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  // Mengubah data JSON (dari Supabase) menjadi Object Flutter
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '', // Jika null, diisi string kosong agar tidak error
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'], // Sesuaikan dengan nama kolom di database
    );
  }

  // Mengubah Object Flutter menjadi JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }
}