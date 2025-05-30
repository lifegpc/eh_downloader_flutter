import 'package:dio/dio.dart';
import 'package:eh_downloader_flutter/api/task.dart';
import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../components/labeled_checkbox.dart';
import '../components/number_field.dart';
import '../globals.dart';

final _log = Logger("NewExportZipTaskPage");

class NewExportZipTaskPage extends StatefulWidget {
  const NewExportZipTaskPage({super.key, this.gid});
  final int? gid;

  static const routeName = "/dialog/new_export_zip_task";

  @override
  State<NewExportZipTaskPage> createState() => _NewExportZipTaskPage();
}

class _NewExportZipTaskPage extends State<NewExportZipTaskPage> {
  final _formKey = GlobalKey<FormState>();
  int? _gid;
  CancelToken? _cancel;
  CancelToken? _cancel2;
  bool _isCreating = false;
  bool _ok = false;
  ExportZipConfig? _cfg;
  ExportZipConfig? _dftCfg;
  bool _useCfg = false;
  bool _fetched = false;

  @override
  void initState() {
    _gid = widget.gid;
    super.initState();
  }

  @override
  void dispose() {
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
    if (_gid == null) return;
    try {
      _cancel = CancelToken();
      setState(() {
        _isCreating = true;
      });
      (await api.createExportZipTask(_gid!,
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
        _log.warning("Failed to create export zip task:", e);
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
      _dftCfg =
          (await api.getDefaultExportZipConfig(cancel: _cancel2)).unwrap();
    } catch (e) {
      if (!_cancel2!.isCancelled) {
        _log.warning("Failed to fetch default export zip config:", e);
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
                child: Column(children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        i18n.createExportZipTask,
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
                  _buildWithVecticalPadding(NumberFormField(
                    initialValue: _gid,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: i18n.gid,
                    ),
                    min: 0,
                    onChanged: (int? value) {
                      setState(() {
                        _gid = value;
                      });
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
                                  ExportZipConfig.fromJson(_dftCfg!.toJson());
                            } else {
                              _cfg = ExportZipConfig();
                            }
                          }
                        });
                      }
                    },
                    label: Text(i18n.overwriteDefaultConfig),
                  )),
                  _useCfg
                      ? _buildWithVecticalPadding(TextFormField(
                          initialValue: _cfg!.output,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: i18n.outputDir,
                          ),
                          onChanged: (String value) {
                            setState(() {
                              _cfg!.output = value.isEmpty ? null : value;
                            });
                          },
                        ))
                      : Container(),
                  _useCfg
                      ? _buildWithVecticalPadding(LabeledCheckbox(
                          value: _cfg!.jpnTitle ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _cfg!.jpnTitle = value;
                              });
                            }
                          },
                          label: Text(i18n.useTitleJpn),
                        ))
                      : Container(),
                  _useCfg
                      ? _buildWithVecticalPadding(NumberFormField(
                          initialValue: _cfg!.maxLength,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: i18n.maxZipFilenameLength,
                          ),
                          min: 0,
                          onChanged: (int? value) {
                            setState(() {
                              _cfg!.maxLength = value;
                            });
                          },
                        ))
                      : Container(),
                  _useCfg
                      ? _buildWithVecticalPadding(LabeledCheckbox(
                          value: _cfg!.exportAd ?? false,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _cfg!.exportAd = value;
                              });
                            }
                          },
                          label: Text(i18n.exportAd),
                        ))
                      : Container(),
                  _buildWithVecticalPadding(ElevatedButton(
                      onPressed: _gid != null && !_isCreating
                          ? () {
                              create();
                            }
                          : null,
                      child: Text(i18n.create))),
                ]))));
  }
}
