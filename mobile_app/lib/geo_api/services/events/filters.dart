class Circle {
  final double x;
  final double y;
  final double radius;

  Circle({required this.x, required this.y, required this.radius});
}

class EventFilter {
  final int userId;
  final String? name;
  final List<int>? members;
  final Circle? circle;
  final DateTime? date;

  EventFilter({required this.userId, this.name, this.members, this.circle, this.date});

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'members': members,
      'circle': circle != null ? {'x': circle!.x, 'y': circle!.y, 'radius': circle!.radius} : null,
      'date': date?.toIso8601String(),
    };
  }

  factory EventFilter.fromJson(Map<String, dynamic> json) {
    return EventFilter(
      userId: json["user"],
      name: json['name'],
      members: List<int>.from(json['members'] ?? []),
      circle: json['circle'] != null ? Circle(x: json['circle']['x'], y: json['circle']['y'], radius: json['circle']['radius']) : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}
