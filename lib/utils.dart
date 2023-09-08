import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
