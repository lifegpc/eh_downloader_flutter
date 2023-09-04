import 'api_result.dart';
import 'gallery.dart';

class Tags {
  const Tags({required this.tags});
  final Map<String, ApiResult<Tag>> tags;
  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        tags: (json).map(
          (k, e) => MapEntry(
              k,
              ApiResult<Tag>.fromJson(e as Map<String, dynamic>,
                  (e) => Tag.fromJson(e as Map<String, dynamic>))),
        ),
      );
}
