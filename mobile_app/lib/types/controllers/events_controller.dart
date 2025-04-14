import 'package:flutter/cupertino.dart';
import 'package:mobile_app/types/events/events.dart';

class EventsController extends ChangeNotifier {

  List<PureEvent> events = [];

  void setEvents(List<PureEvent> events) {
    this.events = events;
    notifyListeners();
  }

  void addEvent(PureEvent event) {
    events.add(event);
    notifyListeners();
  }

  void removeEvent(PureEvent event) {
    events.remove(event);
    notifyListeners();
  }

  void clearEvents() {
    events.clear();
    notifyListeners();
  }

}