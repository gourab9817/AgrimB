// lib/data/services/local_storage_service2.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService2 {
  static LocalStorageService2? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService2._();

  static Future<LocalStorageService2> getInstance() async {
    _instance ??= LocalStorageService2._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // String operations
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _preferences?.getString(key);
  }

  // Bool operations
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _preferences?.getBool(key);
  }

  // Int operations
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _preferences?.getInt(key);
  }

  // Double operations
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _preferences?.getDouble(key);
  }

  // List operations
  Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _preferences?.getStringList(key);
  }

  // Remove operation
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Clear all
  Future<void> clear() async {
    await _preferences?.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }
}