import '../../geo_api/services/users/users_service.dart';
import '../../types/user/user.dart';

class UserRepository {
  static final usersService = UsersService();

  Future<List<PureUser>> getUsersFromIds(List<int> ids) async {
    return await usersService.getUsersFromIds(ids);
  }

  Future<User> getDetailedUser(int userId) async {
    return await usersService.getDetailedUser(userId);
  }

  Future<void> modifyUser(User user) async {
    return await usersService.modifyUser(user);
  }

  Future<List<User>> fetchFriendsForUser(int userId, {String query = "", int? limit, int? offset}) async {
    return await usersService.fetchFriendsForUser(userId, query: query, limit: limit, offset: offset);
  }

  Future<List<User>> fetchUsersFromQuery(String query) async {
    return await usersService.fetchUsersFromQuery(query);
  }

  Future<PureUser> getUserFromId(int id) async {
    return await usersService.getUserFromId(id);
  }
}

