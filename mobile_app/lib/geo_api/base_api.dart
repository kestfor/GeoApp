import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_app/geo_api/auth.dart';
import 'package:mobile_app/geo_api/token_manager/token_manager.dart';

enum AuthType { google }

class BaseApi {
  //static const String baseUrl = "https://d5d4vtbtvlgjp2bmr1pb.yl4tuxdu.apigw.yandexcloud.net";
  static const String baseUrl = "http://192.168.0.18";
  static const String mobileNetUrl = "http://192.168.0.187";
  static const String wifiNetUrl = "http://192.168.0.18";
  static const String remoteUrl = "http://138.124.50.226";

  static final String url = mobileNetUrl;

  static final Encoding defaultEncoding = Encoding.getByName('utf-8')!;
  static final Map<String, String> _defaultHeaders = <String, String>{
    "Content-Type": "application/json; charset=UTF-8",
  };
  static final refresher = ApiKeyRefresher(refreshUrl: "$url/api/users_service/auth/refresh");
  static final Map<AuthType, Authenticator> authenticators = {
    AuthType.google: ThroughGoogleAuthenticator(authUrl: "$url/api/users_service/auth/google"),
  };
  static final BaseApi _instance = BaseApi._internal();
  static TokenManager? _tokenManager;

  Map<String, String> get defaultHeaders => _defaultHeaders;

  /// This method is used to authenticate the user using the specified AuthType, if auth is successful, userData will be returned
  static Future<Map<dynamic, dynamic>> authenticate(AuthType authType, Map<String, dynamic> additional) async {
    Authenticator? authenticator = authenticators[authType];
    if (authenticator == null) {
      throw Exception('Authenticator for $authType not found');
    }

    authenticator.setAdditionalData(additional);
    Map<dynamic, dynamic> authData = await authenticator.authenticate();
    final jwt = authData['jwt'];
    Map<dynamic, dynamic> userData = authData['user'];

    _tokenManager = TokenManager.fromTokenData(
      refresher: refresher,
      refreshToken: jwt['refresh_token'],
      accessToken: jwt['access_token'],
      expiresAt: jwt['expires_at'],
    );

    return userData;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    if (_tokenManager == null) {
      throw Exception('token is not initialized, need to call authenticate() first');
    }
    final headers = Map.of(defaultHeaders);
    // TODO убрать X-User-Id
    headers.addAll({
      'Authorization': 'Bearer ${await _tokenManager!.accessToken}',
      //  "X-User-Id": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
    });
    return headers;
  }

  Future<http.Response> post(Uri uri, {Object? body, Map<String, String>? headers}) async {
    headers ??= {};
    headers.addAll(await getAuthHeaders());

    var res = await http.post(uri, body: jsonEncode(body), headers: headers, encoding: defaultEncoding);
    return res;
  }

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    headers ??= {};
    headers.addAll(await getAuthHeaders());
    var res = await http.get(uri, headers: headers);
    return res;
  }

  Future<http.Response> delete(Uri uri, {Object? body, Map<String, String>? headers}) async {
    headers ??= {};
    headers.addAll(await getAuthHeaders());

    var res = await http.delete(uri, body: jsonEncode(body), headers: headers, encoding: defaultEncoding);
    return res;
  }

  Future<http.Response> put(Uri uri, {Object? body, Map<String, String>? headers}) async {
    headers ??= {};
    headers.addAll(await getAuthHeaders());

    var res = await http.put(uri, body: jsonEncode(body), headers: headers, encoding: defaultEncoding);
    return res;
  }

  Future<http.Response> patch(Uri uri, {Object? body, Map<String, String>? headers}) async {
    headers ??= {};
    headers.addAll(await getAuthHeaders());

    var res = await http.patch(uri, body: jsonEncode(body), headers: headers, encoding: defaultEncoding);
    return res;
  }

  BaseApi._internal();

  factory BaseApi() {
    return _instance;
  }

  static Future<void> loadTokenData() async {
    try {
      await TokenManager.read(refresher);
      _tokenManager = TokenManager(refresher);
    } catch (e) {
      throw Exception('Failed to load token data, $e');
    }
  }

  factory BaseApi.fromTokenData(String refreshToken, String accessToken, int expiresAt) {
    _tokenManager = TokenManager.fromTokenData(
      refresher: refresher,
      refreshToken: refreshToken,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
    return _instance;
  }
}
