import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'globals.dart';
import 'main.dart';

final _log = Logger("SettingsPage");

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> with ThemeModeWidget {
  Lang _oriLang = Lang.system;
  bool _oriUseTitleJpn = false;
  Lang _lang = Lang.system;
  bool _useTitleJpn = false;
  @override
  void initState() {
    super.initState();
    try {
      _oriLang = Lang.values[prefs.getInt("lang") ?? 0];
      _lang = _oriLang;
    } catch (e) {
      _log.warning("Failed to get lang:", e);
      _oriLang = Lang.system;
      _lang = Lang.system;
    }
    try {
      _oriUseTitleJpn = prefs.getBool("useTitleJpn") ?? false;
      _useTitleJpn = _oriUseTitleJpn;
    } catch (e) {
      _log.warning("Failed to get useTitleJpn:", e);
      _oriUseTitleJpn = false;
      _useTitleJpn = false;
    }
  }

  void fallback(BuildContext context) {
    if (_oriLang != _lang) {
      MainApp.of(context).changeLang(_oriLang);
    }
  }

  void reset(BuildContext context) {
    if (_lang != Lang.system) MainApp.of(context).changeLang(Lang.system);
    setState(() {
      _lang = Lang.system;
      _useTitleJpn = false;
    });
  }

  Future<bool> save() async {
    bool re = true;
    if (_lang != _oriLang && !await prefs.setInt("lang", _lang.index)) {
      re = false;
      _log.warning("Failed to save lang.");
    } else {
      _oriLang = _lang;
    }
    if (_oriUseTitleJpn != _useTitleJpn) {
      if (!await prefs.setBool("useTitleJpn", _useTitleJpn)) {
        re = false;
        _log.warning("Failed to save useTitleJpn.");
      } else {
        _oriUseTitleJpn = _useTitleJpn;
      }
    }
    return re;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              fallback(context);
              context.canPop() ? context.pop() : context.go("/");
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(AppLocalizations.of(context)!.settings),
          actions: [
            buildThemeModeIcon(context),
            buildMoreVertSettingsButon(context),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Container(
                        padding: MediaQuery.of(context).size.width > 810
                            ? const EdgeInsets.symmetric(horizontal: 100)
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: DropdownMenu<Lang>(
                                  initialSelection: _lang,
                                  onSelected: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _lang = value;
                                      });
                                      MainApp.of(context).changeLang(_lang);
                                    }
                                  },
                                  label:
                                      Text(AppLocalizations.of(context)!.lang),
                                  dropdownMenuEntries: Lang.values
                                      .map((e) => DropdownMenuEntry(
                                          value: e,
                                          label: e == Lang.system
                                              ? AppLocalizations.of(context)!
                                                  .systemLang
                                              : e.langName))
                                      .toList(),
                                  leadingIcon: const Icon(Icons.language),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: CheckboxMenuButton(
                                  value: _useTitleJpn,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _useTitleJpn = value;
                                      });
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!
                                      .useTitleJpn),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          reset(context);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .reset))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        save();
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.save),
                                    ))
                              ],
                            ),
                          ],
                        ))));
          },
        ));
  }
}
