import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../globals.dart';

final _log = Logger("ServerUrlSettingsPage");

class ServerUrlSettingsPage extends StatefulWidget {
  const ServerUrlSettingsPage({super.key});

  static const String routeName = '/settings/server/url';

  @override
  State<ServerUrlSettingsPage> createState() => _ServerUrlSettingsPage();
}

class _ServerUrlSettingsPage extends State<ServerUrlSettingsPage>
    with ThemeModeWidget {
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
        _log.warning("Failed to parse baseUrl:", e);
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
    final i18n = AppLocalizations.of(context)!;
    bool? skipBaseUrl = const bool.fromEnvironment("skipBaseUrl");
    if (skipBaseUrl == true) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/");
      });
    }
    final bool hasBaseUrl = prefs.getString('baseUrl') != null;
    var actions = [
      buildThemeModeIcon(context),
    ];
    if (hasBaseUrl) actions.add(buildMoreVertSettingsButon(context));
    setCurrentTitle("${i18n.settings} - ${i18n.setServerUrl}",
        Theme.of(context).primaryColor.value);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.setServerUrl),
        leading: hasBaseUrl
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.canPop() ? context.pop() : context.go("/settings");
                },
              )
            : null,
        actions: actions,
      ),
      body: Container(
          padding: MediaQuery.of(context).size.width > 810
              ? const EdgeInsets.symmetric(horizontal: 100)
              : null,
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: i18n.serverHost,
                        ),
                        initialValue: _serverUrl,
                        onChanged: _serverUrlChanged,
                      )),
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: i18n.apiPath,
                        ),
                        initialValue: _apiPath,
                        onChanged: _apiPathChanged,
                      )),
                  ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              prefs
                                  .setString('baseUrl', _serverUrl + _apiPath)
                                  .then((re) {
                                if (re) {
                                  tryInitApi(context);
                                  context.canPop()
                                      ? context.pop()
                                      : context.go("/");
                                }
                              });
                            }
                          : null,
                      child: Text(i18n.save)),
                ],
              ))),
    );
  }
}
