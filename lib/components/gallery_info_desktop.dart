import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/gallery.dart';
import 'thumbnail.dart';

class GalleryInfoDesktop extends StatelessWidget {
  const GalleryInfoDesktop(this.gData, {Key? key, this.fileId})
      : super(key: key);
  final GalleryData gData;
  final int? fileId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
            height: 400,
            width: 1280,
            child: Row(children: [
              Expanded(
                  flex: 3, child: Thumbnail(gData.pages.first, fileId: fileId)),
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
                              SelectableText(gData.meta.category),
                              SelectableText(gData.meta.uploader),
                            ])),
                        const VerticalDivider(indent: 10, endIndent: 10),
                        Expanded(child: Column(children: [])),
                        const VerticalDivider(indent: 10, endIndent: 10),
                        SizedBox(width: 150, child: Column(children: [])),
                      ])),
                    ],
                  ))
            ])));
  }
}
