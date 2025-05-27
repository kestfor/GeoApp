import 'dart:convert';
import 'dart:typed_data';

import 'package:mobile_app/geo_api/base_api.dart';

import '../../../logger/logger.dart';
import '../../../types/user/user.dart';

class UsersService {
  static final BaseApi baseApi = BaseApi();
  final String baseUrl = "${BaseApi.url}:8003/api/users_service";

  List<PureUser> _parseUsersFromJson(Uint8List body) {
    List<dynamic> jsonList = jsonDecode(utf8.decode(body));
    return jsonList.map((e) => PureUser.fromJson(e)).toList();
  }

  Future<List<PureUser>> getUsersFromIds(List<String> ids) async {
    final Uri uri = Uri.parse('$baseUrl/users/list');
    final res = await baseApi.post(uri, body: ids);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch users with ids $ids, ${res.reasonPhrase}');
    }

    return _parseUsersFromJson(res.bodyBytes);
  }

  Future<PureUser> getUserFromId(String id) async {
    List<PureUser> users = await getUsersFromIds([id]);
    if (users.isEmpty) {
      throw Exception('User with id $id not found');
    }
    return users.first;
  }

  Future<User> getDetailedUser(String userId) async {
    final Uri uri = Uri.parse('$baseUrl/users/detailed/$userId');

    final res = await baseApi.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch user with id $userId, ${res.reasonPhrase}');
    }

    print(res.body);
    final user = User.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    return user;
  }

  Future<User> modifyUser(User user) async {
    final Uri uri = Uri.parse('$baseUrl/users');
    final res = await baseApi.patch(uri, body: user.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to modify user, ${res.reasonPhrase}');
    }
    Logger().debug("user successfully modified");
    return user;
  }

  Future<void> deleteUser(String userId) async {
    final Uri uri = Uri.parse('$baseUrl/users/$userId');
    final res = await baseApi.delete(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete user with id $userId, ${res.reasonPhrase}');
    }
    Logger().debug("user with id $userId successfully deleted");
  }

  Future<List<PureUser>> fetchFriendsForUser(String userId) async {
    final Uri uri = Uri.parse('$baseUrl/users/friends/$userId');
    final res = await baseApi.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to modify user, ${res.reasonPhrase}');
    }
    return _parseUsersFromJson(res.bodyBytes);
  }

  Future<List<PureUser>> fetchUsersFromQuery(String query) async {
    final Uri uri = Uri.parse('$baseUrl/users/search');
    Map<String, dynamic> body = {"text": query};
    final res = await baseApi.post(uri, body: body);
    if (res.statusCode != 200) {
      throw Exception('Failed to get users, ${res.reasonPhrase}');
    }
    print(res.body);
    return _parseUsersFromJson(res.bodyBytes);
  }
}
