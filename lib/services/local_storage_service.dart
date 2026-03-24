import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyUsername = 'saved_username';
  static const _keyPassword = 'saved_password';
  static const _keyRememberMe = 'remember_me';

  static Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRememberMe, true);
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRememberMe, false);
  }

  static Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRememberMe) ?? false;
    if (!remember) return {};
    return {
      'username': prefs.getString(_keyUsername) ?? '',
      'password': prefs.getString(_keyPassword) ?? '',
    };
  }

  static Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }
}
