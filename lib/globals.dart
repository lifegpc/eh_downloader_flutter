import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/client.dart';
import 'auth.dart';
import 'config/base.dart';
import 'config/shared_preferences.dart';
import 'config/windows.dart';
import 'main.dart';
import 'platform/path.dart';
import 'utils.dart';

final dio = Dio()
  ..options.validateStatus = (int? _) {
    return true;
  }
  ..options.extra['withCredentials'] = true;
Config? _prefs;
EHApi? _api;

Future<String> _getJarPath() async {
  if (isWindows) {
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

Future<void> prepareJar() async {
  final jar = PersistCookieJar(storage: FileStorage(await _getJarPath()));
  dio.interceptors.add(CookieManager(jar));
}

Future<void> preparePrefs() async {
  if (isWindows) {
    try {
      var tmp = WindowsConfig();
      tmp.reload();
      _prefs = tmp;
      return;
    } catch (e) {
      // Do nothing.
    }
  }
  _prefs = SharedPreferencesConfig(await SharedPreferences.getInstance());
}

Config get prefs {
  if (_prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return _prefs!;
}

void initApi(String baseUrl) {
  _api = EHApi(dio, baseUrl: baseUrl);
}

bool tryInitApi(BuildContext context) {
  bool? skipBaseUrl = const bool.fromEnvironment("skipBaseUrl");
  if (skipBaseUrl == true) {
    if (_api != null) {
      return true;
    }
    initApi("/api");
    return true;
  }
  String? baseUrl = prefs.getString("baseUrl");
  if (baseUrl == null) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.go("/set_server");
    });
    return false;
  }
  if (_api != null && _api!.baseUrl == baseUrl) {
    return true;
  }
  auth.clear();
  initApi(baseUrl);
  return true;
}

bool get apiInited {
  return _api != null;
}

EHApi get api {
  if (_api == null) {
    throw Exception('EHApi not initialized');
  }
  return _api!;
}

final AuthInfo auth = AuthInfo();
final Path platformPath = Path();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum MoreVertSettings {
  setServerUrl,
}

void onMoreVertSettingsSelected(BuildContext context, MoreVertSettings value) {
  switch (value) {
    case MoreVertSettings.setServerUrl:
      context.go("/set_server");
      break;
    default:
      break;
  }
}

ThemeMode themeModeNext(ThemeMode mode) {
  if (mode == ThemeMode.system) return ThemeMode.light;
  if (mode == ThemeMode.dark) return ThemeMode.system;
  return ThemeMode.dark;
}

mixin ThemeModeWidget<T extends StatefulWidget> on State<T> {
  @protected
  Widget buildThemeModeIcon(BuildContext context) {
    final mode = MainApp.of(context).themeMode;
    return IconButton(
        onPressed: () {
          final n = themeModeNext(mode);
          MainApp.of(context).changeThemeMode(n);
          setState(() {});
        },
        icon: Icon(mode == ThemeMode.system
            ? Icons.brightness_auto
            : mode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode));
  }
}
