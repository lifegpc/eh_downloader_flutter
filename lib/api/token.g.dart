// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      id: (json['id'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      token: json['token'] as String,
      expired: Token._fromJson(json['expired'] as String),
      httpOnly: json['http_only'] as bool,
      secure: json['secure'] as bool,
      lastUsed: Token._fromJson(json['last_used'] as String),
      client: json['client'] as String?,
      device: json['device'] as String?,
      clientVersion: json['client_version'] as String?,
      clientPlatform: json['client_platform'] as String?,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'token': instance.token,
      'expired': Token._toJson(instance.expired),
      'http_only': instance.httpOnly,
      'secure': instance.secure,
      'last_used': Token._toJson(instance.lastUsed),
      'client': instance.client,
      'device': instance.device,
      'client_version': instance.clientVersion,
      'client_platform': instance.clientPlatform,
    };

TokenWithUserInfo _$TokenWithUserInfoFromJson(Map<String, dynamic> json) =>
    TokenWithUserInfo(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      name: json['name'] as String,
      isAdmin: json['is_admin'] as bool,
      permissions:
          UserPermissions.fromJson((json['permissions'] as num).toInt()),
    );

Map<String, dynamic> _$TokenWithUserInfoToJson(TokenWithUserInfo instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'is_admin': instance.isAdmin,
      'permissions': UserPermissions.toJson2(instance.permissions),
    };

GallerySharedTokenInfo _$GallerySharedTokenInfoFromJson(
        Map<String, dynamic> json) =>
    GallerySharedTokenInfo(
      gid: (json['gid'] as num).toInt(),
    );

Map<String, dynamic> _$GallerySharedTokenInfoToJson(
        GallerySharedTokenInfo instance) =>
    <String, dynamic>{
      'gid': instance.gid,
    };

SharedTokenWithUrl _$SharedTokenWithUrlFromJson(Map<String, dynamic> json) =>
    SharedTokenWithUrl(
      token: SharedToken.fromJson(json['token'] as Map<String, dynamic>),
      url: json['url'] as String,
    );
