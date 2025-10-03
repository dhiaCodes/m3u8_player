import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'dart:async';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '../player_interface.dart';
import 'dart:ui_web' as ui;

@JS('window')
external JSObject get window;

@JS('Hls')
extension type HlsJS._(JSObject _) implements JSObject {
  external HlsJS(JSObject config);
  external static bool isSupported();
  external void loadSource(String url);
  external void attachMedia(web.HTMLVideoElement video);
  external void on(String event, JSFunction callback);
  external void destroy();
  external int get currentLevel;
  external set currentLevel(int level);
  external JSObject get levels;
}

class M3u8Player implements PlayerInterface {
  static void registerWith(Registrar registrar) {
    // Se necessário, registre o plugin web.
  }

  web.HTMLVideoElement? _videoElement;
  JSObject? _hls;
  Timer? _progressTimer;
  final String _viewId = 'hls-video-${DateTime.now().millisecondsSinceEpoch}';
  final Function(List<String>) onQualitiesUpdated;
  final Function(String) onQualityChanged;
  final Function(Duration) onDurationChanged;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onBufferedChanged;
  bool _isInitialized = false;
  bool _hasCompleted = false;
  bool get hasCompleted => _hasCompleted;
  double _completedPercentage = 1.0; // Default to 100%
  Function()? _onCompleted;

