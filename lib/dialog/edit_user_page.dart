import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/user.dart';
import '../components/labeled_checkbox.dart';
import '../components/user_permissions_chips.dart';
import '../globals.dart';

final _log = Logger("EditUserPage");

class EditUserPageExtra {
  const EditUserPageExtra({this.user});
  final BUser? user;
}

class EditUserPage extends StatefulWidget {
  const EditUserPage(this.uid, {super.key, this.user});
  final int uid;
  final BUser? user;

  static const routeName = "/dialog/user/edit/:uid";

  @override
  State<StatefulWidget> createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  BUser? _user;
  CancelToken? _fetchCancel;
  CancelToken? _requestCancel;
  bool _isLoading = false;
  bool _isRequesting = false;
  Object? _error;
  String? _username;
  String? _password;
  bool? _isAdmin;
  bool _revokeToken = false;
  bool _passwordVisible = false;
  UserPermissions? _permissions;
  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  @override
  void initState() {
    _user = widget.user;
    super.initState();
  }

  @override
  void dispose() {
    _fetchCancel?.cancel();
    _requestCancel?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      _fetchCancel = CancelToken();
      _isLoading = true;
      final user =
          (await api.getUser(id: widget.uid, cancel: _fetchCancel)).unwrap();
      if (!_fetchCancel!.isCancelled) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_fetchCancel!.isCancelled) {
        _log.severe("Failed to load user ${widget.uid}: $e");
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _request() async {
    setState(() {
      _isRequesting = true;
    });
    try {
      _requestCancel = CancelToken();
      // 关闭对话框不中断连接
      final user = (await api.updateUser(
              id: widget.uid,
              username: _username,
              password: _password,
              isAdmin: _isAdmin,
              revokeToken: _revokeToken,
              permissions: _permissions?.code))
          .unwrap();
      if (!_requestCancel!.isCancelled) {
        setState(() {
          _isRequesting = false;
          _user = user;
          _username = null;
          _password = null;
          _isAdmin = null;
          _revokeToken = false;
          _permissions = null;
        });
      }
      listener.tryEmit("update_user", user);
    } catch (e) {
      _log.severe("Failed to update user ${widget.uid}: $e");
      if (!_requestCancel!.isCancelled) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
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
    if (_user != null && _user!.isAdmin && auth.isRoot == false) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/users");
      });
      return Container();
    }
    final isLoading = _user == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: maxWidth < 400
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
          : const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      width: maxWidth < 810 ? null : 800,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: $_error"),
                    ElevatedButton.icon(
                        onPressed: () {
                          _fetchData();
                          setState(() {
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(i18n.retry)),
                  ],
                ))
              : SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  i18n.editUser,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
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
                              initialValue: _username ?? _user?.username,
                              onChanged: (value) {
                                setState(() {
                                  _username =
                                      value.isEmpty || value == _user!.username
                                          ? null
                                          : value;
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
                              onChanged: (value) {
                                setState(() {
                                  _password = value.isEmpty ? null : value;
                                });
                              },
                              obscureText: !_passwordVisible,
                            )),
                            auth.isRoot == true && widget.uid != 0
                                ? _buildWithVecticalPadding(LabeledCheckbox(
                                    value: _isAdmin ?? _user!.isAdmin,
                                    onChanged: (b) {
                                      if (b != null) {
                                        setState(() {
                                          _isAdmin =
                                              b == _user!.isAdmin ? null : b;
                                        });
                                      }
                                    },
                                    label: Text(i18n.admin)))
                                : Container(),
                            _isAdmin == false ||
                                    (_isAdmin == null && !_user!.isAdmin)
                                ? _buildWithVecticalPadding(
                                    UserPermissionsChips(
                                        permissions: _permissions ??
                                            UserPermissions(
                                                _user!.permissions.code),
                                        onChanged: (v) {
                                          setState(() {
                                            _permissions = v.code ==
                                                    _user!.permissions.code
                                                ? null
                                                : v;
                                          });
                                        }))
                                : Container(),
                            _buildWithVecticalPadding(LabeledCheckbox(
                                value: _revokeToken,
                                onChanged: (b) {
                                  if (b != null) {
                                    setState(() {
                                      _revokeToken = b;
                                    });
                                  }
                                },
                                label: Text(i18n.revokeToken))),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: !_isRequesting &&
                                              (_username != null ||
                                                  _password != null ||
                                                  _isAdmin != null ||
                                                  _permissions != null ||
                                                  _revokeToken)
                                          ? () {
                                              _request();
                                            }
                                          : null,
                                      child: Text(i18n.update))
                                ]),
                          ]))),
    );
  }
}
