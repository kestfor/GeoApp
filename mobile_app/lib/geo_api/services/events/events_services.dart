import 'package:mobile_app/geo_api/base_api.dart';

import '../../../types/events/comments.dart';
import '../../../types/events/events.dart';
import '../../../utils/mocks.dart';
import 'filters.dart';

class EventsService {
  final BaseApi baseApi = BaseApi();

  Future<List<PureEvent>> fetchEventsForUser(EventFilter filter) async {
    Map<String, dynamic> body = {"limit": 20, "offset": 0, "filter": filter};
    return Future.delayed(Duration(milliseconds: 300), () => pureEventsMock);
  }

  Future<Event> getDetailedEvent(int eventId) async {
    return Future.delayed(Duration(milliseconds: 300), () => detailedEventMock);
  }

  Future<List<PureComment>> getCommentsForEvent(int eventId) async {
    return Future.delayed(Duration(milliseconds: 300), () => commentsMock);
  }
}
