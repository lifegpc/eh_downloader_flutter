import 'dart:io';

String? get device => null;

String? get clientPlatform {
  if (Platform.isAndroid) return "android";
  if (Platform.isIOS) return "ios";
  if (Platform.isLinux) return "linux";
  if (Platform.isMacOS) return "macos";
  if (Platform.isWindows) return "windows";
  return null;
}
