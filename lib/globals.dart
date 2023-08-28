import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();
SharedPreferences? _prefs;

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
