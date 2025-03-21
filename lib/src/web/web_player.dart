// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:async';
import 'package:js/js.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '../player_interface.dart';
// Importação condicional para registrar a view (dart:ui_web está disponível na web)
import 'dart:ui' as ui;

@JS('window')
external dynamic get window;

class M3u8Player implements PlayerInterface {
  static void registerWith(Registrar registrar) {
    // Se necessário, registre o plugin web.
  }

  html.VideoElement? _videoElement;
  dynamic _hls;
  Timer? _progressTimer;
  final String _viewId = 'hls-video-${DateTime.now().millisecondsSinceEpoch}';
  final Function(List<String>) onQualitiesUpdated;
  final Function(String) onQualityChanged;
  final Function(Duration) onDurationChanged;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onBufferedChanged;
  final Function(bool)? onFullscreenChanged;
  bool _isInitialized = false;
  bool _hasCompleted = false;
  double _completedPercentage = 1.0; // Default to 100%
  Function()? _onCompleted;

  // Novo: Aceita onCompleted e completedPercentage via construtor.
  M3u8Player({
    required this.onQualitiesUpdated,
    required this.onQualityChanged,
    required this.onDurationChanged,
    required this.onPositionChanged,
    required this.onBufferedChanged,
    this.onFullscreenChanged,
    Function()? onCompleted,
    double completedPercentage = 1.0,
  }) {
    print("DEBUG: M3u8Player constructor chamado");
    _onCompleted = onCompleted;
    _completedPercentage = completedPercentage;
 
    _videoElement = html.VideoElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.objectFit = 'contain'
      ..controls = false
      ..muted = true;

    html.document.onFullscreenChange.listen((_) {
      final isFullscreen = html.document.fullscreenElement != null;
      onFullscreenChanged?.call(isFullscreen);
    });

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
    if (!js_util.hasProperty(window, 'Hls')) {
      final completer = Completer<void>();
      final script = html.ScriptElement()
        ..src = "https://cdn.jsdelivr.net/npm/hls.js@latest"
        ..type = "text/javascript";
      script.onLoad.listen((_) {
         completer.complete();
      });
      script.onError.listen((_) {
         completer.completeError("Error loading hls.js");
      });
      html.document.head?.append(script);
      try {
         await completer.future;
      } catch(e) {
         html.window.console.error("DEBUG: hls.js dynamic load failed: $e");
         return;
      }
    }
    
    final isSupported = js_util.callMethod(
      js_util.getProperty(window, 'Hls'),
      'isSupported',
      [],
    );
    if (!isSupported) {
      return;
    }

    final hlsConfig = js_util.jsify({
      'debug': false,
      'enableWorker': true,
      'lowLatencyMode': true,
      'autoStartLoad': true,
    });

    try {
      _hls = js_util.callConstructor(
        js_util.getProperty(window, 'Hls'),
        [hlsConfig],
      );
    } catch (e) {
      return;
    }

    final manifestLoadedCallback = js_util.allowInterop((dynamic event, dynamic data) {
      try {
        final levels = js_util.getProperty(data, 'levels');
        if (levels == null) return;

        final levelsLength = js_util.getProperty(levels, 'length') as int;
        List<String> qualities = ['Auto'];
        List<Map<String, dynamic>> qualityList = [];

        for (var i = 0; i < levelsLength; i++) {
          try {
            final level = js_util.getProperty(levels, '$i');
            final quality = _getQualityString(level);
            final height = js_util.getProperty(level, 'height');
            qualityList.add({
              'quality': quality,
              'height': height,
              'index': i,
            });
          } catch (_) {
            continue;
          }
        }
        qualityList.sort((a, b) => (b['height'] as int).compareTo(a['height'] as int));
        qualities.addAll(qualityList.map((q) => q['quality'] as String));

        if (qualities.isNotEmpty) {
          onQualitiesUpdated(qualities);
          js_util.setProperty(_hls, 'currentLevel', -1);
          onQualityChanged('Auto');
          _setupLevelSwitchCallback(qualityList);
        }
      } catch (_) {}
    });

    final manifestParsedCallback = js_util.allowInterop((dynamic event, dynamic data) {
      if (_videoElement != null) {
        _videoElement!.volume = 1.0;
        _videoElement!.muted = false;
      }
    });

    js_util.callMethod(_hls, 'on', ['hlsManifestLoaded', manifestLoadedCallback]);
    js_util.callMethod(_hls, 'on', ['hlsManifestParsed', manifestParsedCallback]);

    js_util.callMethod(_hls, 'loadSource', [url]);
    js_util.callMethod(_hls, 'attachMedia', [_videoElement]);

    _setupVideoEventListeners();
    _startProgressTimer();
    _isInitialized = true;
  }

