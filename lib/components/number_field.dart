import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NumberFormField extends StatelessWidget {
  const NumberFormField(
      {super.key,
      this.min,
      this.max,
      this.initialValue,
      this.errorMsg,
      this.decoration,
      this.onChanged,
      this.controller});

  final int? min;
  final int? max;
  final int? initialValue;
  final String? errorMsg;
  final InputDecoration? decoration;
  final Function(int?)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return TextFormField(
        controller: controller,
        initialValue: initialValue?.toString(),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[\-0-9]")),
        ],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          try {
            int v = int.parse(value);
            if (min != null && v < min!) {
              return errorMsg ?? i18n.numberOutOfRange;
            }
            if (max != null && v > max!) {
              return errorMsg ?? i18n.numberOutOfRange;
            }
          } catch (e) {
            return errorMsg ?? i18n.invalidNumber;
          }
          return null;
        },
        decoration: decoration,
        onChanged: (String? value) {
          if (value == null || value.isEmpty) {
            onChanged?.call(null);
          } else {
            try {
              int v = int.parse(value);
              if (max != null && v > max!) {
                onChanged?.call(null);
              } else if (min != null && v < min!) {
                onChanged?.call(null);
              } else {
                onChanged?.call(v);
              }
            } catch (e) {
              onChanged?.call(null);
            }
          }
        });
  }
}
