import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../components/alert_number_form_dialog.dart';
import '../../globals.dart';

final _log = Logger("SearchSettingsPage");

class SearchSettingsPage extends StatefulWidget {
  const SearchSettingsPage({super.key});

  static const String routeName = '/settings/search';

  @override
  State<StatefulWidget> createState() => _SearchSettingsPage();
}

class _SearchSettingsPage extends State<SearchSettingsPage>
    with ThemeModeWidget, IsTopWidget2 {
  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  @override
  void initState() {
    listener.on("settings_updated", _onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    listener.removeEventListener("settings_updated", _onStateChanged);
    super.dispose();
  }

  Widget _buildMain(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(
        title: Text(i18n.maxSearchSuggestions),
        onTap: () => showDialog(
            context: context,
            builder: (context) => AlertNumberFormDialog("maxSearchSuggestions",
                initial: 100,
                min: 1,
                max: 1000,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: i18n.maxSearchSuggestions,
                ))),
        subtitle:
            Text((prefs.getInt("maxSearchSuggestions") ?? 100).toString()),
      )
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle("${i18n.settings} - ${i18n.search}");
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go("/settings");
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(i18n.search),
        actions: [
          buildThemeModeIcon(context),
          buildMoreVertSettingsButon(context),
        ],
      ),
      body: _buildMain(context),
    );
  }
}
