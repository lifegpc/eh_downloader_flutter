import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../api/gallery.dart';
import 'thumbnail.dart';

class GalleryBasicInfo extends StatelessWidget {
  const GalleryBasicInfo(this.gMeta, this.firstPage, {Key? key, this.fileId})
      : super(key: key);
  final GMeta gMeta;
  final ExtendedPMeta firstPage;
  final int? fileId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: Column(children: [
          Expanded(
              child: Row(children: [
            Expanded(
                flex: 2,
                child: Thumbnail(firstPage, fileId: fileId, gid: gMeta.gid)),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(gMeta.preferredTitle),
                    SelectableText(gMeta.uploader),
                    SelectableText(gMeta.category),
                  ],
                ))
          ])),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          context.push('/gallery/${gMeta.gid}/page/1');
                        },
                        child: Text(AppLocalizations.of(context)!.read)),
                    ElevatedButton(
                        onPressed: () {
                          context.push('/dialog/download/zip/${gMeta.gid}');
                        },
                        child: Text(AppLocalizations.of(context)!.download)),
                  ]))
        ]));
  }
}
