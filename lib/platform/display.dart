import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _log = Logger("platformDisplay");

class Display {
  static const platform =
      MethodChannel("lifegpc.eh_downloader_flutter/display");
  Future<bool> disableProtect() async {
    if (kIsWeb) return true;
    try {
      await platform.invokeMethod<void>("disableProtect");
      return true;
    } catch (e) {
      _log.warning("Failed to disable protect", e);
      return false;
    }
  }

  Future<bool> enableProtect() async {
    if (kIsWeb) return true;
    try {
      await platform.invokeMethod<void>("enableProtect");
      return true;
    } catch (e) {
      _log.warning("Failed to enable protect", e);
      return false;
    }
  }
}
