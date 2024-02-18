// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eh.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryMetadataTorrentInfo _$GalleryMetadataTorrentInfoFromJson(
        Map<String, dynamic> json) =>
    GalleryMetadataTorrentInfo(
      hash: json['hash'] as String,
      added: json['added'] as String,
      name: json['name'] as String,
      tsize: json['tsize'] as String,
      fsize: json['fsize'] as String,
    );

Map<String, dynamic> _$GalleryMetadataTorrentInfoToJson(
        GalleryMetadataTorrentInfo instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'added': instance.added,
      'name': instance.name,
      'tsize': instance.tsize,
      'fsize': instance.fsize,
    };

GalleryMetadataSingle _$GalleryMetadataSingleFromJson(
        Map<String, dynamic> json) =>
    GalleryMetadataSingle(
      gid: json['gid'] as int,
      token: json['token'] as String,
      archiverKey: json['archiver_key'] as String,
      title: json['title'] as String,
      titleJpn: json['title_jpn'] as String,
      category: json['category'] as String,
      thumb: json['thumb'] as String,
      uploader: json['uploader'] as String,
      posted: json['posted'] as String,
      filecount: json['filecount'] as String,
      filesize: json['filesize'] as int,
      expunged: json['expunged'] as bool,
      rating: json['rating'] as String,
      torrentcount: json['torrentcount'] as String,
      torrents: (json['torrents'] as List<dynamic>)
          .map((e) =>
              GalleryMetadataTorrentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      parentGid: json['parent_gid'] as String?,
      parentKey: json['parent_key'] as String?,
      firstGid: json['first_gid'] as String?,
      firstKey: json['first_key'] as String?,
    );

Map<String, dynamic> _$GalleryMetadataSingleToJson(
        GalleryMetadataSingle instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'token': instance.token,
      'archiver_key': instance.archiverKey,
      'title': instance.title,
      'title_jpn': instance.titleJpn,
      'category': instance.category,
      'thumb': instance.thumb,
      'uploader': instance.uploader,
      'posted': instance.posted,
      'filecount': instance.filecount,
      'filesize': instance.filesize,
      'expunged': instance.expunged,
      'rating': instance.rating,
      'torrentcount': instance.torrentcount,
      'torrents': instance.torrents,
      'tags': instance.tags,
      'parent_gid': instance.parentGid,
      'parent_key': instance.parentKey,
      'first_gid': instance.firstGid,
      'first_key': instance.firstKey,
    };
