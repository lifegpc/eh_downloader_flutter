import 'package:json_annotation/json_annotation.dart';

part 'log.g.dart';

enum LogLevel {
  @JsonValue(1)
  trace,
  @JsonValue(2)
  debug,
  @JsonValue(3)
  log,
  @JsonValue(4)
  info,
  @JsonValue(5)
  warn,
  @JsonValue(6)
  error;

  static LogLevel? tryParse(String level) {
    int? levnum = int.tryParse(level);
    if (levnum != null && levnum <= 6 && levnum >= 1) {
      return LogLevel.values[levnum - 1];
    }
    switch (level) {
      case 'trace':
        return LogLevel.trace;
      case 'debug':
        return LogLevel.debug;
      case 'log':
        return LogLevel.log;
      case 'info':
        return LogLevel.info;
      case 'warn':
        return LogLevel.warn;
      case 'error':
        return LogLevel.error;
      default:
        return null;
    }
  }

  int toInt() {
    return index + 1;
  }
}

@JsonSerializable()
class LogEntry {
  LogEntry({
    required this.id,
    required this.time,
    required this.message,
    required this.level,
    required this.type,
    this.stack,
  });
  int id;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  DateTime time;
  String message;
  LogLevel level;
  String type;
  String? stack;

  static DateTime _fromJson(String d) => DateTime.parse(d);
  static String _toJson(DateTime d) => d.toIso8601String();
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);
}

@JsonSerializable()
class LogEntries {
  LogEntries({
    required this.datas,
    this.count,
  });
  List<LogEntry> datas;
  int? count;

  factory LogEntries.fromJson(Map<String, dynamic> json) =>
      _$LogEntriesFromJson(json);
  Map<String, dynamic> toJson() => _$LogEntriesToJson(this);
}
