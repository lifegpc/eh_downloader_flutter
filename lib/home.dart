import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'globals.dart';

final _log = Logger("HomePage");

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (!tryInitApi(context)) return;
      if (!auth.isAuthed) {
        auth.checkAuth().then((re) {
          if (!re) {
            context.go(auth.status!.noUser ? "/create_root_user" : "/login");
          }
        }).catchError((err) {
          _log.log(Level.SEVERE, "Failed to check auth info:", err);
        });
      }
      return;
    }, []);
    return const Scaffold(
      body: Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
