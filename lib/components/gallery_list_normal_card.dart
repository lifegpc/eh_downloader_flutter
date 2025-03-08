import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
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
    final max =
        ((useMobile ? 300 : 400) * MediaQuery.of(context).devicePixelRatio)
            .toInt();
    final fileId =
        _pMeta != null ? _files?.files[_pMeta!.token]?.firstOrNull?.id : null;
    final card = Card(
        child: Row(children: [
      Expanded(
          flex: useMobile ? 2 : 3,
          child: _pMeta != null
              ? Thumbnail(_pMeta!,
                  key: Key("thumbnail-conver-${widget.gMeta.gid}-$max"),
                  files: _files,
                  gid: widget.gMeta.gid,
                  fileId: fileId,
                  max: max)
              : Container()),
      Expanded(
          flex: useMobile ? 3 : 7,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.gMeta.title),
                    Text(widget.gMeta.titleJpn),
                    Text(widget.gMeta.uploader),
                    Text(widget.gMeta.category),
                    Text(widget.gMeta.filecount.toString()),
                    Text(widget.gMeta.rating.toString()),
                  ])))
    ]));
    final box = SizedBox(
        height: useMobile ? 300 : 400,
        width: useMobile ? null : 600,
        child: card);
    return InkWell(
        onTap: () {
          context.push('/gallery/${widget.gMeta.gid}',
              extra: GalleryPageExtra(title: widget.gMeta.preferredTitle));
        },
        child: box);
  }
}
