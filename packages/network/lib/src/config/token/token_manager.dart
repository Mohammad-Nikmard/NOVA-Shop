abstract class TokenManager {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  String get tokenType; // e.g., "Bearer"
  String get tokenHeader; // e.g., "Authorization"
  String get tokenKeyInAuthResponse; // e.g., "token"
}
