// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      gid: (json['gid'] as num).toInt(),
      token: json['token'] as String,
      pid: (json['pid'] as num).toInt(),
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
  TaskType.import: 4,
  TaskType.updateTagTranslation: 5,
};

TaskDownloadSingleProgress _$TaskDownloadSingleProgressFromJson(
        Map<String, dynamic> json) =>
    TaskDownloadSingleProgress(
      index: (json['index'] as num).toInt(),
      token: json['token'] as String,
      name: json['name'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      isOriginal: json['is_original'] as bool,
      total: (json['total'] as num).toInt(),
      started: TaskDownloadSingleProgress._fromJson(
          (json['started'] as num).toInt()),
      downloaded: (json['downloaded'] as num).toInt(),
      speed: (json['speed'] as num).toDouble(),
      lastUpdated: TaskDownloadSingleProgress._fromJson(
          (json['last_updated'] as num).toInt()),
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
      'speed': instance.speed,
      'last_updated': TaskDownloadSingleProgress._toJson(instance.lastUpdated),
    };

TaskDownloadProgess _$TaskDownloadProgessFromJson(Map<String, dynamic> json) =>
    TaskDownloadProgess(
      downloadedPage: (json['downloaded_page'] as num).toInt(),
      failedPage: (json['failed_page'] as num).toInt(),
      totalPage: (json['total_page'] as num).toInt(),
      details: (json['details'] as List<dynamic>)
          .map((e) =>
              TaskDownloadSingleProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      started: (json['started'] as num).toInt(),
      downloadedBytes: (json['downloaded_bytes'] as num).toInt(),
    );

Map<String, dynamic> _$TaskDownloadProgessToJson(
        TaskDownloadProgess instance) =>
    <String, dynamic>{
      'downloaded_page': instance.downloadedPage,
      'failed_page': instance.failedPage,
      'total_page': instance.totalPage,
      'started': instance.started,
      'downloaded_bytes': instance.downloadedBytes,
      'details': instance.details,
    };

TaskExportZipProgress _$TaskExportZipProgressFromJson(
        Map<String, dynamic> json) =>
    TaskExportZipProgress(
      addedPage: (json['added_page'] as num).toInt(),
      totalPage: (json['total_page'] as num).toInt(),
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
      totalGallery: (json['total_gallery'] as num).toInt(),
      updatedGallery: (json['updated_gallery'] as num).toInt(),
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
      totalGallery: (json['total_gallery'] as num).toInt(),
      checkedGallery: (json['checked_gallery'] as num).toInt(),
    );

Map<String, dynamic> _$TaskFixGalleryPageProgressToJson(
        TaskFixGalleryPageProgress instance) =>
    <String, dynamic>{
      'total_gallery': instance.totalGallery,
      'checked_gallery': instance.checkedGallery,
    };

TaskImportProgress _$TaskImportProgressFromJson(Map<String, dynamic> json) =>
    TaskImportProgress(
      importedPage: (json['imported_page'] as num).toInt(),
      failedPage: (json['failed_page'] as num).toInt(),
      totalPage: (json['total_page'] as num).toInt(),
    );

Map<String, dynamic> _$TaskImportProgressToJson(TaskImportProgress instance) =>
    <String, dynamic>{
      'imported_page': instance.importedPage,
      'failed_page': instance.failedPage,
      'total_page': instance.totalPage,
    };

TaskUpdateTagTranslationProgress _$TaskUpdateTagTranslationProgressFromJson(
        Map<String, dynamic> json) =>
    TaskUpdateTagTranslationProgress(
      addedTag: (json['added_tag'] as num).toInt(),
      totalTag: (json['total_tag'] as num).toInt(),
    );

Map<String, dynamic> _$TaskUpdateTagTranslationProgressToJson(
        TaskUpdateTagTranslationProgress instance) =>
    <String, dynamic>{
      'added_tag': instance.addedTag,
      'total_tag': instance.totalTag,
    };

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      running: (json['running'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
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

DownloadConfig _$DownloadConfigFromJson(Map<String, dynamic> json) =>
    DownloadConfig(
      maxDownloadImgCount: (json['max_download_img_count'] as num?)?.toInt(),
      mpv: json['mpv'] as bool?,
      downloadOriginalImg: json['download_original_img'] as bool?,
      maxRetryCount: (json['max_retry_count'] as num?)?.toInt(),
      removePreviousGallery: json['remove_previous_gallery'] as bool?,
    );

Map<String, dynamic> _$DownloadConfigToJson(DownloadConfig instance) =>
    <String, dynamic>{
      'max_download_img_count': instance.maxDownloadImgCount,
      'mpv': instance.mpv,
      'download_original_img': instance.downloadOriginalImg,
      'max_retry_count': instance.maxRetryCount,
      'remove_previous_gallery': instance.removePreviousGallery,
    };

ExportZipConfig _$ExportZipConfigFromJson(Map<String, dynamic> json) =>
    ExportZipConfig(
      output: json['output'] as String?,
      jpnTitle: json['jpn_title'] as bool?,
      maxLength: (json['max_length'] as num?)?.toInt(),
      exportAd: json['export_ad'] as bool?,
    );

Map<String, dynamic> _$ExportZipConfigToJson(ExportZipConfig instance) =>
    <String, dynamic>{
      'output': instance.output,
      'jpn_title': instance.jpnTitle,
      'max_length': instance.maxLength,
      'export_ad': instance.exportAd,
    };

ImportConfig _$ImportConfigFromJson(Map<String, dynamic> json) => ImportConfig(
      json['import_path'] as String,
      size: $enumDecodeNullable(_$ImportSizeEnumMap, json['size']) ??
          ImportSize.original,
      maxImportImgCount: (json['max_import_img_count'] as num?)?.toInt(),
      mpv: json['mpv'] as bool?,
      method: $enumDecodeNullable(_$ImportMethodEnumMap, json['method']),
      removePreviousGallery: json['remove_previous_gallery'] as bool?,
    );

Map<String, dynamic> _$ImportConfigToJson(ImportConfig instance) =>
    <String, dynamic>{
      'max_import_img_count': instance.maxImportImgCount,
      'mpv': instance.mpv,
      'method': _$ImportMethodEnumMap[instance.method],
      'remove_previous_gallery': instance.removePreviousGallery,
      'import_path': instance.importPath,
      'size': _$ImportSizeEnumMap[instance.size]!,
    };

const _$ImportSizeEnumMap = {
  ImportSize.original: 0,
  ImportSize.x780: 780,
  ImportSize.x980: 980,
  ImportSize.resampled: 1280,
  ImportSize.x1600: 1600,
  ImportSize.x2400: 2400,
};

const _$ImportMethodEnumMap = {
  ImportMethod.copy: 0,
  ImportMethod.copyThenDelete: 1,
  ImportMethod.move: 2,
  ImportMethod.keep: 3,
};

DefaultImportConfig _$DefaultImportConfigFromJson(Map<String, dynamic> json) =>
    DefaultImportConfig(
      maxImportImgCount: (json['max_import_img_count'] as num?)?.toInt(),
      method: $enumDecodeNullable(_$ImportMethodEnumMap, json['method']),
      mpv: json['mpv'] as bool?,
      removePreviousGallery: json['remove_previous_gallery'] as bool?,
    );

Map<String, dynamic> _$DefaultImportConfigToJson(
        DefaultImportConfig instance) =>
    <String, dynamic>{
      'max_import_img_count': instance.maxImportImgCount,
      'method': _$ImportMethodEnumMap[instance.method],
      'mpv': instance.mpv,
      'remove_previous_gallery': instance.removePreviousGallery,
    };
