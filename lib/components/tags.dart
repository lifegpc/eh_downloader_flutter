import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/gallery.dart';
import '../globals.dart';
import 'scroll_parent.dart';

class TagsPanel extends StatefulWidget {
  const TagsPanel(this.tags, {Key? key, this.controller}) : super(key: key);
  final List<Tag> tags;
  final ScrollController? controller;

  @override
  State<TagsPanel> createState() => _TagsPanel();
}

String _getTag(Tag tag) {
  final tags = tag.tag.split(":");
  if (tags.length < 2) return tag.translated ?? tag.tag;
  final name = tags[1]!;
  return tag.translated ?? name;
}

class _TagsPanel extends State<TagsPanel> {
  List<(String, List<Tag>)>? data;
  @override
  void initState() {
    Map<String, List<Tag>> maps = {};
    for (var e in widget.tags) {
      final tags = e.tag.split(":");
      if (tags.length < 2) {
        final list = maps[""] ?? [];
        list.add(e);
        maps[""] = list;
        continue;
      }
      final name = tags[0];
      final list = maps[name] ?? [];
      list.add(e);
      maps[name] = list;
    }
    data = [];
    maps.forEach((key, value) {
      data!.add((key, value));
    });
    if (tags.rows == null) {
      tags.getRows().then((re) {
        if (re) setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final re = ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data!.length,
        itemBuilder: (context, index) {
          final t = data![index].$1;
          final ta = data![index].$2;
          final namespace =
              "${tags.getTagTranslate(t) ?? t}${AppLocalizations.of(context)!.colon}";
          return Wrap(
              children: List.generate(ta.length + 1, (index) {
            if (index == 0) {
              return Container(
                  margin: const EdgeInsets.all(2),
                  child: SelectableText(namespace));
            } else {
              return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(width: 1, color: cs.primary),
                  ),
                  child: SelectableText(_getTag(ta[index - 1]!)));
            }
          }));
        });
    return widget.controller != null
        ? ScrollParent(controller: widget.controller!, child: re)
        : re;
  }
}
