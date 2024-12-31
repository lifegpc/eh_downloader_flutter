import 'package:json_annotation/json_annotation.dart';
import 'api_result.dart';
import '../globals.dart';

part 'eh.g.dart';

@JsonSerializable()
class GalleryMetadataTorrentInfo {
  const GalleryMetadataTorrentInfo({
    required this.hash,
    required this.added,
    required this.name,
    required this.tsize,
    required this.fsize,
  });
  final String hash;
  final String added;
  final String name;
  final String tsize;
  final String fsize;
  factory GalleryMetadataTorrentInfo.fromJson(Map<String, dynamic> json) =>
      _$GalleryMetadataTorrentInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryMetadataTorrentInfoToJson(this);
}

@JsonSerializable()
class GalleryMetadataSingle {
  const GalleryMetadataSingle({
    required this.gid,
    required this.token,
    this.archiverKey,
    required this.title,
    required this.titleJpn,
    required this.category,
    required this.thumb,
    required this.uploader,
    required this.posted,
    required this.filecount,
    required this.filesize,
    required this.expunged,
    required this.rating,
    required this.torrentcount,
    required this.torrents,
    required this.tags,
    this.parentGid,
    this.parentKey,
    this.firstGid,
    this.firstKey,
  });
  final int gid;
  final String token;
  @JsonKey(name: 'archiver_key')
  final String? archiverKey;
  final String title;
  @JsonKey(name: 'title_jpn')
  final String titleJpn;
  final String category;
  final String thumb;
  final String uploader;
  final String posted;
  final String filecount;
  final int filesize;
  final bool expunged;
  final String rating;
  final String torrentcount;
  final List<GalleryMetadataTorrentInfo> torrents;
  final List<String> tags;
  @JsonKey(name: 'parent_gid')
  final String? parentGid;
  @JsonKey(name: 'parent_key')
  final String? parentKey;
  @JsonKey(name: 'first_gid')
  final String? firstGid;
  @JsonKey(name: 'first_key')
  final String? firstKey;
  factory GalleryMetadataSingle.fromJson(Map<String, dynamic> json) =>
      _$GalleryMetadataSingleFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryMetadataSingleToJson(this);

  String get preferredTitle => prefs.getBool("useTitleJpn") == true
      ? titleJpn.isEmpty
          ? title
          : titleJpn
      : title;
}

class EHMetaInfo {
  const EHMetaInfo({
    required this.metas,
  });
  final Map<int, ApiResult<GalleryMetadataSingle>> metas;
  factory EHMetaInfo.fromJson(Map<String, dynamic> json) => EHMetaInfo(
      metas: json.map((key, value) => MapEntry(
          int.parse(key),
          ApiResult<GalleryMetadataSingle>.fromJson(
              value as Map<String, dynamic>,
              (json) => GalleryMetadataSingle.fromJson(
                  json as Map<String, dynamic>)))));
}
