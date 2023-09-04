import 'package:flutter/material.dart';
import '../api/gallery.dart';
import 'gallery_basic_info.dart';
import 'gallery_info_desktop.dart';

class GalleryInfo extends StatefulWidget {
  const GalleryInfo(this.gData, {Key? key}) : super(key: key);
  final GalleryData gData;

  @override
  State<GalleryInfo> createState() => _GalleryInfo();
}

class _GalleryInfo extends State<GalleryInfo> {
  @override
  Widget build(BuildContext context) {
    bool useMobile = MediaQuery.of(context).size.width <= 810;
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: useMobile ? Column(children: [
                  GalleryBasicInfo(widget.gData.meta, widget.gData.pages.first),
                ],
              ) : Column(children: [
                GalleryInfoDesktop(widget.gData),
              ],)));
    });
  }
}
