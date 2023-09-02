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
    if (!auth.isAuthed) {
      auth.checkAuth().then((re) {
        if (!re) {
          if (auth.status!.noUser &&
              prefs.getBool("skipCreateRootUser") == true) return;
          context.push(auth.status!.noUser ? "/create_root_user" : "/login");
        }
      }).catchError((err) {
        _log.log(Level.SEVERE, "Failed to check auth info:", err);
      });
    }
    var mode = useState(MainApp.of(context).themeMode);
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
      body: const Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
