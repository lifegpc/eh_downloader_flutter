import 'package:logging/logging.dart';
import 'api/status.dart';
import 'api/token.dart';
import 'api/user.dart';
import 'globals.dart';
import 'platform/device.dart';

final _log = Logger("AuthInfo");

class AuthInfo {
  AuthInfo();
  BUser? _user;
  BUser? get user => _user;
  ServerStatus? _status;
  ServerStatus? get status => _status;
  Token? _token;
  Token? get token => _token;
  bool get isAuthed => (_user != null);
  bool _checked = false;
  bool get checked => _checked;
  bool _isChecking = false;
  bool get isChecking => _isChecking;
  bool? get isAdmin => _user?.isAdmin;
  bool? get isDocker => _status?.isDocker;

  void clear() {
    _user = null;
    _status = null;
    _checked = false;
  }

  Future<void> getServerStatus() async {
    _status = (await api.getStatus()).unwrap();
  }

  Future<void> checkSessionInfo() async {
    final data = (await api.getToken()).unwrap();
    _token = data.token;
    final d = await device;
    final cv = await clientVersion;
    final cp = clientPlatform;
    String? client;
    String? ed;
    String? ecv;
    String? ecp;
    if (_token!.client != "flutter") {
      client = "flutter";
    }
    if (_token!.device != d) {
      ed = d;
    }
    if (_token!.clientVersion != cv) {
      ecv = cv;
    }
    if (_token!.clientPlatform != cp) {
      ecp = cp;
    }
    if (client != null || ed != null || ecv != null || ecp != null) {
      try {
        final re = await api.updateToken(
            client: client,
            device: ed,
            clientVersion: ecv,
            clientPlatform: ecp);
        _token = re.unwrap();
      } catch (e) {
        _log.warning("Failed to update token:", e);
      }
    }
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
      await checkSessionInfo();
      return re.ok;
    } finally {
      _isChecking = false;
    }
  }
}
