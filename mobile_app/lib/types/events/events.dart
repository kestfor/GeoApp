import 'package:mobile_app/types/media/media.dart';
import 'package:mobile_app/types/user/user.dart';

class Point {
  double lat;
  double lon;

  Point({required this.lat, required this.lon});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(lat: json['latitude'], lon: json['longitude']);
  }

  Map<String, dynamic> toJson() {
    return {'latitude': lat, 'longitude': lon};
  }

  @override
  String toString() {
    return 'Point{lat: $lat, lon: $lon}';
  }
}

class PureEvent {
  String id;
  String coverUrl;
  String name;
  String? authorId;
  List<String> membersId;
  Point point;
  DateTime createdAt;

  PureEvent({
    required this.id,
    required this.coverUrl,
    required this.name,
    required this.authorId,
    required this.membersId,
    required this.point,
    required this.createdAt,
  });

  factory PureEvent.fromJson(Map<String, dynamic> json) {
    DateTime cr = DateTime.parse(json["createdAt"]);
    return PureEvent(
      point: Point(lat: json["latitude"], lon: json["longitude"]),
      id: json['id'],
      coverUrl: json["displayPhoto"]["representations"]["medium"]["url"],
      name: json['name'],
      authorId: json['ownerId'],
      membersId: List<String>.from(json['participantIds']),
      createdAt: cr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayPhoto': coverUrl,
      'name': name,
      'ownerId': authorId,
      'participantIds': membersId,
      'longitude': point.lon,
      "latitude": point.lat,
    };
  }

  factory PureEvent.fromEvent(Event event) {
    return PureEvent(
      createdAt: event.createdAt,
      id: event.id,
      coverUrl: event.coverUrl,
      name: event.name,
      authorId: event.authorId,
      membersId: event.membersId,
      point: event.point,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, coverUrl: $coverUrl, name: $name, authorId: $authorId, membersId: $membersId}';
  }
}

class Event extends PureEvent {
  String? description;
  List<PureUser> members;
  List<MediaContent> files = [];
  List<String> mediaIds = [];

  Event({
    required super.point,
    required super.id,
    required super.coverUrl,
    required super.name,
    required super.authorId,
    required super.membersId,
    required super.createdAt,
    this.description,
    this.members = const [],
    this.mediaIds = const [],
    required this.files,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime cr = DateTime.parse(json["createdAt"]);
    final res = Event(
      createdAt: cr,
      point: Point(lat: json["latitude"], lon: json["longitude"]),
      id: json['eventId'],
      coverUrl: "",
      name: json['name'],
      authorId: json['ownerId'],
      membersId: List<String>.from(json['participantIds']),
      description: json['description'],
      //members: (json['members'] as List).map((e) => PureUser.fromJson(e)).toList(),
      files: (json['media'] as List).map((e) => resolveFromJson(e)).toList(),
    );
    res.coverUrl = getCover(res.files);
    return res;
  }

  factory Event.from(Event event) {
    return Event(
      createdAt: event.createdAt,
      point: event.point,
      id: event.id,
      coverUrl: event.coverUrl,
      name: event.name,
      files: event.files,
      membersId: event.membersId,
      description: event.description,
      authorId: event.authorId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'longitude': point.lon,
      "latitude": point.lat,
      //'displayPhoto': coverUrl,
      "eventId": id,
      'name': name,
      'ownerId': authorId,
      'participantIds': membersId,
      'description': description,
      'mediaIds': files.isNotEmpty ? files.map((file) => getId(file)).toList() : mediaIds,
      //'members': members.map((e) => e.toJson()).toList(),
    };
  }
}
