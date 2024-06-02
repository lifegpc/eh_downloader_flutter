import 'package:flutter/material.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'thumbnail.dart';

class ThumbnailGridView extends StatelessWidget {
  const ThumbnailGridView(this.gdata, this.gridDelegate,
      {super.key, this.files, this.gid});
  final GalleryData gdata;
  final int? gid;
  final EhFiles? files;
  final SliverGridDelegate gridDelegate;

  @override
  Widget build(BuildContext context) {
    final displayAd = prefs.getBool("displayAd") ?? false;
    final npages =
        displayAd ? gdata.pages : gdata.pages.where((e) => !e.isAd).toList();
    return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: npages.length,
        itemBuilder: (context, index) {
          final page = npages[index]!;
          final fileId =
              files != null ? files!.files[page.token]!.firstOrNull?.id : null;
          final key = Key("thumbnail$gid-${page.index}");
          return Container(
              padding: const EdgeInsets.all(4),
              child: Thumbnail(page,
                  key: key,
                  fileId: fileId,
                  gid: gid,
                  index: page.index,
                  files: files,
                  gdata: gdata));
        });
  }
}
