import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../api/gallery.dart';
import '../dialog/gallery_details_page.dart';
import '../main.dart';
import '../utils/filesize.dart';
import 'rate.dart';

class GalleryInfoDetail extends StatelessWidget {
  const GalleryInfoDetail(this.meta, {Key? key}) : super(key: key);
  final GMeta meta;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i18n = AppLocalizations.of(context)!;
    final locale = MainApp.of(context).lang.toLocale().toString();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: 73,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(i18n.pages(meta.filecount),
                style: TextStyle(color: cs.secondary)),
            Text(getFileSize(meta.filesize),
                style: TextStyle(color: cs.secondary)),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Rate(meta.rating, fontSize: 14),
              Text(DateFormat.yMd(locale).add_jms().format(meta.posted),
                  style: TextStyle(color: cs.secondary)),
            ],
          ),
          TextButton(
              onPressed: () {
                context.push('/dialog/gallery/details/${meta.gid}',
                    extra: GalleryDetailsPageExtra(meta: meta));
              },
              child: Text(i18n.seeMoreInfo)),
        ]),
      ),
    );
  }
}
