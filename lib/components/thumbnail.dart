import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:palette_generator/palette_generator.dart';
import '../api/client.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import '../utils.dart';
import '../utils/clipboard.dart';
import '../viewer/single.dart';
import 'image.dart';

final _log = Logger("Thumbnail");

class Thumbnail extends StatefulWidget {
  const Thumbnail(ExtendedPMeta pMeta,
      {super.key,
      int? max,
      int? width,
      int? height,
      int? fileId,
      this.gid,
      this.index,
      this.files,
      this.gdata})
      : _pMeta = pMeta,
        _max = max ?? 1200,
        _width = width,
        _height = height,
        _fileId = fileId;
  final ExtendedPMeta _pMeta;
  final int _max;
  final int? _width;
  final int? _height;
  final int? _fileId;
  final int? gid;
  final int? index;
  final EhFiles? files;
  final GalleryData? gdata;

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

enum _ThumbnailMenu {
  copyImage,
  copyImgUrl,
  saveAs,
  markAsNsfw,
  markAsSfw,
  markAsAd,
  markAsNonAd,
}

class _Thumbnail extends State<Thumbnail> {
  Uint8List? _data;
  bool _isLoading = false;
  Object? _error;
  int? _fileId;
  bool _showNsfw = false;
  String? _uri;
  CancelToken? _cancel;
  CancelToken? _markAsNsfwCancel;
  CancelToken? _markAsAdCancel;
  String? _fileName;
  String _dir = "";
  Color? _iconColor;
  double? _iconSize;
  bool _disposed = false;
  String? _originalUrl;
  void _onNsfwChanged(dynamic args) {
    final arguments = args as (String, bool)?;
    if (arguments == null) return;
    final token = arguments.$1;
    final isNsfw = arguments.$2;
    if (token != widget._pMeta.token) return;
    widget._pMeta.isNsfw = isNsfw;
    setState(() {});
  }

  Future<void> _markAsNsfw(bool isNsfw) async {
    try {
      _markAsNsfwCancel = CancelToken();
      final token = widget._pMeta.token;
      (await api.updateFileMeta(token,
              isNsfw: isNsfw, cancel: _markAsNsfwCancel))
          .unwrap();
      listener.tryEmit("nsfwChanged", (token, isNsfw));
    } catch (e) {
      if (!_markAsNsfwCancel!.isCancelled) {
        _log.warning("Failed to mark as nsfw:", e);
      }
    }
  }

  Future<void> _markAsAd(bool isAd) async {
    try {
      _markAsAdCancel = CancelToken();
      final token = widget._pMeta.token;
      (await api.updateFileMeta(token, isAd: isAd, cancel: _markAsAdCancel))
          .unwrap();
      listener.tryEmit("adChanged", (token, isAd));
    } catch (e) {
      if (!_markAsAdCancel!.isCancelled) {
        _log.warning("Failed to mark as ad:", e);
      }
    }
  }

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
      _originalUrl ??= api.getThumbnailUrl(_fileId!,
          max: widget._max,
          width: widget._width,
          height: widget._height,
          method: ThumbnailMethod.contain,
          align: ThumbnailAlign.center);
      if (isImageCacheEnabled) {
        try {
          final cache = await imageCaches.getCache(_originalUrl!);
          if (cache != null) {
            setState(() {
              _data = cache!.$1;
              _uri = cache!.$3 ?? _originalUrl;
              _isLoading = false;
              _cancel = null;
            });
            return;
          }
        } catch (e, stack) {
          _log.warning("Failed to get cache for $_originalUrl: $e\n$stack");
        }
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
        if (isImageCacheEnabled) {
          try {
            await imageCaches.putCache(
                _originalUrl!, data, re.response.headers.map, _uri);
          } catch (e, stack) {
            _log.warning("Failed to put cache for $_originalUrl: $e\n$stack");
          }
        }
        setState(() {
          _isLoading = false;
          _data = data;
          _cancel = null;
        });
        updateIconColor();
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
    _fileName = "${basenameWithoutExtension(widget._pMeta.name)}_thumb";
    _dir = isAndroid && widget.gid != null ? widget.gid!.toString() : "";
    listener.on("nsfwChanged", _onNsfwChanged);
    super.initState();
  }

  Future<void> updateIconColor() async {
    if (_data == null) return;
    try {
      final img = await instantiateImageCodec(_data!);
      try {
        final frame = await img.getNextFrame();
        final i = frame.image;
        try {
          final iconSize = _iconSize ?? 24.0;
          final pattle = await PaletteGenerator.fromImage(i,
              region: Rect.fromCenter(
                  center: Offset(i.width / 2, i.height / 2),
                  width: iconSize,
                  height: iconSize),
              filters: [(_) => true]);
          if (!_disposed) {
            setState(() {
              _iconColor = pattle.colors.first.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white;
            });
          }
        } finally {
          i.dispose();
        }
      } finally {
        img.dispose();
      }
    } catch (e) {
      _log.warning("Failed to generate icon's color from image data:", e);
    }
  }

