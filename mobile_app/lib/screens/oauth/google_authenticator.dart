import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/geo_api/base_api.dart';
import 'package:mobile_app/notifications/firebase_notifications.dart';
import 'package:mobile_app/utils/mocks.dart';

import '../../types/user/user.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: scopes,
//   serverClientId: "659561258557-7vnkeva48n8oga6s07bpaoob4pecbdgg.apps.googleusercontent.com",
// );

class GoogleAuthenticator {
  late final List<String> scopes;
  late final String clientId;
  late final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;
  User? _user;

  GoogleAuthenticator({required this.clientId, this.scopes = const []}) {
    _googleSignIn = GoogleSignIn(scopes: scopes, serverClientId: clientId);
  }

  Future<Map<dynamic, dynamic>> _verifyIdToken(GoogleSignInAuthentication auth) async {
    String? idToken = auth.idToken;
    if (idToken == null) {
      throw Exception("idToken is null");
    }
    final res = await BaseApi.authenticate(AuthType.google, {"idToken": idToken});
    return res;
  }

  Future<void> authenticate() async {
    if (_currentUser == null) {
      throw Exception('User is not signed in');
    }

    final auth = await _currentUser!.authentication;
    final userData = await _verifyIdToken(auth);

    //TODO : remove mock user
    _user = mockUser;
    _user!.onLogOut = () {
      FirebaseNotificationService.instance.deleteToken();
      signOut();
    };
  }

  Future<User> getUser() {
    if (_user != null) {
      return Future.value(_user);
    } else {
      throw Exception('User is not authorized');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    _currentUser = await _googleSignIn.signInSilently();
    return _currentUser;
  }

  Future<GoogleSignInAccount> signIn() async {
    if (_currentUser != null) {
      return _currentUser!;
    }

    _currentUser = await _googleSignIn.signInSilently();

    _currentUser ??= await _googleSignIn.signIn();
    if (_currentUser == null) {
      throw Exception('User cancelled sign-in');
    }

    return _currentUser!;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _user = null;
  }
}
