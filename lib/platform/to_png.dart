import 'dart:typed_data';

import 'package:image/image.dart';

Future<Uint8List> jpgToPng(Uint8List data) async {
  return encodePng(decodeJpg(data)!);
}

Future<Uint8List> webpToPng(Uint8List data) async {
  return encodePng(decodeWebP(data)!);
}
