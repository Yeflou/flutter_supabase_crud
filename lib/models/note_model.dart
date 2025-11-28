class Note {
  final int? id; 
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

 
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
    
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

 
  Map<String, dynamic> toJson() {
    return {
     
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
     
    };
  }
}