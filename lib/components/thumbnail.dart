import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import '../api/client.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'image.dart';

final _log = Logger("Thumbnail");

class Thumbnail extends StatefulWidget {
  const Thumbnail(ExtendedPMeta pMeta,
      {Key? key, int? max, int? width, int? height, int? fileId})
      : _pMeta = pMeta,
        _max = max ?? 1200,
        _width = width,
        _height = height,
        _fileId = fileId,
        super(key: key);
  final ExtendedPMeta _pMeta;
  final int _max;
  final int? _width;
  final int? _height;
  final int? _fileId;

  int get height => _height != null
      ? _height!
      : _pMeta.height > _pMeta.width
          ? _max
          : _max * _pMeta.height ~/ _pMeta.width;
  int get width => _width != null
      ? _width!
      : _pMeta.width > _pMeta.height
          ? _max
          : _max * _pMeta.width ~/ _pMeta.height;

  @override
  State<Thumbnail> createState() => _Thumbnail();
}

class _Thumbnail extends State<Thumbnail> {
  Uint8List? _data;
  bool _isLoading = false;
  Object? _error;
  int? _fileId;
  bool _showNsfw = false;
  String? _uri;
  CancelToken? _cancel;
  Future<void> _fetchData() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      if (_fileId == null) {
        final token = widget._pMeta.token;
        _fileId = (await api.getFiles([token], cancel: _cancel))
            .unwrap()
            .files[token]![0]!
            .id;
      }
      final re = await api.getThumbnail(_fileId!,
          max: widget._max,
          width: widget._width,
          height: widget._height,
          method: ThumbnailMethod.contain,
          align: ThumbnailAlign.center,
          cancel: _cancel);
      if (re.response.statusCode != 200) {
        throw Exception(
            'Failed to get thumbnail: ${re.response.statusCode} ${re.response.statusMessage}');
      }
      _uri = re.response.realUri.toString();
      final data = Uint8List.fromList(re.data);
      if (!_cancel!.isCancelled) {
        setState(() {
          _isLoading = false;
          _data = data;
          _cancel = null;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.warning("Failed to get file data:", e);
        setState(() {
          _isLoading = false;
          _error = e;
          _cancel = null;
        });
      }
    }
  }

  @override
  void initState() {
    _data = null;
    _isLoading = false;
    _error = null;
    _fileId = widget._fileId;
    _showNsfw = false;
    _uri = null;
    super.initState();
  }

  bool get showNsfw => _showNsfw || (prefs.getBool("showNsfw") ?? false);

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _data == null && _error == null;
    final isNsfw = widget._pMeta.isNsfw;
    if (isLoading && !_isLoading) _fetchData();
    return SizedBox(
        width: widget.width.toDouble(),
        height: widget.height.toDouble(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _data != null
                ? isNsfw && !showNsfw
                    ? Stack(
                        children: [
                          SizedBox(
                              width: widget.width.toDouble(),
                              height: widget.height.toDouble(),
                              child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                      tileMode: TileMode.decal),
                                  child:
                                      ImageWithContextMenu(_data!, uri: _uri))),
                          SizedBox(
                              width: widget.width.toDouble(),
                              height: widget.height.toDouble(),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showNsfw = true;
                                    });
                                  },
                                  icon: const Icon(Icons.visibility),
                                ),
                              ))
                        ],
                      )
                    : ImageWithContextMenu(_data!, uri: _uri)
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
}
