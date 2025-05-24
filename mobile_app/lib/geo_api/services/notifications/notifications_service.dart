import 'dart:developer';
import 'dart:io';

import '../../base_api.dart';

class NotificationService {
  static final BaseApi baseApi = BaseApi();
  static final String baseUrl = "${BaseApi.url}:8004/api/notifications";

  String _getPlatformString() {
    if (Platform.isAndroid) {
      return "android";
    } else if (Platform.isIOS) {
      return "ios";
    }

    throw Exception("unknown platform");

  }

  Future<void> registerToken(String token) async {
    Map<String, dynamic> body = {
      "token": token,
      "platform": _getPlatformString()
    };

    final uri = Uri.parse("$baseUrl/tokens");
    final res = await baseApi.post(uri, body: body);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("failed to register token: ${res.reasonPhrase}");
    } else {
      log("token successfully sent");
    }
  }

  Future<void> deleteToken(String token) async {
    Map<String, dynamic> body = {
      "token": token,
    };

    final uri = Uri.parse("$baseUrl/tokens");
    final res = await baseApi.delete(uri, body: body);
    if (res.statusCode != HttpStatus.noContent) {
      throw Exception("failed to delete token: ${res.reasonPhrase}");
    } else {
      log("token successfully deleted");
    }
  }

}