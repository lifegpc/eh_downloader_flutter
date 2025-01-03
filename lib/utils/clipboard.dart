import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../platform/to_png_none.dart'
    if (dart.library.html) '../platform/to_png.dart';
import '../globals.dart';
import '../utils.dart';

enum ImageFmt {
  jpg,
  png,
  gif,
  webp;

  String toMimeType() {
    switch (this) {
      case ImageFmt.jpg:
        return "image/jpeg";
      case ImageFmt.png:
        return "image/png";
      case ImageFmt.gif:
        return "image/gif";
      case ImageFmt.webp:
        return "image/webp";
    }
  }

  static ImageFmt? fromMimeType(String? mime) {
    if (mime == null) return null;
    switch (mime) {
      case "image/jpeg":
        return ImageFmt.jpg;
      case "image/webp":
        return ImageFmt.webp;
      case "image/png":
        return ImageFmt.png;
      case "image/gif":
        return ImageFmt.gif;
      default:
        return null;
    }
  }
}

Future<void> copyImageToClipboard(Uint8List data, ImageFmt fmt) async {
  if (isAndroid) {
    return await platformClipboard.copyImageToClipboard(fmt.toMimeType(), data);
  }
  final item = DataWriterItem();
  if (!kIsWeb) {
    item.add(fmt == ImageFmt.jpg
        ? Formats.jpeg(data)
        : fmt == ImageFmt.gif
            ? Formats.gif(data)
            : fmt == ImageFmt.png
                ? Formats.png(data)
                : Formats.webp(data));
  } else {
    item.add(fmt == ImageFmt.gif
        ? Formats.gif(data)
        : Formats.png(fmt == ImageFmt.jpg
            ? await jpgToPng(data)
            : fmt == ImageFmt.webp
                ? await webpToPng(data)
                : data));
  }
  await SystemClipboard.instance!.write([item]);
}

Future<void> copyTextToClipboard(String text) async {
  final item = DataWriterItem();
  item.add(Formats.plainText(text));
  await SystemClipboard.instance!.write([item]);
}
