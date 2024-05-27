import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart';

Future<bool> makeStoragePersist() async {
  final storage = window.navigator.storage;
  bool peristed = (await storage.persisted().toDart).toDart;
  if (!peristed) {
    peristed = (await storage.persist().toDart).toDart;
  }
  return peristed;
}

class IndexedDb {
  late IDBDatabase _db;
  bool _inited = false;
  bool get inited => _inited;
  final String dbName;
  final int? version;
  final void Function(IDBVersionChangeEvent, IDBDatabase) onUpgradeNeeded;
  IndexedDb(this.dbName, this.onUpgradeNeeded, this.version);
  Future<JSAny?> _waitRequest(IDBRequest request) async {
    bool ok = false;
    bool handled = false;
    void onsuccess(Event _) {
      ok = true;
      handled = true;
    }

    void onerror(Event _) {
      handled = true;
    }

    request.onsuccess = onsuccess.toJS;
    request.onerror = onerror.toJS;
    FutureOr<bool> waitResult() {
      if (handled) return ok;
      return Future.delayed(const Duration(milliseconds: 1), waitResult);
    }

    await Future.microtask(waitResult);
    if (ok) {
      return request.result;
    } else {
      _inited = false;
      throw request.error ?? "";
    }
  }

  Future<void> init() async {
    makeStoragePersist();
    final req = version != null
        ? window.indexedDB.open(dbName, version!)
        : window.indexedDB.open(dbName);
    void onupgradeneeded(IDBVersionChangeEvent event) {
      onUpgradeNeeded(event, req.result as IDBDatabase);
    }

    req.onupgradeneeded = onupgradeneeded.toJS;
    bool ok = false;
    bool handled = false;
    void onsuccess(Event _) {
      ok = true;
      handled = true;
    }

    void onerror(Event _) {
      handled = true;
    }

    req.onsuccess = onsuccess.toJS;
    req.onerror = onerror.toJS;
    FutureOr<bool> waitResult() {
      if (handled) return ok;
      return Future.delayed(const Duration(milliseconds: 1), waitResult);
    }

    await Future.microtask(waitResult);
    if (ok) {
      _db = req.result as IDBDatabase;
    } else {
      throw req.error ?? "";
    }
    _inited = true;
  }

  Future<void> clear(String table) async {
    final tx = _db.transaction([table.toJS].toJS, 'readwrite');
    final store = tx.objectStore(table);
    final req = store.clear();
    await _waitRequest(req);
  }

  Future<void> delete(String table, JSAny key) async {
    final tx = _db.transaction([table.toJS].toJS, 'readwrite');
    final store = tx.objectStore(table);
    final req = store.delete(key);
    await _waitRequest(req);
  }

  Future<JSAny?> get(String table, JSAny key) async {
    await init();
    final tx = _db.transaction([table.toJS].toJS, 'readonly');
    final store = tx.objectStore(table);
    final req = store.get(key);
    return await _waitRequest(req);
  }

  Future<JSArray<JSAny?>> getAllKeys(String table,
      {JSAny? query, int? count}) async {
    await init();
    final tx = _db.transaction([table.toJS].toJS, 'readonly');
    final store = tx.objectStore(table);
    final req = query != null && count != null
        ? store.getAllKeys(query, count!)
        : query != null
            ? store.getAllKeys(query)
            : store.getAllKeys();
    final r = await _waitRequest(req);
    return r as JSArray<JSAny?>;
  }

  Future<void> openCursor(
      String table, void Function(IDBCursorWithValue) callback,
      {JSAny? query, String? direction, bool readwrite = false}) async {
    await init();
    final tx = _db.transaction(
        [table.toJS].toJS, readwrite ? 'readwrite' : 'readonly');
    final store = tx.objectStore(table);
    final req = query != null && direction != null
        ? store.openCursor(query, direction!)
        : query != null
            ? store.openCursor(query)
            : store.openCursor();
    bool ok = false;
    bool handled = false;
    void onsuccess(Event _) {
      if (req.result != null) {
        final cursor = req.result as IDBCursorWithValue;
        callback(cursor);
      } else {
        ok = true;
        handled = true;
      }
    }

    void onerror(Event _) {
      handled = true;
    }

    req.onsuccess = onsuccess.toJS;
    req.onerror = onerror.toJS;
    FutureOr<bool> waitResult() {
      if (handled) return ok;
      return Future.delayed(const Duration(milliseconds: 1), waitResult);
    }

    await Future.microtask(waitResult);
  }

  Future<void> openKeyCursor(String table, void Function(IDBCursor) callback,
      {JSAny? query, String? direction, bool readwrite = false}) async {
    await init();
    final tx = _db.transaction(
        [table.toJS].toJS, readwrite ? 'readwrite' : 'readonly');
    final store = tx.objectStore(table);
    final req = query != null && direction != null
        ? store.openKeyCursor(query, direction!)
        : query != null
            ? store.openKeyCursor(query)
            : store.openKeyCursor();
    bool ok = false;
    bool handled = false;
    void onsuccess(Event _) {
      if (req.result != null) {
        final cursor = req.result as IDBCursor;
        callback(cursor);
      } else {
        ok = true;
        handled = true;
      }
    }

    void onerror(Event _) {
      handled = true;
    }

    req.onsuccess = onsuccess.toJS;
    req.onerror = onerror.toJS;
    FutureOr<bool> waitResult() {
      if (handled) return ok;
      return Future.delayed(const Duration(milliseconds: 1), waitResult);
    }

    await Future.microtask(waitResult);
  }

  Future<JSAny?> put(String table, JSAny value, {JSAny? key}) async {
    await init();
    final tx = _db.transaction([table.toJS].toJS, 'readwrite');
    final store = tx.objectStore(table);
    final req = key == null ? store.put(value) : store.put(value, key);
    return await _waitRequest(req);
  }
}
