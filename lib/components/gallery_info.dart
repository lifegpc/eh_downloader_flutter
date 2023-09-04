import 'package:eh_downloader_flutter/globals.dart';
import 'package:flutter/material.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import 'gallery_basic_info.dart';
import 'gallery_info_desktop.dart';
import 'thumbnail_gridview.dart';

class GalleryInfo extends StatefulWidget {
  const GalleryInfo(this.gData, {Key? key, this.files}) : super(key: key);
  final GalleryData gData;
  final EhFiles? files;

  @override
  State<GalleryInfo> createState() => _GalleryInfo();
}

class _GalleryInfo extends State<GalleryInfo> {
  void showNsfwChanged(dynamic _) {
    setState(() {});
  }

  @override
  void initState() {
    listener.on("showNsfwChanged", showNsfwChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool useMobile = MediaQuery.of(context).size.width <= 810;
    final firstPage = widget.gData.pages.first;
    final int? firstFileId = widget.files != null
        ? widget.files!.files[firstPage.token]!.first.id
        : null;
    return CustomScrollView(
      slivers: [
        useMobile
            ? SliverList(
                delegate: SliverChildListDelegate([
                  GalleryBasicInfo(widget.gData.meta, firstPage,
                      fileId: firstFileId),
                ]),
              )
            : SliverList(
                delegate: SliverChildListDelegate([
                  GalleryInfoDesktop(widget.gData, fileId: firstFileId),
                ]),
              ),
        ThumbnailGridView(widget.gData.pages,
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            files: widget.files),
      ],
    );
  }

  @override
  void dispose() {
    listener.removeEventListener("showNsfwChanged", showNsfwChanged);
    super.dispose();
  }
}
