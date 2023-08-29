import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
