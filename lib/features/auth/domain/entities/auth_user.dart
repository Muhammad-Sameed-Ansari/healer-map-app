class AuthUser {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? token;
  final int? tokenExpires;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.token,
    this.tokenExpires,
  });

  String get name => '$firstName $lastName'.trim();

  // Check if token is valid (not expired)
  bool get isTokenValid {
    if (token == null || tokenExpires == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return tokenExpires! > now;
  }

  // Create a copy with updated token
  AuthUser copyWithToken({String? token, int? tokenExpires}) {
    return AuthUser(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      token: token ?? this.token,
      tokenExpires: tokenExpires ?? this.tokenExpires,
    );
  }
}
