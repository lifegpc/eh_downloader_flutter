// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EhFileBasic _$EhFileBasicFromJson(Map<String, dynamic> json) => EhFileBasic(
      id: json['id'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      isOriginal: json['is_original'] as bool,
    );

Map<String, dynamic> _$EhFileBasicToJson(EhFileBasic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'width': instance.width,
      'height': instance.height,
      'is_original': instance.isOriginal,
    };

EhFileExtend _$EhFileExtendFromJson(Map<String, dynamic> json) => EhFileExtend(
      id: json['id'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      isOriginal: json['is_original'] as bool,
      token: json['token'] as String,
    );

Map<String, dynamic> _$EhFileExtendToJson(EhFileExtend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'width': instance.width,
      'height': instance.height,
      'is_original': instance.isOriginal,
      'token': instance.token,
    };
