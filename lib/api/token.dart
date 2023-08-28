import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  const Token ({
    required this.id,
    required this.uid,
    required this.token,
    required this.expired,
    required this.httpOnly,
    required this.secure,
  });
  final int id;
  final int uid;
  final String token;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime expired;
  @JsonKey(name: 'http_only')
  final bool httpOnly;
  final bool secure;
  static DateTime _fromJson(String d) => DateTime.parse(d);
  static String _toJson(DateTime d) => d.toIso8601String();
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
