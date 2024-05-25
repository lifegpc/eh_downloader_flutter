import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

enum TaskType {
  @JsonValue(0)
  download,
  @JsonValue(1)
  exportZip,
  @JsonValue(2)
  updateMeiliSearchData,
  @JsonValue(3)
  fixGalleryPage;

  String text(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case TaskType.download:
        return i18n.downloadTask;
      case TaskType.exportZip:
        return i18n.exportZipTask;
      case TaskType.updateMeiliSearchData:
        return i18n.updateMeiliSearchDataTask;
      case TaskType.fixGalleryPage:
        return i18n.fixGalleryPageTask;
    }
  }
}

@JsonSerializable()
class Task {
  const Task({
    required this.id,
    required this.type,
    required this.gid,
    required this.token,
    required this.pid,
    this.details,
  });
  final int id;
  final TaskType type;
  final int gid;
  final String token;
  final int pid;
  final String? details;
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

sealed class TaskProgressBasicType {}

@JsonSerializable()
class TaskDownloadSingleProgress {
  const TaskDownloadSingleProgress({
    required this.index,
    required this.token,
    required this.name,
    required this.width,
    required this.height,
    required this.isOriginal,
    required this.total,
    required this.started,
    required this.downloaded,
    required this.speed,
    required this.lastUpdated,
  });
  final int index;
  final String token;
  final String name;
  final int width;
  final int height;
  @JsonKey(name: 'is_original')
  final bool isOriginal;
  final int total;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime started;
  final int downloaded;
  final double speed;
  @JsonKey(name: 'last_updated')
  final int lastUpdated;
  static DateTime _fromJson(int d) =>
      DateTime.fromMillisecondsSinceEpoch(d, isUtc: true);
  static int _toJson(DateTime d) => d.millisecondsSinceEpoch;
  factory TaskDownloadSingleProgress.fromJson(Map<String, dynamic> json) =>
      _$TaskDownloadSingleProgressFromJson(json);
  Map<String, dynamic> toJson() => _$TaskDownloadSingleProgressToJson(this);
}

@JsonSerializable()
class TaskDownloadProgess implements TaskProgressBasicType {
  const TaskDownloadProgess({
    required this.downloadedPage,
    required this.failedPage,
    required this.totalPage,
    required this.details,
    required this.started,
    required this.downloadedBytes,
  });
  @JsonKey(name: 'downloaded_page')
  final int downloadedPage;
  @JsonKey(name: 'failed_page')
  final int failedPage;
  @JsonKey(name: 'total_page')
  final int totalPage;
  final int started;
  @JsonKey(name: 'downloaded_bytes')
  final int downloadedBytes;
  final List<TaskDownloadSingleProgress> details;
  factory TaskDownloadProgess.fromJson(Map<String, dynamic> json) =>
      _$TaskDownloadProgessFromJson(json);
  Map<String, dynamic> toJson() => _$TaskDownloadProgessToJson(this);
}

@JsonSerializable()
class TaskExportZipProgress implements TaskProgressBasicType {
  const TaskExportZipProgress({
    required this.addedPage,
    required this.totalPage,
  });
  @JsonKey(name: 'added_page')
  final int addedPage;
  @JsonKey(name: 'total_page')
  final int totalPage;
  factory TaskExportZipProgress.fromJson(Map<String, dynamic> json) =>
      _$TaskExportZipProgressFromJson(json);
  Map<String, dynamic> toJson() => _$TaskExportZipProgressToJson(this);
}

@JsonSerializable()
class TaskUpdateMeiliSearchDataProgress implements TaskProgressBasicType {
  const TaskUpdateMeiliSearchDataProgress({
    required this.totalGallery,
    required this.updatedGallery,
  });
  @JsonKey(name: 'total_gallery')
  final int totalGallery;
  @JsonKey(name: 'updated_gallery')
  final int updatedGallery;
  factory TaskUpdateMeiliSearchDataProgress.fromJson(
          Map<String, dynamic> json) =>
      _$TaskUpdateMeiliSearchDataProgressFromJson(json);
  Map<String, dynamic> toJson() =>
      _$TaskUpdateMeiliSearchDataProgressToJson(this);
}

@JsonSerializable()
class TaskFixGalleryPageProgress implements TaskProgressBasicType {
  const TaskFixGalleryPageProgress({
    required this.totalGallery,
    required this.checkedGallery,
  });
  @JsonKey(name: 'total_gallery')
  final int totalGallery;
  @JsonKey(name: 'checked_gallery')
  final int checkedGallery;
  factory TaskFixGalleryPageProgress.fromJson(Map<String, dynamic> json) =>
      _$TaskFixGalleryPageProgressFromJson(json);
  Map<String, dynamic> toJson() => _$TaskFixGalleryPageProgressToJson(this);
}

class TaskProgress {
  const TaskProgress({
    required this.type,
    required this.taskId,
    required this.detail,
  });
  final TaskType type;
  final int taskId;
  final TaskProgressBasicType detail;
  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as int;
    final taskId = json['task_id'] as int;
    switch (type) {
      case 0:
        return TaskProgress(
          type: TaskType.download,
          taskId: taskId,
          detail: TaskDownloadProgess.fromJson(
              json['detail'] as Map<String, dynamic>),
        );
      case 1:
        return TaskProgress(
          type: TaskType.exportZip,
          taskId: taskId,
          detail: TaskExportZipProgress.fromJson(
              json['detail'] as Map<String, dynamic>),
        );
      case 2:
        return TaskProgress(
          type: TaskType.updateMeiliSearchData,
          taskId: taskId,
          detail: TaskUpdateMeiliSearchDataProgress.fromJson(
              json['detail'] as Map<String, dynamic>),
        );
      case 3:
        return TaskProgress(
          type: TaskType.fixGalleryPage,
          taskId: taskId,
          detail: TaskFixGalleryPageProgress.fromJson(
              json['detail'] as Map<String, dynamic>),
        );
      default:
        throw ArgumentError.value(type, 'type', 'Invalid task type');
    }
  }
}

