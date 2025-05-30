import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../globals.dart';
import '../../utils/filesize.dart';

final _log = Logger("CacheSettingsPage");

class CacheSettingsPage extends StatefulWidget {
  const CacheSettingsPage({super.key});

  static const String routeName = '/settings/cache';

  @override
  State<CacheSettingsPage> createState() => _CacheSettingsPage();
}

class _CacheSettingsPage extends State<CacheSettingsPage>
    with ThemeModeWidget, IsTopWidget2 {
  bool _oriEnableImageCache = false;
  bool _enableImageCache = false;
  @override
  void initState() {
    super.initState();
    try {
      _oriEnableImageCache = prefs.getBool("enableImageCache") ?? true;
      _enableImageCache = _oriEnableImageCache;
    } catch (e) {
      _log.warning("Failed to get enableImageCache:", e);
      _oriEnableImageCache = true;
      _enableImageCache = true;
    }
  }

  void fallback(BuildContext context) {}

  void reset(BuildContext context) {
    setState(() {
      _enableImageCache = true;
    });
  }

  Future<bool> save() async {
    bool re = true;
    if (_enableImageCache != _oriEnableImageCache) {
      if (!await prefs.setBool("enableImageCache", _enableImageCache)) {
        re = false;
        _log.warning("Failed to save enableImageCache.");
      } else {
        _oriEnableImageCache = _enableImageCache;
      }
    }
    return re;
  }

  Widget _buildCache(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final text = SelectableText(
        "${i18n.cachedFileSize}${i18n.colon}${getFileSize(imageCaches.size)}");
    final button = ElevatedButton(
        onPressed: () {
          imageCaches.updateSize(clear: true).then((_) {
            setState(() {});
          }).onError((e, _) {
            _log.warning("Failed to update image cache size: $e");
            return null;
          });
        },
        child: Text(i18n.updateFileSize));
    final cButton = Container(
        padding: const EdgeInsets.only(left: 8),
        child: ElevatedButton(
            onPressed: () {
              imageCaches.clear().then((_) {
                setState(() {});
              }).onError((e, _) {
                _log.warning("Failed to clear image cache: $e");
                return null;
              });
            },
            child: Text(i18n.clearCaches)));
    final maxWidth = MediaQuery.of(context).size.width;
    final useTwoLine = maxWidth <= 500 ? true : false;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CheckboxMenuButton(
        value: _enableImageCache,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              _enableImageCache = value;
            });
          }
        },
        child: Text(i18n.enableImageCache),
      ),
      Container(
          padding: const EdgeInsets.only(left: 6, top: 4),
          child: useTwoLine ? text : Row(children: [text, button, cButton])),
      useTwoLine ? Row(children: [button, cButton]) : Container(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle("${i18n.settings} - ${i18n.cache}");
    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              fallback(context);
              context.canPop() ? context.pop() : context.go("/settings");
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(i18n.cache),
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: _buildCache(context),
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
                                        child: Text(i18n.reset))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        save();
                                      },
                                      child: Text(i18n.save),
                                    ))
                              ],
                            ),
                          ],
                        ))));
          },
        ));
  }
}
