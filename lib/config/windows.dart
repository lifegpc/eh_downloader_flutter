import 'dart:convert' show json;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'base.dart';
import '../globals.dart';

final _log = Logger("WindowsConfig");

class WindowsConfig implements Config {
  WindowsConfig();
  FileSystem fs = const LocalFileSystem();
  Map<String, Object>? _cachedPreferences;
  File? _filePath;
  Future<File?> filePath() async {
    if (_filePath != null) return _filePath;
    final String? exe = await platformPath.getCurrentExe();
    if (exe == null) return null;
    final dir = path.dirname(exe);
    final name = path.basenameWithoutExtension(exe);
    return _filePath = fs.file(path.join(dir, "$name.json"));
  }

  Future<Map<String, Object>> reload() async {
    Map<String, Object> preferences = <String, Object>{};
    final File? localDataFile = await filePath();
    if (localDataFile != null && localDataFile.existsSync()) {
      final String stringMap = localDataFile.readAsStringSync();
      if (stringMap.isNotEmpty) {
        final Object? data = json.decode(stringMap);
        if (data is Map) {
          preferences = data.cast<String, Object>();
        }
      }
    }
    _cachedPreferences = preferences;
    return preferences;
  }

  Future<Map<String, Object>> _readPreferences() async {
    return _cachedPreferences ?? await reload();
  }

  Future<bool> _writePreferences(Map<String, Object> preferences) async {
    try {
      final File? localDataFile = await filePath();
      if (localDataFile == null) {
        _log.warning('Unable to determine where to write preferences.');
        return false;
      }
      if (!localDataFile.existsSync()) {
        localDataFile.createSync(recursive: true);
      }
      final String stringMap = json.encode(preferences);
      localDataFile.writeAsStringSync(stringMap);
    } catch (e) {
      _log.severe('Error saving preferences to disk: ', e);
      return false;
    }
    return true;
  }

  @override
  Future<bool> clear() async {
    final Map<String, Object> preferences = await _readPreferences();
    preferences.clear();
    return _writePreferences(preferences);
  }

  Future<bool> setValue(String key, Object value) async {
    final Map<String, Object> preferences = await _readPreferences();
    preferences[key] = value;
    return _writePreferences(preferences);
  }

  @override
  bool containsKey(String key) {
    return _cachedPreferences?.containsKey(key) ?? false;
  }

  @override
  Object? get(String key) => _cachedPreferences?[key];

  @override
  String? getString(String key) => _cachedPreferences?[key] as String?;

  @override
  Future<bool> setString(String key, String value) {
    return setValue(key, value);
  }

  @override
  int? getInt(String key) => _cachedPreferences?[key] as int?;

  @override
  Future<bool> setInt(String key, int value) {
    return setValue(key, value);
  }

  @override
  bool? getBool(String key) => _cachedPreferences?[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) {
    return setValue(key, value);
  }
}
