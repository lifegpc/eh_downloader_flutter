import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      String? baseUrl = prefs.getString("baseUrl");
      if (baseUrl == null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.go("/set_server");
        });
        return;
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
