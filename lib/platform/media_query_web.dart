import 'package:web/web.dart';

bool get pointerIsMouse => window.matchMedia('(pointer: fine)').matches;
bool get pointerIsTouch => window.matchMedia('(pointer: coarse)').matches;
