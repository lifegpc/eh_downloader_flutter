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

  Future<void> saveFile(
      String filenameWithoutExtension, String mimeType, Uint8List bytes,
      {String dir = "", bool saveAs = true}) async {
    if (kIsWeb) {
      return saveFileWeb(bytes, mimeType, filenameWithoutExtension);
    }
    final f = await openFile(filenameWithoutExtension, mimeType,
        dir: dir, saveAs: saveAs);
    try {
      await f.write(bytes);
    } finally {
      await f.dispose();
    }
  }

  Future<SAFFile> openFile(String filenameWithoutExtension, String mimeType,
      {String dir = "",
      bool read = false,
      bool write = true,
      bool append = false,
      bool saveAs = true}) async {
    if (!write) {
      append = false;
    }
    final fd = await _safChannel.invokeMethod<int>("openFile",
        [filenameWithoutExtension, dir, mimeType, read, write, append, saveAs]);
    return SAFFile(fd!, read, write);
  }
}

class SAFFile {
  SAFFile(this._fd, this._read, this._write);

  final int _fd;
  final bool _read;
  final bool _write;
  bool _disposed = false;

  Future<Uint8List> read(int maxLen) async {
    if (_disposed) throw Exception("File already closed");
    if (!_read) throw Exception("File not opened for read");
    return await Path._safChannel.invokeMethod("readFile", [_fd, maxLen]);
  }

  /// 写入文件，返回此次写入的字节数
  ///
  /// [data] 要写入文件的数据
  Future<int> write(Uint8List data) async {
    if (_disposed) throw Exception("File already closed");
    if (!_write) throw Exception("File not opened for write");
    return await Path._safChannel.invokeMethod("writeFile", [_fd, data]);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Path._safChannel.invokeMethod("closeFile", [_fd]);
  }
}
