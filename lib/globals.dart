import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_listener/event_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart'
    show ApplicationSwitcherDescription, SystemChrome;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'api/client.dart';
import 'auth.dart';
import 'config/base.dart';
import 'config/shared_preferences.dart';
import 'config/windows.dart';
import 'main.dart';
import 'pages/gallery.dart';
import 'platform/clipboard.dart';
import 'platform/display.dart';
import 'platform/get_jar.dart';
import 'platform/image_cache.dart';
import 'platform/path.dart';
import 'platform/set_title.dart';
import 'tags.dart';
import 'task.dart';
import 'utils.dart';
export 'pages/galleries.dart' show GalleriesPageExtra;
export 'pages/gallery.dart' show GalleryPageExtra;

final dio = Dio()
  ..options.validateStatus = (int? _) {
    return true;
  }
  ..options.extra['withCredentials'] = true;
Config? _prefs;
EHApi? _api;
PersistCookieJar? _jar;
ImageCaches? _imageCaches;

Future<void> prepareJar() async {
  final jar = PersistCookieJar(storage: FileStorage(await getJarPath()));
  _jar = jar;
  dio.interceptors.add(CookieManager(jar));
}

Future<void> preparePrefs() async {
  if (isWindows || isLinux) {
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

final _globalLog = Logger("global");

Future<void> prepareImageCaches() async {
  _imageCaches = ImageCaches();
  try {
    await _imageCaches!.init();
  } catch (e, stack) {
    _globalLog.warning("Failed to initiailzed image caches: $e\n$stack");
  }
}

ImageCaches get imageCaches => _imageCaches!;

bool get isImageCacheEnabled => prefs.getBool("enableImageCache") ?? true;

void initApi(String baseUrl) {
  _api = EHApi(dio, baseUrl: baseUrl);
}

bool tryInitApi(BuildContext context) {
  bool? skipBaseUrl = const bool.fromEnvironment("skipBaseUrl");
  if (skipBaseUrl == true) {
    if (_api != null) {
      return true;
    }
    initApi("${Uri.base.origin}/api/");
    clearAllStates(context);
    return true;
  }
  String? baseUrl = prefs.getString("baseUrl");
  if (baseUrl == null) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.go("/settings/server/url");
    });
    return false;
  }
  if (_api != null && _api!.baseUrl == baseUrl) {
    return true;
  }
  initApi(baseUrl);
  clearAllStates(context);
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

PersistCookieJar? get cookieJar {
  return _jar;
}

final AuthInfo auth = AuthInfo();
final Clipboard platformClipboard = Clipboard();
final Display platformDisplay = Display();
final Path platformPath = Path();
final TagsInfo tags = TagsInfo();
final TaskManager tasks = TaskManager();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final EventListener listener = EventListener()..maxListeners = 0;

enum MoreVertSettings {
  createRootUser,
  settings,
  markAsNsfw,
  markAsSfw,
  taskManager,
}

void onMoreVertSettingsSelected(BuildContext context, MoreVertSettings value) {
  switch (value) {
    case MoreVertSettings.createRootUser:
      context.push("/create_root_user");
      break;
    case MoreVertSettings.settings:
      context.push("/settings");
      break;
    case MoreVertSettings.markAsNsfw:
      GalleryPage.maybeOf(context)?.markGalleryAsNsfw(true);
      break;
    case MoreVertSettings.markAsSfw:
      GalleryPage.maybeOf(context)?.markGalleryAsNsfw(false);
      break;
    case MoreVertSettings.taskManager:
      context.push("/task_manager");
      break;
    default:
      break;
  }
}

