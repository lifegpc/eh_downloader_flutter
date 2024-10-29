import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:keymap/keymap.dart';
import 'package:logging/logging.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:quiver/collection.dart';
import 'package:super_context_menu/super_context_menu.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../components/fit_text.dart';
import '../globals.dart';
import '../platform/media_query.dart';
import '../provider/dio_image_provider.dart';
import '../utils/clipboard.dart';

final _log = Logger("SinglePageViewer");

class SinglePageViewerExtra {
  const SinglePageViewerExtra({this.data, this.files});
  final GalleryData? data;
  final EhFiles? files;
}

class SinglePageViewer extends StatefulWidget {
  const SinglePageViewer(
      {super.key,
      required this.gid,
      required this.index,
      this.data,
      this.files});
  final GalleryData? data;
  final EhFiles? files;
  final int gid;
  final int index;
  static const String routeName = '/gallery/:gid/page/:index';

  @override
  State<SinglePageViewer> createState() => _SinglePageViewer();
}

class _SinglePageViewer extends State<SinglePageViewer>
    with ThemeModeWidget, IsTopWidget2 {
  final Key _key = GlobalKey();
  late PageController _pageController;
  late int _index;
  late GalleryData? _data;
  late List<ExtendedPMeta>? _pages;
  late EhFiles? _files;
  late String _back;
  CancelToken? _cancel;
  bool _isLoading = false;
  bool _pageChanged = false;
  Object? _error;
  bool _inited = false;
  bool _showMenu = false;
  late PhotoViewController _photoViewController;
  final LruMap<int, (Uint8List, String?, String)> _imgData =
      LruMap(maximumSize: 20);
  void _updatePages() {
    if (_data == null) return;
    final displayAd = prefs.getBool("displayAd") ?? false;
    _pages =
        displayAd ? _data!.pages : _data!.pages.where((e) => !e.isAd).toList();
    _index = _pages!.indexWhere((e) => e.index == widget.index);
    if (_index == -1) _index = 0;
    if (!_inited) {
      _pageController = PageController(initialPage: _index);
      _inited = true;
    }
  }

  @override
  void initState() {
    _data = widget.data;
    _updatePages();
    _files = widget.files;
    _back = "/gallery/${widget.gid}";
    _photoViewController = PhotoViewController();
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _pageController.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      if (_data == null) {
        final data =
            (await api.getGallery(widget.gid, cancel: _cancel)).unwrap();
        _data = data;
      }
      final fileData = (await api.getFiles(
              _data!.pages.map((e) => e.token).toList(),
              cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        _updatePages();
        setState(() {
          _files = fileData;
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load gallery ${widget.gid}:", e);
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  void _onPageChanged(BuildContext context) {
    context.replace("/gallery/${widget.gid}/page/${_pages![_index].index}",
        extra: SinglePageViewerExtra(data: _data, files: _files));
    _pageChanged = false;
  }

  Widget _buildGallery(BuildContext context) {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      pageController: _pageController,
      itemCount: _pages!.length,
      builder: (BuildContext context, int index) {
        final data = _pages![index];
        final f = _files!.files[data.token]!.first;
        if (_index != index) {
          _photoViewController.reset();
        }
        return PhotoViewGalleryPageOptions(
          imageProvider: DioImage.string(api.getFileUrl(f.id),
              dio: dio, key: _key, onData: (data, headers, url) {
            _imgData[index] = (data, headers.value("content-type"), url);
          }),
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(
            tag: data.token,
            transitionOnUserGestures: true,
          ),
          filterQuality: FilterQuality.high,
          controller: _photoViewController,
        );
      },
      onPageChanged: (index) {
        _index = index;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _onPageChanged(context);
        });
      },
    );
  }

  Widget _buildWithKeyboardSupport(BuildContext context,
      {required Widget child}) {
    return KeyboardWidget(
      bindings: [
        KeyAction(LogicalKeyboardKey.arrowLeft, "previous page", () {
          if (_index > 0) {
            _pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          }
        }),
        KeyAction(LogicalKeyboardKey.arrowRight, "next page", () {
          if (_index < _pages!.length - 1) {
            _pageController.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          }
        }),
        KeyAction(LogicalKeyboardKey.backspace, "back", () {
          context.canPop() ? context.pop() : context.go(_back);
        }),
      ],
      child: child,
    );
  }

  Widget _buildWithTap(BuildContext context, {required Widget child}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMenu = !_showMenu;
        });
      },
      child: child,
    );
  }

  Widget _buildWithScrollSupport(BuildContext context,
      {required Widget child}) {
    if (kIsWeb && pointerIsTouch) {
      return child;
    }
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent &&
            event.kind == PointerDeviceKind.mouse) {
          if (_photoViewController.scale != null) {
            _photoViewController.scale = _photoViewController.scale! *
                (1 - event.scrollDelta.dy / MediaQuery.of(context).size.height);
          }
        }
      },
      child: child,
    );
  }

  Widget _buildWithContextMenu(BuildContext context, {required Widget child}) {
    final i18n = AppLocalizations.of(context)!;
    return ContextMenuWidget(
        menuProvider: (_) {
          var list = <MenuElement>[];
          final url = _imgData[_index]?.$3;
          if (url != null) {
            list.add(MenuAction(
                title: i18n.copyImgUrl,
                callback: () {
                  copyTextToClipboard(url!).catchError((err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  });
                }));
          }
          final data = _imgData[_index]?.$1;
          if (data != null) {
            final fmt =
                ImageFmt.fromMimeType(_imgData[_index]?.$2) ?? ImageFmt.jpg;
            list.add(MenuAction(
                title: i18n.copyImage,
                callback: () {
                  copyImageToClipboard(data!, fmt).catchError((err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  });
                }));
          }
          return Menu(children: list);
        },
        child: child);
  }

  Widget _buildViewer(BuildContext context) {
    return _buildWithTap(context,
        child: _buildWithKeyboardSupport(context,
            child: _buildWithScrollSupport(context,
                child: _buildWithContextMenu(context,
                    child: _buildGallery(context)))));
  }

  Widget _buildTopAppBar(BuildContext context) {
    if (!_showMenu) return Container();
    final theme = Theme.of(context);
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AppBar(
            leading: IconButton(
                onPressed: () {
                  context.canPop() ? context.pop() : context.go(_back);
                },
                icon: const Icon(Icons.close)),
            title: FitText(
                texts: [
                  (_data!.meta.preferredTitle, 0),
                  (_pages![_index].name, 1)
                ],
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge,
                separator: " - "),
            actions: [
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final isLoading = _error == null && (_data == null || _files == null);
    if (isLoading && !_isLoading) _fetchData();
    final title = _data != null && _pages != null
        ? "${_data!.meta.preferredTitle} - ${_pages![_index].name}"
        : AppLocalizations.of(context)!.loading;
    if (isTop(context)) {
      if (!kIsWeb || (_data != null && kIsWeb)) {
        setCurrentTitle(title, Theme.of(context).primaryColor.value,
            includePrefix: false);
      }
    }
    if (_data == null || _files == null) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.canPop() ? context.pop() : context.go(_back);
              },
            ),
            title: Text(title),
            actions: [
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      SelectableText("Error $_error"),
                      ElevatedButton.icon(
                          onPressed: () {
                            _fetchData();
                            setState(() {
                              _error = null;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.retry))
                    ])));
    }
    if (_pageChanged) {
      _onPageChanged(context);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        _buildViewer(context),
        _buildTopAppBar(context),
      ]),
    );
  }
}
