import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:super_context_menu/super_context_menu.dart';
import '../globals.dart';
import '../utils/clipboard.dart';

final _log = Logger("ImageWithContextMenu");

class ImageWithContextMenu extends StatelessWidget {
  const ImageWithContextMenu(this.data,
      {super.key,
      this.uri,
      this.dir,
      this.fileName,
      this.fmt = ImageFmt.jpg,
      this.isNsfw,
      this.changeNsfw,
      this.isAd,
      this.changeAd});
  final Uint8List data;
  final String? uri;
  final ImageFmt fmt;
  final String? fileName;
  final String? dir;
  final bool Function()? isNsfw;
  final Function(bool isNsfw)? changeNsfw;
  final bool Function()? isAd;
  final Function(bool isAd)? changeAd;
  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
        menuProvider: (_) {
          var list = <MenuElement>[
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
          if (fileName != null) {
            list.add(MenuAction(
                title: AppLocalizations.of(context)!.saveAs,
                callback: () {
                  try {
                    platformPath.saveFile(fileName!, fmt.toMimeType(), data,
                        dir: dir ?? "");
                  } catch (err) {
                    _log.warning("Failed to save image:", err);
                  }
                }));
          }
          if ((isNsfw != null && changeNsfw != null) || (isAd != null && changeAd != null)) {
            list.add(MenuSeparator());
          }
          if (isNsfw != null && changeNsfw != null) {
            final nsfw = isNsfw!();
            list.add(MenuAction(
                title: nsfw
                    ? AppLocalizations.of(context)!.markAsSfw
                    : AppLocalizations.of(context)!.markAsNsfw,
                callback: () {
                  changeNsfw!(!isNsfw!());
                }));
          }
          if (isAd != null && changeAd != null) {
            final ad = isAd!();
            list.add(MenuAction(
                title: ad
                    ? AppLocalizations.of(context)!.markAsNonAd
                    : AppLocalizations.of(context)!.markAsAd,
                callback: () {
                  changeAd!(!isAd!());
                }));
          }
          return Menu(children: list);
        },
        child: Image.memory(data));
  }
}
