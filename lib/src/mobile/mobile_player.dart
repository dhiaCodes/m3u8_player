import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../player_interface.dart';
import 'dart:async';

class M3u8Player implements PlayerInterface {
  VideoPlayerController? _controller;
  final Function(List<String>) onQualitiesUpdated;
  final Function(String) onQualityChanged;
  final Function(Duration) onDurationChanged;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onBufferedChanged;
  final Function(bool)? onFullscreenChanged;
  bool _hasCompleted = false;
  double _completedPercentage = 1.0; // Default to 100%
  Function()? _onCompleted;

  // Atualizado para aceitar onCompleted e completedPercentage
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
    _onCompleted = onCompleted;
    _completedPercentage = completedPercentage;

    _controller = VideoPlayerController.networkUrl(Uri.parse(''))
      ..setVolume(1.0);

    _controller?.addListener(() {
      final position = _controller?.value.position ?? Duration.zero;
      onPositionChanged(position);

      final duration = _controller?.value.duration ?? Duration.zero;
      onDurationChanged(duration);

      // Estimativa para buffer (não tem buffer real)
      final buffered = position + const Duration(seconds: 10);
      onBufferedChanged(buffered);

      if (!_hasCompleted &&
          duration.inMilliseconds > 0 &&
          position.inMilliseconds >= (_completedPercentage * duration.inMilliseconds).toInt()) {
        _hasCompleted = true;
        _onCompleted?.call();
        print('Vídeo completado com base na porcentagem: $_completedPercentage');
      }
    });

    // Inicializa qualidades padrão
    onQualitiesUpdated([]);
    onQualityChanged('Auto');
  }


  @override
  VideoPlayerController get controller {
    if (_controller == null) {
      throw StateError('Controller não foi inicializado');
    }
    return _controller!;
  }

  @override
  String get viewId => ''; // Não usado no mobile

  @override
  Future<void> initialize(String url) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller?.setVolume(1.0);
    await _controller?.initialize();

    _controller?.addListener(() {
      final position = _controller?.value.position ?? Duration.zero;
      onPositionChanged(position);

      final duration = _controller?.value.duration ?? Duration.zero;
      onDurationChanged(duration);

      final buffered = position + const Duration(seconds: 10);
      onBufferedChanged(buffered);

      if (!_hasCompleted &&
          duration.inMilliseconds > 0 &&
          position.inMilliseconds >= (_completedPercentage * duration.inMilliseconds).toInt()) {
        _hasCompleted = true;
        _onCompleted?.call();
      }
    });

    // Inicializa com lista vazia de qualidades e padrão 'Auto'
    onQualitiesUpdated([]);
    onQualityChanged('Auto');
  }

  @override
  void play() {
    _controller?.play();
    WakelockPlus.enable();
  }

  @override
  void pause() {
    _controller?.pause();
    WakelockPlus.disable();
  }

  @override
  void seekTo(Duration position) => _controller?.seekTo(position);

  @override
  void setVolume(double volume) => _controller?.setVolume(volume);

  @override
  void setPlaybackSpeed(double speed) => _controller?.setPlaybackSpeed(speed);

  @override
  void setQuality(String quality) {
    // Não suportado no mobile.
  }

  @override
  void enterFullscreen() {
    // O fullscreen mobile é gerenciado via SystemChrome.
  }

  @override
  void exitFullscreen() {
    // O fullscreen mobile é gerenciado via SystemChrome.
  }

  @override
  void dispose() => _controller?.dispose();
}
