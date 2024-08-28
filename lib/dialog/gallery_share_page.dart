import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import '../api/token.dart';
import '../globals.dart';
import '../main.dart';
import '../platform/media_query.dart';
import '../utils.dart';
import '../utils/clipboard.dart';

final _log = Logger("GallerySharePage");

Future<void> _change(
    String token, DateTime? expired, AppLocalizations i18n) async {
  try {
    final t = (await api.updateShareGallery(token,
            expired: expired?.millisecondsSinceEpoch))
        .unwrap();
    listener.tryEmit("gallery_share_token_changed", t);
  } catch (e, stack) {
    String errmsg = "${i18n.failedChangeExpireTime}$e";
    if (e is (int, String)) {
      _log.warning("Failed to change expire time: $e");
    } else {
      _log.severe("Failed to change expire time: $e\n$stack");
    }
    final snack = SnackBar(content: Text(errmsg));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

Future<void> _add(int gid, DateTime? expired, AppLocalizations i18n) async {
  try {
    final t =
        (await api.shareGallery(gid, expired: expired?.millisecondsSinceEpoch))
            .unwrap();
    listener.tryEmit("gallery_share_token_added", t);
  } catch (e, stack) {
    String errmsg = "${i18n.failedShareGallery}$e";
    if (e is (int, String)) {
      _log.warning("Failed to share gallery: $e");
    } else {
      _log.severe("Failed to share gallery: $e\n$stack");
    }
    final snack = SnackBar(content: Text(errmsg));
    rootScaffoldMessengerKey.currentState?.showSnackBar(snack);
  }
}

class _ChangeDialog extends StatefulWidget {
  const _ChangeDialog(this.gid, {this.token});
  final int gid;
  final String? token;
  @override
  State<_ChangeDialog> createState() => _ChangeDialogState();
}

enum _ExpireDuration {
  day,
  week,
  month,
  never,
  custom;

  DateTime? expiredTime() {
    switch (this) {
      case _ExpireDuration.day:
        return DateTime.now().add(const Duration(days: 1));
      case _ExpireDuration.week:
        return DateTime.now().add(const Duration(days: 7));
      case _ExpireDuration.month:
        return DateTime.now().add(const Duration(days: 30));
      default:
        return null;
    }
  }

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case _ExpireDuration.custom:
        return i18n.custom;
      case _ExpireDuration.day:
        return i18n.oneDayAfter;
      case _ExpireDuration.week:
        return i18n.oneWeekAfter;
      case _ExpireDuration.month:
        return i18n.oneMonthAfter;
      case _ExpireDuration.never:
        return i18n.never;
    }
  }
}

class _ChangeDialogState extends State<_ChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _expired = DateTime.now();
  _ExpireDuration _dur = _ExpireDuration.never;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return AlertDialog(
      title:
          Text(widget.token != null ? i18n.editExpireTime : i18n.shareGallery),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<_ExpireDuration>(
              items: _ExpireDuration.values
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e.localText(context))))
                  .toList(),
              value: _dur,
              onChanged: (dur) {
                if (dur != null) {
                  setState(() {
                    _dur = dur;
                  });
                }
                if (dur == _ExpireDuration.custom) {
                  DatePicker.showDateTimePicker(context, onConfirm: (e) {
                    setState(() {
                      _expired = e;
                    });
                  },
                      locale: MainApp.of(context).lang.toLocaleType(),
                      minTime: DateTime.now());
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: i18n.expireTime,
              )),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: _dur != _ExpireDuration.custom ||
                    _dur == _ExpireDuration.custom &&
                        _expired.isAfter(DateTime.now())
                ? () {
                    final expired = _dur != _ExpireDuration.custom
                        ? _dur.expiredTime()
                        : _expired;
                    if (widget.token != null) {
                      _change(widget.token!, expired, i18n);
                    } else {
                      _add(widget.gid, expired, i18n);
                    }
                    context.pop();
                  }
                : null,
            child: Text(widget.token != null ? i18n.edit : i18n.share)),
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(i18n.cancel)),
      ],
    );
  }
}

class GallerySharePage extends StatefulWidget {
  const GallerySharePage(this.gid, {super.key});
  final int gid;

  static const routeName = "/dialog/gallery/share/:gid";

  @override
  State<GallerySharePage> createState() => _GallerySharePage();
}

