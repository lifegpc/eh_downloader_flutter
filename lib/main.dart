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
import 'logs/file.dart';
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

void defaultLogger(LogRecord record) {
  final stack = record.stackTrace != null ? '\n${record.stackTrace}' : '';
  final error = record.error != null ? '${record.error}' : '';
  // ignore: avoid_print
  print(
      '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}$error$stack');
}

Future<void> initLogger() async {
  var logLevel = prefs.getInt("logLevel");
  var logLevelName = prefs.getString("logLevelName");
  if (logLevel != null && logLevelName != null) {
    Logger.root.level = Level(logLevelName, logLevel);
  }
  if (!kIsWeb) {
    try {
      final logFile = LogsFile();
      await logFile.init();
      Logger.root.onRecord.listen((record) {
        if (!logFile.log(record)) defaultLogger(record);
      });
      return;
    } catch (_) {
      // Do nothing
    }
  }
  Logger.root.onRecord.listen(defaultLogger);
  return;
}

void main() async {
  if (!kIsWeb) WidgetsFlutterBinding.ensureInitialized();
  bool? usePathUrl = const bool.fromEnvironment("usePathUrl");
  if (usePathUrl == true && kIsWeb) {
    usePathUrlStrategy();
  }
  if (!kIsWeb) await prepareJar();
  await preparePrefs();
  if (isDesktop) {
    await windowManager.ensureInitialized();
  }
  await initLogger();
  runApp(const MainApp());
}

final _log = Logger("MainApp");

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainApp();
  // ignore: library_private_types_in_public_api
  static _MainApp of(BuildContext context) =>
      context.findAncestorStateOfType<_MainApp>()!;
}

class _MainApp extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _themeData = ThemeData();
  ThemeData _darkThemeData = ThemeData.dark();
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    try {
      _themeMode = ThemeMode.values[prefs.getInt("themeMode") ?? 0];
    } catch (e) {
      _log.warning("Failed to read themeMode from prefs:", e);
    }
    if (kIsWeb || isWindows) {
      _themeData = _themeData.useSystemChineseFont();
      _darkThemeData = _darkThemeData.useSystemChineseFont();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      theme: _themeData,
      darkTheme: _darkThemeData,
      themeMode: _themeMode,
    );
  }

  void changeThemeMode(ThemeMode mode) {
    prefs.setInt("themeMode", mode.index);
    setState(() {
      _themeMode = mode;
    });
  }
}
