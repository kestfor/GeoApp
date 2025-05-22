import 'dart:io';

import '../../base_api.dart';

class NotificationService {
  static final BaseApi baseApi = BaseApi();
  static final String baseUrl = "${BaseApi.baseUrl}/api/notifications";

  Future<void> sendToken(String token) async {
    Map<String, dynamic> body = {
      "token": token
    };

    final uri = Uri.parse("$baseUrl/token");
    final res = await baseApi.post(uri, body: body);
    if (res.statusCode != HttpStatus.ok) {
      throw Exception("failed to send token: ${res.reasonPhrase}");
    }

  }
}