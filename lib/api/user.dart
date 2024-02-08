import 'package:enum_flag/enum_flag.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserPermission with EnumFlag {
  readGallery,
  editGallery,
  deleteGallery,
  manageTasks,
}

const userPermissionAll = 15;

class UserPermissions {
  const UserPermissions(this.code);
  final int code;
  bool has(UserPermission permission) => code.hasFlag(permission);
  int toJson() => code;
  static int toJson2(UserPermissions code) {
    return code.code;
  }

  static fromJson(int code) {
    return UserPermissions(code);
  }

  @override
  String toString() {
    if (code & userPermissionAll == userPermissionAll) return "all";
    final set = code.getFlags(UserPermission.values).toSet();
    if (set.isEmpty) return "none";
    return set.map((e) => e.name).join("|");
  }
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
  @JsonKey(fromJson: UserPermissions.fromJson, toJson: UserPermissions.toJson2)
  final UserPermissions permissions;
  factory BUser.fromJson(Map<String, dynamic> json) => _$BUserFromJson(json);
  Map<String, dynamic> toJson() => _$BUserToJson(this);
}
