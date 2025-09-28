import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:keymap/keymap.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
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
import '../utils.dart';
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
  int _scrollMethod = 0;
  double? _sliderValue;
  late PhotoViewController _photoViewController;
  final LruMap<int, (Uint8List, String?, String)> _imgData =
      LruMap(maximumSize: 20);
  Axis get _scrollAxis => _scrollMethod >= 2 ? Axis.vertical : Axis.horizontal;
  bool get _isReverseScroll => _scrollMethod == 1 || _scrollMethod == 3;
  void _showPageSettings(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final options = [
      MapEntry(0, i18n.scrollDirectionDefault),
      MapEntry(1, i18n.scrollDirectionRtl),
      MapEntry(2, i18n.scrollDirectionDown),
      MapEntry(3, i18n.scrollDirectionUp)
    ];

    showModalBottomSheet(
        context: context,
        builder: (sheetContext) {
          var selected = _scrollMethod;
          return StatefulBuilder(builder: (context, setSheetState) {
            return SafeArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  ListTile(
                    dense: true,
                    title: Text(i18n.scrollDirection),
                  ),
                  for (final entry in options)
                    RadioListTile<int>(
                        title: Text(entry.value),
                        value: entry.key,
                        groupValue: selected,
                        onChanged: (value) async {
                          if (value == null) return;
                          setSheetState(() {
                            selected = value;
                          });
                          Navigator.of(sheetContext).pop();
                          final saved =
                              await prefs.setInt("single_viewer_scroll_method", value);
                          if (!saved) {
                            _log.warning(
                                "Failed to save single_viewer_scroll_method.");
                            return;
                          }
                          if (!mounted) return;
                          setState(() {
                            _scrollMethod = value;
                          });
                        })
                ]));
          });
        });
  }

  Widget _buildBottomBar(BuildContext context) {
    if (!_showMenu || _pages == null) return Container();
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;
    final pagesCount = _pages!.length;
    if (pagesCount == 0) return Container();
    final double maxPage = (pagesCount - 1).toDouble();
    final double currentValue =
        (_sliderValue ?? _index.toDouble()).clamp(0.0, maxPage).toDouble();
    final displayIndex = currentValue.round().clamp(0, pagesCount - 1);

    Slider buildSlider() {
      return Slider(
        value: currentValue,
        min: 0,
        max: maxPage,
        divisions: pagesCount - 1,
        onChanged: (value) {
          setState(() {
            _sliderValue = value;
          });
        },
        onChangeEnd: (value) {
          final target = value.round().clamp(0, pagesCount - 1);
          if (target != _index) {
            _pageController.animateToPage(target,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          }
          setState(() {
            _sliderValue = target.toDouble();
          });
        },
      );
    }

    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 480;
              return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16)),
                  child: isWide
                      ? Row(children: [
                          Text(
                            "${displayIndex + 1} / $pagesCount",
                            style: textStyle,
                          ),
                          if (pagesCount > 1) ...[
                            const SizedBox(width: 16),
                            Expanded(child: buildSlider()),
                            const SizedBox(width: 16),
                          ] else ...[
                            const Spacer(),
                            const SizedBox(width: 16),
                          ],
                          IconButton(
                              onPressed: () {
                                _showPageSettings(context);
                              },
                              icon: const Icon(Icons.settings))
                        ])
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pagesCount > 1) ...[
                              buildSlider(),
                              const SizedBox(height: 12),
                            ],
                            Row(children: [
                              Text(
                                "${displayIndex + 1} / $pagesCount",
                                style: textStyle,
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    _showPageSettings(context);
                                  },
                                  icon: const Icon(Icons.settings))
                            ])
                          ],
                        ));
            })));
  }
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
    _sliderValue = _index.toDouble();
  }

  @override
  void initState() {
    _data = widget.data;
    _updatePages();
    _files = widget.files;
    _back = "/gallery/${widget.gid}";
    _scrollMethod = prefs.getInt("single_viewer_scroll_method") ?? 0;
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
      scrollDirection: _scrollAxis,
      reverse: _isReverseScroll,
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
        setState(() {
          _index = index;
          _sliderValue = index.toDouble();
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _onPageChanged(context);
        });
      },
    );
  }

  Widget _buildWithKeyboardSupport(BuildContext context,
      {required Widget child}) {
    void goPrevious() {
      if (_index > 0) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      }
    }

    void goNext() {
      if (_index < _pages!.length - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      }
    }

    final bindings = <KeyAction>[];
    if (_scrollAxis == Axis.horizontal) {
      if (_isReverseScroll) {
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowLeft, "next page", () => goNext()));
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowRight, "previous page", () => goPrevious()));
      } else {
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowLeft, "previous page", () => goPrevious()));
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowRight, "next page", () => goNext()));
      }
    } else {
      if (_isReverseScroll) {
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowUp, "next page", () => goNext()));
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowDown, "previous page", () => goPrevious()));
      } else {
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowUp, "previous page", () => goPrevious()));
        bindings.add(KeyAction(
            LogicalKeyboardKey.arrowDown, "next page", () => goNext()));
      }
    }

    bindings.add(KeyAction(LogicalKeyboardKey.backspace, "back", () {
      context.canPop() ? context.pop() : context.go(_back);
    }));

    return KeyboardWidget(
      bindings: bindings,
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
            list.add(MenuAction(
                title: i18n.saveAs,
                callback: () {
                  try {
                        platformPath.saveFile(
                            basenameWithoutExtension(_pages![_index].name),
                            fmt.toMimeType(),
                            data,
                            dir: isAndroid ? widget.gid.toString() : "");
                  } catch (err, stack) {
                    _log.warning("Failed to save image: $err\n$stack");
                  }
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
        setCurrentTitle(title, includePrefix: false);
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
        _buildBottomBar(context),
      ]),
    );
  }
}
