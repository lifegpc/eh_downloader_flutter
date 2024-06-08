import 'package:flutter/material.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'thumbnail.dart';

class ThumbnailGridView extends StatelessWidget {
  const ThumbnailGridView(this.gdata, this.gridDelegate,
      {super.key,
      this.files,
      this.gid,
      this.isSelectMode = false,
      this.selected,
      this.onSelectedChange});
  final GalleryData gdata;
  final int? gid;
  final EhFiles? files;
  final SliverGridDelegateWithMaxCrossAxisExtent gridDelegate;
  final bool isSelectMode;
  final List<String>? selected;
  final Function? onSelectedChange;

  @override
  Widget build(BuildContext context) {
    final displayAd = prefs.getBool("displayAd") ?? false;
    final npages =
        displayAd ? gdata.pages : gdata.pages.where((e) => !e.isAd).toList();
    final baseSize = gridDelegate.maxCrossAxisExtent.toInt();
    final max = (baseSize * MediaQuery.of(context).devicePixelRatio).toInt();
    return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: npages.length,
        itemBuilder: (context, index) {
          final page = npages[index]!;
          final fileId =
              files != null ? files!.files[page.token]!.firstOrNull?.id : null;
          final key = Key("thumbnail$gid-${page.index}-$fileId-$max");
          return Container(
              padding: const EdgeInsets.all(4),
              child: Thumbnail(
                page,
                key: key,
                fileId: fileId,
                gid: gid,
                index: page.index,
                files: files,
                gdata: gdata,
                isSelectMode: isSelectMode,
                isSelected: selected?.contains(page.token) ?? false,
                onSelectedChange: (v) {
                  if (v) {
                    selected?.add(page.token);
                  } else {
                    selected?.remove(page.token);
                  }
                  if (onSelectedChange != null) {
                    onSelectedChange!();
                  }
                },
                max: max,
              ));
        });
  }
}
