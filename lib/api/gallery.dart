import 'package:json_annotation/json_annotation.dart';
import '../globals.dart';

part 'gallery.g.dart';

@JsonSerializable()
class GMeta {
  const GMeta({
    required this.gid,
    required this.token,
    required this.title,
    required this.titleJpn,
    required this.category,
    required this.uploader,
    required this.posted,
    required this.filecount,
    required this.filesize,
    required this.expunged,
    required this.rating,
    this.parentGid,
    this.parentToken,
    this.firstGid,
    this.firstToken,
  });
  final int gid;
  final String token;
  final String title;
  @JsonKey(name: 'title_jpn')
  final String titleJpn;
  final String category;
  final String uploader;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime posted;
  final int filecount;
  final int filesize;
  final bool expunged;
  final double rating;
  @JsonKey(name: 'parent_gid')
  final int? parentGid;
  @JsonKey(name: 'parent_token')
  final String? parentToken;
  @JsonKey(name: 'first_gid')
  final int? firstGid;
  @JsonKey(name: 'first_token')
  final String? firstToken;

  static DateTime _fromJson(int posted) =>
      DateTime.fromMillisecondsSinceEpoch(posted * 1000);
  static int _toJson(DateTime posted) => posted.millisecondsSinceEpoch ~/ 1000;
  factory GMeta.fromJson(Map<String, dynamic> json) => _$GMetaFromJson(json);
  Map<String, dynamic> toJson() => _$GMetaToJson(this);
  String get preferredTitle => prefs.getBool("useTitleJpn") == true
      ? titleJpn.isEmpty
          ? title
          : titleJpn
      : title;
}

@JsonSerializable()
class GMetaOptional {
  const GMetaOptional({
    this.gid,
    this.token,
    this.title,
    this.titleJpn,
    this.category,
    this.uploader,
    this.posted,
    this.filecount,
    this.filesize,
    this.expunged,
    this.rating,
    this.parentGid,
    this.parentToken,
    this.firstGid,
    this.firstToken,
  });
  final int? gid;
  final String? token;
  final String? title;
  @JsonKey(name: 'title_jpn')
  final String? titleJpn;
  final String? category;
  final String? uploader;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime? posted;
  final int? filecount;
  final int? filesize;
  final bool? expunged;
  final double? rating;
  @JsonKey(name: 'parent_gid')
  final int? parentGid;
  @JsonKey(name: 'parent_token')
  final String? parentToken;
  @JsonKey(name: 'first_gid')
  final int? firstGid;
  @JsonKey(name: 'first_token')
  final String? firstToken;

  static DateTime? _fromJson(int? posted) => posted != null
      ? DateTime.fromMillisecondsSinceEpoch(posted! * 1000)
      : null;
  static int? _toJson(DateTime? posted) =>
      posted != null ? posted.millisecondsSinceEpoch ~/ 1000 : null;
  factory GMetaOptional.fromJson(Map<String, dynamic> json) =>
      _$GMetaOptionalFromJson(json);
  Map<String, dynamic> toJson() => _$GMetaOptionalToJson(this);
}

@JsonSerializable()
class Tag {
  const Tag({
    required this.id,
    required this.tag,
    this.translated,
    this.intro,
  });
  final int id;
  final String tag;
  final String? translated;
  final String? intro;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
class ExtendedPMeta {
  const ExtendedPMeta({
    required this.gid,
    required this.index,
    required this.token,
    required this.name,
    required this.width,
    required this.height,
    required this.isNsfw,
    required this.isAd,
  });
  final int gid;
  final int index;
  final String token;
  final String name;
  final int width;
  final int height;
  @JsonKey(name: 'is_nsfw')
  final bool isNsfw;
  @JsonKey(name: 'is_ad')
  final bool isAd;

  factory ExtendedPMeta.fromJson(Map<String, dynamic> json) =>
      _$ExtendedPMetaFromJson(json);
  Map<String, dynamic> toJson() => _$ExtendedPMetaToJson(this);
}

@JsonSerializable()
class GalleryData {
  const GalleryData({
    required this.meta,
    required this.tags,
    required this.pages,
  });
  final GMeta meta;
  final List<Tag> tags;
  final List<ExtendedPMeta> pages;
  bool get isAllNsfw => pages.every((page) => page.isNsfw);

  factory GalleryData.fromJson(Map<String, dynamic> json) =>
      _$GalleryDataFromJson(json);
  Map<String, dynamic> toJson() => _$GalleryDataToJson(this);
}
