// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GMeta _$GMetaFromJson(Map<String, dynamic> json) => GMeta(
      gid: (json['gid'] as num).toInt(),
      token: json['token'] as String,
      title: json['title'] as String,
      titleJpn: json['title_jpn'] as String,
      category: json['category'] as String,
      uploader: json['uploader'] as String,
      posted: GMeta._fromJson((json['posted'] as num).toInt()),
      filecount: (json['filecount'] as num).toInt(),
      filesize: (json['filesize'] as num).toInt(),
      expunged: json['expunged'] as bool,
      rating: (json['rating'] as num).toDouble(),
      parentGid: (json['parent_gid'] as num?)?.toInt(),
      parentToken: json['parent_token'] as String?,
      firstGid: (json['first_gid'] as num?)?.toInt(),
      firstToken: json['first_token'] as String?,
    );

Map<String, dynamic> _$GMetaToJson(GMeta instance) => <String, dynamic>{
      'gid': instance.gid,
      'token': instance.token,
      'title': instance.title,
      'title_jpn': instance.titleJpn,
      'category': instance.category,
      'uploader': instance.uploader,
      'posted': GMeta._toJson(instance.posted),
      'filecount': instance.filecount,
      'filesize': instance.filesize,
      'expunged': instance.expunged,
      'rating': instance.rating,
      'parent_gid': instance.parentGid,
      'parent_token': instance.parentToken,
      'first_gid': instance.firstGid,
      'first_token': instance.firstToken,
    };

GMetaOptional _$GMetaOptionalFromJson(Map<String, dynamic> json) =>
    GMetaOptional(
      gid: (json['gid'] as num?)?.toInt(),
      token: json['token'] as String?,
      title: json['title'] as String?,
      titleJpn: json['title_jpn'] as String?,
      category: json['category'] as String?,
      uploader: json['uploader'] as String?,
      posted: GMetaOptional._fromJson((json['posted'] as num?)?.toInt()),
      filecount: (json['filecount'] as num?)?.toInt(),
      filesize: (json['filesize'] as num?)?.toInt(),
      expunged: json['expunged'] as bool?,
      rating: (json['rating'] as num?)?.toDouble(),
      parentGid: (json['parent_gid'] as num?)?.toInt(),
      parentToken: json['parent_token'] as String?,
      firstGid: (json['first_gid'] as num?)?.toInt(),
      firstToken: json['first_token'] as String?,
    );

Map<String, dynamic> _$GMetaOptionalToJson(GMetaOptional instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'token': instance.token,
      'title': instance.title,
      'title_jpn': instance.titleJpn,
      'category': instance.category,
      'uploader': instance.uploader,
      'posted': GMetaOptional._toJson(instance.posted),
      'filecount': instance.filecount,
      'filesize': instance.filesize,
      'expunged': instance.expunged,
      'rating': instance.rating,
      'parent_gid': instance.parentGid,
      'parent_token': instance.parentToken,
      'first_gid': instance.firstGid,
      'first_token': instance.firstToken,
    };

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: (json['id'] as num).toInt(),
      tag: json['tag'] as String,
      translated: json['translated'] as String?,
      intro: json['intro'] as String?,
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'tag': instance.tag,
      'translated': instance.translated,
      'intro': instance.intro,
    };

ExtendedPMeta _$ExtendedPMetaFromJson(Map<String, dynamic> json) =>
    ExtendedPMeta(
      gid: (json['gid'] as num).toInt(),
      index: (json['index'] as num).toInt(),
      token: json['token'] as String,
      name: json['name'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      isNsfw: json['is_nsfw'] as bool,
      isAd: json['is_ad'] as bool,
    );

Map<String, dynamic> _$ExtendedPMetaToJson(ExtendedPMeta instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'index': instance.index,
      'token': instance.token,
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'is_nsfw': instance.isNsfw,
      'is_ad': instance.isAd,
    };

GalleryData _$GalleryDataFromJson(Map<String, dynamic> json) => GalleryData(
      meta: GMeta.fromJson(json['meta'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      pages: (json['pages'] as List<dynamic>)
          .map((e) => ExtendedPMeta.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GalleryDataToJson(GalleryData instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'tags': instance.tags,
      'pages': instance.pages,
    };
