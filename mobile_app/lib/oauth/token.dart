class Token {
  String accessToken;
  String refreshToken;
  int expiresIn;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
}