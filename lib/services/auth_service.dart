import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/database_helper.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();

  // Save user data
  static Future<void> saveUserData(UserModel user, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyRememberMe, rememberMe);
    
    if (rememberMe) {
      // Save session persistently to SQLite
      await DatabaseHelper().saveSession(user);
      
      // We also store token/id in SharedPreferences for legacy/quick access if needed, 
      // but SQLite is the source of truth for persistent auto-login.
      await prefs.setString(AppConstants.keyToken, user.token);
      await prefs.setString(AppConstants.keyUserId, user.id);
    } else {
      // If not remembered, we clear SQLite to ensure no auto-login
      await DatabaseHelper().clearSession();
      await prefs.remove(AppConstants.keyToken);
      await prefs.remove(AppConstants.keyUserId);
      await prefs.remove(AppConstants.keyUserData);
    }
  }

  // Get saved user data
  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.keyRememberMe) ?? false;
    
    if (rememberMe) {
      // Fetch from SQLite
      return await DatabaseHelper().getSession();
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }

  // Save credentials for remember me (securely)
  static Future<void> saveCredentials(String username, String password) async {
    await _secureStorage.write(key: 'saved_username', value: username);
    await _secureStorage.write(key: 'saved_password', value: password);
  }

  // Get saved credentials
  static Future<Map<String, String>?> getCredentials() async {
    final username = await _secureStorage.read(key: 'saved_username');
    final password = await _secureStorage.read(key: 'saved_password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserData);
    
    // We DO NOT set rememberMe to false or clear secure storage here.
    // If the user checked "Remember Me", they want their credentials 
    // to stay filled in the next time they open the login screen.
    
    // Clear SQLite session
    await DatabaseHelper().clearSession();
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
    await DatabaseHelper().clearSession();
  }
}
