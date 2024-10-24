import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../globals.dart';
import './number_field.dart';

class AlertNumberFormDialog extends StatefulWidget {
  const AlertNumberFormDialog(this.confKey,
      {this.title,
      this.initial,
      this.decoration,
      this.max,
      this.min,
      this.errorMsg,
      super.key});
  final Widget? title;
  final int? initial;
  final InputDecoration? decoration;
  final int? max;
  final int? min;
  final String? errorMsg;
  final String confKey;
  @override
  State<StatefulWidget> createState() => _AlertNumberFormDialog();
}

class _AlertNumberFormDialog extends State<AlertNumberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? now;
  @override
  void initState() {
    now = prefs.getInt(widget.confKey) ?? widget.initial;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: widget.title ?? Text(i18n.changeSettings),
      content: Form(
          key: _formKey,
          child: NumberFormField(
            initialValue: now,
            decoration: widget.decoration,
            onChanged: (s) {
              setState(() {
                now = s;
              });
            },
            max: widget.max,
            min: widget.min,
            errorMsg: widget.errorMsg,
          )),
      actions: [
        TextButton(
            onPressed: now != null
                ? () {
                    prefs.setInt(widget.confKey, now!);
                    listener
                        .tryEmit("settings_updated", (widget.confKey, now!));
                    context.pop();
                  }
                : null,
            child: Text(i18n.ok)),
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(i18n.cancel)),
      ],
    );
  }
}
