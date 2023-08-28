// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BUser _$BUserFromJson(Map<String, dynamic> json) => BUser(
      id: json['id'] as int,
      username: json['username'] as String,
      isAdmin: json['is_admin'] as bool,
      permissions: $enumDecode(_$UserPermissionEnumMap, json['permissions']),
    );

Map<String, dynamic> _$BUserToJson(BUser instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'is_admin': instance.isAdmin,
      'permissions': _$UserPermissionEnumMap[instance.permissions]!,
    };

const _$UserPermissionEnumMap = {
  UserPermission.none: 0,
  UserPermission.readGallery: 1,
  UserPermission.editGallery: 2,
  UserPermission.all: 3,
};
