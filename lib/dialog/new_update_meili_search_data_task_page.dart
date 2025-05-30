import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../components/number_field.dart';
import '../globals.dart';

final _log = Logger("NewUpdateTagTranslationTaskPage");

class NewUpdateMeiliSearchDataTaskPage extends StatefulWidget {
  const NewUpdateMeiliSearchDataTaskPage({this.gid, super.key});

  final int? gid;

  static const routeName = "/dialog/new_update_meili_search_data_task";

  @override
  State<NewUpdateMeiliSearchDataTaskPage> createState() =>
      _NewUpdateMeiliSearchDataTaskPage();
}

class _NewUpdateMeiliSearchDataTaskPage
    extends State<NewUpdateMeiliSearchDataTaskPage> {
  final _formKey = GlobalKey<FormState>();
  bool _ok = false;
  bool _isCreating = false;
  CancelToken? _cancel;
  int? _gid;

  @override
  void initState() {
    _gid = widget.gid;
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Future<void> create() async {
    try {
      _cancel = CancelToken();
      setState(() {
        _isCreating = true;
      });
      (await api.createUpdateMeiliSearchDataTask(gid: _gid, cancel: _cancel))
          .unwrap();
      _ok = true;
      if (!_cancel!.isCancelled) {
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.warning("Failed to create import task:", e);
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
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
                          i18n.createUpdateMeiliSearchDataTask,
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
                      min: 0,
                      initialValue: _gid,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: i18n.gid,
                        helperText: i18n.updateMeiliSearchDataGidHelp,
                        helperMaxLines: 3,
                      ),
                      onChanged: (gid) {
                        _gid = gid;
                      },
                    )),
                    _buildWithVecticalPadding(ElevatedButton(
                        onPressed: _isCreating
                            ? null
                            : () {
                                create();
                              },
                        child: Text(i18n.create))),
                  ],
                ))));
  }
}
