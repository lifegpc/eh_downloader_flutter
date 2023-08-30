import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
import 'set_server.dart';
import 'utils.dart';

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
    GoRoute(
      path: LoginPage.routeName,
      builder: (context, state) => const LoginPage(),
    ),
  ],
);

Future<void> initLogger() async {
  var logLevel = prefs.getInt("logLevel");
  var logLevelName = prefs.getString("logLevelName");
  if (logLevel != null && logLevelName != null) {
    Logger.root.level = Level(logLevelName, logLevel);
  }
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  return;
}

void main() async {
  bool? usePathUrl = const bool.fromEnvironment("usePathUrl");
  if (usePathUrl == true && kIsWeb) {
    usePathUrlStrategy();
  }
  if (!kIsWeb) await prepareJar();
  await preparePrefs();
  if (isDesktop) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
  }
  await initLogger();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = ThemeData();
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (context) {
        final title = AppLocalizations.of(context)!.title;
        if (isDesktop) {
          windowManager.setTitle(title);
        }
        return title;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: (kIsWeb || isWindows) ? theme.useSystemChineseFont() : theme,
    );
  }
}
