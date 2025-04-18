import 'package:mobile_app/geo_api/services/events/filters.dart';
import 'package:mobile_app/types/events/comments.dart';

import '../../geo_api/services/events/events_services.dart';
import '../../types/events/events.dart';

class EventsRepository {
  static final eventsService = EventsService();

  Future<Event> getDetailedEvent(int id) async {
    return await eventsService.getDetailedEvent(id);
  }

  Future<List<PureEvent>> fetchEventsForUser(EventFilter filter) async {
    return await eventsService.fetchEventsForUser(filter);
  }

  Future<List<PureComment>> getCommentsForEvent(int eventId) async {
    return await eventsService.getCommentsForEvent(eventId);
  }
}