class _GallerySharePage extends State<GallerySharePage> {
  List<SharedTokenWithUrl>? _lists;
  CancelToken? _cancel;
  bool _isLoading = false;
  Object? _error;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchList() async {
    _cancel = CancelToken();
    _isLoading = true;
    try {
      _lists = (await api.listShareGalleries(gid: widget.gid, cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load gallery shared list ${widget.gid}:", e);
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  void onTokenChanged(dynamic arg) {
    if (_lists == null) return;
    final t = arg as SharedTokenWithUrl;
    final ind = _lists!.indexWhere((a) => a.token.id == t.token.id);
    if (ind != -1) {
      setState(() {
        _lists![ind] = t;
      });
    }
  }

  void onTokenAdded(dynamic arg) {
    if (_lists == null) return;
    final t = arg as SharedTokenWithUrl;
    final g = t.token.info as GallerySharedTokenInfo;
    if (g.gid == widget.gid) {
      setState(() {
        _lists!.add(t);
      });
    }
  }

  @override
  void initState() {
    listener.on("gallery_share_token_changed", onTokenChanged);
    listener.on("gallery_share_token_added", onTokenAdded);
    super.initState();
  }

  @override
  void dispose() {
    _cancel?.cancel();
    listener.removeEventListener("gallery_share_token_changed", onTokenChanged);
    listener.removeEventListener("gallery_share_token_added", onTokenAdded);
    super.dispose();
  }

  Widget _buildView(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final p = Theme.of(context).colorScheme.primary;
    final s = TextStyle(color: p);
    return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                i18n.shareGallery,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go("/gallery/${widget.gid}"),
                    icon: const Icon(Icons.close),
                  )),
            ],
          )),
          SliverToBoxAdapter(
              child: Row(children: [
            Expanded(
                child: Text(i18n.token, textAlign: TextAlign.center, style: s)),
            Expanded(
                child: Text(i18n.expireTime,
                    textAlign: TextAlign.center, style: s)),
            SizedBox(
                width: 120,
                child:
                    Text(i18n.action, textAlign: TextAlign.center, style: s)),
          ])),
          SliverList.builder(
              itemBuilder: (context, index) {
                final item = _lists![index];
                return Row(children: [
                  Expanded(
                      child: SelectableText(item.token.token,
                          textAlign: TextAlign.center)),
                  Expanded(
                    child: SelectableText(
                        item.token.expired == null
                            ? i18n.never
                            : DateFormat.yMd(MainApp.of(context)
                                    .lang
                                    .toLocale()
                                    .toString())
                                .add_jms()
                                .format(item.token.expired!.toLocal()),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: 120,
                    child: Row(children: [
                      IconButton.filled(
                          onPressed: () {
                            copyTextToClipboard(item.url);
                          },
                          icon: const Icon(Icons.link)),
                      IconButton.filled(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => _ChangeDialog(widget.gid,
                                  token: item.token.token)),
                          icon: const Icon(Icons.edit)),
                      IconButton.filled(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(title: Text(i18n.delete));
                              }),
                          icon: const Icon(Icons.delete)),
                    ]),
                  ),
                ]);
              },
              itemCount: _lists!.length),
        ]);
  }

  Widget _buildRefreshIcon(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return IconButton(
        onPressed: () {
          _refreshIndicatorKey.currentState?.show();
        },
        tooltip: i18n.refresh,
        icon: const Icon(Icons.refresh));
  }

  Widget _buildAddIcon(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return IconButton(
        onPressed: () => showDialog(
            context: context, builder: (context) => _ChangeDialog(widget.gid)),
        tooltip: i18n.create,
        icon: const Icon(Icons.add));
  }

  Widget _buildIconList(BuildContext context) {
    return Row(children: [
      isDesktop || (kIsWeb && pointerIsMouse)
          ? _buildRefreshIcon(context)
          : Container(),
      _buildAddIcon(context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final isLoading = _lists == null && _error == null;
    final i18n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width;
    if (isLoading && !_isLoading) _fetchList();
    return Container(
      padding: maxWidth < 400
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
          : const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      width: maxWidth < 810 ? null : 800,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? SingleChildScrollView(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: $_error"),
                    ElevatedButton.icon(
                        onPressed: () {
                          _fetchList();
                          setState(() {
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(i18n.retry)),
                  ],
                ))
              : Stack(
                  children: <Widget>[
                    RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: () async {
                          return await _fetchList();
                        },
                        child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                            child: _buildView(context))),
                    Positioned(
                        bottom: size.height / 10,
                        right: size.width / 10,
                        child: _buildIconList(context))
                  ],
                ),
    );
  }
}
