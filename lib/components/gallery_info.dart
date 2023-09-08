import 'package:eh_downloader_flutter/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class _GalleryInfo extends State<GalleryInfo> with ThemeModeWidget {
  final ScrollController controller = ScrollController();
  void stateChanged(dynamic _) {
    setState(() {});
  }

  @override
  void initState() {
    listener.on("showNsfwChanged", stateChanged);
    listener.on("displayAdChanged", stateChanged);
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
      controller: controller,
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.canPop() ? context.pop() : context.go("/");
            },
          ),
          title: SelectableText(
              maxLines: 2, minLines: 1, widget.gData.meta.preferredTitle),
          actions: [
            buildThemeModeIcon(context),
            buildMoreVertSettingsButon(context),
          ],
          floating: true,
        ),
        useMobile
            ? SliverList(
                delegate: SliverChildListDelegate([
                  GalleryBasicInfo(widget.gData.meta, firstPage,
                      fileId: firstFileId),
                ]),
              )
            : SliverList(
                delegate: SliverChildListDelegate([
                  GalleryInfoDesktop(widget.gData,
                      fileId: firstFileId, controller: controller),
                ]),
              ),
        ThumbnailGridView(widget.gData.pages,
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: useMobile ? 2 : 5),
            files: widget.files),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    listener.removeEventListener("showNsfwChanged", stateChanged);
    listener.removeEventListener("displayAdChanged", stateChanged);
    super.dispose();
  }
}
