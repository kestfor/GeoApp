import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../logger/logger.dart';

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
      firstName: json['firstName'],
      lastName: json['lastName'],
      pictureUrl: json['pictureUrl']?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'firstName': firstName, 'lastName': lastName, 'pictureUrl': pictureUrl};
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

  static String convertRelationType(String type) {
    return type.toLowerCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? birthDate = json['birthDate'] != null
        ? DateTime.tryParse(json['birthDate'])
        : null;
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      pictureUrl: json['pictureUrl']?? "",
      bio: json['bio'],
      birthDate: birthDate,
      relationType: convertRelationType(json["relationType"]),
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
      'birthDate': birthDate?.toIso8601String(),
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

  Future<void> logOut() async {
    if (onLogOut != null) {
      Logger().debug("logging out user");
      await onLogOut!();
    } else {
      Logger().debug("log out function is null");
    }
  }
}
