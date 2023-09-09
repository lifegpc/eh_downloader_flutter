import 'package:flutter/services.dart';

class Clipboard {
  final MethodChannel _clipboardChannel =
      const MethodChannel("lifegpc.eh_downloader_flutter/clipboard");

  Future<void> copyImageToClipboard(String mimeType, Uint8List bytes) async {
    return _clipboardChannel
        .invokeMethod("copyImageToClipboard", [mimeType, bytes]);
  }
}
