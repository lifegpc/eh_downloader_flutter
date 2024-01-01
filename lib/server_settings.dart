import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'api/config.dart';
import 'globals.dart';

final _log = Logger("ServerSettingsPage");

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({Key? key}) : super(key: key);
  static get routeName => "/server_settings";

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPage();
}

class _ServerSettingsPage extends State<ServerSettingsPage>
    with IsTopWidget2, ThemeModeWidget {
  final _formKey = GlobalKey<FormState>();
  late bool _isLoading;
  late bool _isSaving;
  late bool _changed;
  late ScrollController _controller;
  late ConfigOptional _now;
  Config? _config;
  Object? _error;
  CancelToken? _cancel;
  CancelToken? _saveCancel;

  Future<void> _fetchData() async {
    _cancel = CancelToken();
    try {
      final config = await api.getConfig(cancel: _cancel);
      if (!_cancel!.isCancelled) {
        setState(() {
          _config = config;
          _error = null;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.warning("Error when fetching config:", e);
        setState(() {
          _error = e;
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_isSaving) return;
    try {
      _saveCancel = CancelToken();
      setState(() {
        _isSaving = true;
      });
      await api.updateConfig(_now, cancel: _saveCancel);
      if (!_saveCancel!.isCancelled) {
        setState(() {
          _isSaving = false;
          _now = ConfigOptional();
          _changed = false;
          _config = null;
        });
      }
    } catch (e) {
      if (!_saveCancel!.isCancelled) {
        _log.warning("Error when saving config:", e);
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _isSaving = false;
    _changed = false;
    _controller = ScrollController();
    _now = ConfigOptional();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _formKey.currentState?.dispose();
    _controller.dispose();
    _saveCancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    final isLoading = _config == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    if (isTop(context)) {
      setCurrentTitle(i18n.serverSettings, cs.primary.value);
    }
    return Scaffold(
        appBar: isLoading
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
                  },
                ),
                title: Text(i18n.serverSettings),
                actions: [
                    buildThemeModeIcon(context),
                    buildMoreVertSettingsButon(context),
                  ])
            : null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SelectableText("Error $_error"),
                        ElevatedButton.icon(
                            onPressed: () {
                              _fetchData();
                              setState(() {
                                _error = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context)!.retry))
                      ]))
                : _buildForm(context));
  }

  Widget _buildForm(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go("/");
                  },
                ),
                title: Text(i18n.serverSettings),
                actions: [
                  buildThemeModeIcon(context),
                  buildMoreVertSettingsButon(context),
                ]),
            SliverList(
                delegate: SliverChildListDelegate([
              _buildCheckBox(context),
              _buildBottomBar(context),
            ])),
          ],
        ));
  }

  Widget _buildWithHorizontalPadding(BuildContext context, Widget child) {
    return Container(
      padding: MediaQuery.of(context).size.width > 810
          ? const EdgeInsets.symmetric(horizontal: 100)
          : null,
      child: child,
    );
  }

  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _buildCheckBox(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return _buildWithHorizontalPadding(
        context,
        Column(mainAxisSize: MainAxisSize.min, children: [
          _buildWithVecticalPadding(CheckboxMenuButton(
              value: _now.ex ?? _config!.ex,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.ex = b;
                    _changed = true;
                  });
                }
              },
              child: Text(i18n.useEx))),
          _buildWithVecticalPadding(CheckboxMenuButton(
              value: _now.mpv ?? _config!.mpv,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.mpv = b;
                    _changed = true;
                  });
                }
              },
              child: Text(i18n.mpv))),
          _buildWithVecticalPadding(CheckboxMenuButton(
              value: _now.downloadOriginalImg ?? _config!.downloadOriginalImg,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.downloadOriginalImg = b;
                    _changed = true;
                  });
                }
              },
              child: Text(i18n.downloadOriginalImg))),
          _buildWithVecticalPadding(CheckboxMenuButton(
              value: _now.exportZipJpnTitle ?? _config!.exportZipJpnTitle,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.exportZipJpnTitle = b;
                    _changed = true;
                  });
                }
              },
              child: Text(i18n.exportZipJpnTitle))),
          _buildWithVecticalPadding(CheckboxMenuButton(
              value:
                  _now.removePreviousGallery ?? _config!.removePreviousGallery,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.removePreviousGallery = b;
                    _changed = true;
                  });
                }
              },
              child: Text(i18n.removePreviousGallery))),
        ]));
  }

  Widget _buildBottomBar(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return _buildWithHorizontalPadding(
        context,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildWithVecticalPadding(ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(i18n.save),
                onPressed: _changed
                    ? () {
                        _saveConfig();
                      }
                    : null)),
          ],
        ));
  }
}
