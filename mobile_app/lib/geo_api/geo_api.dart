import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_app/oauth/token_manager/token_manager.dart';
import 'package:mobile_app/utils/mocks.dart';

import '../types/user/user.dart';

class GeoApiInstance implements Refresher {
  static const String _baseUrl = 'https://geo_api.com';
  static Encoding? defaultEncoding = Encoding.getByName('utf-8');
  static final Map<String, String> defaultHeaders = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
  static GeoApiInstance? _instance;

  static late TokenManager _tokenManager;

  GeoApiInstance._internal();

  factory GeoApiInstance() => _instance!;

  static Future<void> loadTokenData() async {
    if (_instance != null) {
      return;
    }

    _instance = GeoApiInstance._internal();
    try {
      await TokenManager.read(_instance);
      _tokenManager = TokenManager(_instance!);
    } catch (e) {
      _instance = null;
      throw Exception('Failed to load token data, $e');
    }
  }

  factory GeoApiInstance.fromTokenData(String refreshToken, String accessToken, int expiresAt) {
    _instance ??= GeoApiInstance._internal();
    _tokenManager = TokenManager.fromTokenData(
      refresher: _instance!,
      refreshToken: refreshToken,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
    return _instance!;
  }

  static Future<Map<String, dynamic>> googleAuth(String token) async {
    Map<String, dynamic> data = {
      "access_token": "access_token",
      "refresh_token": "refresh_token",
      "expires_at": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
    };
    return data;

    final Uri uri = Uri.parse('$_baseUrl/google_auth');
    Map<String, dynamic> body = {"token": token};
    var res = await http.post(uri, body: jsonEncode(body), headers: defaultHeaders, encoding: defaultEncoding);

    if (res.statusCode != 200) {
      throw Exception('Failed to authenticate with Google');
    }

    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    Map<String, dynamic> data = {
      "access_token": "access_token",
      "refresh_token": "refresh_token",
      "expires_at": (DateTime.now().millisecondsSinceEpoch / 1000 + 3600).toInt(),
    };

    return data;

    final Uri uri = Uri.parse('$_baseUrl/token');
    Map<String, dynamic> body = {"refresh_token": refreshToken, "grant_type": "refresh_token"};
    var res = await http.post(uri, body: jsonEncode(body), headers: defaultHeaders, encoding: defaultEncoding);

    if (res.statusCode != 200) {
      throw Exception('Failed to refresh token');
    }

    return jsonDecode(res.body);
  }

  @override
  Future<Map<String, dynamic>> refresh(String token) async {
    return await refreshToken(token);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final headers = Map.of(defaultHeaders);
    headers.addAll({'Authorization': 'Bearer ${await _tokenManager.accessToken}'});

    return headers;
  }

  Future<List<User>> fetchFriendsForUser(int userId, {String query = "", int? limit, int? offset}) async {
    Map<String, dynamic> body = {"limit": 20, "offset": 0, "query": query, "user_id": userId};
    final headers = await getAuthHeaders();
    return Future.delayed(Duration(milliseconds: 300), () => friendsMocks);
  }

  Future<List<User>> fetchUsersFromQuery(String query) async {
    Map<String, dynamic> body = {"limit": 20, "offset": 0, "query": query};
    final headers = await getAuthHeaders();
    return Future.delayed(Duration(milliseconds: 300), () => friendsMocks);
  }

  Future<User> getDetailedUser(int userId) async {
    final headers = await getAuthHeaders();
    return Future.delayed(Duration(milliseconds: 300), () => friendsMocks[0]);
  }
}
