import 'package:eh_downloader_flutter/globals.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import 'gallery_basic_info.dart';
import 'gallery_info_desktop.dart';
import 'gallery_info_detail.dart';
import 'tags.dart';
import 'thumbnail_gridview.dart';

class GalleryInfo extends StatefulWidget {
  const GalleryInfo(this.gData, {super.key, this.files});
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

  void _onAdChanged(dynamic args) {
    final arguments = args as (String, bool)?;
    if (arguments == null) return;
    final token = arguments.$1;
    final isAd = arguments.$2;
    var changed = false;
    for (var e in widget.gData.pages) {
      if (e.token == token) {
        e.isAd = isAd;
        changed = true;
        break;
      }
    }
    if (changed) {
      setState(() {});
    }
  }

  @override
  void initState() {
    listener.on("showNsfwChanged", stateChanged);
    listener.on("displayAdChanged", stateChanged);
    listener.on("adChanged", _onAdChanged);
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
          title: SelectableText(widget.gData.meta.preferredTitle,
              maxLines: 1, minLines: 1),
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
                      fileId: firstFileId,
                      gData: widget.gData,
                      files: widget.files),
                  const Divider(indent: 20, endIndent: 20),
                  GalleryInfoDetail(widget.gData.meta),
                  const Divider(indent: 20, endIndent: 20),
                ]),
              )
            : SliverList(
                delegate: SliverChildListDelegate([
                  GalleryInfoDesktop(widget.gData,
                      fileId: firstFileId,
                      controller: controller,
                      files: widget.files),
                ]),
              ),
        useMobile
            ? TagsPanel(widget.gData.tags,
                sliver: true,
                margin: const EdgeInsets.symmetric(horizontal: 20.0))
            : SliverToBoxAdapter(child: Container()),
        useMobile
            ? const SliverToBoxAdapter(
                child: Divider(indent: 20, endIndent: 20))
            : SliverToBoxAdapter(child: Container()),
        ThumbnailGridView(
            widget.gData,
            SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: useMobile ? 2 : 5),
            files: widget.files,
            gid: widget.gData.meta.gid),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    listener.removeEventListener("showNsfwChanged", stateChanged);
    listener.removeEventListener("displayAdChanged", stateChanged);
    listener.removeEventListener("adChanged", _onAdChanged);
    super.dispose();
  }
}
