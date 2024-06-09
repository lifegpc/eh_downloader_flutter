import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import 'thumbnail.dart';
import '../viewer/single.dart';

class GalleryBasicInfo extends StatelessWidget {
  const GalleryBasicInfo(this.gMeta, this.firstPage,
      {super.key, this.fileId, this.gData, this.files});
  final GMeta gMeta;
  final ExtendedPMeta? firstPage;
  final int? fileId;
  final GalleryData? gData;
  final EhFiles? files;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final max = (300 * MediaQuery.of(context).devicePixelRatio).toInt();
    return SizedBox(
        height: 300,
        child: Column(children: [
          Expanded(
              child: Row(children: [
            Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: firstPage != null
                      ? Thumbnail(
                          firstPage!,
                          fileId: fileId,
                          gid: gMeta.gid,
                          key: Key(
                              "thumbnail${gMeta.gid}-${firstPage!.index}-$fileId-$max"),
                          max: max,
                        )
                      : Container(),
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(gMeta.preferredTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: cs.primary)),
                    SelectableText.rich(TextSpan(
                        text: gMeta.uploader,
                        style: TextStyle(color: cs.secondary),
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pushNamed("/galleries",
                                queryParameters: {"uploader": gMeta.uploader});
                          })),
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
                          context.push('/gallery/${gMeta.gid}/page/1',
                              extra: SinglePageViewerExtra(
                                  data: gData, files: files));
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
