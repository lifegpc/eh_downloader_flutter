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
