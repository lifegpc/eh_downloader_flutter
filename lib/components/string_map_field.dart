import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eh_downloader_flutter/l10n_gen/app_localizations.dart';

class StringMapFormField extends StatefulWidget {
  const StringMapFormField(
      {super.key,
      this.initialValue,
      this.onChanged,
      this.keyDecoration,
      this.valueDecoration,
      this.padding,
      this.keyPadding,
      this.valuePadding,
      this.keyValidator,
      this.valueValidator,
      this.keyAutovalidateMode,
      this.valueAutovalidateMode,
      this.label,
      this.helper,
      this.constraints});
  final Map<String, String>? initialValue;
  final ValueChanged<Map<String, String>>? onChanged;
  final InputDecoration? keyDecoration;
  final InputDecoration? valueDecoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? keyPadding;
  final EdgeInsetsGeometry? valuePadding;
  final FormFieldValidator<String>? keyValidator;
  final FormFieldValidator<String>? valueValidator;
  final AutovalidateMode? keyAutovalidateMode;
  final AutovalidateMode? valueAutovalidateMode;
  final Widget? label;
  final Widget? helper;
  final BoxConstraints? constraints;

  @override
  State<StringMapFormField> createState() => _StringMapFormField();
}

class _StringMapFormField extends State<StringMapFormField> {
  late Map<String, String> value;
  late String parentKey;
  late Key lastKey;
  late List<Key> keys;
  late int rebuildKeys;
  late List<String> keyList;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue ?? {};
    parentKey = widget.key?.toString() ?? "";
    lastKey = ValueKey("${parentKey}_new");
    final len = value.length;
    keys = List.generate(len, (index) => ValueKey("${parentKey}_$index"));
    keyList = value.keys.toList();
    rebuildKeys = 0;
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = keyList.removeAt(oldIndex);
      keyList.insert(newIndex, item);
      final key = keys.removeAt(oldIndex);
      keys.insert(newIndex, key);
    });
    widget.onChanged?.call(value);
  }

  Widget _buildKeyItem(BuildContext context, int index, bool expanded) {
    final i18n = AppLocalizations.of(context)!;
    Widget item = TextFormField(
      initialValue: keyList[index],
      decoration: widget.keyDecoration,
      onChanged: (String? value) {
        if (widget.keyValidator != null) {
          final re = widget.keyValidator?.call(value);
          if (re != null) {
            return;
          }
        }
        final v = value ?? "";
        if (v.isEmpty || this.value.containsKey(v)) {
          return;
        }
        final old = keyList[index];
        keyList[index] = v;
        final va = this.value.remove(old);
        this.value[v] = va ?? "";
        widget.onChanged?.call(this.value);
      },
      validator: (s) {
        final re = widget.keyValidator?.call(s);
        if (re != null) {
          return re;
        }
        final v = s ?? "";
        if (v.isEmpty) {
          return i18n.keyIsEmpty;
        }
        if (value.containsKey(v)) {
          return i18n.keyIsExists;
        }
        return null;
      },
      autovalidateMode: widget.keyAutovalidateMode,
    );
    if (expanded) {
      if (widget.keyPadding != null) {
        item = Padding(
          padding: widget.keyPadding!,
          child: item,
        );
      }
      item = Expanded(child: item);
    } else if (widget.padding != null) {
      item = Padding(
        padding: widget.padding!,
        child: item,
      );
    }
    return item;
  }

  Widget _buildValueItem(BuildContext context, int index, bool expanded) {
    Widget item = TextFormField(
      initialValue: value[keyList[index]],
      decoration: widget.keyDecoration,
      onChanged: (String? value) {
        if (widget.valueValidator != null) {
          final re = widget.valueValidator?.call(value);
          if (re != null) {
            return;
          }
        }
        this.value[keyList[index]] = value ?? "";
        widget.onChanged?.call(this.value);
      },
      validator: widget.valueValidator,
      autovalidateMode: widget.valueAutovalidateMode,
    );
    if (expanded) {
      if (widget.valuePadding != null) {
        item = Padding(
          padding: widget.valuePadding!,
          child: item,
        );
      }
      item = Expanded(child: item);
    } else if (widget.padding != null) {
      item = Padding(
        padding: widget.padding!,
        child: item,
      );
    }
    return item;
  }

  Widget _buildItem(BuildContext context, int index) {
    final useMobile = MediaQuery.of(context).size.width <= 810;
    Widget item = Row(
      key: keys[index],
      children: [
        useMobile
            ? Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                _buildKeyItem(context, index, false),
                _buildValueItem(context, index, false),
              ]))
            : _buildKeyItem(context, index, true),
        useMobile ? Container() : _buildValueItem(context, index, true),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              final key = keyList.removeAt(index);
              value.remove(key);
            });
            widget.onChanged?.call(value);
          },
        ),
        ReorderableDragStartListener(
            index: index, child: const Icon(Icons.reorder)),
      ],
    );
    if (!useMobile && widget.padding != null) {
      item = Padding(
        key: item.key,
        padding: widget.padding!,
        child: item,
      );
    }
    return item;
  }

  Widget _buildList(BuildContext context) {
    Widget list = ReorderableList(
        itemBuilder: _buildItem,
        itemCount: value.length,
        onReorder: onReorder,
        proxyDecorator: proxyDecorator,
        shrinkWrap: true);
    if (widget.constraints != null) {
      list = ConstrainedBox(
        constraints: widget.constraints!,
        child: list,
      );
    }
    return list;
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildLabel(BuildContext context) {
    if (widget.label == null) {
      return Container();
    }
    if (widget.padding == null) {
      return widget.label!;
    }
    return Padding(
      padding: widget.padding!,
      child: widget.label!,
    );
  }

  Widget _buildHelper(BuildContext context) {
    if (widget.helper == null) {
      return Container();
    }
    if (widget.padding == null) {
      return widget.helper!;
    }
    return Padding(
      padding: widget.padding!,
      child: widget.helper!,
    );
  }

  Widget _buildAddButton(BuildContext context) {
    Widget button = LayoutBuilder(builder: (context, box) {
      return SizedBox(
          width: box.maxWidth,
          child: IconButton(
              key: lastKey,
              onPressed: value.containsKey("")
                  ? null
                  : () {
                      if (value.containsKey("")) {
                        return;
                      }
                      setState(() {
                        value[""] = "";
                        keyList.add("");
                        keys.add(ValueKey("${parentKey}_${value.length}"));
                      });
                      widget.onChanged?.call(value);
                    },
              icon: const Icon(Icons.add)));
    });
    if (widget.padding != null) {
      button = Padding(
        padding: widget.padding!,
        child: button,
      );
    }
    return button;
  }

  @override
  Widget build(BuildContext context) {
    if (value.length != keys.length) {
      final len = value.length;
      keys = List.generate(
          len, (index) => ValueKey("${parentKey}_${rebuildKeys}_$index"));
      keyList = value.keys.toList();
      rebuildKeys++;
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(context),
          _buildList(context),
          _buildAddButton(context),
          _buildHelper(context),
        ]);
  }
}
