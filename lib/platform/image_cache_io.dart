import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../globals.dart';
import '../utils.dart';

const _imagesTable = """CREATE TABLE images (
url TEXT,
path TEXT,
last_used INT,
headers TEXT,
realUrl TEXT,
size INT,
PRIMARY KEY(url)
);""";
const _allTables = ['images'];

final _log = Logger("ImageCachesIO");

class ImageCaches {
  Database? _db;
  final _fs = const LocalFileSystem();
  Directory? _cacheDir;
  String? _exeDir;
  final Set<String> _existingTable = {};
  bool _inited = false;
  static const version = 1;
  int _size = 0;
  int get size => _size;
  late Mutex _mutex;
  ImageCaches();
  Future<String?> _desktopFilePath() async {
    final String? exe = await platformPath.getCurrentExe();
    if (exe == null) return null;
    _exeDir = path.dirname(exe);
    return path.join(_exeDir!, "image_caches.db");
  }

  Future<String> get _filePath async {
    if (isWindows || isLinux) {
      try {
        final tmp = await _desktopFilePath();
        if (tmp != null) return tmp;
      } catch (e) {
        _log.warning("Failed to get database file location.");
      }
    }
    final io.Directory appSupportDir = await getApplicationSupportDirectory();
    return path.join(appSupportDir.path, "image_caches.db");
  }

  Future<Directory> get cacheDir async {
    if (_cacheDir != null) return _cacheDir!;
    if ((isWindows || isLinux) && _exeDir != null) {
      return _cacheDir = _fs.directory(path.join(_exeDir!, "image_caches"));
    }
    final io.Directory cacheDir = await getApplicationCacheDirectory();
    return _cacheDir = _fs.directory(path.join(cacheDir.path, "image_caches"));
  }

  Future<void> _createDir() async {
    final dir = await cacheDir;
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
  }

  Future<bool> _checkDatabase() async {
    await _updateExistsTable();
    final v = await _db!.getVersion();
    _log.fine("Database version: $v");
    if (v < version) {
      bool needOptimized = false;
      if (v < 1 && _existingTable.contains("images")) {
        await _db!.execute("ALTER TABLE images ADD size INT;");
        final re = await _db!.query("images", columns: ['url', 'path']);
        for (final r in re) {
          final f = _fs.file(r["path"] as String);
          try {
            final stats = await f.stat();
            Map<String, Object?> map = {};
            map["size"] = stats.size;
            await _db!
                .update("images", map, where: 'url = ?', whereArgs: [r["url"]]);
          } catch (e) {
            _log.warning("Failed to stat ${f.path}: $e");
            await _db!
                .delete("images", where: 'url = ?', whereArgs: [r["url"]]);
            needOptimized = true;
          }
        }
      }
      await _db!.setVersion(version);
      if (needOptimized) await _optimize();
    }
    if (_allTables.length != _existingTable.length ||
        !_allTables.every((e) => _existingTable.contains(e))) {
      return false;
    }
    return true;
  }

  Future<void> _createTable() async {
    if (!_existingTable.contains("images")) {
      await _db!.execute(_imagesTable);
    }
    await _updateExistsTable();
  }

  Future<void> _updateExistsTable() async {
    _existingTable.clear();
    final cur = await _db!
        .query("sqlite_master", where: 'type = ?', whereArgs: ['table']);
    for (final c in cur) {
      _existingTable.add(c["name"]! as String);
    }
  }

  Future<void> _optimize() async {
    await _db!.execute("VACUUM;");
  }

  Future<void> _removeUnexist() async {
    List<String> needDeleted = [];
    int offset = 0;
    late List<Map<String, Object?>> records;
    do {
      records = await _db!.query("images",
          columns: ["url", "path"], limit: 100, offset: offset);
      for (final record in records) {
        final url = record["url"] as String;
        var p = record["path"] as String;
        if (_exeDir != null && path.isRelative(p)) {
          p = path.join(_exeDir!, p);
        }
        final f = _fs.file(p);
        try {
          if (!await f.exists()) {
            needDeleted.add(url);
          }
        } catch (e) {
          _log.warning("Failed to check $p is exists or not. Url: $url. $e");
        }
      }
      offset += records.length;
    } while (records.isNotEmpty);
    for (final url in needDeleted) {
      await _db!.delete("images", where: "url = ?", whereArgs: [url]);
    }
    if (needDeleted.isNotEmpty) await _optimize();
  }

