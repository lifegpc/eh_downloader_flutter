import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'gallery_basic_info.dart';
import 'gallery_info_desktop.dart';
import 'gallery_info_detail.dart';
import 'tags.dart';
import 'thumbnail_gridview.dart';

class GalleryInfo extends StatefulWidget {
  const GalleryInfo(this.gData,
      {super.key,
      this.files,
      this.refreshIndicatorKey,
      this.onRefresh,
      this.isSelectMode = false,
      this.onSelectChanged,
      this.selected});
  final GalleryData gData;
  final EhFiles? files;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  final Future<void> Function()? onRefresh;
  final bool isSelectMode;
  final ValueChanged<bool>? onSelectChanged;
  final List<String>? selected;

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
    final maxWidth = MediaQuery.of(context).size.width;
    bool useMobile = maxWidth <= 810;
    final thumb = prefs.getInt("thumbnailSize") ?? 1;
    final tsize = (thumb >= 0 && thumb < ThumbnailSize.values.length
            ? ThumbnailSize.values[thumb]
            : ThumbnailSize.medium)
        .size;
    final max = maxWidth > 810
        ? tsize
        : maxWidth >= 400
            ? min(tsize, ThumbnailSize.medium.size)
            : ThumbnailSize.smail.size;
    final firstPage = widget.gData.pages.firstOrNull;
    final int? firstFileId = widget.files != null && firstPage != null
        ? widget.files!.files[firstPage!.token]!.firstOrNull?.id
        : null;
    final v = CustomScrollView(
      controller: controller,
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: Icon(widget.isSelectMode ? Icons.close : Icons.arrow_back),
            onPressed: () {
              if (widget.isSelectMode) {
                if (widget.onSelectChanged != null) {
                  widget.onSelectChanged!(false);
                }
              } else {
                context.canPop() ? context.pop() : context.go("/");
              }
            },
          ),
          title: SelectableText(widget.gData.meta.preferredTitle,
              maxLines: 1, minLines: 1),
          actions: [
            widget.isSelectMode || widget.onSelectChanged == null
                ? Container()
                : IconButton(
                    onPressed: () {
                      if (widget.onSelectChanged != null) {
                        widget.onSelectChanged!(true);
                      }
                    },
                    icon: const Icon(Icons.check_box)),
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
            SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: max.toDouble(),
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            files: widget.files,
            gid: widget.gData.meta.gid,
            isSelectMode: widget.isSelectMode,
            selected: widget.selected,
            onSelectedChange: () => setState(() {})),
      ],
    );
    if (widget.refreshIndicatorKey != null && widget.onRefresh != null) {
      return RefreshIndicator(
          key: widget.refreshIndicatorKey,
          onRefresh: widget.onRefresh!,
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: v));
    }
    return v;
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
