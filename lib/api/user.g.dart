// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BUser _$BUserFromJson(Map<String, dynamic> json) => BUser(
      id: json['id'] as int,
      username: json['username'] as String,
      isAdmin: json['is_admin'] as bool,
      permissions: UserPermissions.fromJson(json['permissions'] as int),
    );

Map<String, dynamic> _$BUserToJson(BUser instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'is_admin': instance.isAdmin,
      'permissions': UserPermissions.toJson2(instance.permissions),
    };
