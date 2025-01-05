import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:event_listener/event_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart'
    show ApplicationSwitcherDescription, SystemChrome;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    show LocaleType;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'api/client.dart';
import 'api/gallery.dart';
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
  ..options.extra['withCredentials'] = true
  ..interceptors.add(_TokenInterceptor());
Config? _prefs;
EHApi? _api;
PersistCookieJar? _jar;
ImageCaches? _imageCaches;
String? queryBaseUrl;
String? shareToken;

class _TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (shareToken != null &&
        _api != null &&
        options.uri.toString().startsWith(_api!.baseUrl!)) {
      options.headers["X-Token"] = shareToken;
    }
    super.onRequest(options, handler);
  }
}

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
  if (shareToken != null) {
    dio.options.extra['withCredentials'] = false;
  }
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
  if (queryBaseUrl != null) {
    if (_api != null && _api!.baseUrl == queryBaseUrl) {
      return true;
    }
    initApi(queryBaseUrl!);
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
  markAsAd,
  markAsNonAd,
  shareGallery,
  sessions,
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
    case MoreVertSettings.markAsAd:
      GalleryPage.maybeOf(context)?.markAsAd(true);
      break;
    case MoreVertSettings.markAsNonAd:
      GalleryPage.maybeOf(context)?.markAsAd(false);
      break;
    case MoreVertSettings.shareGallery:
      final gid = GalleryPage.maybeOf(context)?.gid;
      if (gid != null) {
        context.push("/dialog/gallery/share/$gid");
      }
      break;
    case MoreVertSettings.sessions:
      context.push("/sessions");
      break;
    default:
      break;
  }
}

List<PopupMenuEntry<MoreVertSettings>> buildMoreVertSettings(
    BuildContext context) {
  var list = <PopupMenuEntry<MoreVertSettings>>[];
  var path = GoRouterState.of(context).path;
  final i18n = AppLocalizations.of(context)!;
  if (auth.status != null &&
      auth.status!.noUser &&
      prefs.getBool("skipCreateRootUser") == true &&
      path != "/create_root_user") {
    list.add(PopupMenuItem(
        value: MoreVertSettings.createRootUser,
        child: Text(i18n.createRootUser)));
  }
  if (path == null ||
      (path != "/settings" && !path!.startsWith("/settings/"))) {
    list.add(PopupMenuItem(
        value: MoreVertSettings.settings, child: Text(i18n.settings)));
  }
  if (path != "/task_manager" && auth.canManageTasks == true) {
    list.add(PopupMenuItem(
        value: MoreVertSettings.taskManager, child: Text(i18n.taskManager)));
  }
  if (path != "/sessions" && auth.noUser != true) {
    list.add(PopupMenuItem(
        value: MoreVertSettings.sessions, child: Text(i18n.sessionManagemant)));
  }
  if (path == "/gallery/:gid" && auth.canShareGallery == true) {
    list.add(PopupMenuItem(
        value: MoreVertSettings.shareGallery, child: Text(i18n.shareGallery)));
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
      title: Text(i18n.showNsfw),
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
      title: Text(i18n.displayAd),
    ),
  )));
  if (path == "/gallery/:gid" && auth.canEditGallery == true) {
    list.add(const PopupMenuDivider());
    final gp = GalleryPage.of(context);
    if (!gp.isSelectMode && gp.isAllNsfw != null) {
      list.add(PopupMenuItem(
        value: gp.isAllNsfw!
            ? MoreVertSettings.markAsSfw
            : MoreVertSettings.markAsNsfw,
        child: Text(gp.isAllNsfw! ? i18n.markAsSfw : i18n.markAsNsfw),
      ));
    }
    if (gp.isSelectMode) {
      list.add(PopupMenuItem(
          value: MoreVertSettings.markAsNsfw, child: Text(i18n.markAsNsfw)));
      list.add(PopupMenuItem(
          value: MoreVertSettings.markAsSfw, child: Text(i18n.markAsSfw)));
      list.add(PopupMenuItem(
          value: MoreVertSettings.markAsAd, child: Text(i18n.markAsAd)));
      list.add(PopupMenuItem(
          value: MoreVertSettings.markAsNonAd, child: Text(i18n.markAsNonAd)));
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

Widget buildSearchButton(BuildContext context, {bool openGallery = true}) {
  return auth.meilisearch != null
      ? SearchAnchor(
          builder: (context, controller) {
            return IconButton(
                onPressed: () {
                  controller.openView();
                },
                icon: const Icon(Icons.search));
          },
          suggestionsBuilder: (context, controller) async {
            if (controller.text.isEmpty) return [];
            final c = auth.meiliSearchClient!;
            final max = prefs.getInt("maxSearchSuggestions") ?? 100;
            final re = await c
                .index("gmeta")
                .search(controller.text, SearchQuery(limit: max));
            return re.asSearchResult().hits.map((e) {
              final m = GMetaSearchInfo.fromJson(e);
              return ListTile(
                title: Text(m.preferredTitle),
                onTap: () {
                  if (openGallery) context.push("/gallery/${m.gid}");
                },
              );
            }).toList();
          },
          isFullScreen: true,
        )
      : Container();
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
        return const Locale("zh", "CN");
      default:
        return PlatformDispatcher.instance.locale;
    }
  }

  LocaleType toLocaleType() {
    final l = toLocale();
    switch (l.languageCode) {
      case "zh":
        return LocaleType.zh;
      default:
        return LocaleType.en;
    }
  }
}

enum ThumbnailSize {
  smail(200),
  medium(300),
  big(400);

  const ThumbnailSize(this.size);
  final int size;

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case ThumbnailSize.smail:
        return i18n.smail;
      case ThumbnailSize.medium:
        return i18n.medium;
      case ThumbnailSize.big:
        return i18n.big;
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

void clearAllStates2(GoRouterState? state, GoRouter router) {
  auth.clear();
  tags.clear();
  tasks.clear();
  checkAuth2(state, router);
}

void checkAuth(BuildContext context) {
  checkAuth2(GoRouterState.of(context), GoRouter.of(context));
}

void checkAuth2(GoRouterState? state, GoRouter router) {
  if (!auth.isAuthed && !auth.checked && !auth.isChecking) {
    auth.checkAuth().then((re) {
      if (!re) {
        if (auth.status!.noUser &&
            prefs.getBool("skipCreateRootUser") == true) {
          return;
        }
        final loc = auth.status!.noUser ? "/create_root_user" : "/login";
        if (state?.path != loc) {
          router.push(loc);
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

void setCurrentTitle(String title,
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
            ApplicationSwitcherDescription(label: title))
        .then((_) {
      _currentTitle = title;
      if (isPrefix) _prefix = title;
    }).catchError((err) {
      _titleLog.warning("Failed to set title:", err);
    });
  }
}
