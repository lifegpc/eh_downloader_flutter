import 'dart:math';
import 'dart:ui';
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:quiver/collection.dart';
import '../api/log.dart';
import '../globals.dart';
import '../main.dart';

final _log = Logger('LogsPage');

class LogsPage extends StatefulWidget {
  const LogsPage(
      {super.key,
      this.page,
      this.type,
      this.minLevel,
      this.allowedLevel,
      this.size});

  static const String routeName = '/logs';

  final int? page;
  final String? type;
  final LogLevel? minLevel;
  final List<LogLevel>? allowedLevel;
  final int? size;

  @override
  State<LogsPage> createState() => _LogsPage();
}

class _LogDataSource extends AdvancedDataTableSource<LogEntry> {
  _LogDataSource(
      {this.type,
      this.minLevel,
      this.allowedLevel,
      this.size = 10,
      this.page = 1,
      this.locale});
  final String? type;
  final LogLevel? minLevel;
  final List<LogLevel>? allowedLevel;
  int size;
  final String? locale;
  int? count;
  int page;
  LruMap<int, List<LogEntry>> logs = LruMap(maximumSize: 20);
  bool offsetMode = false;
  List<LogEntry> offsetData = [];
  @override
  bool get isRowCountApproximate => count != null;
  @override
  int get rowCount => count ?? 0;
  @override
  int get selectedRowCount => 0;
  @override
  Future<RemoteDataSourceDetails<LogEntry>> getNextPage(
      NextPageRequest pageRequest) async {
    if (size != pageRequest.pageSize) {
      size = pageRequest.pageSize;
      logs.clear();
    }
    if (pageRequest.offset % size != 0) {
      offsetMode = true;
      offsetData = (await api.queryLog(
              offset: pageRequest.offset,
              limit: size,
              minLevel: minLevel?.toInt(),
              allowedLevel: allowedLevel?.map((e) => e.toInt()).join(","),
              type: type))
          .unwrap()
          .datas;
      return RemoteDataSourceDetails(count ?? offsetData.length, offsetData);
    }
    offsetMode = false;
    int npage = pageRequest.offset ~/ pageRequest.pageSize + 1;
    page = npage;
    var log = logs[page];
    if (log != null) {
      return RemoteDataSourceDetails(count ?? log.length, log);
    }
    var data = (await api.queryLog(
            page: page,
            type: type,
            minLevel: minLevel?.toInt(),
            allowedLevel: allowedLevel?.map((e) => e.toInt()).join(","),
            limit: size))
        .unwrap();
    if (count != data.count) {
      logs.clear();
    }
    count = data.count;
    logs[page] = data.datas;
    return RemoteDataSourceDetails(count ?? data.datas.length, data.datas);
  }

  DataRow? getDataRow(LogEntry? log) {
    if (log == null) return null;
    var messages = log.message.split("\n");
    var message = messages.getRange(0, min(messages.length, 2)).join("\n");
    return DataRow(cells: [
      DataCell(SelectableText(
          DateFormat.yMd(locale).add_jms().format(log.time.toLocal()))),
      DataCell(SelectableText(message, minLines: 1, maxLines: 2)),
      DataCell(SelectableText(log.level.name)),
      DataCell(SelectableText(log.type)),
    ]);
  }

  @override
  DataRow? getRow(int index) {
    if (offsetMode) {
      var log = offsetData.elementAtOrNull(index);
      return getDataRow(log);
    }
    var vlog = logs[page];
    if (vlog == null) return null;
    var log = vlog.elementAtOrNull(index);
    return getDataRow(log);
  }
}

class _LogsPage extends State<LogsPage> with ThemeModeWidget, IsTopWidget2 {
  int? _page;
  String? _type;
  LogLevel? _minLevel;
  List<LogLevel>? _allowedLevel;
  int _size = 10;
  int _offset = 0;
  bool _pageMode = false;
  _LogDataSource? _dataSource;

  @override
  void initState() {
    _page = widget.page;
    _type = widget.type;
    _minLevel = widget.minLevel ?? LogLevel.log;
    _allowedLevel = widget.allowedLevel;
    _size = widget.size ?? 10;
    _pageMode =
        _page != null ? true : (prefs.getBool("serverLogsPageMode") ?? true);
    super.initState();
  }

  void updateRoute(BuildContext context) {
    var params = {
      "page": _page?.toString(),
      "type": _type,
      "min_level": _minLevel?.name,
      "allowed_level": _allowedLevel?.map((e) => e.name).join(","),
      "size": _size.toString(),
    };
    params.removeWhere((key, value) => value == null || value!.isEmpty);
    context.replaceNamed("/logs", queryParameters: params);
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.serverLogs);
    }
    final locale = MainApp.of(context).lang.toLocale().toString();
    if (_pageMode) {
      _dataSource ??= _LogDataSource(
          page: _page ?? 1,
          type: _type,
          minLevel: _minLevel,
          allowedLevel: _allowedLevel,
          size: _size,
          locale: locale);
      _offset = ((_page ?? 1) - 1) * _size;
    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.canPop() ? context.pop() : context.go("/");
            },
          ),
          title: Text(i18n.serverLogs),
          actions: [
            buildThemeModeIcon(context),
            buildMoreVertSettingsButon(context),
          ],
        ),
        body: _pageMode
            ? _dataSource != null
                ? SingleChildScrollView(
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: (AdvancedPaginatedDataTable(
                            columns: <DataColumn>[
                              DataColumn(label: Text(i18n.time)),
                              DataColumn(label: Text(i18n.message)),
                              DataColumn(label: Text(i18n.level)),
                              DataColumn(label: Text(i18n.type)),
                            ],
                            source: _dataSource!,
                            rowsPerPage: _size,
                            onPageChanged: (page) {
                              _page = page ~/ _size + 1;
                              updateRoute(context);
                            },
                            showHorizontalScrollbarAlways: true,
                            showFirstLastButtons: true,
                            initialFirstRowIndex: _offset,
                            onRowsPerPageChanged: (size) {
                              setState(() {
                                _size = size ?? 10;
                                _page = _offset ~/ _size + 1;
                                updateRoute(context);
                              });
                            },
                            addEmptyRows: false))))
                : const Center(child: CircularProgressIndicator())
            : Container());
  }
}
