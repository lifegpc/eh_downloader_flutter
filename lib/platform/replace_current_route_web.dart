// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void replaceCurrentRoute(String query) {
  const usePathUrl = bool.fromEnvironment("usePathUrl");
  if (usePathUrl) {
    final q = query.substring(1);
    final base = document.baseUri ?? "/";
    window.history.replaceState(null, "", "$base$q");
  } else {
    window.history.replaceState(null, "", "#$query");
  }
}
