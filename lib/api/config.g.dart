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
      maxTaskCount: json['max_task_count'] as int,
      mpv: json['mpv'] as bool,
      maxRetryCount: json['max_retry_count'] as int,
      maxDownloadImgCount: json['max_download_img_count'] as int,
      downloadOriginalImg: json['download_original_img'] as bool,
      port: json['port'] as int,
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
      fetchTimeout: json['fetch_timeout'] as int,
      downloadTimeout: json['download_timeout'] as int,
      ffprobePath: json['ffprobe_path'] as String,
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
    };

const _$ThumbnailMethodEnumMap = {
  ThumbnailMethod.ffmpegBinary: 0,
  ThumbnailMethod.ffmpegApi: 1,
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
      dbPath: json['dbPath'] as String?,
      ua: json['ua'] as String?,
      ex: json['ex'] as bool?,
      base: json['base'] as String?,
      maxTaskCount: json['maxTaskCount'] as int?,
      mpv: json['mpv'] as bool?,
      maxRetryCount: json['maxRetryCount'] as int?,
      maxDownloadImgCount: json['maxDownloadImgCount'] as int?,
      downloadOriginalImg: json['downloadOriginalImg'] as bool?,
      port: json['port'] as int?,
      exportZipJpnTitle: json['exportZipJpnTitle'] as bool?,
      hostname: json['hostname'] as String?,
      meiliHost: json['meiliHost'] as String?,
      meiliSearchApiKey: json['meiliSearchApiKey'] as String?,
      meiliUpdateApiKey: json['meiliUpdateApiKey'] as String?,
      ffmpegPath: json['ffmpegPath'] as String?,
      thumbnailMethod: $enumDecodeNullable(
          _$ThumbnailMethodEnumMap, json['thumbnailMethod']),
      thumbnailDir: json['thumbnailDir'] as String?,
      removePreviousGallery: json['removePreviousGallery'] as bool?,
      imgVerifySecret: json['imgVerifySecret'] as String?,
      meiliHosts: (json['meiliHosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      corsCredentialsHosts: (json['corsCredentialsHosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      flutterFrontend: json['flutterFrontend'] as String?,
      fetchTimeout: json['fetchTimeout'] as int?,
      downloadTimeout: json['downloadTimeout'] as int?,
      ffprobePath: json['ffprobePath'] as String?,
    );

Map<String, dynamic> _$ConfigOptionalToJson(ConfigOptional instance) =>
    <String, dynamic>{
      'cookies': instance.cookies,
      'dbPath': instance.dbPath,
      'ua': instance.ua,
      'ex': instance.ex,
      'base': instance.base,
      'maxTaskCount': instance.maxTaskCount,
      'mpv': instance.mpv,
      'maxRetryCount': instance.maxRetryCount,
      'maxDownloadImgCount': instance.maxDownloadImgCount,
      'downloadOriginalImg': instance.downloadOriginalImg,
      'port': instance.port,
      'exportZipJpnTitle': instance.exportZipJpnTitle,
      'hostname': instance.hostname,
      'meiliHost': instance.meiliHost,
      'meiliSearchApiKey': instance.meiliSearchApiKey,
      'meiliUpdateApiKey': instance.meiliUpdateApiKey,
      'ffmpegPath': instance.ffmpegPath,
      'thumbnailMethod': _$ThumbnailMethodEnumMap[instance.thumbnailMethod],
      'thumbnailDir': instance.thumbnailDir,
      'removePreviousGallery': instance.removePreviousGallery,
      'imgVerifySecret': instance.imgVerifySecret,
      'meiliHosts': instance.meiliHosts,
      'corsCredentialsHosts': instance.corsCredentialsHosts,
      'flutterFrontend': instance.flutterFrontend,
      'fetchTimeout': instance.fetchTimeout,
      'downloadTimeout': instance.downloadTimeout,
      'ffprobePath': instance.ffprobePath,
    };
