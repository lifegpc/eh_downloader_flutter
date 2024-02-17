import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectWebSocket(Uri uri) async {
  return HtmlWebSocketChannel.connect(uri, binaryType: BinaryType.list);
}