List<PopupMenuEntry<MoreVertSettings>> buildMoreVertSettings(
    BuildContext context) {
  var list = <PopupMenuEntry<MoreVertSettings>>[];
  var path = GoRouterState.of(context).path;
  if (auth.status != null &&
      auth.status!.noUser &&
      prefs.getBool("skipCreateRootUser") == true &&
      path != "/create_root_user") {
    list.add(PopupMenuItem(
        value: MoreVertSettings.createRootUser,
        child: Text(AppLocalizations.of(context)!.createRootUser)));
  }
  if (path != "/settings") {
    list.add(PopupMenuItem(
        value: MoreVertSettings.settings,
        child: Text(AppLocalizations.of(context)!.settings)));
  }
  if (path != "/task_manager" && auth.canManageTasks == true) {
    list.add(PopupMenuItem(
        value: MoreVertSettings.taskManager,
        child: Text(AppLocalizations.of(context)!.taskManager)));
  }
  var showNsfw = prefs.getBool("showNsfw") ?? false;
  list.add(PopupMenuItem(
      child: StatefulBuilder(
    builder: (context, setState) => CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: showNsfw,
      onChanged: (value) {
        if (value != null) {
          prefs.setBool("showNsfw", value).then((bool _) {
            listener.tryEmit("showNsfwChanged", null);
          });
          setState(() {
            showNsfw = value;
          });
        }
      },
      title: Text(AppLocalizations.of(context)!.showNsfw),
    ),
  )));
  var displayAd = prefs.getBool("displayAd") ?? false;
  list.add(PopupMenuItem(
      child: StatefulBuilder(
    builder: (context, setState) => CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: displayAd,
      onChanged: (value) {
        if (value != null) {
          prefs.setBool("displayAd", value).then((bool _) {
            listener.tryEmit("displayAdChanged", null);
          });
          setState(() {
            displayAd = value;
          });
        }
      },
      title: Text(AppLocalizations.of(context)!.displayAd),
    ),
  )));
  if (path == "/gallery/:gid" && auth.canEditGallery == true) {
    list.add(const PopupMenuDivider());
    final isAllNsfw = GalleryPage.of(context).isAllNsfw;
    if (isAllNsfw != null) {
      list.add(PopupMenuItem(
        value: isAllNsfw
            ? MoreVertSettings.markAsSfw
            : MoreVertSettings.markAsNsfw,
        child: Text(isAllNsfw
            ? AppLocalizations.of(context)!.markAsSfw
            : AppLocalizations.of(context)!.markAsNsfw),
      ));
    }
  }
  return list;
}

Widget buildMoreVertSettingsButon(BuildContext context) {
  return PopupMenuButton(
    icon: const Icon(Icons.more_vert),
    onSelected: (MoreVertSettings value) {
      onMoreVertSettingsSelected(context, value);
    },
    itemBuilder: buildMoreVertSettings,
  );
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

mixin IsTopWidget on Widget {
  @protected
  bool isTop(BuildContext context) {
    final last = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .matches
        .last
        .pageKey;
    return last == key;
  }
}

mixin IsTopWidget2<T extends StatefulWidget> on State<T> {
  @protected
  bool isTop(BuildContext context) {
    final last = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .matches
        .last
        .pageKey;
    return last == widget.key;
  }
}

enum Lang {
  system("System"),
  english("English"),
  simplifiedChinese("简体中文");

  const Lang(String lang) : langName = lang;
  final String langName;
  Locale toLocale() {
    switch (this) {
      case Lang.english:
        return const Locale("en");
      case Lang.simplifiedChinese:
        return const Locale("zh");
      default:
        return PlatformDispatcher.instance.locale;
    }
  }
}

final _authLog = Logger("AuthLog");

void clearAllStates(BuildContext context) {
  auth.clear();
  tags.clear();
  tasks.clear();
  checkAuth(context);
}

void checkAuth(BuildContext context) {
  if (!auth.isAuthed && !auth.checked && !auth.isChecking) {
    auth.checkAuth().then((re) {
      if (!re) {
        if (auth.status!.noUser &&
            prefs.getBool("skipCreateRootUser") == true) {
          return;
        }
        final loc = auth.status!.noUser ? "/create_root_user" : "/login";
        final path = GoRouterState.of(context).path;
        if (path != loc) {
          context.push(loc);
        }
      }
    }).catchError((err) {
      _authLog.log(Level.SEVERE, "Failed to check auth info:", err);
    });
  }
}

String? _currentTitle;
String? _prefix;
final _titleLog = Logger("Title");

void setCurrentTitle(String title, int primaryColor,
    {bool isPrefix = false,
    bool includePrefix = true,
    bool usePrefix = false}) {
  if (!isPrefix && includePrefix && _prefix != null) {
    title = "$_prefix - $title";
  }
  if (usePrefix) {
    if (_prefix == null) return;
    title = _prefix!;
  }
  if (_currentTitle != null && title == _currentTitle) return;
  if (isDesktop) {
    windowManager.setTitle(title).then((_) {
      _currentTitle = title;
      if (isPrefix) _prefix = title;
    }).catchError((err) {
      _titleLog.warning("Failed to set title:", err);
    });
  } else if (kIsWeb) {
    setTitleWeb(title);
    _currentTitle = title;
    if (isPrefix) _prefix = title;
  } else {
    SystemChrome.setApplicationSwitcherDescription(
            ApplicationSwitcherDescription(
                label: title, primaryColor: primaryColor))
        .then((_) {
      _currentTitle = title;
      if (isPrefix) _prefix = title;
    }).catchError((err) {
      _titleLog.warning("Failed to set title:", err);
    });
  }
}
