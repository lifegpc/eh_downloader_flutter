import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _passwordVisible = false;
  bool _isValid = false;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();
    _username = "";
    _password = "";
    _passwordVisible = false;
    _isValid = false;
    _isLogin = false;
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

  static Future<bool> _login(String username, String password) async {
    String baseUrl = api.baseUrl!;
    final u = Uri.parse(baseUrl);
    final re = await api.createToken(
        username: username,
        password: password,
        setCookie: true,
        httpOnly: true,
        secure: u.scheme == 'https');
    return re.ok;
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 100),
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
                            labelText: AppLocalizations.of(context)!.username,
                          ),
                          initialValue: _username,
                          onChanged: _usernameChanged,
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)!.password,
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
                                _login(_username, _password).then((re) {
                                  if (re) {
                                    context.go("/");
                                  } else {
                                    setState(() {
                                      _isLogin = false;
                                    });
                                  }
                                }).catchError((e) {
                                  setState(() {
                                    _isLogin = false;
                                  });
                                });
                              }
                            : null,
                        child: Text(AppLocalizations.of(context)!.login)),
                  ]))),
    );
  }
}
