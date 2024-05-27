import 'package:web/web.dart';

void setTitleWeb(String title) {
  Future.delayed(const Duration(milliseconds: 10), () {
    document.title = title;
  });
}
