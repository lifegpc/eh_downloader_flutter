// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

void saveFileWeb(
    Uint8List data, String mimeType, String filenameWithoutExtension) {
  final blob = Blob([data], mimeType);
  final url = Url.createObjectUrlFromBlob(blob);
  final a = document.createElement("a") as AnchorElement;
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
  Url.revokeObjectUrl(url);
}

void saveUriWeb(String uri) {
  final a = document.createElement("a") as AnchorElement;
  a.href = uri;
  a.click();
}
