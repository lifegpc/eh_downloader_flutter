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
  factory MeilisearchInfo.fromJson(Map<String, dynamic> json) => _$MeilisearchInfoFromJson(json);
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
  factory ServerStatus.fromJson(Map<String, dynamic> json) => _$ServerStatusFromJson(json);
  Map<String, dynamic> toJson() => _$ServerStatusToJson(this);
}
