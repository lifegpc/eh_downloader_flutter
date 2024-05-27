import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:web/web.dart';
import 'web/indexed_db.dart';

final _log = Logger("ImageCachesWeb");

class ImageCaches {
  late Cache cache;
  ImageCaches();
  int _size = 0;
  int get size => _size;
  late IndexedDb _db;
  bool _inited = false;
  Future<void> _updateSize() async {
    int total = 0;
    await _db.openCursor("images", (cur) {
      final v = cur.value as JSObject;
      final size = v.getProperty("size".toJS) as JSNumber;
      total += size.toDartInt;
      cur.continue_();
    });
    _size = total;
  }

  Future<void> _removeUnexist() async {
    final urls = (await _db.getAllKeys("images"))
        .toDart
        .map((e) => (e as JSString).toDart)
        .toList();
    for (final uri in urls) {
      final init = RequestInit(credentials: 'include');
      final req = Request(URL(uri), init);
      final opts = CacheQueryOptions(ignoreVary: true);
      final re = await cache.match(req, opts).toDart;
      if (re == null) await _db.delete("images", uri.toJS);
    }
  }

  Future<void> init() async {
    cache = await window.caches.open("image_caches").toDart;
    _db = IndexedDb("image_caches", (event, db) {
      _log.info(
          "upgrade image_caches from ${event.oldVersion} to ${event.newVersion}");
      if (event.oldVersion.isNaN || event.oldVersion < 1) {
        final opts = IDBObjectStoreParameters(keyPath: 'url'.toJS);
        db.createObjectStore('images', opts);
      }
    }, 1);
    await _db.init();
    await _updateSize();
    _inited = true;
  }

  Future<(Uint8List, Map<String, List<String>>, String?)?> getCache(
      String uri) async {
    if (!_inited) return null;
    final init = RequestInit(credentials: 'include');
    final req = Request(URL(uri), init);
    final opts = CacheQueryOptions(ignoreVary: true);
    final re = await cache.match(req, opts).toDart;
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
    final lastUsed = DateTime.now().millisecondsSinceEpoch;
    try {
      final data = await _db.get("images", uri.toJS) as JSObject?;
      if (data != null) {
        data!.setProperty("last_used".toJS, lastUsed.toJS);
        await _db.put("images", data!);
      } else {
        _log.info("Can not find record for $uri in database.");
      }
    } catch (e) {
      _log.warning("Failed to set last_used to $lastUsed for $uri: $e");
    }
    return (buffer.asUint8List(), h, null);
  }

  Future<void> putCache(String uri, Uint8List data,
      Map<String, List<String>> headers, String? realUri) async {
    if (!_inited) return;
    final he = JSObject();
    for (final e in headers.entries) {
      he.setProperty(e.key.toJS, e.value.map((e) => e.toJS).toList().toJS);
    }
    final opts = ResponseInit(status: 200, statusText: 'OK', headers: he);
    final lastUsed = DateTime.now().millisecondsSinceEpoch;
    final res = Response(data.toJS, opts);
    await cache.put(uri.toJS, res).toDart;
    final oObj = (await _db.get("images", uri.toJS)) as JSObject?;
    final obj = JSObject();
    obj.setProperty("url".toJS, uri.toJS);
    obj.setProperty("size".toJS, data.length.toJS);
    obj.setProperty("last_used".toJS, lastUsed.toJS);
    await _db.put("images", obj);
    if (oObj == null) {
      _size += data.length;
    } else {
      final originalSize =
          (oObj!.getProperty("size".toJS) as JSNumber).toDartInt;
      _size += (data.length - originalSize);
    }
  }

  Future<void> updateSize({bool clear = false}) async {
    if (!_inited) return;
    if (clear) await _removeUnexist();
    await _updateSize();
  }

  Future<void> clear() async {
    if (!_inited) return;
    await _db.openKeyCursor("images", (cur) {
      final uri = (cur.key as JSString).toDart;
      final init = RequestInit(credentials: 'include');
      final req = Request(URL(uri), init);
      final opts = CacheQueryOptions(ignoreVary: true);
      cache.delete(req, opts);
      cur.continue_();
    });
    await _db.clear("images");
    _size = 0;
  }
}
