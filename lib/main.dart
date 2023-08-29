import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'globals.dart';
import 'home.dart';
import 'set_server.dart';
import 'utils.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: SetServerPage.routeName,
      builder: (context, state) => const SetServerPage(),
    ),
  ],
);

void main() async {
  if (!kIsWeb) await prepareJar();
  await preparePrefs();
  if (isDesktop) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await windowManager.setTitle("E-Hentai Downloader Dashboard");
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (context) {
        final title = AppLocalizations.of(context)!.title;
        if (isDesktop) {
          windowManager.setTitle(title);
        }
        return title;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
