// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      id: json['id'] as int,
      uid: json['uid'] as int,
      token: json['token'] as String,
      expired: Token._fromJson(json['expired'] as String),
      httpOnly: json['http_only'] as bool,
      secure: json['secure'] as bool,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'token': instance.token,
      'expired': Token._toJson(instance.expired),
      'http_only': instance.httpOnly,
      'secure': instance.secure,
    };

TokenWithUserInfo _$TokenWithUserInfoFromJson(Map<String, dynamic> json) =>
    TokenWithUserInfo(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      name: json['name'] as String,
      isAdmin: json['is_admin'] as bool,
      permissions: UserPermissions.fromJson(json['permissions'] as int),
    );

Map<String, dynamic> _$TokenWithUserInfoToJson(TokenWithUserInfo instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'is_admin': instance.isAdmin,
      'permissions': UserPermissions.toJson2(instance.permissions),
    };
