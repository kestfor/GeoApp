import 'package:flutter/cupertino.dart';
import 'package:mobile_app/types/events/events.dart';

class EventsController extends ChangeNotifier {

  List<PureEvent> _events = [];

  void setEvents(List<PureEvent> events) {
    _events = events;
    notifyListeners();
  }

  void addEvent(PureEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(PureEvent event) {
    _events.remove(event);
    notifyListeners();
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  List<PureEvent> get events => _events;

}