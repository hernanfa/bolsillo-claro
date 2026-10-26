/// Modelo del token devuelto al autenticarse.
class AuthTokenModel {
  final String accessToken;
  final String tokenType;

  const AuthTokenModel({required this.accessToken, required this.tokenType});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'token_type': tokenType};
  }

  @override
  String toString() => 'AuthTokenModel(tokenType: $tokenType)';
}
