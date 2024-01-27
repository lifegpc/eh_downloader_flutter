import "package:flutter/material.dart";

class FitText extends StatefulWidget {
  const FitText({
    Key? key,
    required this.texts,
    this.style,
    this.separator = " ",
  }) : super(key: key);
  final List<(String, int)> texts;
  final TextStyle? style;
  final String separator;

  @override
  State<FitText> createState() => _FitText();
}

class _FitText extends State<FitText> {
  late List<String> texts;
  late List<double> sizes;

  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  void initState() {
    super.initState();
    final tmp = widget.texts.map((e) => e.$2).toSet().toList()
      ..sort((b, a) => a.compareTo(b));
    sizes = [];
    texts = [];
    for (final i in tmp) {
      final text = widget.texts
          .where((e) => e.$2 >= i)
          .map((e) => e.$1)
          .join(widget.separator);
      texts.add(text);
      sizes.add(_textSize(text, widget.style).width);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) return Container();
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      for (int i = sizes.length - 1; i >= 0; i--) {
        if (sizes[i] <= maxWidth) {
          return Text(texts[i], style: widget.style);
        }
      }
      return Text(texts[0], style: widget.style);
    });
  }
}
