import 'package:flutter/foundation.dart';
import 'package:mobile_app/types/events/events.dart';

import '../user/user.dart';

class MainUserController extends ChangeNotifier {
  User? _user;
  final Map<String, PureUser> _friends = {};
  final Map<String, PureEvent> _events = {};

  /// Singleton instance of MainUserController
  /// This is a global controller that manages the main user state, events, and friends.
  /// It is used throughout the app to access the current user, their events, and friends.
  /// This controller is initialized in the main.dart file and is available to all widgets in the app.
  /// It is recommended to use this controller instead of creating new instances of User, EventsController, or FriendsController.
  /// This controller is used to manage the main user state, events, and friends.
  /// It is a singleton, so it can be accessed from anywhere in the app.
  ///

  static final MainUserController instance = MainUserController._internal();

  MainUserController._internal();

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  List<PureEvent> get events {
    final res = _events.values.toList();
    res.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return res;
  }

  void logOut() {
    if (_user != null) {
      _user!.onLogOut?.call();
    }
    _user = null;
    notifyListeners();
  }

  void addFriend(PureUser friend) {
    _friends[friend.id] = friend;
    notifyListeners();
  }

  void addFriends(List<PureUser> friends) {
    for (var friend in friends) {
      _friends[friend.id] = friend;
    }
    notifyListeners();
  }

  void removeFriend(PureUser friend) {
    _friends.remove(friend.id);
    notifyListeners();
  }

  void clearFriends() {
    _friends.clear();
    notifyListeners();
  }

  void addEvent(PureEvent event) {
    _events[event.id] = event;
    notifyListeners();
  }

  void addEvents(List<PureEvent> events) {
    for (var event in events) {
      _events[event.id] = event;
    }
    notifyListeners();
  }

  void removeEvent(PureEvent event) {
    _events.remove(event.id);
    notifyListeners();
  }

  List<PureUser> get friends {
    final res = _friends.values.toList();
    res.sort((a, b) => a.firstName.compareTo(b.firstName));
    return res;
  }

  PureUser? getFriendById(String id) {
    return _friends[id];
  }

  PureEvent? getEventById(String id) {
    return _events[id];
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}
