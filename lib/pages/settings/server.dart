import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../../api/config.dart';
import '../../components/labeled_checkbox.dart';
import '../../components/number_field.dart';
import '../../components/string_list_field.dart';
import '../../components/string_map_field.dart';
import '../../globals.dart';
import '../../platform/ua.dart';

final _log = Logger("ServerSettingsPage");

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});
  static get routeName => "/settings/server";

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
  late TextEditingController _uaController;
  late AppLocalizations i18n;

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
      _now.corsCredentialsHosts?.removeWhere((e) => e.isEmpty);
      _now.meiliHosts?.removeWhere((k, v) => k.isEmpty || v.isEmpty);
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
    if (kIsWeb) {
      _uaController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    _formKey.currentState?.dispose();
    _controller.dispose();
    _saveCancel?.cancel();
    if (kIsWeb) {
      _uaController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!tryInitApi(context)) {
      return Container();
    }
    this.i18n = AppLocalizations.of(context)!;
    final isLoading = _config == null && _error == null;
    if (isLoading && !_isLoading) _fetchData();
    final i18n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    if (isTop(context)) {
      setCurrentTitle("${i18n.settings} - ${i18n.server}", cs.primary.value);
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
                title: Text(i18n.server),
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

  String? urlOriginValidator(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final u = Uri.parse(s);
      if (u.hasQuery ||
          u.userInfo.isNotEmpty ||
          u.hasFragment ||
          !u.hasEmptyPath ||
          !u.hasScheme) return i18n.invalidURLOrigin;
      if (u.scheme != "http" && u.scheme != "https") {
        return i18n.httpHttpsNeeded;
      }
      return null;
    } catch (e) {
      return i18n.invalidURL;
    }
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
                title: Text(i18n.server),
                actions: [
                  buildThemeModeIcon(context),
                  buildMoreVertSettingsButon(context),
                ],
                floating: true),
            SliverList(
                delegate: SliverChildListDelegate([
              _buildCheckBox(context),
              _buildTextBox(context),
              _buildBottomBar(context),
            ])),
          ],
        ));
  }

  Widget _buildWithHorizontalPadding(BuildContext context, Widget child) {
    return Container(
      padding: MediaQuery.of(context).size.width > 810
          ? const EdgeInsets.symmetric(horizontal: 100)
          : const EdgeInsets.symmetric(horizontal: 16),
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
          _buildWithVecticalPadding(LabeledCheckbox(
              value: _now.ex ?? _config!.ex,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.ex = b;
                    _changed = true;
                  });
                }
              },
              label: Text(i18n.useEx))),
          _buildWithVecticalPadding(LabeledCheckbox(
              value: _now.mpv ?? _config!.mpv,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.mpv = b;
                    _changed = true;
                  });
                }
              },
              label: Text(i18n.mpv))),
          _buildWithVecticalPadding(LabeledCheckbox(
              value: _now.downloadOriginalImg ?? _config!.downloadOriginalImg,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.downloadOriginalImg = b;
                    _changed = true;
                  });
                }
              },
              label: Text(i18n.downloadOriginalImg))),
          _buildWithVecticalPadding(LabeledCheckbox(
              value: _now.exportZipJpnTitle ?? _config!.exportZipJpnTitle,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.exportZipJpnTitle = b;
                    _changed = true;
                  });
                }
              },
              label: Text(i18n.exportZipJpnTitle))),
          _buildWithVecticalPadding(LabeledCheckbox(
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
              label: Text(i18n.removePreviousGallery))),
          _buildWithVecticalPadding(LabeledCheckbox(
              value: _now.redirectToFlutter ?? _config!.redirectToFlutter,
              onChanged: (b) {
                if (b != null) {
                  setState(() {
                    _now.redirectToFlutter = b;
                    _changed = true;
                  });
                }
              },
              label: Text(i18n.redirectToFlutter))),
        ]));
  }

  Widget _buildTextBox(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      final t = _now.ua ?? _config!.ua ?? "";
      if (_uaController.text != t) {
        _uaController.text = t;
      }
    }
    return _buildWithHorizontalPadding(
        context,
        Column(mainAxisSize: MainAxisSize.min, children: [
          _buildWithVecticalPadding(TextFormField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText:
                  _config!.cookies ? i18n.enterNewCookies : i18n.enterCookies,
            ),
            onChanged: (s) {
              setState(() {
                _now.cookies = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
              initialValue: _now.dbPath ?? _config!.dbPath,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.serverDbPath,
                helperText: auth.isDocker == true
                    ? i18n.dockerHelper
                    : i18n.serverDbPathHelp,
              ),
              onChanged: (s) {
                setState(() {
                  _now.dbPath = s;
                  _changed = true;
                });
              })),
          _buildWithVecticalPadding(TextFormField(
              initialValue: kIsWeb ? null : _now.ua ?? _config!.ua,
              controller: kIsWeb ? _uaController : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.userAgent,
                counter: kIsWeb
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _now.ua = oUA;
                            _changed = true;
                          });
                        },
                        child: Text(i18n.useBrowserUA))
                    : null,
              ),
              onChanged: (s) {
                setState(() {
                  _now.ua = s;
                  _changed = true;
                });
              })),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.base ?? _config!.base,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.downloadLocation,
              helperText: auth.isDocker == true ? i18n.dockerHelper : null,
            ),
            onChanged: (s) {
              setState(() {
                _now.base = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue: _now.maxTaskCount ?? _config!.maxTaskCount,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.maxTaskCount,
            ),
            onChanged: (s) {
              if (s != null) {
                setState(() {
                  _now.maxTaskCount = s;
                  _changed = true;
                });
              }
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue: _now.maxRetryCount ?? _config!.maxRetryCount,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.maxRetryCount,
            ),
            onChanged: (s) {
              if (s != null) {
                setState(() {
                  _now.maxRetryCount = s;
                  _changed = true;
                });
              }
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue:
                _now.maxDownloadImgCount ?? _config!.maxDownloadImgCount,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.maxDownloadImgCount,
            ),
            onChanged: (s) {
              if (s != null) {
                setState(() {
                  _now.maxDownloadImgCount = s;
                  _changed = true;
                });
              }
            },
          )),
          auth.isDocker == true
              ? Container()
              : _buildWithVecticalPadding(NumberFormField(
                  min: 0,
                  max: 65535,
                  initialValue: _now.port ?? _config!.port,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: i18n.listeningPort,
                  ),
                  onChanged: (s) {
                    if (s != null) {
                      setState(() {
                        _now.port = s;
                        _changed = true;
                      });
                    }
                  },
                )),
          auth.isDocker == true
              ? Container()
              : _buildWithVecticalPadding(TextFormField(
                  initialValue: _now.hostname ?? _config!.hostname,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: i18n.listeningHostname,
                  ),
                  onChanged: (s) {
                    setState(() {
                      _now.hostname = s;
                      _changed = true;
                    });
                  },
                )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.meiliHost ?? _config!.meiliHost,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.meiliHost,
            ),
            onChanged: (s) {
              setState(() {
                _now.meiliHost = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.meiliSearchApiKey ?? _config!.meiliSearchApiKey,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.meiliSearchApiKey,
            ),
            onChanged: (s) {
              setState(() {
                _now.meiliSearchApiKey = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.meiliUpdateApiKey ?? _config!.meiliUpdateApiKey,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.meiliUpdateApiKey,
            ),
            onChanged: (s) {
              setState(() {
                _now.meiliUpdateApiKey = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.ffmpegPath ?? _config!.ffmpegPath,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.ffmpegPath,
              helperText: auth.isDocker == true ? i18n.dockerHelper : null,
            ),
            onChanged: (s) {
              setState(() {
                _now.ffmpegPath = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(DropdownButtonFormField<ThumbnailMethod>(
              items: [
                DropdownMenuItem(
                    value: ThumbnailMethod.ffmpegBinary,
                    child: Text(i18n.thumbnailMethod0)),
                DropdownMenuItem(
                    value: ThumbnailMethod.ffmpegApi,
                    child: Text(i18n.thumbnailMethod1)),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _now.thumbnailMethod = v;
                    _changed = true;
                  });
                }
              },
              value: _now.thumbnailMethod ?? _config!.thumbnailMethod,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.thumbnailMethod,
              ))),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.thumbnailDir ?? _config!.thumbnailDir,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.thumbnailDir,
              helperText: auth.isDocker == true ? i18n.dockerHelper : null,
            ),
            onChanged: (s) {
              setState(() {
                _now.thumbnailDir = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.imgVerifySecret ?? _config!.imgVerifySecret,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.imgVerifySecret,
            ),
            onChanged: (s) {
              setState(() {
                _now.imgVerifySecret = s;
                _changed = true;
              });
            },
          )),
          StringMapFormField(
            key: const ValueKey("meiliHosts"),
            initialValue: _now.meiliHosts ?? _config!.meiliHosts,
            keyDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            valueDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            keyPadding: const EdgeInsets.only(right: 4),
            valuePadding: const EdgeInsets.only(left: 4),
            onChanged: (s) {
              setState(() {
                _now.meiliHosts = s;
                _changed = true;
              });
            },
            keyValidator: urlOriginValidator,
            valueValidator: urlOriginValidator,
            keyAutovalidateMode: AutovalidateMode.onUserInteraction,
            valueAutovalidateMode: AutovalidateMode.onUserInteraction,
            label: Text(i18n.meiliHosts),
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            helper: Text(i18n.meiliHostsHelp,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          StringListFormField(
            key: const ValueKey("corsCredentialsHosts"),
            initialValue:
                _now.corsCredentialsHosts ?? _config!.corsCredentialsHosts,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: i18n.corsCredentialsHostsHint,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            onChanged: (s) {
              setState(() {
                _now.corsCredentialsHosts = s;
                _changed = true;
              });
            },
            validator: urlOriginValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            label: Text(i18n.corsCredentialsHosts),
            constraints: const BoxConstraints(
              maxHeight: 300,
            ),
            helper: Text(i18n.corsCredentialsHostsHelp,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red)),
          ),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.flutterFrontend ?? _config!.flutterFrontend,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.flutterFrontend,
              helperText: auth.isDocker == true ? i18n.dockerHelper : null,
            ),
            onChanged: (s) {
              setState(() {
                _now.flutterFrontend = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue: _now.fetchTimeout ?? _config!.fetchTimeout,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.fetchTimeout,
              suffixText: i18n.millisecond,
            ),
            onChanged: (s) {
              setState(() {
                _now.fetchTimeout = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue: _now.downloadTimeout ?? _config!.downloadTimeout,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.downloadTimeout,
              suffixText: i18n.millisecond,
              helperText: i18n.downloadTimeoutHelp,
              helperMaxLines: 3,
            ),
            onChanged: (s) {
              setState(() {
                _now.downloadTimeout = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.ffprobePath ?? _config!.ffprobePath,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.ffprobePath,
            ),
            onChanged: (s) {
              setState(() {
                _now.ffprobePath = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue: _now.downloadTimeoutCheckInterval ??
                _config!.downloadTimeoutCheckInterval,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.downloadTimeoutCheckInterval,
              suffixText: i18n.millisecond,
              helperText: i18n.downloadTimeoutCheckIntervalHelp,
              helperMaxLines: 3,
            ),
            onChanged: (s) {
              setState(() {
                _now.downloadTimeoutCheckInterval = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(NumberFormField(
            min: 1,
            initialValue:
                _now.ehMetadataCacheTime ?? _config!.ehMetadataCacheTime,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.ehMetadataCacheTime,
              suffixText: i18n.hour,
            ),
            onChanged: (s) {
              setState(() {
                _now.ehMetadataCacheTime = s;
                _changed = true;
              });
            },
          )),
          _buildWithVecticalPadding(TextFormField(
            initialValue: _now.randomFileSecret ?? _config!.randomFileSecret,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: i18n.randomFileSecret,
            ),
            onChanged: (s) {
              setState(() {
                _now.randomFileSecret = s;
                _changed = true;
              });
            },
          )),
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
