import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';

class SetServerPage extends StatefulWidget {
  const SetServerPage({Key? key}) : super(key: key);

  static const String routeName = '/set_server';

  @override
  State<SetServerPage> createState() => _SetServerPageState();
}

class _SetServerPageState extends State<SetServerPage> {
  String _serverUrl = "";
  String _apiPath = "/api/";
  bool _isValid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    String? baseUrl = prefs.getString('baseUrl');
    if (baseUrl != null) {
      try {
        Uri url = Uri.parse(baseUrl);
        _serverUrl = url.origin;
        _apiPath = url.path;
        _isValid = true;
      } catch (e) {
        // Do nothing.
      }
    }
  }

  static bool _checkIsValid(String serverUrl, String apiPath) {
    try {
      Uri url = Uri.parse(serverUrl + apiPath);
      return url.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  void _serverUrlChanged(String value) {
    bool isValid = _checkIsValid(value, _apiPath);
    setState(() {
      _serverUrl = value;
      _isValid = isValid;
    });
  }

  void _apiPathChanged(String value) {
    bool isValid = _checkIsValid(_serverUrl, value);
    setState(() {
      _apiPath = value;
      _isValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'EH Downloader Server URL',
                        ),
                        initialValue: _serverUrl,
                        onChanged: _serverUrlChanged,
                      )),
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'API Path',
                        ),
                        initialValue: _apiPath,
                        onChanged: _apiPathChanged,
                      )),
                  ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              prefs.setString('baseUrl', _serverUrl + _apiPath);
                              context.go('/');
                            }
                          : null,
                      child: const Text("Save")),
                ],
              ))),
    );
  }
}
