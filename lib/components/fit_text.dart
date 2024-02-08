import "package:flutter/material.dart";

class FitText extends StatelessWidget {
  const FitText({
    super.key,
    required this.texts,
    this.style,
    this.separator = " ",
  });
  final List<(String, int)> texts;
  final TextStyle? style;
  final String separator;

  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final tmp = this.texts.map((e) => e.$2).toSet().toList()
      ..sort((b, a) => a.compareTo(b));
    final List<double> sizes = [];
    final List<String> texts = [];
    for (final i in tmp) {
      final text =
          this.texts.where((e) => e.$2 >= i).map((e) => e.$1).join(separator);
      texts.add(text);
      sizes.add(_textSize(text, style).width);
    }
    if (texts.isEmpty) return Container();
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      for (int i = sizes.length - 1; i >= 0; i--) {
        if (sizes[i] <= maxWidth) {
          return Text(texts[i], style: style);
        }
      }
      return Text(texts[0], style: style);
    });
  }
}
