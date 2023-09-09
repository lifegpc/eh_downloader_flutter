import 'package:shared_preferences/shared_preferences.dart';

import 'base.dart';

class SharedPreferencesConfig implements Config {
  SharedPreferencesConfig(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> clear() {
    return _prefs.clear();
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Object? get(String key) {
    return _prefs.get(key);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }
}
