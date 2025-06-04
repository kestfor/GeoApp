import 'package:flutter/cupertino.dart';
import 'package:mobile_app/geo_api/services/users/users_service.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:provider/provider.dart';

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

  void handleRelationChange(context, oldStatus, newStatus) async {
    // try {
    final controller = Provider.of<MainUserController>(context, listen: true);

    if (oldStatus == FriendStatus.none && newStatus == FriendStatus.request_sent) {
      await userService.sendRequestToFriendship(openedProfileUserId);
      Logger().debug("request sent");
    } else if (oldStatus == FriendStatus.request_received && newStatus == FriendStatus.friends) {
      await userService.sendRequestToFriendship(openedProfileUserId);
      controller.addFriend(PureUser.fromUser(user!));
      Logger().debug("request upproved");
    } else if (oldStatus == FriendStatus.request_sent && newStatus == FriendStatus.none) {
      await userService.removeFriend(openedProfileUserId);
      controller.removeFriend(PureUser.fromUser(user!));
      Logger().debug("friend removed");
    } else if (oldStatus == FriendStatus.friends && newStatus == FriendStatus.none) {
      await userService.removeFriend(openedProfileUserId);
      controller.removeFriend(PureUser.fromUser(user!));
      Logger().debug("friend removed");
    }
    // } catch (e, stack) {
    //   Logger().error("error changing relation, $e");
    // }
  }

  Widget _buildNameInfo() {
    final iconSize = 24.0; // можно подставить нужный размер или вычислить от темы

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Ограничиваем ширину имени, чтобы текст обрезался и не выталкивал кнопку
            Expanded(
              child: Text(
                "${user!.firstName} ${user!.lastName}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            FriendButton(
              status: FriendStatus.values.byName(user!.relationType!),
              size: iconSize,
              onStatusChanged: (oldStatus, newStatus) async {
                handleRelationChange(context, oldStatus, newStatus);
              },
            ),
          ],
        ),
        SizedBox(height: 4),
        Text("@${user!.username}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16)),
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
