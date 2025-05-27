import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../logger/logger.dart';

abstract class Refresher {
  Future<Map<String, dynamic>> refresh(String refreshToken);
}

abstract class Authenticator {
  void setAdditionalData(Map<String, dynamic> data);
  Future<Map<String, dynamic>> authenticate();
}

class TokenManager {
  static TokenManager? _instance;
  static String keyName = "token_data";
  static int closestToExpireSeconds = 60;
  static bool _ready = false;

  factory TokenManager.fromTokenData({
    required Refresher refresher,
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) {
    _instance = TokenManager._internal(refresher, accessToken, refreshToken, expiresAt);
    return _instance!;
  }

  factory TokenManager(Refresher refresher) {
    _refresher = refresher;
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("TokenManager is not initialized");
  }

  TokenManager._internal(Refresher refresher, String accessToken, String refreshToken, int expiresAt) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;
    _refresher = refresher;
    _save();
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static late Refresher _refresher;
  static String _accessToken = "access_token";
  static String _refreshToken = "refresh_token";
  static int _expiresAt = 0;

  static Future<void> _save() async {
    Map<String, dynamic> data = {
      "access_token": _accessToken,
      "refresh_token": _refreshToken,
      "expires_at": _expiresAt,
    };

    await _storage.write(key: keyName, value: jsonEncode(data));
  }

  static Future<void> read(refresher) async {
    final jsonString = await _storage.read(key: keyName);
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      _accessToken = data["access_token"];
      _refreshToken = data["refresh_token"];
      _expiresAt = data["expires_at"];
      _refresher = refresher;
      _instance = TokenManager._internal(refresher, _accessToken, _refreshToken, _expiresAt);
      Logger().debug("TokenManager: read token data, expires at ${DateTime.fromMillisecondsSinceEpoch(_expiresAt * 1000)}");
    } else {
      throw Exception("No token data found");
    }
  }

  Future<void> _refresh(Refresher refresher) async {
    final data = await refresher.refresh(_refreshToken);
    if (data.containsKey("access_token")) {
      _accessToken = data["access_token"];
      _expiresAt = data["expires_at"];
      _refreshToken = data["refresh_token"];
      await _save();
      Logger().debug("token refreshed: $_accessToken, $_refreshToken, $_expiresAt");
    } else {
      throw Exception("Failed to refresh token");
    }
  }

  Future<String> get accessToken async {
    if (isExpired || isExpiring) {
      await _refresh(_refresher);
    }
    return _accessToken;
  }

  Future<void> delete() async {
    await _storage.delete(key: keyName);
  }

  bool get isReady => _ready;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch / 1000 >= _expiresAt;

  bool get isExpiring => (_expiresAt - DateTime.now().millisecondsSinceEpoch / 1000).abs() <= closestToExpireSeconds;
}
