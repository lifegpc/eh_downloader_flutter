import 'package:flutter/material.dart';
import '../api/gallery.dart';

String _getTag(Tag tag) {
  final tags = tag.tag.split(":");
  if (tags.length < 2) return tag.translated ?? tag.tag;
  final name = tags[1]!;
  return tag.translated ?? name;
}

class TagTooltip extends StatelessWidget {
  const TagTooltip(this.tag, {Key? key}) : super(key: key);
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final name = _getTag(tag);
    final t = SelectableText(name);
    return tag.intro != null && tag.intro!.isNotEmpty ? Tooltip(
      message: tag.intro!,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: t,
    ) : t;
  }
}
