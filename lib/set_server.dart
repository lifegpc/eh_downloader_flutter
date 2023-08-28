import 'package:flutter/material.dart';

class SetServerPage extends StatefulWidget {
  const SetServerPage({Key? key}) : super(key: key);

  static const String routeName = '/set_server';

  @override
  State<SetServerPage> createState() => _SetServerPageState();
}

class _SetServerPageState extends State<SetServerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('EH Downloader server url:'),
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Server URL',
            ),
          ),
          const Text('API path'),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'API Path',
            ),
            controller: TextEditingController(text: "/api"),
          ),
        ],
      )),
    );
  }
}
