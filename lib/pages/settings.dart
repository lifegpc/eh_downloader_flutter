import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>
    with ThemeModeWidget, IsTopWidget2 {
  void _onStateChanged(dynamic _) {
    setState(() {});
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
    tryInitApi(context);
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.settings, Theme.of(context).primaryColor.value);
    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.canPop() ? context.pop() : context.go("/");
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(i18n.settings),
          actions: [
            buildThemeModeIcon(context),
            buildMoreVertSettingsButon(context),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const bool.fromEnvironment("skipBaseUrl") != true
                    ? ListTile(
                        leading: const Icon(Icons.api),
                        title: Text(i18n.setServerUrl),
                        onTap: () {
                          context.push("/settings/server/url");
                        })
                    : Container(),
                auth.isAuthed
                    ? ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: Text(i18n.user),
                        onTap: () {
                          context.push("/settings/user");
                        })
                    : Container(),
                ListTile(
                    leading: const Icon(Icons.display_settings),
                    title: Text(i18n.display),
                    onTap: () {
                      context.push("/settings/display");
                    }),
                ListTile(
                    leading: const Icon(Icons.cached),
                    title: Text(i18n.cache),
                    onTap: () {
                      context.push("/settings/cache");
                    }),
                auth.isAdmin == true
                    ? ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: Text(i18n.server),
                        onTap: () {
                          context.push("/settings/server");
                        },
                      )
                    : Container(),
              ],
            ));
          },
        ));
  }
}
