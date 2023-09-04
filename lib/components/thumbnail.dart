import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import '../api/client.dart';
import '../api/gallery.dart';
import '../globals.dart';

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
  Future<void> _fetchData() async {
    try {
      _isLoading = true;
      if (_fileId == null) {
        final token = widget._pMeta.token;
        _fileId = (await api.getFiles([token])).unwrap().files[token]![0]!.id;
      }
      final re = await api.getThumbnail(_fileId!,
          max: widget._max,
          width: widget._width,
          height: widget._height,
          method: ThumbnailMethod.contain,
          align: ThumbnailAlign.center);
      if (re.response.statusCode != 200) {
        throw Exception(
            'Failed to get thumbnail: ${re.response.statusCode} ${re.response.statusMessage}');
      }
      final data = Uint8List.fromList(re.data);
      setState(() {
        _isLoading = false;
        _data = data;
      });
    } catch (e) {
      _log.warning("Failed to get file data:", e);
      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }

  @override
  void initState() {
    _data = null;
    _isLoading = false;
    _error = null;
    _fileId = widget._fileId;
    _showNsfw = false;
    super.initState();
  }

  bool get showNsfw => _showNsfw || (prefs.getBool("showNsfw") ?? false);

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
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Image.memory(_data!))),
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
                    : Image.memory(_data!)
                : Text("Error $_error"));
  }
}
