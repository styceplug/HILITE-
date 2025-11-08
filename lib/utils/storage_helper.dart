import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _kName = 'user_name';
  static const _kUsername = 'user_username';
  static const _kEmail = 'user_email';
  static const _kPasswordKey = 'user_password'; // stored securely

  static final _secureStorage = const FlutterSecureStorage();


  static Future<void> saveBasicInfo({
    required String name,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kEmail, email);
  }


  static Future<Map<String, String?>> readBasicInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_kName),
      'username': prefs.getString(_kUsername),
      'email': prefs.getString(_kEmail),
    };
  }


  static Future<void> savePassword(String password) async {
    await _secureStorage.write(key: _kPasswordKey, value: password);
  }


  static Future<String?> readPassword() async {
    return await _secureStorage.read(key: _kPasswordKey);
  }


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    await prefs.remove(_kUsername);
    await prefs.remove(_kEmail);
    await _secureStorage.delete(key: _kPasswordKey);
  }
}