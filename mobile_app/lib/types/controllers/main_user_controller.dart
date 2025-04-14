import 'package:flutter/foundation.dart';

import '../user/user.dart';

class MainUserController extends ChangeNotifier {
  User? _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void logOut() {
    if (_user != null) {
      _user!.onLogOut?.call();
    }
    _user = null;
    notifyListeners();
  }
}
