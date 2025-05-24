class PureComment {
  final String id;
  final String eventId;

  final String authorId;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  PureComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.eventId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PureComment.fromJson(Map<String, dynamic> json) {
    DateTime cr = DateTime.parse(json["createdAt"]);
    DateTime up = DateTime.parse(json["createdAt"]);
    return PureComment(
      eventId: json["eventId"],
      createdAt: cr,
      updatedAt: up,
      id: json['id'],
      authorId: json['authorId'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      "eventId": eventId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'id': id,
      'authorId': authorId,
      'text': text,
    };
  }
}
