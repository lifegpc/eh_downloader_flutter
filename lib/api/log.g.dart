// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
      id: (json['id'] as num).toInt(),
      time: LogEntry._fromJson(json['time'] as String),
      message: json['message'] as String,
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      type: json['type'] as String,
      stack: json['stack'] as String?,
    );

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'id': instance.id,
      'time': LogEntry._toJson(instance.time),
      'message': instance.message,
      'level': _$LogLevelEnumMap[instance.level]!,
      'type': instance.type,
      'stack': instance.stack,
    };

const _$LogLevelEnumMap = {
  LogLevel.trace: 1,
  LogLevel.debug: 2,
  LogLevel.log: 3,
  LogLevel.info: 4,
  LogLevel.warn: 5,
  LogLevel.error: 6,
};

LogEntries _$LogEntriesFromJson(Map<String, dynamic> json) => LogEntries(
      datas: (json['datas'] as List<dynamic>)
          .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LogEntriesToJson(LogEntries instance) =>
    <String, dynamic>{
      'datas': instance.datas,
      'count': instance.count,
    };
