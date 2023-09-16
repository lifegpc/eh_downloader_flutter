import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../utils.dart';
import 'save_file.dart';

final Logger _log = Logger("platformPath");

class Path {
  static const platform = MethodChannel("lifegpc.eh_downloader_flutter/path");
  static const _safChannel = MethodChannel("lifegpc.eh_downloader_flutter/saf");
  String? _currentExe;
  bool _currentExeLoaded = false;

  String? get currentExe => _currentExe;

  Future<String?> getCurrentExe() async {
    if (_currentExeLoaded) return _currentExe;
    try {
      final String result = await platform.invokeMethod("getCurrentExe");
      _currentExe = result;
    } on PlatformException catch (e) {
      if (isWindows) {
        _log.warning("Failed to get current exe path:", e);
      }
    }
    _currentExeLoaded = true;
    return _currentExe;
  }

  /// 保存文件
  Future<void> saveFile(
      String filenameWithoutExtension, String mimeType, Uint8List bytes,
      {String dir = ""}) async {
    if (kIsWeb) {
      return saveFileWeb(bytes, mimeType, filenameWithoutExtension);
    }
    return _safChannel.invokeMethod(
        "saveFile", [filenameWithoutExtension, dir, mimeType, bytes]);
  }

  Future<SAFFile> openFile(String filenameWithoutExtension, String mimeType,
      {String dir = ""}) async {
    final fd = await _safChannel.invokeMethod<int>(
        "openFile", [filenameWithoutExtension, dir, mimeType]);
    return SAFFile(fd!);
  }
}

class SAFFile {
  SAFFile(this._fd);
  final int _fd;
  bool _disposed = false;
  Future<int> write(Uint8List data) async {
    if (_disposed) throw Exception("File already closed");
    return await Path._safChannel.invokeMethod("writeFile", [_fd, data]);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Path._safChannel.invokeMethod("closeFile", [_fd]);
  }
}
