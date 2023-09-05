import 'package:flutter/material.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'thumbnail.dart';

class ThumbnailGridView extends StatelessWidget {
  const ThumbnailGridView(this.pages, this.gridDelegate, {Key? key, this.files})
      : super(key: key);
  final List<ExtendedPMeta> pages;
  final EhFiles? files;
  final SliverGridDelegate gridDelegate;

  @override
  Widget build(BuildContext context) {
    final displayAd = prefs.getBool("displayAd") ?? false;
    final npages = displayAd ? pages : pages.where((e) => !e.isAd).toList();
    return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: npages.length,
        itemBuilder: (context, index) {
          final page = npages[index]!;
          final fileId =
              files != null ? files!.files[page.token]!.first.id : null;
          return Container(
              padding: const EdgeInsets.all(4),
              child: Thumbnail(page, fileId: fileId));
        });
  }
}
