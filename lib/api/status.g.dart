// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeilisearchInfo _$MeilisearchInfoFromJson(Map<String, dynamic> json) =>
    MeilisearchInfo(
      host: json['host'] as String,
      key: json['key'] as String,
    );

Map<String, dynamic> _$MeilisearchInfoToJson(MeilisearchInfo instance) =>
    <String, dynamic>{
      'host': instance.host,
      'key': instance.key,
    };

ServerStatus _$ServerStatusFromJson(Map<String, dynamic> json) => ServerStatus(
      ffmpegApiEnabled: json['ffmpeg_api_enabled'] as bool,
      ffmpegBinaryEnabled: json['ffmpeg_binary_enabled'] as bool,
      meilisearchEnabled: json['meilisearch_enabled'] as bool,
      meilisearch: json['meilisearch'] == null
          ? null
          : MeilisearchInfo.fromJson(
              json['meilisearch'] as Map<String, dynamic>),
      noUser: json['no_user'] as bool,
      isDocker: json['is_docker'] as bool,
    );

Map<String, dynamic> _$ServerStatusToJson(ServerStatus instance) =>
    <String, dynamic>{
      'ffmpeg_api_enabled': instance.ffmpegApiEnabled,
      'ffmpeg_binary_enabled': instance.ffmpegBinaryEnabled,
      'meilisearch_enabled': instance.meilisearchEnabled,
      'meilisearch': instance.meilisearch,
      'no_user': instance.noUser,
      'is_docker': instance.isDocker,
    };
