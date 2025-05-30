import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import '../api/client.dart';
import '../api/file.dart';
import '../api/gallery.dart';
import '../components/gallery_list_normal_card.dart';
import '../globals.dart';
import '../main.dart';

final _log = Logger("GalleriesPage");

class GalleriesPageExtra {
  const GalleriesPageExtra({this.translatedTag});
  final String? translatedTag;
}

class GalleriesPage extends StatefulWidget {
  const GalleriesPage(
      {super.key,
      this.sortByGid,
      this.uploader,
      this.tag,
      this.translatedTag,
      this.category,
      this.hasExtra = false});
  final SortByGid? sortByGid;
  final String? uploader;
  final String? tag;
  final String? translatedTag;
  final bool hasExtra;
  final String? category;
  bool _stt(BuildContext context) =>
      prefs.getBool("showTranslatedTag") ??
      MainApp.of(context).lang.toLocale().languageCode == "zh";

  static const String routeName = '/galleries';

  @override
  State<GalleriesPage> createState() => _GalleriesPage();
}

class _GalleriesPage extends State<GalleriesPage>
    with ThemeModeWidget, IsTopWidget2 {
  final ScrollController controller = ScrollController();
  static const int _pageSize = 20;
  bool? _sortByGid;
  SortByGid _sortByGid2 = SortByGid.none;
  String? _translatedTag;
  String? preferredTag(BuildContext context) =>
      widget._stt(context) ? _translatedTag ?? widget.tag : widget.tag;
  CancelToken? _tagCancel;
  bool _isFetchingTag = false;
  bool _fetchedTag = false;
  late GalleryThumbnails _thumbnails;
  late EhFiles _files;

  final PagingController<int, GMeta> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final list = (await api.listGalleries(
              offset: pageKey,
              limit: _pageSize,
              sortByGid: _sortByGid,
              uploader: widget.uploader,
              category: widget.category,
              tag: widget.tag))
          .unwrap();
      if (list.isNotEmpty) {
        final thumbnails =
            (await api.getGalleriesThumbnail(list.map((e) => e.gid).toList()))
                .unwrap();
        _thumbnails.merge(thumbnails);
        final files = (await api.getFiles(list
                .map((e) {
                  var thumbnail = _thumbnails.thumbnails[e.gid];
                  if (thumbnail != null && thumbnail.ok) {
                    return thumbnail.unwrap().token;
                  }
                })
                .where((t) => t != null)
                .cast<String>()
                .toList()))
            .unwrap();
        _files.merge(files);
      }
      final isLastPage = list.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length;
        _pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      _log.severe("Failed to load page with offset $pageKey:", e);
      _pagingController.error = e;
    }
  }

  Future<void> _fetchTag() async {
    _isFetchingTag = true;
    try {
      _tagCancel = CancelToken();
      final tags =
          (await api.getTags2([widget.tag!], cancel: _tagCancel)).unwrap();
      final tag = tags.tags[widget.tag!]!.unwrap();
      if (!_tagCancel!.isCancelled) {
        setState(() {
          _translatedTag = tag.translated;
        });
      }
    } catch (e, stack) {
      if (!_tagCancel!.isCancelled) {
        if (e is (int, String)) {
          _log.warning("Failed to fetch tags: $e");
        } else {
          _log.severe("Failed to fetch tags: $e\n$stack");
        }
      }
    }
    _fetchedTag = true;
    _isFetchingTag = false;
  }

  @override
  void initState() {
    try {
      _sortByGid2 = widget.sortByGid != null
          ? widget.sortByGid!
          : SortByGid.values[prefs.getInt("sortByGid") ?? 0];
      _sortByGid = _sortByGid2.toBool();
    } catch (e) {
      _log.warning("Failed to load sortByGid from prefs:", e);
    }
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _translatedTag = widget.translatedTag;
    _thumbnails = GalleryThumbnails(thumbnails: {});
    _files = EhFiles(files: {});
    listener.on("user_logined", _onStateChanged);
    listener.on("meilisearch_enabled", _onStateChanged);
    super.initState();
  }

  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final i18n = AppLocalizations.of(context)!;
    final sortByGidMenu = DropdownMenu<SortByGid>(
      initialSelection: _sortByGid2,
      onSelected: (v) {
        if (v != null) {
          prefs.setInt("sortByGid", v!.index).then((re) {
            if (!re) _log.warning("Failed to save sortByGid to prefs.");
          }).catchError((error) {
            _log.warning("Failed to save sortByGid to prefs:", error);
          });
          var queryParameters = {
            "sortByGid": [v!.index.toString()],
            "tag": [widget.tag ?? ""],
            "uploader": [widget.uploader ?? ""],
            "category": [widget.category ?? ""],
          };
          queryParameters.removeWhere((k, v) => v[0].isEmpty);
          context.pushReplacementNamed("/galleries",
              queryParameters: queryParameters,
              extra: GalleriesPageExtra(translatedTag: _translatedTag));
        }
      },
      label: Text(i18n.sortByGid),
      dropdownMenuEntries: [
        DropdownMenuEntry(value: SortByGid.none, label: i18n.none),
        DropdownMenuEntry(value: SortByGid.asc, label: i18n.asc),
        DropdownMenuEntry(value: SortByGid.desc, label: i18n.desc),
      ],
      leadingIcon: const Icon(Icons.sort),
    );
    final title = widget.tag != null
        ? widget.uploader != null
            ? widget.category != null
                ? i18n.tagUploaderCategoryGalleries(
                    preferredTag(context)!, widget.uploader!, widget.category!)
                : i18n.tagUploaderGalleries(
                    preferredTag(context)!, widget.uploader!)
            : widget.category != null
                ? i18n.tagCategoryGalleries(
                    widget.category!, preferredTag(context)!)
                : i18n.tagGalleries(preferredTag(context)!)
        : widget.uploader != null
            ? widget.category != null
                ? i18n.uploaderCategoryGalleries(
                    widget.category!, widget.uploader!)
                : i18n.uploaderGalleries(widget.uploader!)
            : widget.category != null
                ? i18n.categoryGalleries(widget.category!)
                : i18n.galleries;
    if (isTop(context)) {
      setCurrentTitle(title);
    }
    if (auth.canManageTasks == true &&
        !widget.hasExtra &&
        widget.tag != null &&
        !_isFetchingTag &&
        !_fetchedTag) {
      _fetchTag();
    }
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.canPop() ? context.pop() : context.go("/");
              },
            ),
            title: Text(title),
            actions: [
              PopupMenuButton(
                  icon: const Icon(Icons.sort),
                  itemBuilder: (context) =>
                      [PopupMenuItem(child: sortByGidMenu)]),
              buildSearchButton(context),
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ]),
        body: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PagedListView<int, GMeta>(
              physics: const AlwaysScrollableScrollPhysics(),
              pagingController: _pagingController,
              scrollController: controller,
              builderDelegate: PagedChildBuilderDelegate<GMeta>(
                  itemBuilder: (context, item, index) {
                final displayMode = GalleryListDisplayMode
                    .values[prefs.getInt("galleryListDisplayMode") ?? 1];
                if (displayMode == GalleryListDisplayMode.normal) {
                  return InkWell(
                      onTap: () {
                        context.push("/gallery/${item.gid}",
                            extra:
                                GalleryPageExtra(title: item.preferredTitle));
                      },
                      mouseCursor: SystemMouseCursors.basic,
                      child: GalleryListNormalCard(item,
                          controller: controller,
                          files: _files,
                          pMeta: _thumbnails.thumbnails[item.gid]
                              ?.unwrapOrNull()));
                }
                return ListTile(
                  title: Text(item.preferredTitle),
                  onTap: () {
                    context.push("/gallery/${item.gid}",
                        extra: GalleryPageExtra(title: item.preferredTitle));
                  },
                );
              }, noItemsFoundIndicatorBuilder: (context) {
                return Center(
                    child: Text(i18n.noGalleriesFound,
                        style: Theme.of(context).textTheme.titleLarge));
              }),
            )));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _tagCancel?.cancel();
    listener.removeEventListener("user_logined", _onStateChanged);
    listener.removeEventListener("meilisearch_enabled", _onStateChanged);
    super.dispose();
  }
}
