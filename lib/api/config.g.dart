// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      cookies: json['cookies'] as bool,
      dbPath: json['db_path'] as String?,
      ua: json['ua'] as String?,
      ex: json['ex'] as bool,
      base: json['base'] as String,
      maxTaskCount: (json['max_task_count'] as num).toInt(),
      mpv: json['mpv'] as bool,
      maxRetryCount: (json['max_retry_count'] as num).toInt(),
      maxDownloadImgCount: (json['max_download_img_count'] as num).toInt(),
      downloadOriginalImg: json['download_original_img'] as bool,
      port: (json['port'] as num).toInt(),
      exportZipJpnTitle: json['export_zip_jpn_title'] as bool,
      hostname: json['hostname'] as String,
      meiliHost: json['meili_host'] as String?,
      meiliSearchApiKey: json['meili_search_api_key'] as String?,
      meiliUpdateApiKey: json['meili_update_api_key'] as String?,
      ffmpegPath: json['ffmpeg_path'] as String,
      thumbnailMethod:
          $enumDecode(_$ThumbnailMethodEnumMap, json['thumbnail_method']),
      thumbnailDir: json['thumbnail_dir'] as String,
      removePreviousGallery: json['remove_previous_gallery'] as bool,
      imgVerifySecret: json['img_verify_secret'] as String?,
      meiliHosts: (json['meili_hosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      corsCredentialsHosts: (json['cors_credentials_hosts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      flutterFrontend: json['flutter_frontend'] as String?,
      fetchTimeout: (json['fetch_timeout'] as num).toInt(),
      downloadTimeout: (json['download_timeout'] as num).toInt(),
      ffprobePath: json['ffprobe_path'] as String,
      redirectToFlutter: json['redirect_to_flutter'] as bool,
      downloadTimeoutCheckInterval:
          (json['download_timeout_check_interval'] as num).toInt(),
      ehMetadataCacheTime: (json['eh_metadata_cache_time'] as num).toInt(),
      randomFileSecret: json['random_file_secret'] as String?,
      usePathBasedImgUrl: json['use_path_based_img_url'] as bool,
      checkFileHash: json['check_file_hash'] as bool,
      importMethod: $enumDecode(_$ImportMethodEnumMap, json['import_method']),
      maxImportImgCount: (json['max_import_img_count'] as num).toInt(),
      enableServerTiming: json['enable_server_timing'] as bool,
      thumbnailFormat:
          $enumDecode(_$ThumbnailFormatEnumMap, json['thumbnail_format']),
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'cookies': instance.cookies,
      'db_path': instance.dbPath,
      'ua': instance.ua,
      'ex': instance.ex,
      'base': instance.base,
      'max_task_count': instance.maxTaskCount,
      'mpv': instance.mpv,
      'max_retry_count': instance.maxRetryCount,
      'max_download_img_count': instance.maxDownloadImgCount,
      'download_original_img': instance.downloadOriginalImg,
      'port': instance.port,
      'export_zip_jpn_title': instance.exportZipJpnTitle,
      'hostname': instance.hostname,
      'meili_host': instance.meiliHost,
      'meili_search_api_key': instance.meiliSearchApiKey,
      'meili_update_api_key': instance.meiliUpdateApiKey,
      'ffmpeg_path': instance.ffmpegPath,
      'thumbnail_method': _$ThumbnailMethodEnumMap[instance.thumbnailMethod]!,
      'thumbnail_dir': instance.thumbnailDir,
      'remove_previous_gallery': instance.removePreviousGallery,
      'img_verify_secret': instance.imgVerifySecret,
      'meili_hosts': instance.meiliHosts,
      'cors_credentials_hosts': instance.corsCredentialsHosts,
      'flutter_frontend': instance.flutterFrontend,
      'fetch_timeout': instance.fetchTimeout,
      'download_timeout': instance.downloadTimeout,
      'ffprobe_path': instance.ffprobePath,
      'redirect_to_flutter': instance.redirectToFlutter,
      'download_timeout_check_interval': instance.downloadTimeoutCheckInterval,
      'eh_metadata_cache_time': instance.ehMetadataCacheTime,
      'random_file_secret': instance.randomFileSecret,
      'use_path_based_img_url': instance.usePathBasedImgUrl,
      'check_file_hash': instance.checkFileHash,
      'import_method': _$ImportMethodEnumMap[instance.importMethod]!,
      'max_import_img_count': instance.maxImportImgCount,
      'enable_server_timing': instance.enableServerTiming,
      'thumbnail_format': _$ThumbnailFormatEnumMap[instance.thumbnailFormat]!,
    };

const _$ThumbnailMethodEnumMap = {
  ThumbnailMethod.ffmpegBinary: 0,
  ThumbnailMethod.ffmpegApi: 1,
};

const _$ImportMethodEnumMap = {
  ImportMethod.copy: 0,
  ImportMethod.copyThenDelete: 1,
  ImportMethod.move: 2,
  ImportMethod.keep: 3,
};

const _$ThumbnailFormatEnumMap = {
  ThumbnailFormat.jpeg: 0,
  ThumbnailFormat.webp: 1,
};

UpdateConfigResult _$UpdateConfigResultFromJson(Map<String, dynamic> json) =>
    UpdateConfigResult(
      isUnsafe: json['is_unsafe'] as bool,
    );

Map<String, dynamic> _$UpdateConfigResultToJson(UpdateConfigResult instance) =>
    <String, dynamic>{
      'is_unsafe': instance.isUnsafe,
    };

ConfigOptional _$ConfigOptionalFromJson(Map<String, dynamic> json) =>
    ConfigOptional(
      cookies: json['cookies'] as String?,
      dbPath: json['db_path'] as String?,
      ua: json['ua'] as String?,
      ex: json['ex'] as bool?,
      base: json['base'] as String?,
      maxTaskCount: (json['max_task_count'] as num?)?.toInt(),
      mpv: json['mpv'] as bool?,
      maxRetryCount: (json['max_retry_count'] as num?)?.toInt(),
      maxDownloadImgCount: (json['max_download_img_count'] as num?)?.toInt(),
      downloadOriginalImg: json['download_original_img'] as bool?,
      port: (json['port'] as num?)?.toInt(),
      exportZipJpnTitle: json['export_zip_jpn_title'] as bool?,
      hostname: json['hostname'] as String?,
      meiliHost: json['meili_host'] as String?,
      meiliSearchApiKey: json['meili_search_api_key'] as String?,
      meiliUpdateApiKey: json['meili_update_api_key'] as String?,
      ffmpegPath: json['ffmpeg_path'] as String?,
      thumbnailMethod: $enumDecodeNullable(
          _$ThumbnailMethodEnumMap, json['thumbnail_method']),
      thumbnailDir: json['thumbnail_dir'] as String?,
      removePreviousGallery: json['remove_previous_gallery'] as bool?,
      imgVerifySecret: json['img_verify_secret'] as String?,
      meiliHosts: (json['meili_hosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      corsCredentialsHosts: (json['cors_credentials_hosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      flutterFrontend: json['flutter_frontend'] as String?,
      fetchTimeout: (json['fetch_timeout'] as num?)?.toInt(),
      downloadTimeout: (json['download_timeout'] as num?)?.toInt(),
      ffprobePath: json['ffprobe_path'] as String?,
      redirectToFlutter: json['redirect_to_flutter'] as bool?,
      downloadTimeoutCheckInterval:
          (json['download_timeout_check_interval'] as num?)?.toInt(),
      ehMetadataCacheTime: (json['eh_metadata_cache_time'] as num?)?.toInt(),
      randomFileSecret: json['random_file_secret'] as String?,
      usePathBasedImgUrl: json['use_path_based_img_url'] as bool?,
      checkFileHash: json['check_file_hash'] as bool?,
      importMethod:
          $enumDecodeNullable(_$ImportMethodEnumMap, json['import_method']),
      maxImportImgCount: (json['max_import_img_count'] as num?)?.toInt(),
      enableServerTiming: json['enable_server_timing'] as bool?,
    )..thumbnailFormat =
        $enumDecodeNullable(_$ThumbnailFormatEnumMap, json['thumbnail_format']);

Map<String, dynamic> _$ConfigOptionalToJson(ConfigOptional instance) =>
    <String, dynamic>{
      'cookies': instance.cookies,
      'db_path': instance.dbPath,
      'ua': instance.ua,
      'ex': instance.ex,
      'base': instance.base,
      'max_task_count': instance.maxTaskCount,
      'mpv': instance.mpv,
      'max_retry_count': instance.maxRetryCount,
      'max_download_img_count': instance.maxDownloadImgCount,
      'download_original_img': instance.downloadOriginalImg,
      'port': instance.port,
      'export_zip_jpn_title': instance.exportZipJpnTitle,
      'hostname': instance.hostname,
      'meili_host': instance.meiliHost,
      'meili_search_api_key': instance.meiliSearchApiKey,
      'meili_update_api_key': instance.meiliUpdateApiKey,
      'ffmpeg_path': instance.ffmpegPath,
      'thumbnail_method': _$ThumbnailMethodEnumMap[instance.thumbnailMethod],
      'thumbnail_dir': instance.thumbnailDir,
      'remove_previous_gallery': instance.removePreviousGallery,
      'img_verify_secret': instance.imgVerifySecret,
      'meili_hosts': instance.meiliHosts,
      'cors_credentials_hosts': instance.corsCredentialsHosts,
      'flutter_frontend': instance.flutterFrontend,
      'fetch_timeout': instance.fetchTimeout,
      'download_timeout': instance.downloadTimeout,
      'ffprobe_path': instance.ffprobePath,
      'redirect_to_flutter': instance.redirectToFlutter,
      'download_timeout_check_interval': instance.downloadTimeoutCheckInterval,
      'eh_metadata_cache_time': instance.ehMetadataCacheTime,
      'random_file_secret': instance.randomFileSecret,
      'use_path_based_img_url': instance.usePathBasedImgUrl,
      'check_file_hash': instance.checkFileHash,
      'import_method': _$ImportMethodEnumMap[instance.importMethod],
      'max_import_img_count': instance.maxImportImgCount,
      'enable_server_timing': instance.enableServerTiming,
      'thumbnail_format': _$ThumbnailFormatEnumMap[instance.thumbnailFormat],
    };
