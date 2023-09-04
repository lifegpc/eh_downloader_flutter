import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';

final _log = Logger("ImageWithContextMenu");

class ImageWithContextMenu extends StatelessWidget {
  const ImageWithContextMenu(this.data, {Key? key, this.uri}) : super(key: key);
  final Uint8List data;
  final String? uri;
  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
        menuProvider: (_) {
          var list = [
            MenuAction(
                title: AppLocalizations.of(context)!.copyImage,
                callback: () {
                  final item = DataWriterItem();
                  item.add(Formats.jpeg(data));
                  ClipboardWriter.instance.write([item]).catchError((err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  });
                })
          ];
          if (uri != null) {
            list.add(MenuAction(
                title: AppLocalizations.of(context)!.copyImgUrl,
                callback: () {
                  final item = DataWriterItem();
                  item.add(Formats.plainText(uri!));
                  ClipboardWriter.instance.write([item]).catchError((err) {
                    _log.warning("Failed to copy image to clipboard:", err);
                  });
                }));
          }
          return Menu(children: list);
        },
        child: Image.memory(data));
  }
}
