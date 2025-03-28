import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/geo_api/geo_api.dart';
import 'package:mobile_app/oauth/sign_in_button/mobile.dart';
import 'package:mobile_app/style/gradient_button.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/user_screens/profile/me_screen.dart';
import 'package:mobile_app/utils/mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../types/user/user.dart';

/// The scopes required by this application.
// #docregion Initialize

const String userDataKey = "user_data";

const List<String> scopes = <String>['email', 'https://www.googleapis.com/auth/contacts.readonly'];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
  serverClientId: "659561258557-7vnkeva48n8oga6s07bpaoob4pecbdgg.apps.googleusercontent.com",
);

// #enddocregion Initialize

Future<Map<String, dynamic>> verifyIdToken(GoogleSignInAuthentication auth) async {
  String? idToken = auth.idToken;
  if (idToken == null) {
    throw Exception("idToken is null");
  }
  final res = await GeoApiInstance.googleAuth(idToken);
  return res;
}

class GoogleSignInScreen extends StatefulWidget {
  static const String routeName = "/log_in";

  const GoogleSignInScreen({super.key});

  @override
  State createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn(context) async {
    try {
      await _googleSignIn.signIn();
      if (_currentUser == null) {
        return;
      }

      GoogleSignInAuthentication auth = await _currentUser!.authentication;

      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return Center(child: CircularProgressIndicator(color: orange));
      //   },
      // );

      await Future.delayed(Duration(milliseconds: 300));
      //TODO проверка токена на сервере
      final data = await verifyIdToken(auth);
      String refreshToken = data["refresh_token"];
      String accessToken = data["access_token"];
      int expiresAt = data["expires_at"];

      //создание экземпляра GeoApiInstance
      GeoApiInstance.fromTokenData(refreshToken, accessToken, expiresAt);

      //User user = User.fromJson(data);
      //Navigator.pop(context);

      // User user = User.fromGoogleSignIn(_currentUser!);
      User user = mockUser;
      user.onLogOut = _handleSignOut;
      Navigator.pushNamed(context, MyProfileScreen.routeName, arguments: user);

      //saving user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final json = user.toJson();
      prefs.setString(userDataKey, jsonEncode(json));

      return;
    } on Exception catch (e) {
      log("Error: $e");
      showError(context, "something went wrong, try again later");
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    setState(() {
      _isAuthorized = isAuthorized;
    });
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
                Center(
                  child: buildSignInButton(
                    onPressed: () async {
                      await _handleSignIn(context);
                    },
                  ),
                ),
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

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: _handleSignOut,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      child: const Text('SIGN OUT'),
    );
  }
}

class GoogleProfileCard extends StatelessWidget {
  final GoogleSignInAccount user;

  const GoogleProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          leading: GoogleUserCircleAvatar(identity: user),
          title: Text(user.displayName ?? '', style: TextStyle(fontSize: 20, color: Colors.black)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Divider(), Text(user.email, style: TextStyle(fontSize: 20, color: Colors.black))],
          ),
        ),
      ),
    );
  }
}
