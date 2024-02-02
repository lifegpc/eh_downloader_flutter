export './device_other.dart' if (dart.library.html) './device_web.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String?> get clientVersion async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } catch (_) {
    return null;
  }
}
