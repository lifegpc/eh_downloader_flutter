import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../utils.dart';

final Logger _log = Logger("platformPath");

class Path {
  static const platform = MethodChannel("lifegpc.eh_downloader_flutter/path");
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
}