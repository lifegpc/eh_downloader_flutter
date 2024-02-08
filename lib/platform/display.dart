import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import '../utils.dart';

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

  Future<bool> setFullscreenMode(bool fullscreenMode) async {
    if (isDesktop) {
      try {
        await WindowManager.instance.setFullScreen(fullscreenMode);
        return true;
      } catch (e) {
        _log.warning("Failed to set screen mode", e);
        return false;
      }
    }
    try {
      await platform.invokeMethod<void>("setScreenMode", fullscreenMode);
      return true;
    } catch (e) {
      _log.warning("Failed to set screen mode", e);
      return false;
    }
  }
}
