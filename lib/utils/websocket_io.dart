import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../globals.dart';

Future<WebSocketChannel> connectWebSocket(Uri uri) async {
  final Map<String, String> headers = {};
  final jar = cookieJar;
  if (jar != null) {
    final nuri =Uri(
      scheme: uri.scheme == "wss" ? "https" : "http",
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      query: uri.query,
    );
    final cookies = await jar.loadForRequest(nuri);
    final list = <String>[];
    for (var cookie in cookies) {
      list.add('${cookie.name}=${cookie.value}');
    }
    headers['cookie'] = list.join('; ');
  }
  return IOWebSocketChannel.connect(uri, headers: headers);
}
