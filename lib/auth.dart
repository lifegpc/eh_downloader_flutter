import 'package:logging/logging.dart';
import 'package:meilisearch/meilisearch.dart';
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
  bool? get noUser => _status?.noUser;
  SharedToken? _sharedToken;
  SharedToken? get sharedToken => _sharedToken;
  bool get isAuthed => (_user != null);
  bool _checked = false;
  bool get checked => _checked;
  bool _isChecking = false;
  bool get isChecking => _isChecking;
  bool? get isAdmin => _user?.isAdmin;
  bool? get isRoot => _user != null ? _user!.id == 0 : null;
  bool? get isDocker => _status?.isDocker;
  bool? get canReadGallery => noUser == true
      ? true
      : _user?.permissions.has(UserPermission.readGallery);
  bool? get canEditGallery => noUser == true
      ? true
      : _user?.permissions.has(UserPermission.editGallery);
  bool? get canDeleteGallery => noUser == true
      ? true
      : _user?.permissions.has(UserPermission.deleteGallery);
  bool? get canManageTasks => noUser == true
      ? true
      : _user?.permissions.has(UserPermission.manageTasks);
  bool? get canShareGallery =>
      _user?.permissions.has(UserPermission.shareGallery);
  MeilisearchInfo? get meilisearch => _status?.meilisearch;
  MeiliSearchClient? _meiliSearchClient;
  MeiliSearchClient? get meiliSearchClient => _meiliSearchClient;

  void clear() {
    _user = null;
    _status = null;
    _meiliSearchClient = null;
    _token = null;
    _checked = false;
  }

  Future<void> getServerStatus() async {
    _status = (await api.getStatus()).unwrap();
    if (_status?.meilisearch != null) {
      _meiliSearchClient = MeiliSearchClient(
          _status!.meilisearch!.host, _status!.meilisearch!.key);
      listener.tryEmit("meilisearch_enabled", null);
    }
  }

  Future<void> checkSessionInfo() async {
    final data = (await api.getToken()).unwrap();
    _token = data.token;
    listener.tryEmit("auth_token_updated", null);
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
        listener.tryEmit("auth_token_updated", null);
      } catch (e) {
        _log.warning("Failed to update token:", e);
      }
    }
  }

  Future<bool> checkAuth() async {
    _isChecking = true;
    if (shareToken != null) {
      try {
        final re = await api.getSharedToken();
        if (re.ok) {
          _sharedToken = re.unwrap();
          _checked = true;
          await getServerStatus();
          return true;
        } else {
          shareToken = null;
        }
      } catch (e) {
        _log.warning("Failed to check shareToken.", e);
      }
    }
    try {
      final re = await api.getUser();
      if (re.ok) {
        _user = re.data!;
        final u = _user!;
        _log.info(
            "Logged in as ${u.username} (${u.id}). isAdmin: ${u.isAdmin}. permissions: ${u.permissions}");
        listener.tryEmit("user_logined", null);
        await checkSessionInfo();
        if (canManageTasks == true) {
          if (!tasks.inited) tasks.init();
          await tasks.connect();
        }
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

  void setUpdatedUser(BUser u) {
    _user = u;
    _log.info(
        "User updated: ${u.username} (${u.id}), isAdmin: ${u.isAdmin}. permissions: ${u.permissions}");
    listener.tryEmit("user_logined", null);
  }
}
