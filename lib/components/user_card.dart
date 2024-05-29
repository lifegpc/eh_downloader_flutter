import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/user.dart';
import '../dialog/edit_user_page.dart';
import '../globals.dart';

final _log = Logger("UserCard");

Future<void> _deleteUser(int id, String errmsg) async {
  try {
    (await api.deleteUser(id: id)).unwrap();
    listener.tryEmit("delete_user", id);
  } catch (e) {
    _log.severe("Failed to delete user $id: $e");
    final snack = SnackBar(content: Text("$errmsg$e"));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

class UserCard extends StatelessWidget {
  const UserCard(this.user, {super.key});
  final BUser user;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Card.outlined(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    user.username,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                  Text(
                      user.id == 0
                          ? i18n.rootUser
                          : user.isAdmin
                              ? i18n.admin
                              : i18n.user,
                      style: TextStyle(color: cs.secondary))
                ],
              )),
              !user.isAdmin || (user.isAdmin && auth.isRoot == true)
                  ? IconButton(
                      onPressed: () {
                        context.push("/dialog/user/edit/${user.id}",
                            extra: EditUserPageExtra(user: user));
                      },
                      tooltip: i18n.edit,
                      icon: const Icon(Icons.edit))
                  : Container(),
              !user.isAdmin ||
                      (user.isAdmin && auth.isRoot == true && user.id != 0)
                  ? IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text(i18n.deleteUser),
                                content:
                                    Text(i18n.deleteUserConfirm(user.username)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        context.pop();
                                        _deleteUser(
                                            user.id, i18n.failedDeleteUser);
                                      },
                                      child: Text(i18n.yes)),
                                  TextButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Text(i18n.no)),
                                ]);
                          }),
                      tooltip: i18n.delete,
                      icon: const Icon(Icons.delete))
                  : Container(),
            ])));
  }
}
