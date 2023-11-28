import 'package:dio/dio.dart';
import 'package:dio_image_provider/dio_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:keymap/keymap.dart';
import 'package:logging/logging.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';

final _log = Logger("SinglePageViewer");

class SinglePageViewerExtra {
  const SinglePageViewerExtra({this.data, this.files});
  final GalleryData? data;
  final EhFiles? files;
}

class SinglePageViewer extends StatefulWidget {
  const SinglePageViewer(
      {Key? key, required this.gid, required this.index, this.data, this.files})
      : super(key: key);
  final GalleryData? data;
  final EhFiles? files;
  final int gid;
  final int index;
  static const String routeName = '/gallery/:gid/page/:index';

  @override
  State<SinglePageViewer> createState() => _SinglePageViewer();
}

class _SinglePageViewer extends State<SinglePageViewer> with ThemeModeWidget {
  late PageController _pageController;
  late int _index;
  late GalleryData? _data;
  late EhFiles? _files;
  CancelToken? _cancel;
  bool _isLoading = false;
  bool _page_changed = false;
  Object? _error;
  @override
  void initState() {
    _index = widget.index - 1;
    _pageController = PageController(initialPage: _index);
    _data = widget.data;
    _files = widget.files;
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      if (_data == null) {
        final data = (await api.getGallery(widget.gid)).unwrap();
        _data = data;
      }
      final fileData = (await api.getFiles(
              _data!.pages.map((e) => e.token).toList(),
              cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        if (_index < 0) {
          _index = 0;
          _pageController.jumpToPage(_index);
          _page_changed = true;
        } else if (_index >= _data!.pages.length) {
          _index = _data!.pages.length - 1;
          _pageController.jumpToPage(_index);
          _page_changed = true;
        }
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
    context.replace("/gallery/${widget.gid}/page/${_index + 1}",
        extra: SinglePageViewerExtra(data: _data, files: _files));
    _page_changed = false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _error == null && (_data == null || _files == null);
    if (isLoading && !_isLoading) _fetchData();
    if (_data == null || _files == null) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.canPop() ? context.pop() : context.go("/");
              },
            ),
            title: Text(AppLocalizations.of(context)!.loading),
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
    if (_page_changed) {
      _onPageChanged(context);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: KeyboardWidget(
        bindings: [
          KeyAction(LogicalKeyboardKey.arrowLeft, "previous page", () {
            if (_index > 0) {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
            }
          }),
          KeyAction(LogicalKeyboardKey.arrowRight, "next page", () {
            if (_index < _data!.pages.length - 1) {
              _pageController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
            }
          }),
          KeyAction(LogicalKeyboardKey.backspace, "back", () {
            context.canPop() ? context.pop() : context.go("/");
          }),
        ],
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          pageController: _pageController,
          itemCount: _data!.pages.length,
          builder: (BuildContext context, int index) {
            final data = _data!.pages[index];
            final f = _files!.files[data.token]!.first;
            return PhotoViewGalleryPageOptions(
              imageProvider: DioImage.string(
                api.getFileUrl(f.id),
                dio: dio,
              ),
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(
                tag: data.token,
                transitionOnUserGestures: true,
              ),
              filterQuality: FilterQuality.high,
            );
          },
          onPageChanged: (index) {
            _index = index;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _onPageChanged(context);
            });
          },
        ),
      ),
    );
  }
}
