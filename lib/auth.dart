import 'package:logging/logging.dart';
import 'api/status.dart';
import 'api/user.dart';
import 'globals.dart';

final _log = Logger("AuthInfo");

class AuthInfo {
  AuthInfo();
  BUser? _user;
  BUser? get user => _user;
  ServerStatus? _status;
  ServerStatus? get status => _status;
  bool get isAuthed => (_user != null);
  bool _checked = false;
  bool get checked => _checked;
  bool _isChecking = false;
  bool get isChecking => _isChecking;

  void clear() {
    _user = null;
    _status = null;
    _checked = false;
  }

  Future<void> getServerStatus() async {
    _status = (await api.getStatus()).unwrap();
  }

  Future<bool> checkAuth() async {
    _isChecking = true;
    try {
      final re = await api.getUser();
      if (re.ok) {
        _user = re.data!;
        final u = _user!;
        _log.info(
            "Logged in as ${u.username} (${u.id}). isAdmin: ${u.isAdmin}. permissions: ${u.permissions}");
      } else if (re.status == 401 || re.status == 1 || re.status == 404) {
        _user = null;
      } else {
        _user = null;
        throw re.unwrapErr();
      }
      _checked = true;
      await getServerStatus();
      return re.ok;
    } finally {
      _isChecking = false;
    }
  }
}
