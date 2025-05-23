import 'package:mobile_app/geo_api/services/events/filters.dart';
import 'package:mobile_app/types/events/comments.dart';
import 'package:uuid/uuid.dart';

import '../../geo_api/services/events/events_services.dart';
import '../../types/events/events.dart';

class EventsRepository {
  static final eventsService = EventsService();

  Future<Event> getDetailedEvent(String id) async {
    return await eventsService.getDetailedEvent(id);
  }

  Future<List<PureEvent>> fetchEventsForUser() async {
    return await eventsService.fetchAllEvents();
  }

  Future<List<PureComment>> getCommentsForEvent(String eventId) async {
    return await eventsService.getCommentsForEvent(eventId);
  }
}
