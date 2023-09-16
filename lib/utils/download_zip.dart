import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../globals.dart';
import '../platform/save_file.dart';
import '../utils.dart';

Future<void> downloadZip(int gid,
    {bool? jpnTitle, int? maxLength, bool? exportAd}) async {
  if (kIsWeb) {
    saveUriWeb(api.exportGalleryZipUrl(gid,
        jpnTitle: jpnTitle, maxLength: maxLength, exportAd: exportAd));
    return;
  }
  final cancel = CancelToken();
  final re = await api.exportGalleryZip(gid,
      jpnTitle: jpnTitle,
      maxLength: maxLength,
      exportAd: exportAd,
      cancel: cancel);
  final data = re.data as ResponseBody;
  if (data.statusCode != 200) {
    throw Exception("${data.statusCode} ${data.statusMessage}.");
  }
  final fileName = re.response.headers.value("content-disposition");
  final filenameWithoutExtension = path.basenameWithoutExtension(
      getFilenameFromContentDisposition(fileName) ?? "$gid");
  try {
    final f = await platformPath.openFile(
        filenameWithoutExtension, "application/zip");
    try {
      await data.stream.forEach((data) {
        f.write(data);
      });
    } finally {
      await f.dispose();
    }
  } catch (e) {
    cancel.cancel();
    rethrow;
  }
}
