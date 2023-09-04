import 'package:logging/logging.dart';
import 'api/gallery.dart';
import 'globals.dart';

final _log = Logger("TagsInfo");

class TagsInfo {
  TagsInfo();
  List<Tag>? _rows;
  List<Tag>? get rows => _rows;

  void clear() {
    _rows = null;
  }

  Future<bool> getRows() async {
    try {
      _rows = (await api.getRowTags()).unwrap();
      return true;
    } catch (e) {
      _log.warning("Failed to load row tags:", e);
      _rows = null;
      return false;
    }
  }

  String? getTagTranslate(String row) {
    final key = "rows:$row";
    if (_rows == null) return null;
    final tag = _rows!.indexWhere((e) => e.tag == key);
    if (tag == -1) return null;
    return _rows![tag].translated;
  }
}
