import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import '../main.dart';
import 'rate.dart';
import 'thumbnail.dart';

class GalleryListNormalCard extends StatefulWidget {
  const GalleryListNormalCard(this.gMeta, {super.key, this.files, this.pMeta});
  final GMeta gMeta;
  final ExtendedPMeta? pMeta;
  final EhFiles? files;

  @override
  State<GalleryListNormalCard> createState() => _GalleryListNormalCard();
}

class _GalleryListNormalCard extends State<GalleryListNormalCard> {
  ExtendedPMeta? _pMeta;
  EhFiles? _files;
  @override
  void initState() {
    _pMeta = widget.pMeta;
    _files = widget.files;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    bool useMobile = maxWidth <= 810;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final max = ((useMobile ? 150 : 200) * dpr).toInt();
    final fileId =
        _pMeta != null ? _files?.files[_pMeta!.token]?.firstOrNull?.id : null;
    final locale = MainApp.of(context).lang.toLocale().toString();
    final cs = Theme.of(context).colorScheme;
    final thumbnailWidget = _pMeta != null
        ? Thumbnail(_pMeta!,
            key: Key("thumbnail-conver-${widget.gMeta.gid}-$max"),
            files: _files,
            gid: widget.gMeta.gid,
            fileId: fileId,
            height: max)
        : Container();
    final mainWidget = Padding(
        padding: useMobile
            ? const EdgeInsets.symmetric(vertical: 2, horizontal: 4)
            : EdgeInsets.all(8 / dpr),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SelectableText(
              useMobile ? widget.gMeta.preferredTitle : widget.gMeta.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: cs.primary),
              textAlign: TextAlign.center,
              minLines: useMobile ? 1 : 1,
              maxLines: useMobile
                  ? 3
                  : widget.gMeta.titleJpn.isEmpty
                      ? 4
                      : 2),
          useMobile || widget.gMeta.titleJpn.isEmpty
              ? Container()
              : SelectableText(
                  widget.gMeta.titleJpn,
                  style: TextStyle(color: cs.secondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minLines: 1,
                ),
          Expanded(child: Container()),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SelectableText.rich(TextSpan(
                  text: widget.gMeta.uploader,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.primary),
                  mouseCursor: SystemMouseCursors.click,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.pushNamed("/galleries",
                          queryParameters: {"uploader": widget.gMeta.uploader});
                    })),
              Rate(widget.gMeta.rating, fontSize: 14, selectable: true),
              SelectableText.rich(TextSpan(
                  text: widget.gMeta.category,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.primary),
                  mouseCursor: SystemMouseCursors.click,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.pushNamed("/galleries",
                          queryParameters: {"category": widget.gMeta.category});
                    }))
            ]),
            Expanded(child: Container()),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SelectableText("${widget.gMeta.filecount}P",
                  style: TextStyle(
                      fontSize: 16,
                      color: cs.primary,
                      fontWeight: FontWeight.bold)),
              SelectableText(
                  DateFormat.yMd(locale)
                      .add_jms()
                      .format(widget.gMeta.posted.toLocal()),
                  style: TextStyle(
                      fontSize: 16,
                      color: cs.primary,
                      fontWeight: FontWeight.bold))
            ]),
          ]),
        ]));
    final box = Container(
        alignment: Alignment.center,
        child: SizedBox(
            height: useMobile ? 150 : 200,
            width: useMobile ? null : 800,
            child: Row(children: [
              useMobile
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth / 2),
                      child: thumbnailWidget)
                  : thumbnailWidget,
              Expanded(child: mainWidget),
            ])));
    final card = Card(child: box);
    return card;
  }
}
