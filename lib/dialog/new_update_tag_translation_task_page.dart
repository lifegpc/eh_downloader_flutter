import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../api/task.dart';
import '../globals.dart';

final _log = Logger("NewUpdateTagTranslationTaskPage");

class NewUpdateTagTranslationTaskPage extends StatefulWidget {
  const NewUpdateTagTranslationTaskPage({super.key});

  static const routeName = "/dialog/new_update_tag_translation_task";

  @override
  State<NewUpdateTagTranslationTaskPage> createState() =>
      _NewUpdateTagTranslationTaskPage();
}

class _NewUpdateTagTranslationTaskPage
    extends State<NewUpdateTagTranslationTaskPage> {
  final _formKey = GlobalKey<FormState>();
  bool _ok = false;
  bool _isCreating = false;
  CancelToken? _cancel;
  String _file = "";

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Widget _buildWithVecticalPadding(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Future<void> create() async {
    try {
      _cancel = CancelToken();
      setState(() {
        _isCreating = true;
      });
      final cfg =
          _file.isEmpty ? null : UpdateTagTranslationConfig(file: _file);
      (await api.createUpdateTagTranslationTask(cfg: cfg, cancel: _cancel))
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
                          i18n.createUpdateTagTranslationTask,
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
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: i18n.translationFile,
                        helperText: i18n.translationFileHelp,
                        helperMaxLines: 3,
                      ),
                      onChanged: (value) {
                        _file = value;
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
