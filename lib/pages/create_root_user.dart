import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../globals.dart';
import 'login.dart';

final _log = Logger("CreateRootUserPage");

class CreateRootUserPage extends StatefulWidget {
  const CreateRootUserPage({super.key});

  static const String routeName = '/create_root_user';

  @override
  State<CreateRootUserPage> createState() => _CreateRootUserPage();
}

class _CreateRootUserPage extends State<CreateRootUserPage>
    with ThemeModeWidget {
  final _formKey = GlobalKey<FormState>();
  bool _createdUser = false;
  String _username = "";
  String _password = "";
  bool _passwordVisible = false;
  bool _isValid = false;
  bool _skipCreateRootUser = false;
  bool _isCreated = false;

  @override
  void initState() {
    super.initState();
    _createdUser = false;
    _username = "";
    _password = "";
    _passwordVisible = false;
    _isValid = false;
    try {
      _skipCreateRootUser = prefs.getBool("skipCreateRootUser") ?? false;
    } catch (e) {
      _log.warning("Failed to get skipCreateRootUser:", e);
      _skipCreateRootUser = false;
    }
    _isCreated = false;
  }

  Future<bool> _createRootUser(String username, String password) async {
    if (!_createdUser) {
      final re = await api.createUser(username, password);
      if (re.ok) {
        final id = re.unwrap();
        _createdUser = true;
        _log.info("New user's id: $id");
        if (id != 0) {
          _log.warning("The new user is not root user.");
        }
      } else if (re.status == 403 || re.status == 2) {
        final e = re.unwrapErr();
        _log.warning("Failed to create root user:", e);
        return false;
      } else {
        throw re.unwrapErr();
      }
    }
    return await login(username, password);
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

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    var actions = [buildThemeModeIcon(context)];
    if (_skipCreateRootUser) {
      actions.add(buildMoreVertSettingsButon(context));
    }
    return Scaffold(
        appBar: AppBar(
          leading: _skipCreateRootUser
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
                  },
                )
              : null,
          title: Text(AppLocalizations.of(context)!.createRootUser),
          actions: actions,
        ),
        body: Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => {
                            prefs
                                .setBool("skipCreateRootUser", true)
                                .then((re) {
                              if (!re) {
                                _log.warning(
                                    "Failed to set skipCreateRootUser.");
                              } else {
                                context.canPop()
                                    ? context.pop()
                                    : context.go("/");
                              }
                            }).catchError((e) {
                              _log.warning(
                                  "Failed to set skipCreateRootUser:", e);
                            })
                          },
                          child: Text(AppLocalizations.of(context)!.skip),
                        ),
                        ElevatedButton(
                          onPressed: !_isCreated && _isValid
                              ? () {
                                  setState(() {
                                    _isCreated = true;
                                  });
                                  _createRootUser(_username, _password)
                                      .then((re) {
                                    if (re) {
                                      clearAllStates(context);
                                      context.canPop()
                                          ? context.pop()
                                          : context.go("/");
                                    } else {
                                      if (!_createdUser) {
                                        context.canPop()
                                            ? context.pop()
                                            : context.go("/");
                                        return;
                                      }
                                      final snackBar = SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .incorrectUserPassword));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      setState(() {
                                        _isCreated = false;
                                      });
                                    }
                                  }).catchError((e) {
                                    _log.severe(
                                        "Failed to create root user:", e);
                                    final isNetworkError = e is! (int, String);
                                    final snackBar = SnackBar(
                                        content: Text(isNetworkError
                                            ? AppLocalizations.of(context)!
                                                .networkError
                                            : AppLocalizations.of(context)!
                                                .internalError));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    setState(() {
                                      _isCreated = false;
                                    });
                                  });
                                }
                              : null,
                          child: Text(AppLocalizations.of(context)!.create),
                        )
                      ],
                    )
                  ],
                ))));
  }
}
