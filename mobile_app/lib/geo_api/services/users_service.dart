import 'package:mobile_app/geo_api/base_api.dart';

import '../../types/user/user.dart';
import '../../utils/mocks.dart';

class UsersService {
  static final BaseApi baseApi = BaseApi();

  Future<List<PureUser>> getUsersFromIds(List<int> ids) async {
    //TODO replace with real API call
    List<PureUser> users = [];
    for (var id in ids) {
      for (var u in allUsers) {
        print("User id: ${u.id}, searching for $id");
        if (u.id == id) {
          users.add(u);
          break;
        }
      }
    }
    return Future.delayed(Duration(milliseconds: 300), () => users);
  }

  Future<PureUser> getUserFromId(int id) async {
    return mockUser;
  }

  Future<User> getDetailedUser(int userId) async {
    for (var u in allUsers) {
      if (u.id == userId) {
        return Future.delayed(Duration(milliseconds: 300), () => u);
      }
    }

    return Future.delayed(Duration(milliseconds: 300), () => mockUser);
  }

  Future<void> modifyUser(User user) async {
    if (user.username.isEmpty) {
      throw Exception("Username cannot be empty");
    }

    if (user.firstName.isEmpty) {
      throw Exception("First name cannot be empty");
    }

    return Future.delayed(Duration(milliseconds: 300), () => null);
  }

  Future<List<User>> fetchFriendsForUser(int userId, {String query = "", int? limit, int? offset}) async {
    Map<String, dynamic> body = {"limit": 20, "offset": 0, "query": query, "user_id": userId};
    return Future.delayed(Duration(milliseconds: 300), () => friendsMocks);
  }

  Future<List<User>> fetchUsersFromQuery(String query) async {
    Map<String, dynamic> body = {"limit": 20, "offset": 0, "query": query};
    return Future.delayed(Duration(milliseconds: 300), () => friendsMocks);
  }
}
