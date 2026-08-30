import 'package:local_storage/local_storage.dart';
import 'package:network/src/config/token/storage_keys.dart';
import 'package:network/src/config/token/token_manager.dart';

class DefaultTokenManager implements TokenManager {
  final LocalStorage _storage;
  DefaultTokenManager(LocalStorage storage) : _storage = storage;

  @override
  Future<String?> getToken() async {
    return _storage.getString(prefTokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.setString(prefTokenKey, token);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.deleteKey(prefTokenKey);
  }

  @override
  String get tokenType => 'Bearer';

  @override
  String get tokenHeader => 'Authorization';

  @override
  String get tokenKeyInAuthResponse => 'token';
}
