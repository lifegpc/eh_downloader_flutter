import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'api/file.dart';
import 'api/gallery.dart';
import 'components/gallery_info.dart';
import 'globals.dart';

final _log = Logger("GalleryPage");

class GalleryPageExtra {
  const GalleryPageExtra({this.title});
  final String? title;
}

class GalleryPage extends StatefulWidget {
  const GalleryPage(int gid, {Key? key, this.title})
      : _gid = gid,
        super(key: key);

  final int _gid;
  final String? title;
  static const String routeName = '/gallery/:gid';

  @override
  State<GalleryPage> createState() => _GalleryPage();
}

class _GalleryPage extends State<GalleryPage>
    with ThemeModeWidget, IsTopWidget2 {
  _GalleryPage();
  int _gid = 0;
  GalleryData? _data;
  EhFiles? _files;
  Object? _error;
  CancelToken? _cancel;
  bool _isLoading = false;

  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      final data = (await api.getGallery(_gid)).unwrap();
      _data = data;
      final fileData = (await api.getFiles(
              data.pages.map((e) => e.token).toList(),
              cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _files = fileData;
          _isLoading = false;
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
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
                ? GalleryInfo(_data!, files: _files)
                : Center(
                    child: Text("Error: $_error"),
                  ));
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}
