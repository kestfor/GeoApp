import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_app/geo_api/token_manager/token_manager.dart';


class ApiKeyRefresher implements Refresher {
  final String refreshUrl;

  ApiKeyRefresher({required this.refreshUrl});

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    Map<String, dynamic> data = {
      "access_token": "access_token",
      "refresh_token": "refresh_token",
      "expires_at": (DateTime.now().millisecondsSinceEpoch / 1000 + 3600).toInt(),
    };
    return data;

    final Uri uri = Uri.parse('$refreshUrl');
    Map<String, dynamic> body = {"refresh_token": refreshToken, "grant_type": "refresh_token"};
    var res = await http.post(uri, body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw Exception('Failed to refresh token');
    }

    return jsonDecode(res.body);
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

    Map<String, dynamic> data = {
      "jwt": {
        "access_token": "access_token",
        "refresh_token": "refresh_token",
        "expires_at": (DateTime
            .now()
            .millisecondsSinceEpoch / 1000).toInt(),
      },
      "user": {
        //some user data
      },
    };
    return Future.delayed(Duration(seconds: 1), () => data);

    final Uri uri = Uri.parse(authUrl);
    Map<String, dynamic> body = {"idToken": idToken};
    var res = await http.post(uri, body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw Exception('Failed to authenticate with Google');
    }

    return jsonDecode(res.body);
  }
}
