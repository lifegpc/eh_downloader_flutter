import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../main.dart';
import '../utils/filesize.dart';
import 'rate.dart';
import 'tags.dart';
import 'thumbnail.dart';
import '../viewer/single.dart';

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.name, this.value,
      {this.maxLines, this.minLines, this.fontSize});
  final String name;
  final String value;
  final int? maxLines;
  final int? minLines;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      SizedBox(
          width: 60,
          child: Text(name,
              style: TextStyle(color: cs.primary, fontSize: fontSize))),
      Expanded(
        child: SelectableText(value,
            style: TextStyle(color: cs.secondary, fontSize: fontSize),
            maxLines: maxLines,
            minLines: minLines),
      )
    ]);
  }
}

class GalleryInfoDesktop extends StatelessWidget {
  const GalleryInfoDesktop(this.gData,
      {super.key, this.fileId, this.controller, this.files});
  final GalleryData gData;
  final int? fileId;
  final ScrollController? controller;
  final EhFiles? files;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i18n = AppLocalizations.of(context)!;
    final locale = MainApp.of(context).lang.toLocale().toString();
    final max = (400 * MediaQuery.of(context).devicePixelRatio).toInt();
    return Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
            height: 400,
            width: 1280,
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: gData.pages.isNotEmpty
                          ? Thumbnail(
                              gData.pages.first,
                              key: Key(
                                  "thumbnail${gData.meta.gid}-${gData.pages.first.index}-$fileId-$max"),
                              fileId: fileId,
                              gid: gData.meta.gid,
                              max: max,
                            )
                          : Container())),
              Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      SelectableText(gData.meta.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: cs.primary)),
                      gData.meta.titleJpn.isEmpty
                          ? Container()
                          : SelectableText(gData.meta.titleJpn,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.secondary)),
                      const Divider(indent: 20, endIndent: 20),
                      Expanded(
                          child: Row(children: [
                        SizedBox(
                            width: 170,
                            child: Column(children: [
                              SelectableText(gData.meta.category,
                                  style: TextStyle(color: cs.secondary)),
                              SelectableText(gData.meta.uploader,
                                  style: TextStyle(color: cs.secondary)),
                              _KeyValue(
                                "${i18n.posted}${i18n.colon}",
                                DateFormat.yMd(locale)
                                    .add_jms()
                                    .format(gData.meta.posted),
                                maxLines: 2,
                                minLines: 1,
                                fontSize: 12,
                              ),
                              _KeyValue(
                                "${i18n.visible}${i18n.colon}",
                                gData.meta.expunged ? i18n.no : i18n.yes,
                                fontSize: 12,
                              ),
                              _KeyValue(
                                "${i18n.fileSize}${i18n.colon}",
                                getFileSize(gData.meta.filesize),
                                fontSize: 12,
                              ),
                              _KeyValue(
                                "${i18n.pageLength}${i18n.colon}",
                                i18n.pages(gData.meta.filecount),
                                fontSize: 12,
                              ),
                              _KeyValue(
                                "${i18n.gid}${i18n.colon}",
                                gData.meta.gid.toString(),
                                fontSize: 12,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 60,
                                      child: Text("${i18n.rating}${i18n.colon}",
                                          style: TextStyle(
                                              color: cs.primary,
                                              fontSize: 12))),
                                  Rate(gData.meta.rating, fontSize: 12),
                                ],
                              )
                            ])),
                        const VerticalDivider(indent: 10, endIndent: 10),
                        Expanded(child: TagsPanel(gData.tags)),
                        const VerticalDivider(indent: 10, endIndent: 10),
                        SizedBox(
                            width: 150,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        context.push(
                                            '/gallery/${gData.meta.gid}/page/1',
                                            extra: SinglePageViewerExtra(
                                                data: gData, files: files));
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.read)),
                                  ElevatedButton(
                                      onPressed: () {
                                        context.push(
                                            '/dialog/download/zip/${gData.meta.gid}');
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .download)),
                                ])),
                      ])),
                    ],
                  ))
            ])));
  }
}
