import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/gallery.dart';
import '../globals.dart';

final _log = Logger("GalleryDetailsPage");

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.name, this.value, {Key? key, this.fontSize})
      : super(key: key);
  final String name;
  final String value;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      SizedBox(
          width: 80,
          child: Center(
              child: Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.primary, fontSize: fontSize)))),
      Expanded(
        child: SelectableText(value,
            style: TextStyle(color: cs.secondary, fontSize: fontSize)),
      )
    ]);
  }
}

class GalleryDetailsPageExtra {
  const GalleryDetailsPageExtra({this.meta});
  final GMeta? meta;
}

class GalleryDetailsPage extends StatefulWidget {
  const GalleryDetailsPage(this.gid, {Key? key, this.meta}) : super(key: key);
  final int gid;
  final GMeta? meta;

  @override
  State<GalleryDetailsPage> createState() => _GalleryDetailsPage();
}

class _GalleryDetailsPage extends State<GalleryDetailsPage> {
  GMeta? _meta;
  CancelToken? _cancel;
  bool _isLoading = false;
  Object? _error;

  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      final data = (await api.getGallery(widget.gid)).unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _meta = data.meta;
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

  @override
  void initState() {
    _meta = widget.meta;
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final isLoading = _meta == null && _error == null;
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    if (isLoading && !_isLoading) _fetchData();
    final indent = maxWidth < 400 ? 5.0 : 10.0;
    return Container(
      padding: maxWidth < 400
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
          : const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: $_error"),
                    ElevatedButton.icon(
                        onPressed: () {
                          _fetchData();
                          setState(() {
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(i18n.retry)),
                  ],
                ))
              : SingleChildScrollView(
                  child: Column(children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        i18n.galleryDetails,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go("/gallery/${widget.gid}"),
                            icon: const Icon(Icons.close),
                          )),
                    ],
                  ),
                  Divider(indent: indent, endIndent: indent),
                  _KeyValue(
                    i18n.gid,
                    _meta!.gid.toString(),
                    fontSize: 16,
                  ),
                  Divider(indent: indent, endIndent: indent),
                  _KeyValue(i18n.title2, _meta!.title, fontSize: 16),
                  _meta!.titleJpn.isEmpty
                      ? Container()
                      : Divider(indent: indent, endIndent: indent),
                  _meta!.titleJpn.isEmpty
                      ? Container()
                      : _KeyValue(i18n.titleJpn, _meta!.titleJpn, fontSize: 16),
                  Divider(indent: indent, endIndent: indent),
                  _KeyValue(i18n.visible, _meta!.expunged ? i18n.no : i18n.yes,
                      fontSize: 16),
                ])),
    );
  }
}
