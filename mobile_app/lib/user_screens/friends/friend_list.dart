import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/geo_api/geo_api.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/user/user.dart';

import '../../utils/mocks.dart';

class LazyDataProvider<T> {
  final List<T>? initData;

  LazyDataProvider({this.initData});

  Future<List<T>> fetchItems({required int userId, required int offset, required int limit, required String query}) {
    throw UnimplementedError();
  }
}

class UserDataProvider extends LazyDataProvider<User> {
  final GeoApiInstance _apiInstance = GeoApiInstance();

  UserDataProvider({super.initData});

  @override
  Future<List<User>> fetchItems({required int userId, int offset = 0, int limit = 20, String query = ""}) async {
    if (offset == 0 && initData != null && initData!.length >= limit && query == "") {
      return initData!;
    }
    return _apiInstance.fetchFriendsForUser(userId, query: query, limit: limit, offset: offset);
  }
}

class MockedDataProvider extends LazyDataProvider<User> {
  MockedDataProvider({super.initData});

  @override
  Future<List<User>> fetchItems({required int userId, int offset = 0, int limit = 20, String query = ""}) async {
    if (offset == 0 && initData != null && initData!.length >= limit && query == "") {
      return initData!;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return friendsMocks;
  }
}

