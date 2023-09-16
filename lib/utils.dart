import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isIOS => !kIsWeb && Platform.isIOS;

String? getFilenameFromContentDisposition(String? contentDisposition) {
  if (contentDisposition == null) {
    return null;
  }
  var ind = contentDisposition.indexOf("filename=\"");
  if (ind != -1) {
    final filename = contentDisposition.substring(
        ind + 10, contentDisposition.lastIndexOf("\""));
    return Uri.decodeComponent(filename);
  }
  ind = contentDisposition.indexOf("filename*=UTF-8''");
  if (ind != -1) {
    final filename =
        contentDisposition.substring(ind + 17, contentDisposition.length);
    return Uri.decodeComponent(filename);
  }
  return null;
}
