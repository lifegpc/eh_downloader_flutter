abstract interface class Config {
  Future<bool> clear();
  bool containsKey(String key);
  Object? get(String key);
  String? getString(String key);
  Future<bool> setString(String key, String value);
  int? getInt(String key);
  Future<bool> setInt(String key, int value);
  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);
}
