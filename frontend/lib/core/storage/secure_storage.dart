import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_jwt_token';
  static const _keyActiveBrand = 'active_brand_id';
  static const _keyUserEmail = 'cached_user_email';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyActiveBrand);
  }

  static Future<void> saveActiveBrandId(String brandId) async {
    await _storage.write(key: _keyActiveBrand, value: brandId);
  }

  static Future<String?> getActiveBrandId() async {
    return await _storage.read(key: _keyActiveBrand);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }
}
