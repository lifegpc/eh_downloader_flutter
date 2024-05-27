import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart';

void saveFileWeb(
    Uint8List data, String mimeType, String filenameWithoutExtension) {
  final blobOpts = BlobPropertyBag(type: mimeType);
  final blob = Blob([data.toJS].toJS, blobOpts);
  final url = URL.createObjectURL(blob);
  final a = document.createElement("a") as HTMLAnchorElement;
  a.href = url;
  var ext = "";
  switch (mimeType) {
    case "image/jpeg":
      ext = ".jpg";
      break;
    case "image/png":
      ext = ".png";
      break;
    case "image/gif":
      ext = ".gif";
      break;
    default:
      break;
  }
  a.download = "$filenameWithoutExtension$ext";
  a.click();
  URL.revokeObjectURL(url);
}

void saveUriWeb(String uri) {
  final a = document.createElement("a") as HTMLAnchorElement;
  a.href = uri;
  a.click();
}
