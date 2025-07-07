import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/user_screens/profile/popup_button.dart';
import 'package:provider/provider.dart';

import '../../../style/colors.dart';
import '../../../types/controllers/main_user_controller.dart';
import '../../../types/events/events.dart';
import '../../oauth/auth_screen.dart';
import '../edit_profile/edit_profile.dart';
import 'base_profile_screen.dart';

enum Actions { edit, logOut }

class MyProfileScreen extends ProfileScreen {
  static const String routeName = "/me";

  static Route getMyProfileRoute(RouteSettings settings) {
    String? user = settings.arguments as String?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => MyProfileScreen(userId: user));
  }

  const MyProfileScreen({super.key, required super.userId});

  @override
  State createState() => MyProfileScreenState();
}

class MyProfileScreenState extends ProfileScreenState {
  Widget _buildMoreButton() {
    Map<Actions, Widget> mapping = {
      Actions.edit: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text("Edit")],
      ),
      Actions.logOut: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Icon(Icons.logout, size: 20), SizedBox(width: 8), Text("Log out", style: TextStyle(color: red))],
      ),
    };
    return PopupMenu<Actions>(
      widgets: mapping,
      onSelected: (Actions value) async {
        switch (value) {
          case Actions.edit:
            await Navigator.pushNamed(context, ProfileEditScreen.routeName, arguments: user!);
            setState(() {});
            break;
          case Actions.logOut:
            {
              await user!.logOut();
              Navigator.pushReplacementNamed(context, GoogleSignInScreen.routeName);
              break;
            }
        }
      },
      //child: Icon(Icons.more_vert),
    );
  }

  Widget _buildNameInfo(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${user!.firstName} ${user!.lastName}",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
        ),
        Text(
          "@${user!.username}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  void setEventsCallback(context, events) {
    Provider.of<MainUserController>(context, listen: false).clearEvents();
    Provider.of<MainUserController>(context, listen: false).addEvents(events);
  }

  @override
  void setFriendsCallback(context, friends) {
    Provider.of<MainUserController>(context, listen: false).clearFriends();
    Provider.of<MainUserController>(context, listen: false).addFriends(friends);
  }

  @override
  Widget get moreButton {
    if (user == null) {
      return SizedBox();
    }
    return _buildMoreButton();
  }

  @override
  Widget nameInfo(context) {
    if (user == null) {
      return nameInfoShimmer;
    } else {
      return _buildNameInfo(context);
    }
  }
}