  // Novo: Aceita onCompleted e completedPercentage via construtor.
  M3u8Player({
    required this.onQualitiesUpdated,
    required this.onQualityChanged,
    required this.onDurationChanged,
    required this.onPositionChanged,
    required this.onBufferedChanged,
    Function()? onCompleted,
    double completedPercentage = 1.0,
  }) {
    _onCompleted = onCompleted;
    _completedPercentage = completedPercentage;

    _videoElement = web.HTMLVideoElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.objectFit = 'contain'
      ..controls = false
      ..muted = true;

    // Registra a view para HtmlElementView
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      return _videoElement!;
    });
  }

  @override
  String get viewId => _viewId;

  // Na web, não usamos controller; retorne null.
  @override
  dynamic get controller => null;

  @override
  Future<void> initialize(String url) async {
    if (!window.has('Hls')) {
      final completer = Completer<void>();
      final script = web.HTMLScriptElement()
        ..src = "https://cdn.jsdelivr.net/npm/hls.js@latest"
        ..type = "text/javascript";
      script.onLoad.listen((_) {
        completer.complete();
      });
      script.onError.listen((_) {
        completer.completeError("Error loading hls.js");
      });
      web.document.head?.append(script);
      try {
        await completer.future;
      } catch (e) {
        log("DEBUG: Error loading hls.js: $e");
        return;
      }
    }

    final hlsConstructor = window.getProperty('Hls'.toJS) as JSFunction;
    final isSupported = hlsConstructor.callMethod('isSupported'.toJS);
    if (!(isSupported as JSBoolean).toDart) {
      return;
    }

    final hlsConfig = {
      'debug': false,
      'enableWorker': true,
      'lowLatencyMode': true,
      'autoStartLoad': true,
    }.jsify();

    try {
      _hls = hlsConstructor.callAsConstructor(hlsConfig);
    } catch (e) {
      return;
    }

    final manifestLoadedCallback = ((JSAny event, JSAny data) {
      try {
        final dataObj = data as JSObject;
        final levels = dataObj.getProperty('levels'.toJS);
        if (levels == null) return;

        final levelsArray = levels as JSObject;
        final levelsLength =
            (levelsArray.getProperty('length'.toJS) as JSNumber).toDartInt;
        List<String> qualities = ['Auto'];
        List<Map<String, dynamic>> qualityList = [];

        for (var i = 0; i < levelsLength; i++) {
          try {
            final level = levelsArray.getProperty('$i'.toJS) as JSObject;
            final quality = _getQualityString(level);
            final height =
                (level.getProperty('height'.toJS) as JSNumber).toDartInt;
            qualityList.add({
              'quality': quality,
              'height': height,
              'index': i,
            });
          } catch (_) {
            continue;
          }
        }
        qualityList
            .sort((a, b) => (b['height'] as int).compareTo(a['height'] as int));
        qualities.addAll(qualityList.map((q) => q['quality'] as String));

        if (qualities.isNotEmpty) {
          onQualitiesUpdated(qualities);
          _hls!.setProperty('currentLevel'.toJS, (-1).toJS);
          onQualityChanged('Auto');
          _setupLevelSwitchCallback(qualityList);
        }
      } catch (_) {}
    }).toJS;

    final manifestParsedCallback = ((JSAny event, JSAny data) {
      if (_videoElement != null) {
        _videoElement!.volume = 1.0;
        _videoElement!.muted = false;
      }
    }).toJS;

    _hls!.callMethod(
        'on'.toJS, 'hlsManifestLoaded'.toJS, manifestLoadedCallback);
    _hls!.callMethod(
        'on'.toJS, 'hlsManifestParsed'.toJS, manifestParsedCallback);

    _hls!.callMethod('loadSource'.toJS, url.toJS);
    _hls!.callMethod('attachMedia'.toJS, _videoElement!);

    _setupVideoEventListeners();
    _startProgressTimer();
    _isInitialized = true;
  }

  String _getQualityString(JSObject level) {
    final height = level.getProperty('height'.toJS) as JSNumber?;
    final attrs = level.getProperty('attrs'.toJS) as JSObject?;
    try {
      if (attrs != null) {
        final name = attrs.getProperty('NAME'.toJS) as JSString?;
        if (name != null) return name.toDart;
      }
    } catch (_) {}
    return '${height?.toDartInt ?? 0}p';
  }

  void _setupLevelSwitchCallback(List<Map<String, dynamic>> qualityList) {
    final levelSwitchCallback = ((JSAny event, JSAny data) {
      final currentLevel =
          (_hls!.getProperty('currentLevel'.toJS) as JSNumber).toDartInt;
      if (currentLevel == -1) {
        onQualityChanged('Auto');
      } else if (currentLevel >= 0 && currentLevel < qualityList.length) {
        onQualityChanged(qualityList[currentLevel]['quality'] as String);
      }
    }).toJS;
    _hls!.callMethod('on'.toJS, 'levelSwitched'.toJS, levelSwitchCallback);
  }

  void _setupVideoEventListeners() {
    _videoElement?.onDurationChange.listen((_) {
      final duration = _videoElement?.duration ?? 0;
      onDurationChanged(Duration(milliseconds: (duration * 1000).toInt()));
    });

    _videoElement?.onTimeUpdate.listen((_) {
      final position = _videoElement?.currentTime ?? 0;
      onPositionChanged(Duration(milliseconds: (position * 1000).toInt()));
      if ((_videoElement?.buffered.length ?? 0) > 0) {
        final buffered =
            _videoElement!.buffered.end(_videoElement!.buffered.length - 1);
        onBufferedChanged(Duration(milliseconds: (buffered * 1000).toInt()));
      }
      // Verifica se a porcentagem de conclusão foi atingida e chama onCompleted.
      if (_videoElement != null && _videoElement!.duration > 0) {
        double progress = _videoElement!.currentTime / _videoElement!.duration;
        if (progress >= _completedPercentage) {
          _hasCompleted = true;

          _onCompleted?.call();
        }
      }
    });
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_isInitialized) {
        final position = _videoElement?.currentTime ?? 0;
        onPositionChanged(Duration(milliseconds: (position * 1000).toInt()));
      }
    });
  }

  @override
  void play() {
    if (_isInitialized) {
      _videoElement?.muted = false;
      _videoElement?.play();
    }
  }

  @override
  void pause() {
    if (_isInitialized) {
      _videoElement?.pause();
    }
  }

  @override
  void seekTo(Duration position) {
    if (_isInitialized) {
      _videoElement?.currentTime = position.inMilliseconds / 1000;
    }
  }

  @override
  void setVolume(double volume) {
    if (_isInitialized) {
      _videoElement?.volume = volume;
      _videoElement?.muted = volume <= 0;
    }
  }

  @override
  void setPlaybackSpeed(double speed) {
    if (_isInitialized) {
      _videoElement?.playbackRate = speed;
    }
  }

  @override
  void setQuality(String quality) {
    if (!_isInitialized || _hls == null) return;

    if (quality == 'Auto') {
      _hls!.setProperty('currentLevel'.toJS, (-1).toJS);
      onQualityChanged('Auto');
      return;
    }

    final levels = _hls!.getProperty('levels'.toJS) as JSObject;
    final levelsLength =
        (levels.getProperty('length'.toJS) as JSNumber).toDartInt;
    for (var i = 0; i < levelsLength; i++) {
      final level = levels.getProperty('$i'.toJS) as JSObject;
      if (_getQualityString(level) == quality) {
        _hls!.setProperty('currentLevel'.toJS, i.toJS);
        onQualityChanged(quality);
        break;
      }
    }
  }

  @override
  void enterFullscreen() {
    try {
      if (_videoElement != null) {
        final videoObj = _videoElement! as JSObject;
        if (videoObj.has('requestFullscreen')) {
          videoObj.callMethod('requestFullscreen'.toJS);
        } else if (videoObj.has('webkitRequestFullscreen')) {
          videoObj.callMethod('webkitRequestFullscreen'.toJS);
        } else if (videoObj.has('mozRequestFullScreen')) {
          videoObj.callMethod('mozRequestFullScreen'.toJS);
        } else if (videoObj.has('msRequestFullscreen')) {
          videoObj.callMethod('msRequestFullscreen'.toJS);
        }
      }
    } catch (e) {
      log("DEBUG: enterFullscreen error: $e");
    }
  }

  @override
  void exitFullscreen() {
    try {
      final documentObj = web.document as JSObject;
      if (documentObj.has('exitFullscreen')) {
        documentObj.callMethod('exitFullscreen'.toJS);
      } else if (documentObj.has('webkitExitFullscreen')) {
        documentObj.callMethod('webkitExitFullscreen'.toJS);
      } else if (documentObj.has('mozCancelFullScreen')) {
        documentObj.callMethod('mozCancelFullScreen'.toJS);
      } else if (documentObj.has('msExitFullscreen')) {
        documentObj.callMethod('msExitFullscreen'.toJS);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    if (_isInitialized) {
      _videoElement?.pause();
      if (_hls != null) {
        _hls!.callMethod('destroy'.toJS);
      }
      _videoElement?.remove();
    }
  }
}
