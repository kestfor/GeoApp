import 'package:flutter/foundation.dart';
import 'package:mobile_app/types/events/events.dart';

import '../user/user.dart';

class MainUserController extends ChangeNotifier {
  User? _user;
  final List<PureUser> _friends = [];
  final List<PureEvent> _events = [];

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
    _events.insert(0, event);
    notifyListeners();
  }

  void addEvents(List<PureEvent> events) {
    _events.insertAll(0, events);
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
