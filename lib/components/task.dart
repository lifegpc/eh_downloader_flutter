import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../api/task.dart';
import '../globals.dart';

class TaskView extends StatefulWidget {
  const TaskView(this.task, this.index, {super.key});
  final TaskDetail task;
  final int index;

  @override
  State<StatefulWidget> createState() => _TaskView();
}

class _TaskView extends State<TaskView> {
  @override
  void initState() {
    listener.on("task_meta_updated", _onStateChanged);
    listener.on("task_progress_updated", _onProgressUpdated);
    super.initState();
  }

  void _onStateChanged(dynamic _) {
    setState(() {});
  }

  void _onProgressUpdated(dynamic arg) {
    final id = arg as int;
    if (id != widget.task.base.id) return;
    setState(() {});
  }

  double get percent {
    if (widget.task.status == TaskStatus.finished) return 1;
    if (widget.task.status != TaskStatus.running) return 0;
    if (widget.task.progress == null) return 0;
    switch (widget.task.base.type) {
      case TaskType.download:
        final progress = widget.task.progress as TaskDownloadProgess;
        double d = progress.downloadedPage.toDouble();
        for (final e in progress.details) {
          d += e.total == 0 ? 0 : e.downloaded / e.total;
        }
        return d / progress.totalPage;
      case TaskType.exportZip:
        final progress = widget.task.progress as TaskExportZipProgress;
        return progress.addedPage / progress.totalPage;
      case TaskType.fixGalleryPage:
        final progress = widget.task.progress as TaskFixGalleryPageProgress;
        return progress.checkedGallery / progress.totalGallery;
      case TaskType.updateMeiliSearchData:
        final progress =
            widget.task.progress as TaskUpdateMeiliSearchDataProgress;
        return progress.updatedGallery / progress.totalGallery;
      case TaskType.import:
        final progress = widget.task.progress as TaskImportProgress;
        return progress.importedPage / progress.totalPage;
      case TaskType.updateTagTranslation:
        final progress =
            widget.task.progress as TaskUpdateTagTranslationProgress;
        return progress.addedTag / progress.totalTag;
    }
  }

  String get percentText {
    return "${(percent * 100).toStringAsFixed(2)}%";
  }

  @override
  void dispose() {
    listener.removeEventListener("task_meta_updated", _onStateChanged);
    listener.removeEventListener("task_progress_updated", _onProgressUpdated);
    super.dispose();
  }

  Widget _buildText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final typ = widget.task.base.type;
    if (typ == TaskType.download) {
      final gid = widget.task.base.gid;
      final title = tasks.meta.containsKey(gid)
          ? tasks.meta[gid]!.preferredTitle
          : gid.toString();
      return Text("${i18n.downloadTask} $title",
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    if (typ == TaskType.exportZip) {
      final gid = widget.task.base.gid;
      final title = tasks.gmeta.containsKey(gid)
          ? tasks.gmeta[gid]!.preferredTitle
          : gid.toString();
      return Text("${i18n.exportZipTask} $title",
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    if (typ == TaskType.import) {
      final gid = widget.task.base.gid;
      final title = tasks.meta.containsKey(gid)
          ? tasks.meta[gid]!.preferredTitle
          : gid.toString();
      return Text("${i18n.importTask} $title",
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    if (typ == TaskType.updateTagTranslation) {
      return Text(i18n.updateTagTranslation,
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    if (typ == TaskType.updateMeiliSearchData) {
      return Text(i18n.updateMeiliSearchDataTask,
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ReorderableDragStartListener(
                index: widget.index, child: const Icon(Icons.reorder))),
        Expanded(
            child: GestureDetector(
                onTap: () {
                  context.push("/dialog/task/${widget.task.base.id}");
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildText(context),
                      LinearPercentIndicator(
                        animation: true,
                        animateFromLastPercent: true,
                        animationDuration: 200,
                        progressColor: Colors.green,
                        lineHeight: 20.0,
                        barRadius: const Radius.circular(10),
                        padding: EdgeInsets.zero,
                        center: Text(percentText,
                            style: const TextStyle(color: Colors.black)),
                        percent: percent,
                      ),
                    ]))),
      ]),
    );
  }
}
