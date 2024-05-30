import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../components/user_permissions_chips.dart';
import '../../globals.dart';

final _log = Logger("UserSettingsPage");

Future<void> _changeUserName(String username, AppLocalizations i18n) async {
  try {
    final user = (await api.changeUserName(username)).unwrap();
    auth.setUpdatedUser(user);
  } catch (e, stack) {
    String errmsg = "${i18n.failedChangeUsername}$e";
    if (e is (int, String)) {
      _log.warning("Failed to change user name: $e");
      if (e.$1 == 4) {
        errmsg = "${i18n.failedChangeUsername}${i18n.usernameIsAlreadyUsed}";
      }
    } else {
      _log.severe("Failed to change user name: $e\n$stack");
    }
    final snack = SnackBar(content: Text(errmsg));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

Future<void> _changeUserPassword(
    String old, String n, AppLocalizations i18n) async {
  try {
    (await api.changeUserPassword(old, n)).unwrap();
    final snack = SnackBar(content: Text(i18n.changedPasswordSuccessfully));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  } catch (e, stack) {
    String errmsg = "${i18n.failedChangePassword}$e";
    if (e is (int, String)) {
      _log.warning("Failed to change password: $e");
      if (e.$1 == 5) {
        errmsg = "${i18n.failedChangePassword}${i18n.incorrectPassword}";
      }
    } else {
      _log.severe("Failed to change password: $e\n$stack");
    }
    final snack = SnackBar(content: Text(errmsg));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

Future<void> _deleteToken(AppLocalizations i18n, GoRouter router) async {
  try {
    (await api.deleteToken()).unwrap();
    clearAllStates2(null, router);
  } catch (e, stack) {
    String errmsg = e.toString();
    if (e is (int, String)) {
      _log.warning("Failed to delete token: $e");
    } else {
      _log.severe("Failed to delete token: $e\n$stack");
    }
    final snack = SnackBar(content: Text("${i18n.failedLogout}$errmsg"));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

class _ChangeUsernameDialog extends StatefulWidget {
  const _ChangeUsernameDialog({this.username});

  final String? username;

  @override
  State<StatefulWidget> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<_ChangeUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _username;

  @override
  void initState() {
    _username = widget.username ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(i18n.changeUsername),
      content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: _username,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.username,
            ),
            onChanged: (s) {
              setState(() {
                _username = s;
              });
            },
          )),
      actions: [
        TextButton(
            onPressed: _username != auth.user!.username && _username.isNotEmpty
                ? () {
                    _changeUserName(_username, i18n);
                    context.pop();
                  }
                : null,
            child: Text(i18n.changeUsername)),
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(i18n.cancel)),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<StatefulWidget> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword = "";
  bool _oldPasswordVisible = false;
  String _newPassword = "";
  bool _newPasswordVisible = false;
  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(i18n.changePassword),
      content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildWithVecticalPadding(TextFormField(
              initialValue: _oldPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.oldPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _oldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _oldPasswordVisible = !_oldPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (s) {
                setState(() {
                  _oldPassword = s;
                });
              },
              obscureText: !_oldPasswordVisible,
            )),
            _buildWithVecticalPadding(TextFormField(
              initialValue: _newPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.newPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _newPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
              onChanged: (s) {
                setState(() {
                  _newPassword = s;
                });
              },
              obscureText: !_newPasswordVisible,
            )),
          ])),
      actions: [
        TextButton(
            onPressed: _oldPassword.isNotEmpty &&
                    _newPassword.isNotEmpty &&
                    _oldPassword != _newPassword
                ? () {
                    _changeUserPassword(_oldPassword, _newPassword, i18n);
                    context.pop();
                  }
                : null,
            child: Text(i18n.changePassword)),
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(i18n.cancel)),
      ],
    );
  }
}

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  static const String routeName = '/settings/user';

  @override
  State<StatefulWidget> createState() => _UserSettingsPage();
}

class _UserSettingsPage extends State<UserSettingsPage> with ThemeModeWidget {
  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  Widget _buildMain(BuildContext context) {
    if (!tryInitApi(context)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!auth.isAuthed) {
      return const Center(child: CircularProgressIndicator());
    }
    final i18n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(
          leading: const Icon(Icons.badge),
          title: Text(i18n.username),
          onTap: () => showDialog(
              context: context,
              builder: (context) =>
                  _ChangeUsernameDialog(username: auth.user!.username)),
          subtitle: Text(auth.user!.username)),
      ListTile(
          leading: const Icon(Icons.password),
          title: Text(i18n.password),
          onTap: () => showDialog(
              context: context,
              builder: (context) => const _ChangePasswordDialog())),
      Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CheckboxMenuButton(
              value: auth.user!.isAdmin,
              onChanged: null,
              child: Text(i18n.admin))),
      Padding(
          padding: const EdgeInsets.only(left: 16),
          child: UserPermissionsChips(
              permissions: auth.user!.permissions, readOnly: true)),
      ListTile(
          leading: const Icon(Icons.logout),
          title: Text(i18n.logout),
          onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(i18n.logout),
                    content: Text(i18n.logoutConfirm),
                    actions: [
                      TextButton(
                          onPressed: () {
                            _deleteToken(i18n, GoRouter.of(context));
                            context.pop();
                          },
                          child: Text(i18n.yes)),
                      TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text(i18n.no)),
                    ],
                  ))),
    ]));
  }

  @override
  void initState() {
    listener.on("user_logined", _onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    listener.removeEventListener("user_logined", _onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    setCurrentTitle("${i18n.settings} - ${i18n.user}",
        Theme.of(context).primaryColor.value);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go("/settings");
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(i18n.user),
        actions: [
          buildThemeModeIcon(context),
          buildMoreVertSettingsButon(context),
        ],
      ),
      body: _buildMain(context),
    );
  }
}
