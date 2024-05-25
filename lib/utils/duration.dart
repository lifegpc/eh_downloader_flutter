import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String fmtDuration(BuildContext context, double ms) {
  if (ms.isInfinite) {
    return "∞";
  }
  final dur = ms.toInt() ~/ 1000;
  String re = "";
  if (dur >= 86400) {
    final i18n = AppLocalizations.of(context)!;
    re += "${i18n.days(dur ~/ 86400)} ";
  }
  if (dur >= 3600) {
    re += "${(dur ~/ 3600).toString().padLeft(2, '0')}:";
  }
  final min = (dur ~/ 60).toString().padLeft(2, '0');
  final secs = (dur % 60).toString().padLeft(2, '0');
  re += "$min:$secs";
  return re;
}
