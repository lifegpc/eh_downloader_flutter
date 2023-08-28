import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';
import 'home.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
  ],
);


void main() async {
  await prepareJar();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
