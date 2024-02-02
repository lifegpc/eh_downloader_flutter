import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

const _platform = MethodChannel("lifegpc.eh_downloader_flutter/device");
final _log = Logger("platformDevice");
String? _device;

Future<String?> get device async {
  if (_device == null) {
    try {
      _device = await _platform.invokeMethod<String>("deviceName");
    } catch (e) {
      _log.warning("Failed to get device:", e);
    }
  }
  return _device;
}

String? get clientPlatform {
  if (Platform.isAndroid) return "android";
  if (Platform.isIOS) return "ios";
  if (Platform.isLinux) return "linux";
  if (Platform.isMacOS) return "macos";
  if (Platform.isWindows) return "windows";
  return null;
}
