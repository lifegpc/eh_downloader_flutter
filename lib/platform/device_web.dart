import 'package:ua_parser_js/ua_parser_js.dart';

final _uaParser = UAParser();
String? _device;

Future<String?> get device {
  if (_device == null) {
    final ua = _uaParser.getResult();
    _device = ua.browser.name;
    if (_device != null && _device!.isNotEmpty) {
      _device = "$_device ${ua.browser.version}";
    }
  }
  return Future.value(_device);
}

String? get clientPlatform => "web";