  Future<void> _updateSize() async {
    final re = await _db!.rawQuery("SELECT SUM(size) AS sizes FROM images;");
    _size = re.isEmpty ? 0 : ((re[0]["sizes"] as int?) ?? 0);
  }

  Future<void> init() async {
    sqfliteFfiInit();
    _db = await databaseFactoryFfi.openDatabase(await _filePath);
    await _createDir();
    if (!(await _checkDatabase())) await _createTable();
    await _updateSize();
    _mutex = Mutex();
    _inited = true;
  }

  Future<(Uint8List, Map<String, List<String>>, String?)?> getCache(
      String uri) async {
    if (!_inited) return null;
    final d = await _db!.query("images", where: 'url = ?', whereArgs: [uri]);
    if (d.isEmpty) return null;
    final data = d.first;
    var p = data["path"] as String;
    if (_exeDir != null && path.isRelative(p)) {
      p = path.join(_exeDir!, p);
    }
    final header = data["headers"] as String;
    final realUrl = data["readUrl"] as String?;
    final lastUsed = DateTime.now().millisecondsSinceEpoch;
    try {
      await _db!.rawUpdate(
          "UPDATE images SET last_used = ? WHERE url = ?;", [lastUsed, uri]);
    } catch (e) {
      _log.warning("Failed to set last_used to $lastUsed for $uri: $e");
    }
    final f = _fs.file(p);
    final da = await f.readAsBytes();
    final h = jsonDecode(header) as Map<String, dynamic>;
    return (
      da,
      h.map((k, v) => MapEntry(k, (v as List<dynamic>).cast<String>())),
      realUrl
    );
  }

  Future<void> putCache(String uri, Uint8List data,
      Map<String, List<String>> headers, String? realUri) async {
    if (!_inited) return;
    await _mutex.protect(() async {
      final u = Uri.parse(uri);
      final dir = await cacheDir;
      String p = path.join(dir.path, u.host.isEmpty ? "nohost" : u.host,
          u.path.substring(1) + (u.hasQuery ? "?${u.query}" : ""));
      final d = _fs.directory(path.dirname(p));
      if (isWindows) {
        if (path.isAbsolute(p)) {
          p = p.substring(0, 2) +
              p.substring(2).replaceAll(RegExp("[:\\*\\?\"\\<\\>\\|]"), '_');
        } else {
          p = p.replaceAll(RegExp("[:\\*\\?\"\\<\\>\\|]"), '_');
        }
      }
      if (!(await d.exists())) {
        await d.create(recursive: true);
      }
      final f = _fs.file(p);
      await f.writeAsBytes(data.toList());
      final lastUsed = DateTime.now().millisecondsSinceEpoch;
      final header = jsonEncode(headers);
      if (_exeDir != null) {
        p = path.relative(p, from: _exeDir!);
      }
      final exes =
          await _db!.query("images", where: 'url = ?', whereArgs: [uri]);
      await _db!.rawInsert(
          "INSERT OR REPLACE INTO images VALUES (?, ?, ?, ?, ?, ?);",
          [uri, p, lastUsed, header, realUri, data.length]);
      if (exes.isEmpty) {
        _size += data.length;
      } else {
        final originalSize = (exes[0]["size"] as int?) ?? 0;
        _size += (data.length - originalSize);
      }
    });
  }

  Future<void> updateSize({bool clear = false}) async {
    if (!_inited) return;
    if (clear) await _removeUnexist();
    await _updateSize();
  }

  Future<void> clear() async {
    if (!_inited) return;
    int offset = 0;
    late List<Map<String, Object?>> records;
    do {
      records = await _db!
          .query("images", columns: ["path"], limit: 100, offset: offset);
      for (final record in records) {
        var p = record["path"] as String;
        if (_exeDir != null && path.isRelative(p)) {
          p = path.join(_exeDir!, p);
        }
        final f = _fs.file(p);
        try {
          await f.delete();
        } catch (e) {
          _log.warning("Failed to delete $p: $e");
        }
      }
      offset += records.length;
    } while (records.isNotEmpty);
    await _db!.delete("images");
    await _optimize();
    _size = 0;
  }
}
