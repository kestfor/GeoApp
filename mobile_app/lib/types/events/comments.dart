class PureComment {
  final int id;
  final String authorId;
  final String text;
  final int createdAt;
  final int updatedAt;

  PureComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PureComment.fromJson(Map<String, dynamic> json) {
    return PureComment(
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      id: json['id'],
      authorId: json['author_id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'created_at': createdAt, 'updated_at': updatedAt, 'id': id, 'author_id': authorId, 'text': text};
  }
}
