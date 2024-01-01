import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

enum ThumbnailMethod {
  @JsonValue(0)
  ffmpegBinary,
  @JsonValue(1)
  ffmpegApi,
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
  });
  String? cookies;
  String? dbPath;
  String? ua;
  bool? ex;
  String? base;
  int? maxTaskCount;
  bool? mpv;
  int? maxRetryCount;
  int? maxDownloadImgCount;
  bool? downloadOriginalImg;
  int? port;
  bool? exportZipJpnTitle;
  String? hostname;
  String? meiliHost;
  String? meiliSearchApiKey;
  String? meiliUpdateApiKey;
  String? ffmpegPath;
  ThumbnailMethod? thumbnailMethod;
  String? thumbnailDir;
  bool? removePreviousGallery;
  String? imgVerifySecret;
  Map<String, String>? meiliHosts;
  List<String>? corsCredentialsHosts;
  String? flutterFrontend;
  int? fetchTimeout;
  int? downloadTimeout;
  String? ffprobePath;
  factory ConfigOptional.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionalFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigOptionalToJson(this);
}
