import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/user.dart';
import '../components/labeled_checkbox.dart';
import '../components/user_permissions_chips.dart';
import '../globals.dart';

final _log = Logger("NewUserPage");

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  static const routeName = "/dialog/user/new";

  @override
  State<StatefulWidget> createState() => _NewUserPage();
}

class _NewUserPage extends State<NewUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool _isAdmin = false;
  UserPermissions _permissions =
      UserPermissions(UserPermission.readGallery.value);
  bool _passwordVisible = false;
  CancelToken? _cancel;
  bool _isRequesting = false;
  int? _newUserId;

  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Future<void> _request() async {
    setState(() {
      _isRequesting = true;
    });
    try {
      _cancel = CancelToken();
      // 关闭对话框不中断连接
      _newUserId = (await api.createUser(_username, _password,
              isAdmin: _isAdmin,
              permissions: _isAdmin ? null : _permissions.code))
          .unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _isRequesting = false;
        });
      }
      listener.tryEmit("new_user", _newUserId);
    } catch (e) {
      _log.severe("Failed to create new user: $e");
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    if (auth.isAdmin == false) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/");
      });
      return Container();
    }
    if (_newUserId != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.canPop() ? context.pop() : context.go("/users");
      });
      return Container();
    }
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: maxWidth < 400
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 5)
          : const EdgeInsets.all(20),
      width: maxWidth < 810 ? null : 800,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        i18n.createNewUser,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go("/users"),
                            icon: const Icon(Icons.close),
                          )),
                    ],
                  ),
                  _buildWithVecticalPadding(TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: i18n.username,
                    ),
                    initialValue: _username,
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                  )),
                  _buildWithVecticalPadding(TextFormField(
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
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    initialValue: _password,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    obscureText: !_passwordVisible,
                  )),
                  _buildWithVecticalPadding(LabeledCheckbox(
                      value: _isAdmin,
                      onChanged: (b) {
                        if (b != null) {
                          setState(() {
                            _isAdmin = b;
                          });
                        }
                      },
                      label: Text(i18n.admin))),
                  !_isAdmin
                      ? _buildWithVecticalPadding(UserPermissionsChips(
                          permissions: _permissions,
                          onChanged: (v) {
                            setState(() {
                              _permissions = v;
                            });
                          }))
                      : Container(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        onPressed: !_isRequesting &&
                                _username.isNotEmpty &&
                                _password.isNotEmpty
                            ? () {
                                _request();
                              }
                            : null,
                        child: Text(i18n.create))
                  ]),
                ],
              ))),
    );
  }
}
