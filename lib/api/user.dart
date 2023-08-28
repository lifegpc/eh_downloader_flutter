import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonEnum(valueField: 'code')
enum UserPermission {
  none(0),
  readGallery(1),
  editGallery(2),
  all(3);

  const UserPermission(this.code);
  final int code;
}

@JsonSerializable()
class BUser {
  const BUser({
    required this.id,
    required this.username,
    required this.is_admin,
    required this.permissions,
  });
  final int id;
  final String username;
  final bool is_admin;
  final UserPermission permissions;
  factory BUser.fromJson(Map<String, dynamic> json) => _$BUserFromJson(json);
  Map<String, dynamic> toJson() => _$BUserToJson(this);
}
