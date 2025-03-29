import 'package:mobile_app/types/user/user.dart';

class Point {
  double lat;
  double lon;

  Point({required this.lat, required this.lon});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(lat: json['lat'], lon: json['lon']);
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lon': lon};
  }

  @override
  String toString() {
    return 'Point{lat: $lat, lon: $lon}';
  }
}

class PureEvent {
  int id;
  String coverUrl;
  String name;
  int authorId;
  List<int> membersId;
  Point point;

  PureEvent({
    required this.id,
    required this.coverUrl,
    required this.name,
    required this.authorId,
    required this.membersId,
    required this.point,
  });

  factory PureEvent.fromJson(Map<String, dynamic> json) {
    return PureEvent(
      point: json["point"],
      id: json['id'],
      coverUrl: json['cover_url'],
      name: json['name'],
      authorId: json['author_id'],
      membersId: List<int>.from(json['members_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cover_url': coverUrl,
      'name': name,
      'author_id': authorId,
      'members_id': membersId,
      'point': point.toJson(),
    };
  }

  @override
  String toString() {
    return 'Event{id: $id, coverUrl: $coverUrl, name: $name, authorId: $authorId, membersId: $membersId}';
  }
}

class Event extends PureEvent {
  String? description;
  List<PureUser> members;

  Event({
    required super.point,
    required super.id,
    required super.coverUrl,
    required super.name,
    required super.authorId,
    required super.membersId,
    this.description,
    this.members = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      point: json["point"],
      id: json['id'],
      coverUrl: json['cover_url'],
      name: json['name'],
      authorId: json['author_id'],
      membersId: List<int>.from(json['members_id']),
      description: json['description'],
      members: (json['members'] as List).map((e) => PureUser.fromJson(e)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'point': point.toJson(),
      'cover_url': coverUrl,
      'name': name,
      'author_id': authorId,
      'members_id': membersId,
      'description': description,
      'members': members.map((e) => e.toJson()).toList(),
    };
  }
}
