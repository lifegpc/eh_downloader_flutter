import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserPermission with EnumFlag {
  readGallery,
  editGallery,
  deleteGallery,
  manageTasks,
  shareGallery;

  String localText(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    switch (this) {
      case UserPermission.readGallery:
        return i18n.readGallery;
      case UserPermission.editGallery:
        return i18n.editGallery;
      case UserPermission.deleteGallery:
        return i18n.deleteGallery;
      case UserPermission.manageTasks:
        return i18n.manageTasks;
      case UserPermission.shareGallery:
        return i18n.shareGallery;
    }
  }
}

const userPermissionAll = 31;

class UserPermissions {
  UserPermissions(this.code);
  int code;
  bool has(UserPermission permission) => code.hasFlag(permission);
  bool get isAll => code == userPermissionAll;
  int toJson() => code;
  void add(UserPermission flag) {
    code |= flag.value;
  }

  static int toJson2(UserPermissions code) {
    return code.code;
  }

  static fromJson(int code) {
    return UserPermissions(code);
  }

  void remove(UserPermission flag) {
    code &= ~flag.value;
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
