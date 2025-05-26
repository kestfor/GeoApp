import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mobile_app/geo_api/token_manager/token_manager.dart';
import 'package:mobile_app/utils/mocks.dart';

import '../logger/logger.dart';

class ApiKeyRefresher implements Refresher {
  final String refreshUrl;

  ApiKeyRefresher({required this.refreshUrl});

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final Uri uri = Uri.parse('$refreshUrl');
    Map<String, dynamic> body = {"refresh": refreshToken};
    var res = await http.post(uri, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to refresh token, ${res.reasonPhrase} for url: $uri');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    final result = {"access_token": data["token"], "refresh_token": data["refresh"], "expires_at": data["exp"]};
    return result;
  }
}

class ThroughGoogleAuthenticator implements Authenticator {
  final String authUrl;
  String? _idToken;

  ThroughGoogleAuthenticator({required this.authUrl});

  set idToken(String idToken) {
    _idToken = idToken;
  }

  String get idToken => _idToken!;

  @override
  void setAdditionalData(Map<String, dynamic> data) {
    if (data.containsKey("idToken")) {
      _idToken = data["idToken"];
    } else {
      throw Exception('ID token is not found in additional data');
    }
  }

  @override
  Future<Map<String, dynamic>> authenticate() async {
    if (_idToken == null) {
      throw Exception('ID token is not set');
    }

    final Uri uri = Uri.parse(authUrl);
    Map<String, dynamic> body = {"token": idToken};
    var res = await http.post(uri, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (res.statusCode != 200) {
      throw Exception('Failed to authenticate with Google, ${res.reasonPhrase} for url: $uri');
    }

    final receivedData = jsonDecode(res.body);

    //mocking
    Map<String, dynamic> data = {
      "jwt": {
        "access_token": receivedData["token"],
        "refresh_token": receivedData["refresh"],
        "expires_at": receivedData["exp"],
      },
      "user": mockUser.toJson(),
    };

    Logger().debug("Google Authenticator: received data: $data");

    return Future.delayed(Duration(seconds: 1), () => data);
  }
}
