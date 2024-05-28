import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../globals.dart';
import '../utils/download_zip.dart';

final _log = Logger("DownloadZipPage");

class DownloadZipPage extends StatefulWidget {
  const DownloadZipPage(this.gid, {super.key});
  final int gid;

  static const routeName = '/dialog/download/zip/:gid';

  @override
  State<DownloadZipPage> createState() => _DownloadZipPage();
}

class _DownloadZipPage extends State<DownloadZipPage> {
  bool useTitleJpn = false;
  bool exportAd = false;
  String maxLength = "";
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    useTitleJpn = prefs.getBool("useTitleJpn") ?? false;
    exportAd = prefs.getBool("exportAd") ?? false;
    maxLength = prefs.getInt("maxZipFilenameLength")?.toString() ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final maxWidth = MediaQuery.of(context).size.width;
    return Container(
        padding: maxWidth < 400
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 5)
            : const EdgeInsets.all(20),
        width: maxWidth < 810 ? null : 800,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          i18n.downloadAsZip,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => context.canPop()
                                  ? context.pop()
                                  : context.go("/gallery/${widget.gid}"),
                              icon: const Icon(Icons.close),
                            )),
                      ],
                    ),
                    CheckboxMenuButton(
                        value: useTitleJpn,
                        onChanged: (u) {
                          if (u != null) {
                            setState(() {
                              useTitleJpn = u!;
                            });
                          }
                        },
                        child: Text(i18n.useTitleJpn)),
                    CheckboxMenuButton(
                        value: exportAd,
                        onChanged: (u) {
                          if (u != null) {
                            setState(() {
                              exportAd = u!;
                            });
                          }
                        },
                        child: Text(i18n.exportAd)),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          initialValue: maxLength,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (v) {
                            setState(() {
                              maxLength = v;
                            });
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: i18n.maxZipFilenameLength),
                        )),
                    ElevatedButton(
                        onPressed: () {
                          downloadZip(widget.gid,
                                  jpnTitle: useTitleJpn,
                                  exportAd: exportAd,
                                  maxLength: int.tryParse(maxLength))
                              .then((_) {
                            if (!kIsWeb) {
                              final snack = SnackBar(
                                  content: Text(i18n.downloadComplete));
                              rootScaffoldMessengerKey.currentState
                                  ?.showSnackBar(snack);
                            }
                          }).catchError((err) {
                            _log.warning("Failed to download zip:", err);
                            if (!kIsWeb) {
                              final snack = SnackBar(
                                  content: Text(i18n.downloadZipFailed));
                              rootScaffoldMessengerKey.currentState
                                  ?.showSnackBar(snack);
                            }
                          });
                          context.canPop()
                              ? context.pop()
                              : context.go("/gallery/${widget.gid}");
                        },
                        child: Text(i18n.download))
                  ],
                ))));
  }
}
