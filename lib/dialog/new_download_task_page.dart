import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/task.dart';
import '../components/labeled_checkbox.dart';
import '../components/number_field.dart';
import '../globals.dart';
import '../utils/parse_url.dart';

final _log = Logger("NewDownloadTaskPage");

class NewDownloadTaskPage extends StatefulWidget {
  const NewDownloadTaskPage({super.key, this.gid, this.token});
  final int? gid;
  final String? token;

  static const routeName = "/dialog/new_download_task";

  @override
  State<NewDownloadTaskPage> createState() => _NewDownloadTaskPage();
}

class _NewDownloadTaskPage extends State<NewDownloadTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _gidController;
  late TextEditingController _tokenController;
  int? _gid;
  String? _token;
  CancelToken? _cancel;
  CancelToken? _cancel2;
  bool _isCreating = false;
  bool _ok = false;
  DownloadConfig? _cfg;
  bool _useCfg = false;
  DownloadConfig? _dftCfg;
  bool _fetched = false;

  @override
  void initState() {
    _urlController = TextEditingController(
        text: widget.gid != null && widget.token != null
            ? "https://e-hentai.org/g/${widget.gid}/${widget.token}/"
            : "");
    _gidController = TextEditingController(text: widget.gid?.toString());
    _tokenController = TextEditingController(text: widget.token);
    _gid = widget.gid;
    _token = widget.token;
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _gidController.dispose();
    _tokenController.dispose();
    _cancel?.cancel();
    _cancel2?.cancel();
    super.dispose();
  }

  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Future<void> create() async {
    if (_gid == null || _token == null || _token!.isEmpty) {
      return;
    }
    try {
      _cancel = CancelToken();
      setState(() {
        _isCreating = true;
      });
      (await api.createDownloadTask(_gid!, _token!,
              cfg: _useCfg ? _cfg : null, cancel: _cancel))
          .unwrap();
      _ok = true;
      if (!_cancel!.isCancelled) {
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.warning("Failed to create download task:", e);
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> fetchDefaultCfg() async {
    _fetched = true;
    try {
      _cancel2 = CancelToken();
      _dftCfg = (await api.getDefaultDownloadConfig(cancel: _cancel2)).unwrap();
    } catch (e) {
      if (!_cancel2!.isCancelled) {
        _log.warning("Failed to fetch default download config:", e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    if (_ok) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        context.canPop() ? context.pop() : context.go("/task_manager");
      });
      _ok = false;
    }
    if (!_fetched) fetchDefaultCfg();
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    return Container(
        padding: maxWidth < 400
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 5)
            : const EdgeInsets.all(20),
        width: maxWidth < 810 ? null : 800,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          i18n.createDownloadTask,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => context.canPop()
                                  ? context.pop()
                                  : context.go("/task_manager"),
                              icon: const Icon(Icons.close),
                            )),
                      ],
                    ),
                    _buildWithVecticalPadding(TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: i18n.galleryURL,
                      ),
                      onChanged: (value) {
                        final match = parseGalleryUrl(value);
                        if (match != null) {
                          setState(() {
                            _gidController.text = match.$1.toString();
                            _tokenController.text = match.$2;
                            _gid = match.$1;
                            _token = match.$2;
                          });
                        }
                      },
                    )),
                    _buildWithVecticalPadding(NumberFormField(
                      controller: _gidController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: i18n.gid,
                      ),
                      min: 0,
                      onChanged: (int? value) {
                        setState(() {
                          _gid = value;
                        });
                        if (_token != null && _token!.isNotEmpty) {
                          _urlController.text =
                              "https://e-hentai.org/g/$_gid/$_token/";
                        }
                      },
                    )),
                    _buildWithVecticalPadding(TextFormField(
                      controller: _tokenController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: i18n.galleryToken,
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _token = value;
                        });
                        if (_gid != null && _token!.isNotEmpty) {
                          _urlController.text =
                              "https://e-hentai.org/g/$_gid/$_token/";
                        }
                      },
                    )),
                    _buildWithVecticalPadding(LabeledCheckbox(
                      value: _useCfg,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _useCfg = value;
                            if (_useCfg && _cfg == null) {
                              if (_dftCfg != null) {
                                _cfg =
                                    DownloadConfig.fromJson(_dftCfg!.toJson());
                              } else {
                                _cfg = DownloadConfig();
                              }
                            }
                          });
                        }
                      },
                      label: Text(i18n.overwriteDefaultConfig),
                    )),
                    _useCfg
                        ? _buildWithVecticalPadding(NumberFormField(
                            min: 1,
                            initialValue: _cfg!.maxDownloadImgCount,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: i18n.maxDownloadImgCount,
                            ),
                            onChanged: (s) {
                              setState(() {
                                _cfg!.maxDownloadImgCount = s;
                              });
                            }))
                        : Container(),
                    _useCfg
                        ? _buildWithVecticalPadding(LabeledCheckbox(
                            value: _cfg!.mpv ?? false,
                            onChanged: (b) {
                              if (b != null) {
                                setState(() {
                                  _cfg!.mpv = b;
                                });
                              }
                            },
                            label: Text(i18n.mpv)))
                        : Container(),
                    _useCfg
                        ? _buildWithVecticalPadding(LabeledCheckbox(
                            value: _cfg!.downloadOriginalImg ?? false,
                            onChanged: (b) {
                              if (b != null) {
                                setState(() {
                                  _cfg!.downloadOriginalImg = b;
                                });
                              }
                            },
                            label: Text(i18n.downloadOriginalImg)))
                        : Container(),
                    _useCfg
                        ? _buildWithVecticalPadding(NumberFormField(
                            min: 1,
                            initialValue: _cfg!.maxRetryCount,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: i18n.maxRetryCount,
                            ),
                            onChanged: (s) {
                              if (s != null) {
                                setState(() {
                                  _cfg!.maxRetryCount = s;
                                });
                              }
                            },
                          ))
                        : Container(),
                    _useCfg
                        ? _buildWithVecticalPadding(LabeledCheckbox(
                            value: _cfg!.removePreviousGallery ?? false,
                            onChanged: (b) {
                              if (b != null) {
                                setState(() {
                                  _cfg!.removePreviousGallery = b;
                                });
                              }
                            },
                            label: Text(i18n.removePreviousGallery)))
                        : Container(),
                    _buildWithVecticalPadding(ElevatedButton(
                        onPressed: _gid != null &&
                                _token != null &&
                                _token!.isNotEmpty &&
                                !_isCreating
                            ? () {
                                create();
                              }
                            : null,
                        child: Text(i18n.create))),
                  ],
                ))));
  }
}
