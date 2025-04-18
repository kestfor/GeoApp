import 'package:flutter/cupertino.dart';

import '../user/user.dart';

class FriendsController extends ChangeNotifier {
  List<PureUser> _friends = [];

  void setFriends(List<PureUser> friends) {
    _friends = friends;
    notifyListeners();
  }

  void addFriend(PureUser friend) {
    _friends.add(friend);
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

  List<PureUser> get friends => _friends;
}
