import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'api/client.dart';
import 'api/gallery.dart';
import 'globals.dart';
import 'main.dart';

final _log = Logger("GalleriesPage");

class GalleriesPageExtra {
  const GalleriesPageExtra({this.translatedTag});
  final String? translatedTag;
}

class GalleriesPage extends StatefulWidget {
  const GalleriesPage(
      {Key? key, this.sortByGid, this.uploader, this.tag, this.translatedTag})
      : super(key: key);
  final SortByGid? sortByGid;
  final String? uploader;
  final String? tag;
  final String? translatedTag;
  bool _stt(BuildContext context) =>
      prefs.getBool("showTranslatedTag") ??
      MainApp.of(context).lang.toLocale().languageCode == "zh";
  String? preferredTag(BuildContext context) =>
      _stt(context) ? translatedTag ?? tag : tag;

  static const String routeName = '/galleries';

  @override
  State<GalleriesPage> createState() => _GalleriesPage();
}

class _GalleriesPage extends State<GalleriesPage>
    with ThemeModeWidget, IsTopWidget2 {
  static const int _pageSize = 20;
  bool? _sortByGid;
  SortByGid _sortByGid2 = SortByGid.none;

  final PagingController<int, GMeta> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final list = (await api.listGalleries(
              offset: pageKey,
              limit: _pageSize,
              sortByGid: _sortByGid,
              uploader: widget.uploader,
              tag: widget.tag))
          .unwrap();
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
    super.initState();
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
          };
          queryParameters.removeWhere((k, v) => v[0].isEmpty);
          context.pushReplacementNamed("/galleries",
              queryParameters: queryParameters);
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
    final title = widget.uploader != null && widget.tag != null
        ? i18n.tagUploaderGalleries(
            widget.preferredTag(context)!, widget.uploader!)
        : widget.uploader != null
            ? i18n.uploaderGalleries(widget.uploader!)
            : widget.tag != null
                ? i18n.tagGalleries(widget.preferredTag(context)!)
                : i18n.galleries;
    if (isTop(context)) {
      setCurrentTitle(title, Theme.of(context).primaryColor.value);
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
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ]),
        body: PagedListView<int, GMeta>(
          physics: const AlwaysScrollableScrollPhysics(),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<GMeta>(
              itemBuilder: (context, item, index) {
            return ListTile(
              title: Text(item.preferredTitle),
              onTap: () {
                context.push("/gallery/${item.gid}",
                    extra: GalleryPageExtra(title: item.preferredTitle));
              },
            );
          }),
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
