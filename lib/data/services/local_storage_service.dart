import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _languageKey = 'language';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> saveUserData(UserModel user) async {
    if (_prefs == null) await init();
    await _prefs!.setString(_userIdKey, user.uid);
    final userData = jsonEncode(user.toJson());

    
    return await _prefs!.setString(_userKey, userData);
  }

  Future<UserModel?> getUserData() async {
    if (_prefs == null) await init();
    final userData = _prefs!.getString(_userKey);
    if (userData == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userData));
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_userIdKey);
  }

  Future<bool> saveAuthToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_authTokenKey);
  }

  Future<bool> setLanguage(String language) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_languageKey, language);
  }

  Future<String> getLanguage() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_languageKey) ?? 'english';
  }

  Future<bool> clearUserData() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_userKey);
    await _prefs!.remove(_userIdKey);
    return await _prefs!.remove(_authTokenKey);
  }

  Future<bool> clearAll() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
} 