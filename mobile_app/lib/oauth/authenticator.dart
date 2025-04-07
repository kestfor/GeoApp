import 'package:mobile_app/oauth/token.dart';
import 'package:mobile_app/types/user/user.dart';

abstract class Authenticator {

  Future<Token> authenticate();

  Future<User?> getUser();

}


