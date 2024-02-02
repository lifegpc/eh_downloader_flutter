import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  const Token({
    required this.id,
    required this.uid,
    required this.token,
    required this.expired,
    required this.httpOnly,
    required this.secure,
    required this.lastUsed,
    this.client,
    this.device,
    this.clientVersion,
    this.clientPlatform,
  });
  final int id;
  final int uid;
  final String token;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime expired;
  @JsonKey(name: 'http_only')
  final bool httpOnly;
  final bool secure;
  @JsonKey(fromJson: _fromJson, toJson: _toJson, name: 'last_used')
  final DateTime lastUsed;
  final String? client;
  final String? device;
  @JsonKey(name: 'client_version')
  final String? clientVersion;
  @JsonKey(name: 'client_platform')
  final String? clientPlatform;
  static DateTime _fromJson(String d) => DateTime.parse(d);
  static String _toJson(DateTime d) => d.toIso8601String();
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class TokenWithUserInfo {
  const TokenWithUserInfo({
    required this.token,
    required this.name,
    required this.isAdmin,
    required this.permissions,
  });
  final Token token;
  final String name;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  @JsonKey(fromJson: UserPermissions.fromJson, toJson: UserPermissions.toJson2)
  final UserPermissions permissions;
  factory TokenWithUserInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenWithUserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenWithUserInfoToJson(this);
}
