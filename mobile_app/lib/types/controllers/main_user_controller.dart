import 'package:flutter/foundation.dart';
import 'package:mobile_app/types/events/events.dart';

import '../user/user.dart';

class MainUserController extends ChangeNotifier {
  User? _user;
  final List<PureUser> _friends = [];
  final List<PureEvent> _events = [];

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  List<PureEvent> get events => _events;
  List<PureUser> get friend => _friends;


  void logOut() {
    if (_user != null) {
      _user!.onLogOut?.call();
    }
    _user = null;
    notifyListeners();
  }

  void addFriend(PureUser friend) {
    _friends.add(friend);
    notifyListeners();
  }

  void addFriends(List<PureUser> friends) {
    _friends.addAll(friends);
    notifyListeners();
  }

  void removeFriend(PureUser friend) {
    _friends.remove(friend);
    notifyListeners();
  }

  void clearFriends() {
    _friends.clear();
    notifyListeners();
  }

  void addEvent(PureEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void addEvents(List<PureEvent> events) {
    _events.addAll(events);
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

}
