import 'package:flutter/material.dart';

class Rate extends StatelessWidget {
  const Rate(this.rate, {super.key, this.fontSize, this.selectable = false});
  final double rate;
  final double? fontSize;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = TextStyle(color: cs.secondary, fontSize: fontSize);
    final t = " $rate";
    return Row(
      children: [
        for (var i = 1; i < 6; i++)
          Icon(
            i <= rate + 0.25
                ? Icons.star
                : i > rate + 0.75
                    ? Icons.star_border
                    : Icons.star_half,
            color: cs.primary,
            size: fontSize,
          ),
        selectable ? SelectableText(t, style: style) : Text(t, style: style),
      ],
    );
  }
}
