// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void setTitleWeb(String title) {
  Future.delayed(const Duration(milliseconds: 10), () {
    document.title = title;
  });
}
