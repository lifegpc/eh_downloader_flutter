import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:web/web.dart';

class ImageCaches {
  Cache? cache;
  ImageCaches();
  int _size = 0;
  int get size => _size;
  Future<void> init() async {
    cache = await window.caches.open("image_caches").toDart;
  }

  Future<(Uint8List, Map<String, List<String>>, String?)?> getCache(
      String uri) async {
    if (cache == null) return null;
    final init = RequestInit(credentials: 'include');
    final req = Request(URL(uri), init);
    final opts = CacheQueryOptions(ignoreVary: true);
    final re = await cache!.match(req, opts).toDart;
    if (re == null || re!.body == null) return null;
    final ab = await re!.arrayBuffer().toDart;
    final buffer = ab.toDart;
    final he = re!.headers;
    final forEach = he.getProperty("forEach".toJS) as JSFunction?;
    Map<String, List<String>> h = {};
    void forE(JSString value, JSString key, Headers headers) {
      h[key.toDart] = value.toDart.split(",");
    }

    forEach?.callAsFunction(he, forE.toJS);
    return (buffer.asUint8List(), h, null);
  }

  Future<void> putCache(String uri, Uint8List data,
      Map<String, List<String>> headers, String? realUri) async {
    if (cache == null) return;
    final he = JSObject();
    for (final e in headers.entries) {
      he.setProperty(e.key.toJS, e.value.map((e) => e.toJS).toList().toJS);
    }
    final opts = ResponseInit(status: 200, statusText: 'OK', headers: he);
    final res = Response(data.toJS, opts);
    await cache!.put(uri.toJS, res).toDart;
  }

  Future<void> updateSize({bool clear = false}) async {}
  Future<void> clear() async {}
}
