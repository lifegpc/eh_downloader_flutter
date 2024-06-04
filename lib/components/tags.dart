import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/gallery.dart';
import '../globals.dart';
import '../main.dart';
import '../platform/ua.dart' as ua;
import '../utils.dart';
import 'tag.dart';
import 'tag_tooltip.dart';
import 'scroll_parent.dart';

class TagsPanel extends StatefulWidget {
  const TagsPanel(this.tags,
      {super.key, this.controller, this.sliver, this.margin});
  final List<Tag> tags;
  final ScrollController? controller;
  final bool? sliver;
  final EdgeInsetsGeometry? margin;

  @override
  State<TagsPanel> createState() => _TagsPanel();
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
    final stt = prefs.getBool("showTranslatedTag") ??
        MainApp.of(context).lang.toLocale().languageCode == "zh";
    Widget itemBuilder(BuildContext context, int index) {
      final t = data![index].$1;
      final ta = data![index].$2;
      final namespace =
          "${stt ? (tags.getTagTranslate(t) ?? t) : t}${AppLocalizations.of(context)!.colon}";
      return Container(
          margin: widget.margin,
          child: Wrap(
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
                  child: stt
                      ? TagTooltip(ta[index - 1]!)
                      : TagWidget(ta[index - 1]!));
            }
          })));
    }

    final re = widget.sliver == true
        ? SliverList.builder(
            itemBuilder: itemBuilder,
            itemCount: data!.length,
          )
        : ListView.builder(
            physics:
                isIOS || ua.isSafari ? const ClampingScrollPhysics() : null,
            padding: const EdgeInsets.all(8),
            itemCount: data!.length,
            itemBuilder: itemBuilder);
    final re2 = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: re);
    return widget.controller != null
        ? ScrollParent(controller: widget.controller!, child: re2)
        : re;
  }
}
