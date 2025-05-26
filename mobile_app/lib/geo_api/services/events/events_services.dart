import 'dart:convert';
import 'dart:io';

import 'package:mobile_app/geo_api/base_api.dart';

import '../../../types/events/comments.dart';
import '../../../types/events/events.dart';
import '../../../utils/mocks.dart';

class EventsService {
  final BaseApi baseApi = BaseApi();
  final String baseUrl = "${BaseApi.url}:8002/api/events_service";

  // Future<List<PureEvent>> fetchEventsForUser(EventFilter filter) async {
  //   Map<String, dynamic> body = {"limit": 20, "offset": 0, "filter": filter};
  //   return Future.delayed(Duration(milliseconds: 300), () => pureEventsMock);
  // }

  Future<List<PureEvent>> fetchAllEvents({bool sort = true}) async {
    final Uri uri = Uri.parse("$baseUrl/events/available");
    var res = await baseApi.get(uri);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("can't fetch events for user, ${res.reasonPhrase}");
    }

    List<PureEvent> items = (jsonDecode(utf8.decode(res.bodyBytes)) as List).map((e) => PureEvent.fromJson(e)).toList();
    if (sort) {
      items.sort((a, b) => b.createdAt.millisecondsSinceEpoch - a.createdAt.millisecondsSinceEpoch);
    }
    return items;
  }

  Future<Event> getDetailedEvent(String eventId) async {
    final Uri uri = Uri.parse("$baseUrl/events/$eventId");
    var res = await baseApi.get(uri);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("can't fetch detailed event with id $eventId for user, ${res.reasonPhrase}");
    }
    return Event.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<List<PureComment>> getCommentsForEvent(String eventId) async {
    return Future.delayed(Duration(milliseconds: 300), () => commentsMock);
  }

  Future<void> updateEvent(Event event) async {
    final Uri uri = Uri.parse("$baseUrl/events/${event.id}");
    final body = event.toJson();
    final res = await baseApi.put(uri, body: body);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("can't update detailed event with id ${event.id} for user, ${res.reasonPhrase}");
    }
  }

  Future<Event> createEvent(Event event) async {
    final Uri uri = Uri.parse("$baseUrl/events");
    final body = event.toJson();
    final res = await baseApi.post(uri, body: body);
    if (res.statusCode != HttpStatus.created) {
      throw Exception("can't create new event with id ${event.id} for user, ${res.reasonPhrase}");
    }
    return Event.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<void> deleteEvent(String eventId) async {
    final Uri uri = Uri.parse("$baseUrl/events/$eventId");
    final res = await baseApi.delete(uri);
    if (res.statusCode != HttpStatus.noContent) {
      throw Exception("can't delete event with id $eventId for user, ${res.reasonPhrase}");
    }
  }

  Future<List<PureComment>> fetchCommentsForEvent(String eventId, {bool sort = true}) async {
    final Uri uri = Uri.parse("$baseUrl/events/$eventId/comments");
    final res = await baseApi.get(uri);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("can't fetch comments for event with id $eventId for user, ${res.reasonPhrase}");
    }

    List<PureComment> items =
        (jsonDecode(utf8.decode(res.bodyBytes)) as List).map((e) => PureComment.fromJson(e)).toList();
    if (sort) {
      items.sort((a, b) => b.createdAt.millisecondsSinceEpoch - a.createdAt.millisecondsSinceEpoch);
    }
    return items;
  }

  Future<PureComment> sendComment(String eventId, String authorId, String comment) async {
    final Uri uri = Uri.parse("$baseUrl/events/$eventId/comments");
    Map<String, dynamic> body = {"authorId": authorId, "text": comment};
    final res = await baseApi.post(uri, body: body);
    if (res.statusCode != HttpStatus.created) {
      throw Exception("can't send comment for event with id $eventId for user, ${res.reasonPhrase}");
    }

    return PureComment.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<PureComment> updateComment(PureComment comment) async {
    final Uri uri = Uri.parse("$baseUrl/events/${comment.eventId}/comments/${comment.id}");
    Map<String, dynamic> body = {"text": comment};
    final res = await baseApi.put(uri, body: body);
    if (res.statusCode != HttpStatus.created) {
      throw Exception("can't modify comment for event with id ${comment.id} for user, ${res.reasonPhrase}");
    }

    return PureComment.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<void> deleteComment(String eventId, String commentId) async {
    final Uri uri = Uri.parse("$baseUrl/events/${eventId}/comments/${commentId}");
    final res = await baseApi.delete(uri);
    if (res.statusCode != HttpStatus.noContent) {
      throw Exception("can't delete comment for event with id ${eventId} for user, ${res.reasonPhrase}");
    }
  }

}
