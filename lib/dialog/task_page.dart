import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../api/task.dart';
import '../components/fit_text.dart';
import '../components/rate.dart';
import '../globals.dart';
import '../main.dart';
import '../utils/duration.dart';
import '../utils/filesize.dart';

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.name, this.value, {this.fontSize});
  final String name;
  final String value;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      SizedBox(
          width: 80,
          child: Center(
              child: Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.primary, fontSize: fontSize)))),
      Expanded(
        child: SelectableText(value,
            style: TextStyle(color: cs.secondary, fontSize: fontSize)),
      )
    ]);
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage(this.id, {super.key});
  final int id;

  static const routeName = "/dialog/task/:id";

  @override
  State<StatefulWidget> createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> {
  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  void _onProgressUpdated(dynamic arg) {
    final id = arg as int;
    if (id != widget.id) return;
    setState(() {});
  }

  @override
  void initState() {
    listener.on("task_list_changed", _onStateChanged);
    listener.on("task_meta_updated", _onStateChanged);
    listener.on("task_progress_updated", _onProgressUpdated);
    super.initState();
  }

  @override
  void dispose() {
    listener.removeEventListener("task_list_changed", _onStateChanged);
    listener.removeEventListener("task_meta_updated", _onStateChanged);
    listener.removeEventListener("task_progress_updated", _onProgressUpdated);
    super.dispose();
  }

  Widget _buildBasicInfo(BuildContext context) {
    if (!tasks.tasksList.contains(widget.id)) return Container();
    final i18n = AppLocalizations.of(context)!;
    final task = tasks.tasks[widget.id]!;
    final typ = task.base.type;
    String gid = "";
    if (task.base.gid != 0) {
      gid = task.base.gid.toString();
    }
    if (task.base.gid == 0 &&
        (typ == TaskType.fixGalleryPage ||
            typ == TaskType.updateMeiliSearchData)) {
      gid = i18n.allGalleries;
    }
    final maxWidth = MediaQuery.of(context).size.width;
    final endIndent = maxWidth < 400 ? 5.0 : 10.0;
    final indent = endIndent + 70;
    final allowLink = task.base.gid != 0 &&
        (typ != TaskType.download ||
            task.status == TaskStatus.running ||
            task.status == TaskStatus.finished);
    String? title;
    if (typ == TaskType.download && tasks.meta.containsKey(task.base.gid)) {
      title = tasks.meta[task.base.gid]!.preferredTitle;
    }
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _KeyValue(i18n.taskId, widget.id.toString(), fontSize: 16),
        Divider(indent: indent, endIndent: endIndent),
        _KeyValue(i18n.taskType, typ.text(context), fontSize: 16),
        Divider(indent: indent, endIndent: endIndent),
        Row(children: [
          SizedBox(
              width: 80,
              child: Center(
                  child: Text(i18n.gid,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.primary, fontSize: 16)))),
          Expanded(
              child: allowLink
                  ? SelectableText.rich(TextSpan(
                      text: gid,
                      style: TextStyle(color: cs.secondary, fontSize: 16),
                      mouseCursor: SystemMouseCursors.click,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.push("/gallery/${task.base.gid}",
                              extra: GalleryPageExtra(title: title));
                        }))
                  : SelectableText(gid,
                      style: TextStyle(color: cs.secondary, fontSize: 16))),
        ]),
        task.base.token.isEmpty
            ? Container()
            : Divider(indent: indent, endIndent: endIndent),
        task.base.token.isEmpty
            ? Container()
            : _KeyValue(i18n.galleryToken, task.base.token, fontSize: 16),
        Divider(indent: indent, endIndent: endIndent),
        _KeyValue(i18n.processId, task.base.pid.toString(), fontSize: 16),
        Divider(indent: indent, endIndent: endIndent),
        _KeyValue(i18n.taskStatus, task.status.text(context), fontSize: 16),
        task.fataled == null
            ? Container()
            : Divider(indent: indent, endIndent: endIndent),
        task.fataled == null
            ? Container()
            : _KeyValue(i18n.fatalError, task.fataled! ? i18n.yes : i18n.no,
                fontSize: 16),
        task.error == null
            ? Container()
            : Divider(indent: indent, endIndent: endIndent),
        task.error == null
            ? Container()
            : SelectableText(task.error!,
                style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  bool get haveProgress => tasks.tasksList.contains(widget.id)
      ? tasks.tasks[widget.id]!.status == TaskStatus.running &&
          tasks.tasks[widget.id]!.progress != null
      : false;

  Widget _buildProgress(BuildContext context) {
    if (!haveProgress) return Container();
    final task = tasks.tasks[widget.id]!;
    final typ = task.base.type;
    if (typ == TaskType.download) {
      final p = task.progress as TaskDownloadProgess;
      final i18n = AppLocalizations.of(context)!;
      if (p.totalPage == 0) {
        return Text(i18n.fetchingMetadata);
      }
      double speed = 0;
      final dlUseAvgSpeed = prefs.getBool("dlUseAvgSpeed") ?? false;
      if (dlUseAvgSpeed) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > p.started) speed = p.downloadedBytes / (now - p.started);
      } else {
        for (final e in p.details) {
          speed += e.speed;
        }
      }
      if (p.failedPage == 0) {
        double downloaded = p.downloadedPage.toDouble();
        for (final e in p.details) {
          downloaded += e.total == 0 ? 0 : e.downloaded / e.total;
        }
        final percent = downloaded / p.totalPage;
        final percentText = "${(percent * 100).toStringAsFixed(2)}%";
        return Column(children: [
          LinearPercentIndicator(
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 200,
            progressColor: Colors.green,
            lineHeight: 20.0,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
            center:
                Text(percentText, style: const TextStyle(color: Colors.black)),
            percent: percent,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: FitText(
              texts: [
                (i18n.downloadedSize(getFileSize(p.downloadedBytes)), 0),
                ("${p.downloadedPage}/${p.totalPage}", 1)
              ],
              overflow: TextOverflow.ellipsis,
              separator: i18n.comma,
              maxLines: 1,
            )),
            Text("${getFileSize((speed * 1000).toInt())}/s"),
          ]),
        ]);
      }
      return Column(children: [
        _KeyValue(i18n.downloadedPages, p.downloadedPage.toString(),
            fontSize: 16),
        _KeyValue(i18n.failedPages, p.failedPage.toString(), fontSize: 16),
        _KeyValue(i18n.totalPages, p.totalPage.toString(), fontSize: 16),
        _KeyValue(i18n.downloadedSize2, getFileSize(p.downloadedBytes),
            fontSize: 16),
        _KeyValue(i18n.speed, "${getFileSize((speed * 1000).toInt())}/s",
            fontSize: 16),
      ]);
    }
    int now = 0;
    int total = 0;
    switch (typ) {
      case TaskType.exportZip:
        final p = task.progress as TaskExportZipProgress;
        now = p.addedPage;
        total = p.totalPage;
      case TaskType.fixGalleryPage:
        final p = task.progress as TaskFixGalleryPageProgress;
        now = p.checkedGallery;
        total = p.totalGallery;
      case TaskType.updateMeiliSearchData:
        final p = task.progress as TaskUpdateMeiliSearchDataProgress;
        now = p.updatedGallery;
        total = p.totalGallery;
      case TaskType.import:
        final p = task.progress as TaskImportProgress;
        now = p.importedPage;
        total = p.totalPage;
      default:
    }
    if (total == 0) return Container();
    final percent = now / total;
    final percentText = "${(percent * 100).toStringAsFixed(2)}%";
    return Row(children: [
      Expanded(
          child: LinearPercentIndicator(
        animation: true,
        animateFromLastPercent: true,
        animationDuration: 200,
        progressColor: Colors.green,
        lineHeight: 20.0,
        barRadius: const Radius.circular(10),
        padding: EdgeInsets.zero,
        center: Text(percentText, style: const TextStyle(color: Colors.black)),
        percent: percent,
      )),
      Text("$now/$total"),
    ]);
  }

  Widget _buildMoreProgress(BuildContext context) {
    if (!haveProgress) return SliverToBoxAdapter(child: Container());
    final task = tasks.tasks[widget.id]!;
    if (task.base.type != TaskType.download) {
      return SliverToBoxAdapter(child: Container());
    }
    final p = task.progress as TaskDownloadProgess;
    if (p.details.isEmpty) return SliverToBoxAdapter(child: Container());
    final i18n = AppLocalizations.of(context)!;
    final dlUseAvgSpeed = prefs.getBool("dlUseAvgSpeed") ?? false;
    return SliverList.builder(
      itemCount: p.details.length,
      itemBuilder: (context, index) {
        final d = p.details[index];
        final percent = d.total == 0 ? 0.0 : d.downloaded / d.total;
        final percentText = "${(percent * 100).toStringAsFixed(2)}%";
        final avgSpeed = d.started.millisecondsSinceEpoch == 0
            ? 0.0
            : d.downloaded /
                (d.lastUpdated.millisecondsSinceEpoch -
                    d.started.millisecondsSinceEpoch);
        final eta = d.total == 0
            ? double.infinity
            : (d.total - d.downloaded) / avgSpeed;
        final speed = dlUseAvgSpeed
            ? d.total == 0
                ? 0.0
                : avgSpeed
            : d.speed;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FitText(
            texts: [
              ("${d.index}.", 2),
              (d.name, 3),
              ("(${d.width}x${d.height})", 0),
              (d.isOriginal ? "(${i18n.originalImg})" : "", 1)
            ],
            selectable: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          LinearPercentIndicator(
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 200,
            progressColor: Colors.green,
            lineHeight: 20.0,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
            center:
                Text(percentText, style: const TextStyle(color: Colors.black)),
            percent: percent,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text(
                    "${getFileSize(d.downloaded)}/${getFileSize(d.total)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            Text(
                "${getFileSize((speed * 1000).toInt())}/s${i18n.comma}${fmtDuration(context, eta)}"),
          ]),
        ]);
      },
    );
  }

  bool get haveMetaInfo {
    if (!tasks.tasksList.contains(widget.id)) return false;
    final task = tasks.tasks[widget.id]!;
    final typ = task.base.type;
    return (typ == TaskType.download || typ == TaskType.import) &&
        tasks.meta.containsKey(task.base.gid);
  }

  Widget _buildMetaInfo(BuildContext context) {
    if (!haveMetaInfo) return Container();
    final task = tasks.tasks[widget.id]!;
    final meta = tasks.meta[task.base.gid]!;
    final i18n = AppLocalizations.of(context)!;
    final locale = MainApp.of(context).lang.toLocale().toString();
    DateTime? posted;
    final r = int.tryParse(meta.posted);
    if (r != null) {
      posted = DateTime.fromMillisecondsSinceEpoch(r! * 1000);
    }
    final cs = Theme.of(context).colorScheme;
    double? rating = double.tryParse(meta.rating);
    final maxWidth = MediaQuery.of(context).size.width;
    final endIndent = maxWidth < 400 ? 5.0 : 10.0;
    final indent = endIndent + 70;
    return Column(key: ValueKey("task_detail_meta_${widget.id}"), children: [
      _KeyValue(i18n.title2, meta.title, fontSize: 16),
      meta.titleJpn.isNotEmpty
          ? Divider(indent: indent, endIndent: endIndent)
          : Container(),
      meta.titleJpn.isNotEmpty
          ? _KeyValue(i18n.titleJpn, meta.titleJpn, fontSize: 16)
          : Container(),
      Divider(indent: indent, endIndent: endIndent),
      _KeyValue(i18n.category, meta.category, fontSize: 16),
      Divider(indent: indent, endIndent: endIndent),
      _KeyValue(i18n.uploader, meta.uploader, fontSize: 16),
      posted != null
          ? Divider(indent: indent, endIndent: endIndent)
          : Container(),
      posted != null
          ? _KeyValue(
              i18n.posted, DateFormat.yMd(locale).add_jms().format(posted),
              fontSize: 16)
          : Container(),
      Divider(indent: indent, endIndent: endIndent),
      _KeyValue(i18n.pageLength, meta.filecount, fontSize: 16),
      Divider(indent: indent, endIndent: endIndent),
      _KeyValue(i18n.fileSize, getFileSize(meta.filesize), fontSize: 16),
      Divider(indent: indent, endIndent: endIndent),
      _KeyValue(i18n.visible, meta.expunged ? i18n.no : i18n.yes, fontSize: 16),
      rating != null
          ? Divider(indent: indent, endIndent: endIndent)
          : Container(),
      rating != null
          ? Row(children: [
              SizedBox(
                  width: 80,
                  child: Center(
                      child: Text(i18n.rating,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.primary, fontSize: 16)))),
              Expanded(child: Rate(rating!, fontSize: 16, selectable: true)),
            ])
          : Container(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    tryInitApi(context);
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    final indent = maxWidth < 400 ? 5.0 : 10.0;
    return Container(
      padding: maxWidth < 400
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 5)
          : const EdgeInsets.all(20),
      width: maxWidth < 810 ? null : 800,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  i18n.taskDetails,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go("/task_manager"),
                      icon: const Icon(Icons.close),
                    )),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _buildBasicInfo(context)),
          SliverToBoxAdapter(
              child: haveProgress
                  ? Divider(indent: indent, endIndent: indent)
                  : Container()),
          SliverToBoxAdapter(child: _buildProgress(context)),
          _buildMoreProgress(context),
          SliverToBoxAdapter(
              child: haveMetaInfo
                  ? Divider(indent: indent, endIndent: indent)
                  : Container()),
          SliverToBoxAdapter(child: _buildMetaInfo(context)),
        ],
      ),
    );
  }
}
