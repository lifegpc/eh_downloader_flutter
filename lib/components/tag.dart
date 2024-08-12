import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/gallery.dart';
import '../globals.dart';

class TagWidget extends StatelessWidget {
  const TagWidget(this.tag, {super.key, this.name});
  final Tag tag;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final t =
        Text(name ?? (tag.tag.contains(':') ? tag.tag.split(':')[1] : tag.tag));
    if (shareToken != null) return t;
    return InkWell(
        onTap: () {
          context.pushNamed("/galleries",
              queryParameters: {
                "tag": [tag.tag]
              },
              extra: GalleriesPageExtra(translatedTag: tag.translated));
        },
        child: t);
  }
}
