import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../globals.dart';
import '../platform/device.dart';

final _log = Logger("LoginPage");

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

Future<bool> login(String username, String password) async {
  String baseUrl = api.baseUrl!;
  final u = Uri.parse(baseUrl);
  _log.info("Secure level: ${u.scheme}");
  final re = await api.createToken(
      username: username,
      password: password,
      setCookie: true,
      httpOnly: true,
      secure: u.scheme == 'https' || u.host == "localhost",
      client: "flutter",
      device: await device,
      clientVersion: await clientVersion,
      clientPlatform: clientPlatform);
  if (re.ok) return true;
  if (re.status == 4) return false;
  throw re.unwrapErr();
}

class _LoginPageState extends State<LoginPage>
    with ThemeModeWidget, IsTopWidget2 {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _passwordVisible = false;
  bool _isValid = false;
  bool _isLogin = false;
  bool _checkAuth = false;
  bool _tryPoped = false;

  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _username = "";
    _password = "";
    _passwordVisible = false;
    _isValid = false;
    _isLogin = false;
    listener.on("user_logined", _onStateChanged);
  }

  @override
  void dispose() {
    listener.removeEventListener("user_logined", _onStateChanged);
    super.dispose();
  }

  static bool _checkIsValid(String username, String password) {
    return (username.isNotEmpty && password.isNotEmpty);
  }

  void _usernameChanged(String value) {
    bool isValid = _checkIsValid(value, _password);
    setState(() {
      _username = value;
      _isValid = isValid;
    });
  }

  void _passwordChanged(String value) {
    bool isValid = _checkIsValid(_username, value);
    setState(() {
      _password = value;
      _isValid = isValid;
    });
  }

  void _passwordVisibleChanged() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _checkStatus(BuildContext build) {
    if (!isTop(context)) return;
    if (auth.isAuthed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        build.go("/");
      });
      return;
    }
    if (!auth.checked) {
      if (_checkAuth) return;
      _checkAuth = true;
      auth.checkAuth().then((re) {
        _checkAuth = false;
        if (re) {
          if (build.mounted) {
            build.go("/");
          } else {
            _log.warning("Context not mounted.");
          }
        }
      }).catchError((e) {
        _log.severe("Failed to check auth info:", e);
        _checkAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    _checkStatus(context);
    if (isTop(context) && auth.user != null && !_tryPoped) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.canPop() ? context.pop() : context.go("/");
      });
      _tryPoped = true;
      return Container();
    }
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.login);
    }
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(i18n.login),
        actions: [
          buildThemeModeIcon(context),
          buildMoreVertSettingsButon(context),
        ],
      ),
      body: PopScope(
          canPop: auth.user != null,
          child: Container(
              padding: MediaQuery.of(context).size.width > 810
                  ? const EdgeInsets.symmetric(horizontal: 100)
                  : null,
              child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: i18n.username,
                              ),
                              initialValue: _username,
                              onChanged: _usernameChanged,
                            )),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: i18n.password,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: _passwordVisibleChanged,
                                ),
                              ),
                              initialValue: _password,
                              onChanged: _passwordChanged,
                              obscureText: !_passwordVisible,
                            )),
                        ElevatedButton(
                            onPressed: _isValid && !_isLogin
                                ? () {
                                    setState(() {
                                      _isLogin = true;
                                    });
                                    login(_username, _password).then((re) {
                                      if (re) {
                                        if (context.mounted) {
                                          clearAllStates(context);
                                          context.canPop()
                                              ? context.pop()
                                              : context.go("/");
                                        } else {
                                          _log.warning("Context not mounted.");
                                        }
                                      } else {
                                        if (context.mounted) {
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  i18n.incorrectUserPassword));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          setState(() {
                                            _isLogin = false;
                                          });
                                        } else {
                                          _log.warning("Context not mounted.");
                                        }
                                      }
                                    }).catchError((e) {
                                      _log.severe("Failed to login:", e);
                                      final isNetworkError =
                                          e is! (int, String);
                                      if (context.mounted) {
                                        final snackBar = SnackBar(
                                            content: Text(isNetworkError
                                                ? i18n.networkError
                                                : i18n.internalError));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        setState(() {
                                          _isLogin = false;
                                        });
                                      } else {
                                        _log.warning("Context not mounted.");
                                      }
                                    });
                                  }
                                : null,
                            child: Text(i18n.login)),
                      ])))),
    );
  }
}
