import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/user.dart';
import '../globals.dart';

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
                  Text(user.isAdmin ? i18n.admin : i18n.user,
                      style: TextStyle(color: cs.secondary))
                ],
              )),
              IconButton(
                  onPressed: () {},
                  tooltip: i18n.edit,
                  icon: const Icon(Icons.edit)),
              !user.isAdmin ||
                      (user.isAdmin && auth.isRoot == true && user.id != 0)
                  ? IconButton(
                      onPressed: () {},
                      tooltip: i18n.delete,
                      icon: const Icon(Icons.delete))
                  : Container(),
            ])));
  }
}
