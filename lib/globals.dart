import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/client.dart';
import 'auth.dart';

final dio = Dio()
  ..options.validateStatus = (int? _) {
    return true;
  }
  ..options.extra['withCredentials'] = true;
SharedPreferences? _prefs;
EHApi? _api;

Future<void> prepareJar() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  final jar = PersistCookieJar(
    storage: FileStorage('$appDocPath/.eh-cookies/'),
  );
  dio.interceptors.add(CookieManager(jar));
}

Future<void> preparePrefs() async {
  _prefs = await SharedPreferences.getInstance();
}

SharedPreferences get prefs {
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
