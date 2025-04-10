import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/oauth/google_authenticator.dart';
import 'package:mobile_app/oauth/sign_in_button/mobile.dart';
import 'package:mobile_app/style/gradient_button.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/user_screens/profile/me_screen.dart';

import '../types/user/user.dart';

const List<String> scopes = <String>['email', 'https://www.googleapis.com/auth/contacts.readonly'];

class GoogleSignInScreen extends StatefulWidget {
  static const String routeName = "/log_in";

  const GoogleSignInScreen({super.key});

  @override
  State createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  GoogleAuthenticator googleAuth = GoogleAuthenticator(clientId: dotenv.get("GOOGLE_CLIENT_ID"), scopes: scopes);

  @override
  void initState() {
    super.initState();
    googleAuth.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await googleAuth.signIn(); // sign in with google
      await googleAuth.authenticate(); // authenticate
      User user = await googleAuth.getUser(); // get user data

      await Navigator.pushNamed(context, MyProfileScreen.routeName, arguments: user.id);

      //saving user data
      await user.saveToSharedPreferences();
      return;
    } on Exception catch (e) {
      log("Error: $e");
      showError(context, "something went wrong, try again later");
    }
  }

  Widget _buildBody() {
    return buildUnauthorizedBody();
  }

  Widget buildUnauthorizedBody() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: Image.asset("assets/log_in_background.jpg").image),
      ),
      child: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: GlassCardWidget(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.account_circle_rounded, color: Colors.black, size: 100),
                SizedBox(height: 32),
                Center(child: buildGoogleSignInButton(onPressed: _handleSignIn)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}
