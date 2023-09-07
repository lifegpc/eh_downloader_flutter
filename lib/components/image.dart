import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:super_context_menu/super_context_menu.dart';
import '../utils/clipboard.dart';

final _log = Logger("ImageWithContextMenu");

class ImageWithContextMenu extends StatelessWidget {
  const ImageWithContextMenu(this.data,
      {Key? key, this.uri, this.fmt = ImageFmt.jpg})
      : super(key: key);
  final Uint8List data;
  final String? uri;
  final ImageFmt fmt;
  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
        menuProvider: (_) {
          var list = [
            MenuAction(
                title: AppLocalizations.of(context)!.copyImage,
                callback: () async {
                  try {
                    await copyImageToClipboard(data, fmt);
                  } catch (err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  }
                })
          ];
          if (uri != null) {
            list.add(MenuAction(
                title: AppLocalizations.of(context)!.copyImgUrl,
                callback: () {
                  copyTextToClipboard(uri!).catchError((err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  });
                }));
          }
          return Menu(children: list);
        },
        child: Image.memory(data));
  }
}
