@JS()
library web_stub;

import 'package:js/js.dart';

// Stub para APIs web quando executando em mobile
class VideoElement {
  dynamic style = _StyleStub();
  String? src;
  bool? controls;
  bool? autoplay;
  double? volume;
  double? playbackRate;
  double? currentTime;

  void play() {}
  void pause() {}
  void remove() {}
}

class _StyleStub {
  String? width;
  String? height;
}

@JS('window')
external dynamic get window;

@JS('document')
external dynamic get document;

VideoElement createVideoElement() => VideoElement();

@JS('JSON.stringify')
external String stringify(Object obj);

@JS()
external dynamic get Hls;

dynamic jsify(Object obj) => null;

dynamic getProperty(dynamic obj, String prop) => null;

dynamic callConstructor(dynamic constructor, List args) => null;

dynamic callMethod(dynamic obj, String method, List args) => null;

dynamic setProperty(dynamic obj, String prop, dynamic value) => null;

T allowInterop<T extends Function>(T fn) => fn; 