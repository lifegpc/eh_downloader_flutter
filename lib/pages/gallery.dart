import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../components/gallery_info.dart';
import '../globals.dart';

final _log = Logger("GalleryPage");

class GalleryPageExtra {
  const GalleryPageExtra({this.title});
  final String? title;
}

class GalleryPage extends StatefulWidget {
  const GalleryPage(int gid, {super.key, this.title}) : _gid = gid;

  final int _gid;
  final String? title;
  static const String routeName = '/gallery/:gid';

  @override
  State<GalleryPage> createState() => _GalleryPage();
  // ignore: library_private_types_in_public_api
  static _GalleryPage of(BuildContext context) =>
      context.findAncestorStateOfType<_GalleryPage>()!;
  // ignore: library_private_types_in_public_api
  static _GalleryPage? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_GalleryPage>();
}

class _GalleryPage extends State<GalleryPage>
    with ThemeModeWidget, IsTopWidget2 {
  _GalleryPage();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int _gid = 0;
  GalleryData? _data;
  EhFiles? _files;
  Object? _error;
  CancelToken? _cancel;
  CancelToken? _markAsNsfwCancel;
  CancelToken? _markAsAdCancel;
  bool _isLoading = false;
  bool _isSelectMode = false;
  final List<String> _selected = [];
  bool? get isAllNsfw => _data?.isAllNsfw;
  bool get isSelectMode => _isSelectMode;
  int get gid => widget._gid;
  Future<void> markGalleryAsNsfw(bool isNsfw) async {
    try {
      _markAsNsfwCancel = CancelToken();
      if (_isSelectMode) {
        if (_selected.isEmpty) return;
        (await api.updateFilesMeta(_selected.join(","),
                isNsfw: isNsfw, cancel: _markAsNsfwCancel))
            .unwrap();
      } else {
        (await api.updateGalleryFileMeta(_gid,
                isNsfw: isNsfw, cancel: _markAsNsfwCancel))
            .unwrap();
      }
      if (!_markAsNsfwCancel!.isCancelled) {
        _fetchData();
      }
    } catch (e) {
      if (!_markAsNsfwCancel!.isCancelled) {
        _log.warning("Failed to mark gallery $_gid:", e);
      }
    }
  }

  Future<void> markAsAd(bool isAd) async {
    if (!_isSelectMode || _selected.isEmpty) return;
    try {
      _markAsAdCancel = CancelToken();
      (await api.updateFilesMeta(_selected.join(","),
              isAd: isAd, cancel: _markAsAdCancel))
          .unwrap();
      if (!_markAsAdCancel!.isCancelled) {
        _fetchData();
      }
    } catch (e) {
      if (!_markAsAdCancel!.isCancelled) {
        _log.warning("Failed to mark gallery $_gid:", e);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      final data = (await api.getGallery(_gid, cancel: _cancel)).unwrap();
      _data = data;
      final fileData = (await api.getFiles(
              data.pages.map((e) => e.token).toList(),
              cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _files = fileData;
          _isLoading = false;
          _selected.clear();
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load gallery $_gid:", e);
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _gid = widget._gid;
    _data = null;
    _error = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final isLoading = _data == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    final title = isLoading
        ? i18n.loading
        : _data != null
            ? _data!.meta.preferredTitle
            : i18n.gallery;
    if (isTop(context)) {
      if (!kIsWeb || (_data != null && kIsWeb)) {
        setCurrentTitle(title, Theme.of(context).primaryColor.value,
            includePrefix: false);
      } else if (kIsWeb && widget.title != null) {
        // 设置预加载标题
        // Chrome 和 Firefox 必须尽快设置标题以确保在历史记录菜单显示正确的标题
        setCurrentTitle(widget.title!, Theme.of(context).primaryColor.value,
            includePrefix: false);
      }
    }
    return Scaffold(
        appBar: _data == null
            ? AppBar(
                leading: shareToken != null
                    ? Container()
                    : IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context.canPop()
                              ? context.pop()
                              : context.go("/gallery");
                        },
                      ),
                title: Text(title),
                actions: [
                  buildThemeModeIcon(context),
                  buildMoreVertSettingsButon(context),
                ],
              )
            : null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _data != null
                ? GalleryInfo(
                    _data!,
                    files: _files,
                    refreshIndicatorKey: _refreshIndicatorKey,
                    onRefresh: () async {
                      await _fetchData();
                    },
                    onSelectChanged: (v) {
                      setState(() {
                        _isSelectMode = v;
                        if (v) _selected.clear();
                      });
                    },
                    isSelectMode: _isSelectMode,
                    selected: _selected,
                  )
                : Center(
                    child: Text("Error: $_error"),
                  ));
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _markAsNsfwCancel?.cancel();
    _markAsAdCancel?.cancel();
    super.dispose();
  }
}
