import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {

  static List<Permission> permissions = [Permission.notification, Permission.location];

  static Future<void> handle() async {

    for (var permission in permissions) {
      await permission.isDenied.then((value) {
        if (value) {
          permission.request();
        }
      });
    }
  }

}