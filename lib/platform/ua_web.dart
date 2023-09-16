// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:user_agent_analyzer/user_agent_analyzer.dart';

UserAgent? _ua;

UserAgent get ua => _ua ??= UserAgent(window.navigator.userAgent);
bool get isSafari => ua.isSafari;
bool get isMobile => ua.isMobile;
