import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../globals.dart';
import '../utils.dart';

class LogsFile {
  LogsFile();
  Directory? _cachedLogDirectory;
  FileSystem fs = const LocalFileSystem();
  DateTime? _startTime;
  DateTime? _endTime;
  File? _cachedFile;
  IOSink? _cached;
  Future<void> init() async {
    if (_cachedLogDirectory != null) return;
    if (isWindows) {
      try {
        final p = await platformPath.getCurrentExe();
        if (p != null) {
          final dir = fs.directory(path.join(path.dirname(p), "logs"));
          if (!(await dir.exists())) {
            await dir.create(recursive: true);
          }
          _cachedLogDirectory = dir;
          return;
        }
      } catch (e) {
        // Do nothing
      }
    }
    final io.Directory appSupportDir = await getApplicationSupportDirectory();
    final dir = fs.directory(path.join(appSupportDir.path, "logs"));
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    _cachedLogDirectory = dir;
    final d = _file(DateTime.now());
    if (d == null) {
      throw Exception("Failed to create log file.");
    }
    return;
  }

  IOSink? _file(DateTime now) {
    if (_cached != null &&
        _cachedFile != null &&
        _startTime != null &&
        _endTime != null) {
      if (now.isAfter(_startTime!) && now.isBefore(_endTime!)) {
        return _cached;
      }
    }
    if (_cached != null) {
      _cached!.close();
    }
    final dir = _cachedLogDirectory;
    if (dir == null) return null;
    final n = now.isUtc ? now.toLocal() : now;
    final year = n.year.toString().padLeft(4, '0');
    final month = n.month.toString().padLeft(2, '0');
    final day = n.day.toString().padLeft(2, '0');
    final f = dir.childFile("$year-$month-$day.log");
    if (!f.existsSync()) {
      f.createSync(recursive: true);
    }
    _cachedFile = f;
    _cached = f.openWrite(mode: FileMode.append);
    _startTime = DateTime(n.year, n.month, n.day);
    _endTime = _startTime!.add(const Duration(days: 1));
    return _cached;
  }

  bool log(LogRecord record) {
    final stack = record.stackTrace != null ? '\n${record.stackTrace}' : '';
    final error = record.error != null ? '${record.error}' : '';
    final t = record.time;
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    final second = t.second.toString().padLeft(2, '0');
    final millisecond = t.millisecond.toString().padLeft(3, '0');
    final time = "$hour:$minute:$second.$millisecond";
    final logText =
        '${record.level.name}: ${record.loggerName}: $time: ${record.message}$error$stack';
    try {
      final file = _file(record.time);
      if (file == null) {
        return false;
      }
      file.write("$logText\n");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> flush() async {
    await _cached?.flush();
  }
}
