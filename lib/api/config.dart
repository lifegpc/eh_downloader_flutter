import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

enum ThumbnailMethod {
  @JsonValue(0)
  ffmpegBinary,
  @JsonValue(1)
  ffmpegApi,
}

enum ThumbnailFormat {
  @JsonValue(0)
  jpeg,
  @JsonValue(1)
  webp,
}

enum ImportMethod {
  @JsonValue(0)
  copy,
  @JsonValue(1)
  copyThenDelete,
  @JsonValue(2)
  move,
  @JsonValue(3)
  keep;

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case ImportMethod.copy:
        return i18n.copy;
      case ImportMethod.copyThenDelete:
        return i18n.copyThenDelete;
      case ImportMethod.move:
        return i18n.move;
      case ImportMethod.keep:
        return i18n.keep;
    }
  }
}

@JsonSerializable()
class Config {
  Config({
    required this.cookies,
    this.dbPath,
    this.ua,
    required this.ex,
    required this.base,
    required this.maxTaskCount,
    required this.mpv,
    required this.maxRetryCount,
    required this.maxDownloadImgCount,
    required this.downloadOriginalImg,
    required this.port,
    required this.exportZipJpnTitle,
    required this.hostname,
    this.meiliHost,
    this.meiliSearchApiKey,
    this.meiliUpdateApiKey,
    required this.ffmpegPath,
    required this.thumbnailMethod,
    required this.thumbnailDir,
    required this.removePreviousGallery,
    this.imgVerifySecret,
    this.meiliHosts,
    required this.corsCredentialsHosts,
    this.flutterFrontend,
    required this.fetchTimeout,
    required this.downloadTimeout,
    required this.ffprobePath,
    required this.redirectToFlutter,
    required this.downloadTimeoutCheckInterval,
    required this.ehMetadataCacheTime,
    this.randomFileSecret,
    required this.usePathBasedImgUrl,
    required this.checkFileHash,
    required this.importMethod,
    required this.maxImportImgCount,
    required this.enableServerTiming,
    required this.thumbnailFormat,
    required this.loggingStack,
  });
  bool cookies;
  @JsonKey(name: 'db_path')
  String? dbPath;
  String? ua;
  bool ex;
  String base;
  @JsonKey(name: 'max_task_count')
  int maxTaskCount;
  bool mpv;
  @JsonKey(name: 'max_retry_count')
  int maxRetryCount;
  @JsonKey(name: 'max_download_img_count')
  int maxDownloadImgCount;
  @JsonKey(name: 'download_original_img')
  bool downloadOriginalImg;
  int port;
  @JsonKey(name: 'export_zip_jpn_title')
  bool exportZipJpnTitle;
  String hostname;
  @JsonKey(name: 'meili_host')
  String? meiliHost;
  @JsonKey(name: 'meili_search_api_key')
  String? meiliSearchApiKey;
  @JsonKey(name: 'meili_update_api_key')
  String? meiliUpdateApiKey;
  @JsonKey(name: 'ffmpeg_path')
  String ffmpegPath;
  @JsonKey(name: 'thumbnail_method')
  ThumbnailMethod thumbnailMethod;
  @JsonKey(name: 'thumbnail_dir')
  String thumbnailDir;
  @JsonKey(name: 'remove_previous_gallery')
  bool removePreviousGallery;
  @JsonKey(name: 'img_verify_secret')
  String? imgVerifySecret;
  @JsonKey(name: 'meili_hosts')
  Map<String, String>? meiliHosts;
  @JsonKey(name: 'cors_credentials_hosts')
  List<String> corsCredentialsHosts;
  @JsonKey(name: 'flutter_frontend')
  String? flutterFrontend;
  @JsonKey(name: 'fetch_timeout')
  int fetchTimeout;
  @JsonKey(name: 'download_timeout')
  int downloadTimeout;
  @JsonKey(name: 'ffprobe_path')
  String ffprobePath;
  @JsonKey(name: 'redirect_to_flutter')
  bool redirectToFlutter;
  @JsonKey(name: 'download_timeout_check_interval')
  int downloadTimeoutCheckInterval;
  @JsonKey(name: "eh_metadata_cache_time")
  int ehMetadataCacheTime;
  @JsonKey(name: "random_file_secret")
  String? randomFileSecret;
  @JsonKey(name: 'use_path_based_img_url')
  bool usePathBasedImgUrl;
  @JsonKey(name: 'check_file_hash')
  bool checkFileHash;
  @JsonKey(name: 'import_method')
  ImportMethod importMethod;
  @JsonKey(name: 'max_import_img_count')
  int maxImportImgCount;
  @JsonKey(name: 'enable_server_timing')
  bool enableServerTiming;
  @JsonKey(name: 'thumbnail_format')
  ThumbnailFormat thumbnailFormat;
  @JsonKey(name: 'logging_stack')
  bool loggingStack;
  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@JsonSerializable()
class UpdateConfigResult {
  const UpdateConfigResult({
    required this.isUnsafe,
  });
  @JsonKey(name: 'is_unsafe')
  final bool isUnsafe;
  factory UpdateConfigResult.fromJson(Map<String, dynamic> json) =>
      _$UpdateConfigResultFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateConfigResultToJson(this);
}

@JsonSerializable()
class ConfigOptional {
  ConfigOptional({
    this.cookies,
    this.dbPath,
    this.ua,
    this.ex,
    this.base,
    this.maxTaskCount,
    this.mpv,
    this.maxRetryCount,
    this.maxDownloadImgCount,
    this.downloadOriginalImg,
    this.port,
    this.exportZipJpnTitle,
    this.hostname,
    this.meiliHost,
    this.meiliSearchApiKey,
    this.meiliUpdateApiKey,
    this.ffmpegPath,
    this.thumbnailMethod,
    this.thumbnailDir,
    this.removePreviousGallery,
    this.imgVerifySecret,
    this.meiliHosts,
    this.corsCredentialsHosts,
    this.flutterFrontend,
    this.fetchTimeout,
    this.downloadTimeout,
    this.ffprobePath,
    this.redirectToFlutter,
    this.downloadTimeoutCheckInterval,
    this.ehMetadataCacheTime,
    this.randomFileSecret,
    this.usePathBasedImgUrl,
    this.checkFileHash,
    this.importMethod,
    this.maxImportImgCount,
    this.enableServerTiming,
    this.thumbnailFormat,
    this.loggingStack,
  });
  String? cookies;
  @JsonKey(name: 'db_path')
  String? dbPath;
  String? ua;
  bool? ex;
  String? base;
  @JsonKey(name: 'max_task_count')
  int? maxTaskCount;
  bool? mpv;
  @JsonKey(name: 'max_retry_count')
  int? maxRetryCount;
  @JsonKey(name: 'max_download_img_count')
  int? maxDownloadImgCount;
  @JsonKey(name: 'download_original_img')
  bool? downloadOriginalImg;
  int? port;
  @JsonKey(name: 'export_zip_jpn_title')
  bool? exportZipJpnTitle;
  String? hostname;
  @JsonKey(name: 'meili_host')
  String? meiliHost;
  @JsonKey(name: 'meili_search_api_key')
  String? meiliSearchApiKey;
  @JsonKey(name: 'meili_update_api_key')
  String? meiliUpdateApiKey;
  @JsonKey(name: 'ffmpeg_path')
  String? ffmpegPath;
  @JsonKey(name: 'thumbnail_method')
  ThumbnailMethod? thumbnailMethod;
  @JsonKey(name: 'thumbnail_dir')
  String? thumbnailDir;
  @JsonKey(name: 'remove_previous_gallery')
  bool? removePreviousGallery;
  @JsonKey(name: 'img_verify_secret')
  String? imgVerifySecret;
  @JsonKey(name: 'meili_hosts')
  Map<String, String>? meiliHosts;
  @JsonKey(name: 'cors_credentials_hosts')
  List<String>? corsCredentialsHosts;
  @JsonKey(name: 'flutter_frontend')
  String? flutterFrontend;
  @JsonKey(name: 'fetch_timeout')
  int? fetchTimeout;
  @JsonKey(name: 'download_timeout')
  int? downloadTimeout;
  @JsonKey(name: 'ffprobe_path')
  String? ffprobePath;
  @JsonKey(name: 'redirect_to_flutter')
  bool? redirectToFlutter;
  @JsonKey(name: 'download_timeout_check_interval')
  int? downloadTimeoutCheckInterval;
  @JsonKey(name: "eh_metadata_cache_time")
  int? ehMetadataCacheTime;
  @JsonKey(name: "random_file_secret")
  String? randomFileSecret;
  @JsonKey(name: 'use_path_based_img_url')
  bool? usePathBasedImgUrl;
  @JsonKey(name: 'check_file_hash')
  bool? checkFileHash;
  @JsonKey(name: 'import_method')
  ImportMethod? importMethod;
  @JsonKey(name: 'max_import_img_count')
  int? maxImportImgCount;
  @JsonKey(name: 'enable_server_timing')
  bool? enableServerTiming;
  @JsonKey(name: 'thumbnail_format')
  ThumbnailFormat? thumbnailFormat;
  @JsonKey(name: 'logging_stack')
  bool? loggingStack;
  factory ConfigOptional.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionalFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigOptionalToJson(this);
}
