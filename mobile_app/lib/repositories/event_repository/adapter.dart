import 'package:hive/hive.dart';

import '../../types/events/events.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0; // Уникальный ID для адаптера

  @override
  Event read(BinaryReader reader) {
    final json = reader.readMap();
    return Event.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeMap(obj.toJson());
  }
}

