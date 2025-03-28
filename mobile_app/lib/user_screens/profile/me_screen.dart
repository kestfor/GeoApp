import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/user_screens/profile/popup_button.dart';
import 'package:mobile_app/user_screens/profile/base_profile_screen.dart';

import '../../oauth/auth_screen.dart';
import '../../style/colors.dart';
import '../../types/user/user.dart';
import '../edit_profile/edit_profile.dart';

enum Actions { edit, logOut }

class MyProfileScreen extends ProfileScreen {

  static const String routeName = "/me";

  static Route getMyProfileRoute(RouteSettings settings) {
    User? user = settings.arguments as User?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => MyProfileScreen(user: user));
  }

  const MyProfileScreen({super.key, required super.user});

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
            await Navigator.pushNamed(context, ProfileEditScreen.routeName, arguments: widget.user);
            setState(() {});
            break;
          case Actions.logOut:
            widget.user.logOut();
            Navigator.pushReplacementNamed(context, GoogleSignInScreen.routeName);
            break;
        }
      },
      //child: Icon(Icons.more_vert),
    );
  }

  Widget _buildNameInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.user.firstName} ${widget.user.lastName}",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
        ),
        Text(
          "@${widget.user.username}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  Widget get moreButton => _buildMoreButton();

  @override
  Widget get nameInfo {
    return _buildNameInfo();
  }
}
