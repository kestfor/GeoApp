import 'package:google_sign_in/google_sign_in.dart';

class User {
  int id;
  String username;
  String firstName;
  String lastName;
  String pictureUrl;
  String? bio;
  DateTime? birthDate;

  Function? onLogOut;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.pictureUrl,
    required this.username,
    this.bio,
    this.birthDate,
    this.onLogOut,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      pictureUrl: json['picture_url'],
      bio: json['bio'],
      birthDate: json['birth_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'picture_url': pictureUrl,
      'bio': bio,
      'birth_date': birthDate,
    };
  }

  factory User.fromGoogleSignIn(GoogleSignInAccount account) {
    return User(
      id: 1,
      firstName: account.displayName!.split(" ")[0],
      lastName: account.displayName!.split(" ")[1],
      pictureUrl: account.photoUrl ?? "",
      username: account.email,
    );
  }

  void logOut() {
    if (onLogOut != null) {
      onLogOut!();
    }
  }
}
