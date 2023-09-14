import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'api/client.dart';
import 'api/gallery.dart';
import 'globals.dart';

final _log = Logger("GalleriesPage");

class GalleriesPage extends StatefulWidget {
  const GalleriesPage({Key? key, this.sortByGid}) : super(key: key);
  final SortByGid? sortByGid;

  static const String routeName = '/galleries';

  @override
  State<GalleriesPage> createState() => _GalleriesPage();
}

class _GalleriesPage extends State<GalleriesPage> with ThemeModeWidget {
  static const int _pageSize = 20;
  bool? _sortByGid;
  SortByGid _sortByGid2 = SortByGid.none;

  final PagingController<int, GMeta> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final list = (await api.listGalleries(
              offset: pageKey, limit: _pageSize, sortByGid: _sortByGid))
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
    final sortByGidMenu = DropdownMenu<SortByGid>(
      initialSelection: _sortByGid2,
      onSelected: (v) {
        if (v != null) {
          prefs.setInt("sortByGid", v!.index).then((re) {
            if (!re) _log.warning("Failed to save sortByGid to prefs.");
          }).catchError((error) {
            _log.warning("Failed to save sortByGid to prefs:", error);
          });
          context.pushReplacementNamed("/galleries", queryParameters: {
            "sortByGid": [v!.index.toString()],
          });
        }
      },
      label: Text(AppLocalizations.of(context)!.sortByGid,
          style: MediaQuery.of(context).size.width > 810
              ? Theme.of(context).textTheme.labelMedium
              : Theme.of(context).textTheme.labelLarge),
      dropdownMenuEntries: [
        DropdownMenuEntry(
            value: SortByGid.none, label: AppLocalizations.of(context)!.none),
        DropdownMenuEntry(
            value: SortByGid.asc, label: AppLocalizations.of(context)!.asc),
        DropdownMenuEntry(
            value: SortByGid.desc, label: AppLocalizations.of(context)!.desc),
      ],
      leadingIcon: const Icon(Icons.sort),
    );
    setCurrentTitle(AppLocalizations.of(context)!.galleries);
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.canPop() ? context.pop() : context.go("/");
              },
            ),
            title: Text(AppLocalizations.of(context)!.galleries),
            actions: [
              MediaQuery.of(context).size.width > 810
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: sortByGidMenu)
                  : PopupMenuButton(
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
                context.push("/gallery/${item.gid}");
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
