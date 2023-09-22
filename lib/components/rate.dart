import 'package:flutter/material.dart';

class Rate extends StatelessWidget {
  const Rate(this.rate, {Key? key}) : super(key: key);
  final double rate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            size: 12,
          ),
        Text(" $rate", style: TextStyle(color: cs.secondary, fontSize: 12)),
      ],
    );
  }
}
