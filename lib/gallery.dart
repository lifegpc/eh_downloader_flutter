import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'api/gallery.dart';
import 'components/thumbnail.dart';
import 'globals.dart';

final _log = Logger("GalleryPage");

class GalleryPage extends StatefulWidget {
  const GalleryPage(int gid, {Key? key})
      : _gid = gid,
        super(key: key);

  final int _gid;
  static const String routeName = '/gallery/:gid';

  @override
  State<GalleryPage> createState() => _GalleryPage();
}

class _GalleryPage extends State<GalleryPage> with ThemeModeWidget {
  _GalleryPage();
  int _gid = 0;
  GalleryData? _data;
  Object? _error;
  bool _isLoading = false;

  Future<void> _fetchData() async {
    try {
      _isLoading = true;
      final data = (await api.getGallery(_gid)).unwrap();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      _log.severe("Failed to load gallery $_gid:", e);
      setState(() {
        _error = e;
        _isLoading = false;
      });
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
    final title = isLoading
        ? AppLocalizations.of(context)!.loading
        : _data != null
            ? _data!.meta.preferredTitle
            : AppLocalizations.of(context)!.gallery;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.canPop() ? context.pop() : context.go("/");
            },
          ),
          title: _data != null ? SelectableText(title) : Text(title),
          actions: [
            buildThemeModeIcon(context),
            buildMoreVertSettingsButon(context),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _data != null
                ? Center(
                    child: Thumbnail(_data!.pages[0]!),
                  )
                : Center(
                    child: Text("Error: $_error"),
                  ));
  }
}