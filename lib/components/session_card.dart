import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import '../api/token.dart';
import '../api/user.dart';
import '../globals.dart';
import '../main.dart';

final _log = Logger("SessionCard");

Future<void> _deleteSession(int id, String errmsg) async {
  try {
    (await api.deleteTokenById(id)).unwrap();
    listener.tryEmit("delete_session", id);
  } catch (e) {
    _log.severe("Failed to delete session $id: $e");
    final snack = SnackBar(content: Text("$errmsg$e"));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard(this.token, {this.user, super.key});
  final BUser? user;
  final TokenWithoutToken token;
  String get device {
    var s = "";
    if (token.device != null) {
      s = token.device!;
    }
    var c = "";
    if (token.client != null) {
      c = token.client!;
    }
    if (token.clientPlatform != null) {
      if (c.isNotEmpty) {
        c += " ${token.clientPlatform!}";
      }
    }
    if (token.clientVersion != null) {
      if (c.isNotEmpty) {
        c += " ${token.clientVersion!}";
      }
    }
    if (s.isEmpty) {
      s = c;
    } else if (c.isNotEmpty) {
      s = "$s($c)";
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final expiredTime =
        DateFormat.yMd(MainApp.of(context).lang.toLocale().toString())
            .add_jms()
            .format(token.expired.toLocal());
    final lastUsed =
        DateFormat.yMd(MainApp.of(context).lang.toLocale().toString())
            .add_jms()
            .format(token.lastUsed.toLocal());
    return Card.outlined(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText("${i18n.sessionId}${i18n.colon}${token.id}",
                      maxLines: 2, minLines: 1),
                  SelectableText("${i18n.expireTime}${i18n.colon}$expiredTime",
                      maxLines: 2, minLines: 1),
                  SelectableText("${i18n.lastUsedTime}${i18n.colon}$lastUsed",
                      maxLines: 2, minLines: 1),
                  device.isEmpty
                      ? Container()
                      : SelectableText("${i18n.device}${i18n.colon}$device",
                          maxLines: 2, minLines: 1),
                  user != null
                      ? SelectableText(
                          "${i18n.username}${i18n.colon}${user!.username}",
                          maxLines: 2,
                          minLines: 1)
                      : Container(),
                ],
              )),
              IconButton(
                  onPressed: token.id != auth.token?.id
                      ? () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text(i18n.deleteSession),
                                content: Text(user != null
                                    ? i18n.deleteSessionForUserConfirm(
                                        user!.username)
                                    : i18n.deleteSessionConfirm),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        _deleteSession(
                                            token.id, i18n.failedDeleteSession);
                                        context.pop();
                                      },
                                      child: Text(i18n.yes)),
                                  TextButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                      child: Text(i18n.no)),
                                ]);
                          })
                      : null,
                  tooltip: i18n.delete,
                  icon: const Icon(Icons.delete))
            ])));
  }
}