enum TaskStatus {
  @JsonValue(0)
  wait,
  @JsonValue(1)
  running,
  @JsonValue(2)
  finished,
  @JsonValue(3)
  failed;

  String text(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case TaskStatus.wait:
        return i18n.waiting;
      case TaskStatus.running:
        return i18n.running;
      case TaskStatus.finished:
        return i18n.finished;
      case TaskStatus.failed:
        return i18n.failed;
    }
  }
}

class TaskDetail {
  TaskDetail({
    required this.base,
    this.progress,
    required this.status,
    this.error,
    this.fataled,
  });
  Task base;
  TaskProgressBasicType? progress;
  TaskStatus status;
  String? error;
  bool? fataled;
}

@JsonSerializable()
class TaskList {
  const TaskList({
    required this.tasks,
    required this.running,
  });
  final List<Task> tasks;
  final List<int> running;
  factory TaskList.fromJson(Map<String, dynamic> json) =>
      _$TaskListFromJson(json);
  Map<String, dynamic> toJson() => _$TaskListToJson(this);
}

@JsonSerializable()
class TaskError {
  const TaskError({
    required this.task,
    required this.error,
    required this.fatal,
  });
  final Task task;
  final String error;
  final bool fatal;
  factory TaskError.fromJson(Map<String, dynamic> json) =>
      _$TaskErrorFromJson(json);
  Map<String, dynamic> toJson() => _$TaskErrorToJson(this);
}

@JsonSerializable()
class DownloadConfig {
  DownloadConfig({
    this.maxDownloadImgCount,
    this.mpv,
    this.downloadOriginalImg,
    this.maxRetryCount,
    this.removePreviousGallery,
  });
  @JsonKey(name: 'max_download_img_count')
  int? maxDownloadImgCount;
  bool? mpv;
  @JsonKey(name: 'download_original_img')
  bool? downloadOriginalImg;
  @JsonKey(name: 'max_retry_count')
  int? maxRetryCount;
  @JsonKey(name: 'remove_previous_gallery')
  bool? removePreviousGallery;
  factory DownloadConfig.fromJson(Map<String, dynamic> json) =>
      _$DownloadConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadConfigToJson(this);
}
