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
  bool _oriDisplayAd = false;
  Lang _oriLang = Lang.system;
  bool _oriShowNsfw = false;
  bool _oriShowTranslatedTag = false;
  bool _oriUseTitleJpn = false;
  bool _displayAd = false;
  Lang _lang = Lang.system;
  bool _showNsfw = false;
  bool _showTranslatedTag = false;
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
    try {
      _oriShowNsfw = prefs.getBool("showNsfw") ?? false;
      _showNsfw = _oriShowNsfw;
    } catch (e) {
      _log.warning("Failed to get showNsfw:", e);
      _oriShowNsfw = false;
      _showNsfw = false;
    }
    try {
      _oriDisplayAd = prefs.getBool("displayAd") ?? false;
      _displayAd = _oriDisplayAd;
    } catch (e) {
      _log.warning("Failed to get displayAd:", e);
      _oriDisplayAd = false;
      _displayAd = false;
    }
    try {
      _oriShowTranslatedTag = prefs.getBool("showTranslatedTag") ??
          _oriLang.toLocale().languageCode == "zh";
      _showTranslatedTag = _oriShowTranslatedTag;
    } catch (e) {
      _log.warning("Failed to get showTranslatedTag:", e);
      _oriShowTranslatedTag = false;
      _showTranslatedTag = false;
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
      _showNsfw = false;
      _displayAd = false;
      _showTranslatedTag = _oriLang.toLocale().languageCode == "zh";
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
    if (_oriShowNsfw != _showNsfw) {
      if (!await prefs.setBool("showNsfw", _showNsfw)) {
        re = false;
        _log.warning("Failed to save showNsfw.");
      } else {
        _oriShowNsfw = _showNsfw;
      }
    }
    if (_oriDisplayAd != _displayAd) {
      if (!await prefs.setBool("displayAd", _displayAd)) {
        re = false;
        _log.warning("Failed to save displayAd.");
      } else {
        _oriDisplayAd = _displayAd;
      }
    }
    if (_oriShowTranslatedTag != _showTranslatedTag) {
      if (!await prefs.setBool("showTranslatedTag", _showTranslatedTag)) {
        re = false;
        _log.warning("Failed to save showTranslatedTag.");
      } else {
        _oriShowTranslatedTag = _showTranslatedTag;
      }
    }
    return re;
  }

  @override
  Widget build(BuildContext context) {
    setCurrentTitle(AppLocalizations.of(context)!.settings);
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
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CheckboxMenuButton(
                                value: _showNsfw,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    setState(() {
                                      _showNsfw = value;
                                    });
                                  }
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.showNsfw),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CheckboxMenuButton(
                                value: _displayAd,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    setState(() {
                                      _displayAd = value;
                                    });
                                  }
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.displayAd),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CheckboxMenuButton(
                                value: _showTranslatedTag,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    setState(() {
                                      _showTranslatedTag = value;
                                    });
                                  }
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .showTranslatedTag),
                              ),
                            ),
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
