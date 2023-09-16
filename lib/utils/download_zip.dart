import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../globals.dart';
import '../platform/save_file.dart';

Future<void> downloadZip(int gid,
    {bool? jpnTitle, int? maxLength, bool? exportAd}) async {
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
  final filenameWithoutExtension = fileName?.substring(
          fileName.indexOf("filename=\"") + 10, fileName.lastIndexOf(".")) ??
      "$gid";
  try {
    final f = await platformPath.openFile(
        Uri.decodeComponent(filenameWithoutExtension), "application/zip");
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
