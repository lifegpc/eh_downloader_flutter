import 'dart:io';
import '../utils.dart';
import '../globals.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> getJarPath() async {
  if (isWindows || isLinux) {
    try {
      final p = await platformPath.getCurrentExe();
      if (p != null) {
        return path.join(path.dirname(p), "cookies");
      }
    } catch (e) {
      // Do nothing
    }
  }
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  return '$appDocPath/.eh-cookies/';
}
