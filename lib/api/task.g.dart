// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as int,
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      gid: json['gid'] as int,
      token: json['token'] as String,
      pid: json['pid'] as int,
      details: json['details'] as String?,
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'gid': instance.gid,
      'token': instance.token,
      'pid': instance.pid,
      'details': instance.details,
    };

const _$TaskTypeEnumMap = {
  TaskType.download: 0,
  TaskType.exportZip: 1,
  TaskType.updateMeiliSearchData: 2,
  TaskType.fixGalleryPage: 3,
};

TaskDownloadSingleProgress _$TaskDownloadSingleProgressFromJson(
        Map<String, dynamic> json) =>
    TaskDownloadSingleProgress(
      index: json['index'] as int,
      token: json['token'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      isOriginal: json['is_original'] as bool,
      total: json['total'] as int,
      started: TaskDownloadSingleProgress._fromJson(json['started'] as int),
      downloaded: json['downloaded'] as int,
    );

Map<String, dynamic> _$TaskDownloadSingleProgressToJson(
        TaskDownloadSingleProgress instance) =>
    <String, dynamic>{
      'index': instance.index,
      'token': instance.token,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'is_original': instance.isOriginal,
      'total': instance.total,
      'started': TaskDownloadSingleProgress._toJson(instance.started),
      'downloaded': instance.downloaded,
    };

TaskDownloadProgess _$TaskDownloadProgessFromJson(Map<String, dynamic> json) =>
    TaskDownloadProgess(
      downloadedPage: json['downloaded_page'] as int,
      failedPage: json['failed_page'] as int,
      totalPage: json['total_page'] as int,
      details: (json['details'] as List<dynamic>)
          .map((e) =>
              TaskDownloadSingleProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TaskDownloadProgessToJson(
        TaskDownloadProgess instance) =>
    <String, dynamic>{
      'downloaded_page': instance.downloadedPage,
      'failed_page': instance.failedPage,
      'total_page': instance.totalPage,
      'details': instance.details,
    };

TaskExportZipProgress _$TaskExportZipProgressFromJson(
        Map<String, dynamic> json) =>
    TaskExportZipProgress(
      addedPage: json['added_page'] as int,
      totalPage: json['total_page'] as int,
    );

Map<String, dynamic> _$TaskExportZipProgressToJson(
        TaskExportZipProgress instance) =>
    <String, dynamic>{
      'added_page': instance.addedPage,
      'total_page': instance.totalPage,
    };

TaskUpdateMeiliSearchDataProgress _$TaskUpdateMeiliSearchDataProgressFromJson(
        Map<String, dynamic> json) =>
    TaskUpdateMeiliSearchDataProgress(
      totalGallery: json['total_gallery'] as int,
      updatedGallery: json['updated_gallery'] as int,
    );

Map<String, dynamic> _$TaskUpdateMeiliSearchDataProgressToJson(
        TaskUpdateMeiliSearchDataProgress instance) =>
    <String, dynamic>{
      'total_gallery': instance.totalGallery,
      'updated_gallery': instance.updatedGallery,
    };

TaskFixGalleryPageProgress _$TaskFixGalleryPageProgressFromJson(
        Map<String, dynamic> json) =>
    TaskFixGalleryPageProgress(
      totalGallery: json['total_gallery'] as int,
      checkedGallery: json['checked_gallery'] as int,
    );

Map<String, dynamic> _$TaskFixGalleryPageProgressToJson(
        TaskFixGalleryPageProgress instance) =>
    <String, dynamic>{
      'total_gallery': instance.totalGallery,
      'checked_gallery': instance.checkedGallery,
    };

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      running: (json['running'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$TaskListToJson(TaskList instance) => <String, dynamic>{
      'tasks': instance.tasks,
      'running': instance.running,
    };

TaskError _$TaskErrorFromJson(Map<String, dynamic> json) => TaskError(
      task: Task.fromJson(json['task'] as Map<String, dynamic>),
      error: json['error'] as String,
      fatal: json['fatal'] as bool,
    );

Map<String, dynamic> _$TaskErrorToJson(TaskError instance) => <String, dynamic>{
      'task': instance.task,
      'error': instance.error,
      'fatal': instance.fatal,
    };
