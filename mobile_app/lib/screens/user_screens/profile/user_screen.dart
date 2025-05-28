import 'package:flutter/cupertino.dart';
import 'package:mobile_app/geo_api/services/users/users_service.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:uuid/uuid.dart';

import '../../../logger/logger.dart';
import '../friends/friend_button.dart';
import 'base_profile_screen.dart';

class UserScreen extends ProfileScreen {

  static const String routeName = "/user_profile";

  static Route getUserRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    String? user = args["user"] as String?;
    if (user == null) {
      throw Exception("User object is required in args");
    }

    return CupertinoPageRoute(builder: (context) => UserScreen(userId: user));
  }

  const UserScreen({super.key, required super.userId});

  @override
  State createState() => UserScreenState();
}

class UserScreenState extends ProfileScreenState {

  final userService = UsersService();

  void handleRelationChange(oldStatus, newStatus) async {
    try {
      if (oldStatus == FriendStatus.none && newStatus == FriendStatus.requestSent) {
        await userService.sendRequestToFriendship(openedProfileUserId);
      } else if (oldStatus == FriendStatus.requestReceived && newStatus == FriendStatus.friends) {
        await userService.sendRequestToFriendship(openedProfileUserId);
      } else if (oldStatus == FriendStatus.requestSent && newStatus == FriendStatus.none) {
        await userService.removeFriend(openedProfileUserId);
      } else if (oldStatus == FriendStatus.friends && newStatus == FriendStatus.requestReceived) {
        await userService.removeFriend(openedProfileUserId);
      }
    } catch (e, stack) {
      Logger().error("error changing relation, $e");
    }

  }

  Widget _buildNameInfo() {
    final name = Text(
      "${user!.firstName} ${user!.lastName}",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
    );
    final iconSize = name.style!.fontSize!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            name,
            SizedBox(width: 8),
            FriendButton(
              status: FriendStatus.values.byName(user!.relationType!),
              size: iconSize,
              onStatusChanged: (oldStatus, newStatus) async {
                handleRelationChange(oldStatus, newStatus);
              },
            ),
          ],
        ),
        Text(
          "@${user!.username}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  Widget get nameInfo {
    if (user == null) {
      return nameInfoShimmer;
    } else {
      return _buildNameInfo();
    }
  }
}
