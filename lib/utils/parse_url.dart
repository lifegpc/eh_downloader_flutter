final _galleryRegex = RegExp(r"(g|mpv)/(\d+)/([^/]+)");

(int, String)? parseGalleryUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }
  final path = uri.path;
  final match = _galleryRegex.firstMatch(path);
  if (match == null) {
    return null;
  }
  final gid = int.parse(match.group(2)!);
  final token = match.group(3)!;
  return (gid, token);
}
