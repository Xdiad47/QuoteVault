class Collection {
  final int id;
  final String userId;
  final String name;
  final DateTime? createdAt;

  Collection({
    required this.id,
    required this.userId,
    required this.name,
    this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
