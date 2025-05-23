import 'package:flutter/cupertino.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:uuid/uuid.dart';

import '../friends/friend_button.dart';
import 'base_profile_screen.dart';

class UserScreen extends ProfileScreen {
  final FriendStatus status;

  static const String routeName = "/user_profile";

  static Route getUserRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
    String? user = args["user"] as String?;
    FriendStatus? status = args["status"] as FriendStatus?;
    if (user == null) {
      throw Exception("User object is required in args");
    }

    if (status == null) {
      throw Exception("FriendStatus object is required in args");
    }

    return CupertinoPageRoute(builder: (context) => UserScreen(userId: user, status: status));
  }

  const UserScreen({super.key, required super.userId, required this.status});

  @override
  State createState() => UserScreenState();
}

class UserScreenState extends ProfileScreenState {

  get status => (widget as UserScreen).status;

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
              status: status,
              size: iconSize,
              onStatusChanged: (oldStatus, newStatus) {
                print("oldStatus: $oldStatus, newStatus: $newStatus");
                switch (newStatus) {
                  case FriendStatus.friends:
                    showMessage(context, "You are friends now!");
                    break;
                  case FriendStatus.requestSent:
                    print("here");
                    showMessage(context, "Friend request sent!");
                    break;
                  default:
                    break;
                }
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
