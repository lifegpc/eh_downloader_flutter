import 'dart:ui';
import 'package:flutter/material.dart';

class StringListFormField extends StatefulWidget {
  const StringListFormField(
      {super.key,
      this.initialValue,
      this.onChanged,
      this.decoration,
      this.padding,
      this.validator,
      this.autovalidateMode,
      this.label,
      this.helper,
      this.constraints});
  final List<String>? initialValue;
  final ValueChanged<List<String>>? onChanged;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget? label;
  final Widget? helper;
  final BoxConstraints? constraints;

  @override
  State<StringListFormField> createState() => _StringListFormField();
}

class _StringListFormField extends State<StringListFormField> {
  late List<String> value;
  late String parentKey;
  late Key lastKey;
  late List<Key> keys;
  late int rebuildKeys;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue ?? [];
    parentKey = widget.key?.toString() ?? "";
    lastKey = ValueKey("${parentKey}_new");
    final len = value.length;
    keys = List.generate(len, (index) => ValueKey("${parentKey}_$index"));
    rebuildKeys = 0;
  }

  Widget _buildItem(BuildContext context, int index) {
    Widget item = Row(
      key: keys[index],
      children: [
        Expanded(
          child: TextFormField(
            initialValue: value[index],
            decoration: widget.decoration,
            onChanged: (String? value) {
              if (widget.validator != null) {
                final re = widget.validator?.call(value);
                if (re != null) {
                  return;
                }
              }
              this.value[index] = value ?? "";
              widget.onChanged?.call(this.value);
            },
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              value.removeAt(index);
            });
            widget.onChanged?.call(value);
          },
        ),
        ReorderableDragStartListener(
            index: index, child: const Icon(Icons.reorder)),
      ],
    );
    if (widget.padding != null) {
      item = Padding(
        key: item.key,
        padding: widget.padding!,
        child: item,
      );
    }
    return item;
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = value.removeAt(oldIndex);
      value.insert(newIndex, item);
      final key = keys.removeAt(oldIndex);
      keys.insert(newIndex, key);
    });
    widget.onChanged?.call(value);
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
              onPressed: () {
                setState(() {
                  value.add("");
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
