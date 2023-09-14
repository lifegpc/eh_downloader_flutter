import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'globals.dart';
import 'main.dart';

final _log = Logger("HomePage");

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    var mode = useState(MainApp.of(context).themeMode);
    setCurrentTitle("", usePrefix: true);
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
      drawer: Drawer(
          child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Row(
                    children: [
                      Expanded(child: Container()),
                      IconButton(
                          onPressed: () => Scaffold.of(context).closeDrawer(),
                          icon: const Icon(Icons.close))
                    ],
                  );
                }
                if (i == 1) {
                  return ListTile(
                    leading: const Icon(Icons.collections),
                    title: Text(AppLocalizations.of(context)!.galleries),
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      context.push("/galleries");
                    },
                  );
                }
                if (i == 2) {
                  return ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.settings),
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      context.push("/settings");
                    },
                  );
                }
                return Container();
              })),
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
