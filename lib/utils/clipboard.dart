import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../platform/to_png_none.dart'
    if (dart.library.html) '../platform/to_png.dart';

enum ImageFmt {
  jpg,
  png,
  gif;

  String toMimeType() {
    switch (this) {
      case ImageFmt.jpg:
        return "image/jpeg";
      case ImageFmt.png:
        return "image/png";
      case ImageFmt.gif:
        return "image/gif";
    }
  }
}

Future<void> copyImageToClipboard(Uint8List data, ImageFmt fmt) async {
  final item = DataWriterItem();
  if (!kIsWeb) {
    item.add(fmt == ImageFmt.jpg
        ? Formats.jpeg(data)
        : fmt == ImageFmt.gif
            ? Formats.gif(data)
            : Formats.png(data));
  } else {
    item.add(fmt == ImageFmt.gif
        ? Formats.gif(data)
        : Formats.png(fmt == ImageFmt.jpg ? await jpgToPng(data) : data));
  }
  await ClipboardWriter.instance.write([item]);
}

Future<void> copyTextToClipboard(String text) async {
  final item = DataWriterItem();
  item.add(Formats.plainText(text));
  await ClipboardWriter.instance.write([item]);
}
