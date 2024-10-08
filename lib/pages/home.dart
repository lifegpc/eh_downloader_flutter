import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../globals.dart';
import '../main.dart';

final _log = Logger("HomePage");

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return Drawer(
        child: ListView(
      children: <Widget>[
        Row(
          children: [
            Expanded(child: Container()),
            IconButton(
                onPressed: () => Scaffold.of(context).closeDrawer(),
                icon: const Icon(Icons.close))
          ],
        ),
        ListTile(
          leading: const Icon(Icons.collections),
          title: Text(i18n.galleries),
          onTap: () {
            Scaffold.of(context).closeDrawer();
            context.push("/galleries");
          },
        ),
        auth.canManageTasks == true
            ? ListTile(
                leading: const Icon(Icons.task),
                title: Text(i18n.taskManager),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  context.push("/task_manager");
                },
              )
            : Container(),
        auth.isAdmin == true
            ? ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: Text(i18n.userManagemant),
                onTap: () {
                  Scaffold.of(context).closeDrawer();
                  context.push("/users");
                })
            : Container(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(AppLocalizations.of(context)!.settings),
          onTap: () {
            Scaffold.of(context).closeDrawer();
            context.push("/settings");
          },
        )
      ],
    ));
  }
}

class HomePage extends HookWidget with IsTopWidget {
  const HomePage({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    var mode = useState(MainApp.of(context).themeMode);
    mode.value = MainApp.of(context).themeMode;
    if (isTop(context)) {
      setCurrentTitle("", Theme.of(context).primaryColor.value,
          usePrefix: true);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleBar),
        actions: [
          IconButton(
              onPressed: () {
                final n = themeModeNext(mode.value);
                MainApp.of(context).changeThemeMode(n);
                mode.value = n;
              },
              icon: Icon(mode.value == ThemeMode.system
                  ? Icons.brightness_auto
                  : mode.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode)),
          buildMoreVertSettingsButon(context),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Center(
        child: TextButton(
          child: Text('Hello World!'),
          onPressed: () {
            context.push("/galleries");
          },
        ),
      ),
    );
  }
}
