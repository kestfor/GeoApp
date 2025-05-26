import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PureUser {
  String id;
  String username;
  String firstName;
  String lastName;
  String pictureUrl;

  PureUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.pictureUrl,
    required this.username,
  });

  factory PureUser.fromJson(Map<String, dynamic> json) {
    return PureUser(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      pictureUrl: json['picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'first_name': firstName, 'last_name': lastName, 'picture_url': pictureUrl};
  }
}

class User extends PureUser {
  static const String userDataKey = "user_data";
  String? relationType; // friends/request_sent/request_received/none
  String? bio;
  DateTime? birthDate;
  Function? onLogOut;

  User({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.pictureUrl,
    required super.username,
    this.bio,
    this.birthDate,
    this.onLogOut,
    this.relationType = "none",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      pictureUrl: json['pictureUrl'],
      bio: json['bio'],
      birthDate: json['birthDate'],
      relationType: json["relationType"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'pictureUrl': pictureUrl,
      'bio': bio,
      'birthDate': birthDate,
      'relationType': relationType,
    };
  }

  Future<void> saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = jsonEncode(toJson());
    await prefs.setString(userDataKey, userData);
  }

  static Future<User?> loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(userDataKey);
    if (userData != null) {
      Map<String, dynamic> json = jsonDecode(userData);
      return User.fromJson(json);
    } else {
      return null;
    }
  }

  // factory User.fromGoogleSignIn(GoogleSignInAccount account) {
  //   return User(
  //     id: 1,
  //     firstName: account.displayName!.split(" ")[0],
  //     lastName: account.displayName!.split(" ")[1],
  //     pictureUrl: account.photoUrl ?? "",
  //     username: account.email,
  //   );
  // }

  void logOut() {
    if (onLogOut != null) {
      print("Logging out user");
      onLogOut!();
    }
  }
}