  String _getQualityString(dynamic level) {
    final height = js_util.getProperty(level, 'height');
    final bitrate = js_util.getProperty(level, 'bitrate');
    final attrs = js_util.getProperty(level, 'attrs');
    try {
      final name = js_util.getProperty(attrs, 'NAME');
      if (name != null) return name;
    } catch (_) {}
    return '${height}p (${(bitrate / 1000).round()}kbps)';
  }

  void _setupLevelSwitchCallback(List<Map<String, dynamic>> qualityList) {
    final levelSwitchCallback = js_util.allowInterop((dynamic event, dynamic data) {
      final currentLevel = js_util.getProperty(_hls, 'currentLevel');
      if (currentLevel == -1) {
        onQualityChanged('Auto');
      } else if (currentLevel >= 0 && currentLevel < qualityList.length) {
        onQualityChanged(qualityList[currentLevel]['quality'] as String);
      }
    });
    js_util.callMethod(_hls, 'on', ['levelSwitched', levelSwitchCallback]);
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
        final buffered = _videoElement!.buffered.end(_videoElement!.buffered.length - 1);
        onBufferedChanged(Duration(milliseconds: (buffered * 1000).toInt()));
      }
      // Verifica se a porcentagem de conclusão foi atingida e chama onCompleted.
      if (!_hasCompleted &&
          _videoElement != null &&
          _videoElement!.duration > 0) {
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
      js_util.setProperty(_hls, 'currentLevel', -1);
      onQualityChanged('Auto');
      return;
    }

    final levels = js_util.getProperty(_hls, 'levels');
    final levelsLength = js_util.getProperty(levels, 'length') as int;
    for (var i = 0; i < levelsLength; i++) {
      final level = js_util.getProperty(levels, '$i');
      if (_getQualityString(level) == quality) {
        js_util.setProperty(_hls, 'currentLevel', i);
        onQualityChanged(quality);
        break;
      }
    }
  }

  @override
  void enterFullscreen() {
    try {
      if (_videoElement != null) {
        if (js_util.hasProperty(_videoElement!, 'requestFullscreen')) {
          js_util.callMethod(_videoElement!, 'requestFullscreen', []);
        } else if (js_util.hasProperty(_videoElement!, 'webkitRequestFullscreen')) {
          js_util.callMethod(_videoElement!, 'webkitRequestFullscreen', []);
        } else if (js_util.hasProperty(_videoElement!, 'mozRequestFullScreen')) {
          js_util.callMethod(_videoElement!, 'mozRequestFullScreen', []);
        } else if (js_util.hasProperty(_videoElement!, 'msRequestFullscreen')) {
          js_util.callMethod(_videoElement!, 'msRequestFullscreen', []);
        }
      }
    } catch (_) {}
  }

  @override
  void exitFullscreen() {
    try {
      if (js_util.hasProperty(html.document, 'exitFullscreen')) {
        js_util.callMethod(html.document, 'exitFullscreen', []);
      } else if (js_util.hasProperty(html.document, 'webkitExitFullscreen')) {
        js_util.callMethod(html.document, 'webkitExitFullscreen', []);
      } else if (js_util.hasProperty(html.document, 'mozCancelFullScreen')) {
        js_util.callMethod(html.document, 'mozCancelFullScreen', []);
      } else if (js_util.hasProperty(html.document, 'msExitFullscreen')) {
        js_util.callMethod(html.document, 'msExitFullscreen', []);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    if (_isInitialized) {
      _videoElement?.pause();
      if (_hls != null) {
        js_util.callMethod(_hls, 'destroy', []);
      }
      _videoElement?.remove();
    }
  }
}
