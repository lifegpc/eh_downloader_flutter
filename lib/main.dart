import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'api/client.dart';
import 'create_root_user.dart';
import 'dialog/dialog_page.dart';
import 'dialog/download_zip_page.dart';
import 'dialog/gallery_details_page.dart';
import 'dialog/new_download_task_page.dart';
import 'dialog/task_page.dart';
import 'galleries.dart';
import 'gallery.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
import 'logs/file.dart';
import 'server_settings.dart';
import 'set_server.dart';
import 'settings.dart';
import 'task_manager.dart';
import 'utils.dart';
import 'viewer/single.dart';

final _routerLog = Logger("Router");

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
    GoRoute(
      path: CreateRootUserPage.routeName,
      builder: (context, state) => const CreateRootUserPage(),
    ),
    GoRoute(
      path: SettingsPage.routeName,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
        name: GalleriesPage.routeName,
        path: GalleriesPage.routeName,
        builder: (context, state) {
          SortByGid? sortByGid;
          try {
            if (state.uri.queryParameters.containsKey("sortByGid")) {
              sortByGid = SortByGid
                  .values[int.parse(state.uri.queryParameters["sortByGid"]!)];
            }
          } catch (e) {
            _routerLog.warning("Failed to load sortByGid from prefs:", e);
          }
          final tag = state.uri.queryParameters["tag"];
          final uploader = state.uri.queryParameters["uploader"];
          final extra = state.extra as GalleriesPageExtra?;
          return GalleriesPage(
              key: state.pageKey,
              sortByGid: sortByGid,
              tag: tag,
              uploader: uploader,
              translatedTag: extra?.translatedTag);
        }),
    GoRoute(
        path: GalleryPage.routeName,
        builder: (context, state) {
          final extra = state.extra as GalleryPageExtra?;
          return GalleryPage(
            int.parse(state.pathParameters["gid"]!),
            key: state.pageKey,
            title: extra?.title,
          );
        },
        redirect: (context, state) {
          try {
            int.parse(state.pathParameters["gid"]!);
            return null;
          } catch (e) {
            _routerLog.warning("Failed to parse gid:", e);
            return "/gallery";
          }
        }),
    GoRoute(
      path: "/gallery",
      redirect: (context, state) => "/galleries",
    ),
    GoRoute(
        path: '/dialog/download/zip/:gid',
        pageBuilder: (context, state) => DialogPage(
            key: state.pageKey,
            builder: (context) {
              return DownloadZipPage(int.parse(state.pathParameters["gid"]!));
            }),
        redirect: (context, state) {
          try {
            int.parse(state.pathParameters["gid"]!);
            return null;
          } catch (e) {
            _routerLog.warning("Failed to parse gid:", e);
            return "/";
          }
        }),
    GoRoute(
        path: SinglePageViewer.routeName,
        builder: (context, state) {
          final extra = state.extra as SinglePageViewerExtra?;
          return SinglePageViewer(
            gid: int.parse(state.pathParameters["gid"]!),
            index: int.parse(state.pathParameters["index"]!),
            key: state.pageKey,
            data: extra?.data,
            files: extra?.files,
          );
        },
        redirect: (context, state) {
          try {
            int.parse(state.pathParameters["gid"]!);
          } catch (e) {
            _routerLog.warning("Failed to parse gid:", e);
            return "/gallery";
          }
          try {
            int.parse(state.pathParameters["index"]!);
            return null;
          } catch (e) {
            _routerLog.warning("Failed to parse index:", e);
            return "/gallery/${state.pathParameters["gid"]}";
          }
        }),
    GoRoute(
        path: '/dialog/gallery/details/:gid',
        pageBuilder: (context, state) {
          final extra = state.extra as GalleryDetailsPageExtra?;
          return DialogPage(
              key: state.pageKey,
              builder: (context) {
                return GalleryDetailsPage(
                    int.parse(state.pathParameters["gid"]!),
                    meta: extra?.meta);
              });
        },
        redirect: (context, state) {
          try {
            int.parse(state.pathParameters["gid"]!);
            return null;
          } catch (e) {
            _routerLog.warning("Failed to parse gid:", e);
            return "/";
          }
        }),
    GoRoute(
      path: ServerSettingsPage.routeName,
      builder: (context, state) => ServerSettingsPage(key: state.pageKey),
    ),
    GoRoute(
      path: TaskManagerPage.routeName,
      builder: (context, state) => TaskManagerPage(key: state.pageKey),
    ),
    GoRoute(
        path: "/dialog/new_download_task",
        pageBuilder: (context, state) {
          int? gid;
          String? token;
          if (state.uri.queryParameters.containsKey("gid")) {
            gid = int.tryParse(state.uri.queryParameters["gid"]!);
          }
          if (state.uri.queryParameters.containsKey("token")) {
            token = state.uri.queryParameters["token"]!;
          }
          return DialogPage(
              key: state.pageKey,
              builder: (context) {
                return NewDownloadTaskPage(gid: gid, token: token);
              });
        }),
    GoRoute(
        path: "/dialog/task/:id",
        pageBuilder: (context, state) {
          return DialogPage(
              key: state.pageKey,
              builder: (context) {
                return TaskPage(int.parse(state.pathParameters["id"]!));
              });
        },
        redirect: (context, state) {
          try {
            int.parse(state.pathParameters["id"]!);
            return null;
          } catch (e) {
            _routerLog.warning("Failed to parse id:", e);
            return "/task_manager";
          }
        }),
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
  if (prefs.getBool("preventScreenCapture") ?? false) {
    await platformDisplay.enableProtect();
  }
  await prepareImageCaches();
  GoRouter.optionURLReflectsImperativeAPIs = true;
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

class _MainApp extends State<MainApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _themeData = ThemeData(useMaterial3: true);
  ThemeData _darkThemeData = ThemeData.dark(useMaterial3: true);
  ThemeMode get themeMode => _themeMode;
  Lang _lang = Lang.system;
  Lang get lang => _lang;
  AppLifecycleState? _lifecycleState;
  AppLifecycleState? get lifecycleState => _lifecycleState;

  @override
  void initState() {
    super.initState();
    try {
      _themeMode = ThemeMode.values[prefs.getInt("themeMode") ?? 0];
    } catch (e) {
      _log.warning("Failed to read themeMode from prefs:", e);
    }
    try {
      _lang = Lang.values[prefs.getInt("lang") ?? 0];
    } catch (e) {
      _log.warning("Failed to read lang from prefs:", e);
    }
    if (isWindows) {
      _themeData = _themeData.useSystemChineseFont(Brightness.light);
      _darkThemeData = _darkThemeData.useSystemChineseFont(Brightness.dark);
    }
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      _lifecycleState = WidgetsBinding.instance.lifecycleState;
      listener.tryEmit("lifecycle", _lifecycleState);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    listener.tryEmit("lifecycle", _lifecycleState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (context) {
        final title = AppLocalizations.of(context)!.title;
        setCurrentTitle(title, Theme.of(context).primaryColor.value,
            isPrefix: true);
        return title;
      },
      locale: _lang.toLocale(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _themeData,
      darkTheme: _darkThemeData,
      themeMode: _themeMode,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
    );
  }

  void changeThemeMode(ThemeMode mode) {
    prefs.setInt("themeMode", mode.index).then(
        (value) => {if (!value) _log.warning("Failed to save themeMode.")});
    setState(() {
      _themeMode = mode;
    });
  }

  void changeLang(Lang lang) {
    setState(() {
      _lang = lang;
    });
  }
}
