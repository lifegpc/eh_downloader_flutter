import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

@JsonSerializable()
class EhFileBasic {
  const EhFileBasic({
    required this.id,
    required this.width,
    required this.height,
    required this.isOriginal,
  });
  final int id;
  final int width;
  final int height;
  @JsonKey(name: 'is_original')
  final bool isOriginal;
  factory EhFileBasic.fromJson(Map<String, dynamic> json) =>
      _$EhFileBasicFromJson(json);
  Map<String, dynamic> toJson() => _$EhFileBasicToJson(this);
}

@JsonSerializable()
class EhFileExtend {
  const EhFileExtend({
    required this.id,
    required this.width,
    required this.height,
    required this.isOriginal,
    required this.token,
  });
  final int id;
  final int width;
  final int height;
  @JsonKey(name: 'is_original')
  final bool isOriginal;
  final String token;
  factory EhFileExtend.fromJson(Map<String, dynamic> json) =>
      _$EhFileExtendFromJson(json);
  Map<String, dynamic> toJson() => _$EhFileExtendToJson(this);
}

class EhFiles {
  EhFiles({required this.files});
  Map<String, List<EhFileBasic>> files;
  factory EhFiles.fromJson(Map<String, dynamic> json) => EhFiles(
        files: (json).map(
          (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map((e) => EhFileBasic.fromJson(e as Map<String, dynamic>))
                  .toList()),
        ),
      );
  void merge(EhFiles another) {
    files.addAll(another.files);
  }
}
