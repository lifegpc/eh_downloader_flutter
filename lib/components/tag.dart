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
    return InkWell(
        onTap: () {
          context.pushNamed("/galleries",
              queryParameters: {
                "tag": [tag.tag]
              },
              extra: GalleriesPageExtra(translatedTag: tag.translated));
        },
        child: Text(name ?? tag.tag));
  }
}