  bool get showNsfw => _showNsfw || (prefs.getBool("showNsfw") ?? false);

  @override
  void dispose() {
    _disposed = true;
    _cancel?.cancel();
    _markAsNsfwCancel?.cancel();
    _markAsAdCancel?.cancel();
    listener.removeEventListener("nsfwChanged", _onNsfwChanged);
    super.dispose();
  }

  Future<void> onItemSelected(_ThumbnailMenu v) async {
    switch (v) {
      case _ThumbnailMenu.copyImage:
        try {
          copyImageToClipboard(_data!, ImageFmt.jpg);
        } catch (err, stack) {
          _log.warning("Failed to copy image to clipboard: $err\n$stack");
        }
        break;
      case _ThumbnailMenu.copyImgUrl:
        try {
          copyTextToClipboard(_uri!);
        } catch (err, stack) {
          _log.warning("Failed to copy image url to clipboard: $err\n$stack");
        }
        break;
      case _ThumbnailMenu.saveAs:
        try {
          await platformPath.saveFile(_fileName!, "image/jpeg", _data!,
              dir: _dir);
        } catch (err, stack) {
          _log.warning("Failed to save image: $err\n$stack");
        }
        break;
      case _ThumbnailMenu.markAsNsfw:
        await _markAsNsfw(true);
        break;
      case _ThumbnailMenu.markAsSfw:
        await _markAsNsfw(false);
        break;
      case _ThumbnailMenu.markAsAd:
        await _markAsAd(true);
        break;
      case _ThumbnailMenu.markAsNonAd:
        await _markAsAd(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _data == null && _error == null;
    final isNsfw = widget._pMeta.isNsfw;
    final isAd = widget._pMeta.isAd;
    if (isLoading && !_isLoading) _fetchData();
    _iconSize ??= Theme.of(context).iconTheme.size;
    final iconSize = MediaQuery.of(context).size.width < 400
        ? 14.0
        : Theme.of(context).iconTheme.size;
    final moreVertMenu = Positioned(
        right: 0,
        top: 0,
        width: iconSize,
        height: iconSize,
        child: PopupMenuButton(
            child: Icon(Icons.more_vert, size: iconSize),
            onSelected: (v) {
              onItemSelected(v);
            },
            itemBuilder: (context) {
              var list = <PopupMenuEntry<_ThumbnailMenu>>[
                PopupMenuItem(
                    value: _ThumbnailMenu.copyImage,
                    child: Text(AppLocalizations.of(context)!.copyImage)),
                PopupMenuItem(
                    value: _ThumbnailMenu.copyImgUrl,
                    child: Text(AppLocalizations.of(context)!.copyImgUrl)),
                PopupMenuItem(
                    value: _ThumbnailMenu.saveAs,
                    child: Text(AppLocalizations.of(context)!.saveAs)),
              ];
              if (auth.canEditGallery == true) {
                list += [
                  const PopupMenuDivider(),
                  PopupMenuItem(
                      value: isNsfw
                          ? _ThumbnailMenu.markAsSfw
                          : _ThumbnailMenu.markAsNsfw,
                      child: Text(isNsfw
                          ? AppLocalizations.of(context)!.markAsSfw
                          : AppLocalizations.of(context)!.markAsNsfw)),
                  PopupMenuItem(
                      value: isAd
                          ? _ThumbnailMenu.markAsNonAd
                          : _ThumbnailMenu.markAsAd,
                      child: Text(isAd
                          ? AppLocalizations.of(context)!.markAsNonAd
                          : AppLocalizations.of(context)!.markAsAd)),
                ];
              }
              return list;
            }));
    final timg = _data != null
        ? ImageWithContextMenu(_data!,
            uri: _uri,
            fileName: _fileName,
            dir: _dir,
            isNsfw:
                auth.canEditGallery == true ? () => widget._pMeta.isNsfw : null,
            changeNsfw: auth.canEditGallery == true
                ? (isNsfw) {
                    _markAsNsfw(isNsfw);
                  }
                : null,
            isAd: auth.canEditGallery == true ? () => widget._pMeta.isAd : null,
            changeAd: auth.canEditGallery == true
                ? (isAd) {
                    _markAsAd(isAd);
                  }
                : null)
        : null;
    final img = widget.gid != null && widget.index != null && _data != null
        ? GestureDetector(
            onTap: () {
              context.push("/gallery/${widget.gid}/page/${widget.index}",
                  extra: SinglePageViewerExtra(
                      data: widget.gdata, files: widget.files));
            },
            child: timg)
        : timg;
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
                                  child: img)),
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
                                  icon: Icon(Icons.visibility,
                                      color: _iconColor ?? Colors.black),
                                ),
                              )),
                          moreVertMenu
                        ],
                      )
                    : Stack(children: [
                        SizedBox(
                            width: widget.width.toDouble(),
                            height: widget.height.toDouble(),
                            child: img),
                        moreVertMenu
                      ])
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
