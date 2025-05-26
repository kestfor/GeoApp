import '../../geo_api/services/users/users_service.dart';
import '../../types/user/user.dart';

class UserRepository {
  static final usersService = UsersService();

  Future<List<PureUser>> getUsersFromIds(List<String> ids) async {
    return await usersService.getUsersFromIds(ids);
  }

  Future<User> getDetailedUser(String userId) async {
    return await usersService.getDetailedUser(userId);
  }

  Future<User> modifyUser(User user) async {
    return await usersService.modifyUser(user);
  }

  Future<List<PureUser>> fetchFriendsForUser(String userId, {String query = "", int? limit, int? offset}) async {
    return await usersService.fetchFriendsForUser(userId);
  }

  Future<List<PureUser>> fetchUsersFromQuery(String query) async {
    return await usersService.fetchUsersFromQuery(query);
  }

  Future<PureUser> getUserFromId(String id) async {
    return await usersService.getUserFromId(id);
  }
}
