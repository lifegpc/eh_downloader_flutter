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
        return progress.downloadedPage / progress.totalPage;
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
    if (widget.task.base.type == TaskType.download) {
      final gid = widget.task.base.gid;
      return Row(children: [
        Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(i18n.downloadTask)),
        Text(tasks.meta.containsKey(gid)
            ? tasks.meta[gid]!.preferredTitle
            : gid.toString()),
      ]);
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
                child: Column(children: [
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