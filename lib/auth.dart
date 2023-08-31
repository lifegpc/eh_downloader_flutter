import 'api/status.dart';
import 'api/user.dart';
import 'globals.dart';

class AuthInfo {
  AuthInfo();
  BUser? _user;
  BUser? get user => _user;
  ServerStatus? _status;
  ServerStatus? get status => _status;
  bool get isAuthed => (_user != null);
  bool _checked = false;
  bool get checked => _checked;

  Future<void> getServerStatus() async {
    _status = (await api.getStatus()).unwrap();
  }

  Future<bool> checkAuth() async {
    final re = await api.getUser();
    if (re.ok) {
      _user = re.data!;
    } else {
      _user = null;
    }
    _checked = true;
    await getServerStatus();
    return re.ok;
  }
}
