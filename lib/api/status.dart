import 'package:json_annotation/json_annotation.dart';

part 'status.g.dart';

@JsonSerializable()
class MeilisearchInfo {
  const MeilisearchInfo({
    required this.host,
    required this.key,
  });

  final String host;
  final String key;

  factory MeilisearchInfo.fromJson(Map<String, dynamic> json) =>
      _$MeilisearchInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MeilisearchInfoToJson(this);
}

@JsonSerializable()
class ServerStatus {
  const ServerStatus({
    required this.ffmpegApiEnabled,
    required this.ffmpegBinaryEnabled,
    required this.meilisearchEnabled,
    this.meilisearch,
    required this.noUser,
    required this.isDocker,
    required this.ffprobeBinaryEnabled,
    required this.libzipEnabled,
  });

  @JsonKey(name: 'ffmpeg_api_enabled')
  final bool ffmpegApiEnabled;
  @JsonKey(name: 'ffmpeg_binary_enabled')
  final bool ffmpegBinaryEnabled;
  @JsonKey(name: 'meilisearch_enabled')
  final bool meilisearchEnabled;
  final MeilisearchInfo? meilisearch;
  @JsonKey(name: 'no_user')
  final bool noUser;
  @JsonKey(name: 'is_docker')
  final bool isDocker;
  @JsonKey(name: 'ffprobe_binary_enabled')
  final bool ffprobeBinaryEnabled;
  @JsonKey(name: 'libzip_enabled')
  final bool libzipEnabled;

  factory ServerStatus.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ServerStatusToJson(this);
}
