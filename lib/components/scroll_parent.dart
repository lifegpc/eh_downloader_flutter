import 'package:flutter/material.dart';

class ScrollParent extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;

  const ScrollParent({super.key, this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    if (controller == null) return child;
    return NotificationListener<OverscrollNotification>(
      onNotification: (OverscrollNotification value) {
        if (value.overscroll < 0 &&
            controller!.offset + value.overscroll <= 0) {
          if (controller!.offset != 0) controller!.jumpTo(0);
          return true;
        }
        if (controller!.offset + value.overscroll >=
            controller!.position.maxScrollExtent) {
          if (controller!.offset != controller!.position.maxScrollExtent) {
            controller!.jumpTo(controller!.position.maxScrollExtent);
          }
          return true;
        }
        controller!.jumpTo(controller!.offset + value.overscroll);
        return true;
      },
      child: child,
    );
  }
}
