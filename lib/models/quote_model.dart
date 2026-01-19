class Quote {
  final int id;
  final String text;
  final String author;
  final String category;
  final DateTime? createdAt;
  bool isFavorite;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.createdAt,
    this.isFavorite = false,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Quote copyWith({
    int? id,
    String? text,
    String? author,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
