import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
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
  _LogDataSource(this.logs,
      {this.type,
      this.minLevel,
      this.allowedLevel,
      this.size = 10,
      this.count,
      this.page = 1,
      this.locale,
      this.start = 0});
  final String? type;
  final LogLevel? minLevel;
  final List<LogLevel>? allowedLevel;
  final int size;
  final String? locale;
  int? count;
  int start;
  int page;
  List<LogEntry> logs;
  @override
  bool get isRowCountApproximate => count == null;
  @override
  int get rowCount => count ?? 10;
  @override
  int get selectedRowCount => 0;
  @override
  Future<RemoteDataSourceDetails<LogEntry>> getNextPage(
      NextPageRequest pageRequest) async {
    int npage = pageRequest.offset ~/ pageRequest.pageSize + 1;
    page = npage;
    if ((logs.length >= pageRequest.offset + pageRequest.pageSize - start &&
            pageRequest.offset >= start) ||
        logs.length == count) {
      return RemoteDataSourceDetails(count ?? logs.length, logs);
    }
    var data = (await api.queryLog(
            page: page,
            type: type,
            minLevel: minLevel?.toInt(),
            allowedLevel: allowedLevel?.map((e) => e.toInt()).join(","),
            limit: size))
        .unwrap();
    count = data.count;
    if (pageRequest.offset < start) {
      logs.insertAll(0, data.datas);
      start -= data.datas.length;
    } else {
      logs.addAll(data.datas);
    }
    return RemoteDataSourceDetails(count ?? logs.length, logs);
  }

  @override
  DataRow? getRow(int index) {
    index += (page - 1) * size;
    index -= start;
    var log = logs.elementAtOrNull(index);
    if (log == null) return null;
    return DataRow(cells: [
      DataCell(
          Text(DateFormat.yMd(locale).add_jms().format(log.time.toLocal()))),
      DataCell(Text(log.message)),
      DataCell(Text(log.level.name)),
      DataCell(Text(log.type)),
    ]);
  }
}

class _LogsPage extends State<LogsPage> with ThemeModeWidget, IsTopWidget2 {
  int? _page;
  String? _type;
  LogLevel? _minLevel;
  List<LogLevel>? _allowedLevel;
  int _size = 50;
  bool _pageMode = false;
  _LogDataSource? _dataSource;
  CancelToken? _cancel;
  bool _isLoading = false;
  LogEntries? _firstPage;

  Future<void> _fetchFirstPage() async {
    try {
      _cancel = CancelToken();
      _isLoading = true;
      _firstPage = (await api.queryLog(
              page: _page ?? 1,
              type: _type,
              minLevel: _minLevel?.toInt(),
              allowedLevel: _allowedLevel?.map((e) => e.toInt()).join(","),
              limit: _size,
              cancel: _cancel))
          .unwrap();
      if (!_cancel!.isCancelled) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_cancel!.isCancelled) {
        _log.severe("Failed to load first page:", e);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final i18n = AppLocalizations.of(context)!;
    if (isTop(context)) {
      setCurrentTitle(i18n.serverLogs);
    }
    final locale = MainApp.of(context).lang.toLocale().toString();
    bool isLoading = false;
    if (_pageMode) {
      isLoading = _firstPage == null;
      if (isLoading && !_isLoading) _fetchFirstPage();
      if (_dataSource == null && _firstPage != null) {
        _dataSource = _LogDataSource(_firstPage!.datas,
            page: _page ?? 1,
            type: _type,
            minLevel: _minLevel,
            allowedLevel: _allowedLevel,
            size: _size,
            count: _firstPage!.count,
            locale: locale,
            start: (_page ?? 1 - 1) * _size);
      }
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
                ? AdvancedPaginatedDataTable(
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
                      var params = {
                        "page": _page?.toString(),
                        "type": _type,
                        "min_level": _minLevel?.name,
                        "allowed_level":
                            _allowedLevel?.map((e) => e.name).join(","),
                        "size": _size.toString(),
                      };
                      params.removeWhere(
                          (key, value) => value == null || value!.isEmpty);
                      context.replaceNamed("/logs", queryParameters: params);
                    })
                : const Center(child: CircularProgressIndicator())
            : Container());
  }
}
