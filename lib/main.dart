import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'globals.dart';
import 'home.dart';
import 'set_server.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: SetServerPage.routeName,
      builder: (context, state) => const SetServerPage(),
    ),
  ],
);

void main() async {
  if (!kIsWeb) await prepareJar();
  await preparePrefs();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await windowManager.setTitle("E-Hentai Downloader Dashboard");
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: _router, title: "E-Hentai Downloader Dashboard");
  }
}
