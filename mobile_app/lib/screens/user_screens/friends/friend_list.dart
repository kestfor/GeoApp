import 'package:mobile_app/geo_api/services/users/users_service.dart';
import 'package:mobile_app/repositories/user_repository/user_repository.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/mocks.dart';

class LazyDataProvider<T> {
  final List<T>? initData;

  LazyDataProvider({this.initData});

  Future<List<T>> fetchItems({required String userId, required int offset, required int limit, required String query}) {
    throw UnimplementedError();
  }
}

class UserDataProvider extends LazyDataProvider<PureUser> {
  final UserRepository _apiInstance = UserRepository();

  UserDataProvider({super.initData});

  @override
  Future<List<PureUser>> fetchItems({required String userId, int offset = 0, int limit = 20, String query = ""}) async {
    if (offset == 0 && initData != null && initData!.length >= limit && query == "") {
      return initData!;
    }
    return _apiInstance.fetchFriendsForUser(userId, query: query, limit: limit, offset: offset);
  }
}

class MockedDataProvider extends LazyDataProvider<User> {
  MockedDataProvider({super.initData});

  @override
  Future<List<User>> fetchItems({required String userId, int offset = 0, int limit = 20, String query = ""}) async {
    if (offset == 0 && initData != null && initData!.length >= limit && query == "") {
      return initData!;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return friendsMocks;
  }
}
