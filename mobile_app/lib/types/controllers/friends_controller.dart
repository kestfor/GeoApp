import 'package:flutter/cupertino.dart';
import '../user/user.dart';

class FriendsController extends ChangeNotifier {
  List<PureUser> friends = [];

  void setFriends(List<PureUser> friends) {
    this.friends = friends;
    notifyListeners();
  }

  void addFriend(PureUser friend) {
    friends.add(friend);
    notifyListeners();
  }

  void removeFriend(PureUser friend) {
    friends.remove(friend);
    notifyListeners();
  }

  void clearFriends() {
    friends.clear();
    notifyListeners();
  }
}