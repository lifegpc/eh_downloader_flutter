import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_context_menu/super_context_menu.dart';

class ImageWithContextMenu extends StatelessWidget {
  const ImageWithContextMenu(this.data, {Key? key}) : super(key: key);
  final Uint8List data;
  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
        menuProvider: (_) {
          return Menu(children: [
            MenuAction(
                title: AppLocalizations.of(context)!.copyImage,
                callback: () {
                  final item = DataWriterItem();
                  item.add(Formats.jpeg(data));
                  ClipboardWriter.instance.write([item]);
                }),
          ]);
        },
        child: Image.memory(data));
  }
}
