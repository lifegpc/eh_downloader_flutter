import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logging/logging.dart';
import 'api/gallery.dart';
import 'globals.dart';

final _log = Logger("GalleriesPage");

class GalleriesPage extends StatefulWidget {
  const GalleriesPage({Key? key}) : super(key: key);

  static const String routeName = '/galleries';

  @override
  State<GalleriesPage> createState() => _GalleriesPage();
}

class _GalleriesPage extends State<GalleriesPage> with ThemeModeWidget {
  static const int _pageSize = 20;

  final PagingController<int, GMeta> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final list =
          (await api.listGalleries(offset: pageKey, limit: _pageSize)).unwrap();
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
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              buildThemeModeIcon(context),
              buildMoreVertSettingsButon(context),
            ]),
        body: PagedListView<int, GMeta>(
          physics: const AlwaysScrollableScrollPhysics(),
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<GMeta>(
              itemBuilder: (context, item, index) {
            return ListTile(
              title: SelectableText(item.title),
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
