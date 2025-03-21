import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/oauth/sign_in_button/mobile.dart';

/// The scopes required by this application.
// #docregion Initialize
const List<String> scopes = <String>['email', 'https://www.googleapis.com/auth/contacts.readonly'];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
  serverClientId: "659561258557-7vnkeva48n8oga6s07bpaoob4pecbdgg.apps.googleusercontent.com",
);
// #enddocregion Initialize

Future<void> verifyIdToken(GoogleSignInAuthentication auth) async {
  String? idToken = auth.idToken;
  if (idToken == null) {
    log("invalid null idToken");
    return;
  }
  print(idToken.length);
  final uri = Uri(scheme: "http", host: "192.168.28.192", port: 8080, path: "/auth/google");
  try {
    Map<String, String> body = {"idToken": idToken};
    final res = await http.post(
      Uri.parse('http://192.168.28.192:8080/auth/google'),
      body: jsonEncode(body),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (res.statusCode != HttpStatus.ok) {
      log("Error: ${res.body}");
    } else if (res.statusCode == HttpStatus.ok) {
      log("Successful token check");
      final data = jsonDecode(res.body);
      print(data);
    }
  } catch (e) {
    log(e.toString());
    return;
  }
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
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

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  // #enddocregion SignIn

  // Prompts the user to authorize `scopes`.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  // #docregion RequestScopes
  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    setState(() {
      _isAuthorized = isAuthorized;
    });
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      user.authentication.then((value) {
        verifyIdToken(value);
      });
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(padding: EdgeInsets.all(16), child: GoogleProfileCard(user: user)),
          _signOutButton(),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Log in", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8,),
          Center(child: buildSignInButton(onPressed: _handleSignIn))],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildBody());
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
