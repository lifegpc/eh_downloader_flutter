// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

bool get pointerIsMouse => window.matchMedia('(pointer: fine)').matches;
bool get pointerIsTouch => window.matchMedia('(pointer: coarse)').matches;
