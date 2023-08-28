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
    required this.isAdmin,
    required this.permissions,
  });
  final int id;
  final String username;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  final UserPermission permissions;
  factory BUser.fromJson(Map<String, dynamic> json) => _$BUserFromJson(json);
  Map<String, dynamic> toJson() => _$BUserToJson(this);
}
