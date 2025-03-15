import 'package:video_player/video_player.dart';
import '../player_interface.dart';

class M3u8Player implements PlayerInterface {
  VideoPlayerController? _controller;
  final Function(List<String>) onQualitiesUpdated;
  final Function(String) onQualityChanged;
  final Function(Duration) onDurationChanged;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onBufferedChanged;
  final Function(bool)? onFullscreenChanged;

  M3u8Player({
    required this.onQualitiesUpdated,
    required this.onQualityChanged,
    required this.onDurationChanged,
    required this.onPositionChanged,
    required this.onBufferedChanged,
    this.onFullscreenChanged,
  });

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
    // Define o volume inicial como 1.0
    await _controller?.setVolume(1.0);
    await _controller?.initialize();

    _controller?.addListener(() {
      final position = _controller?.value.position ?? Duration.zero;
      onPositionChanged(position);

      final duration = _controller?.value.duration ?? Duration.zero;
      onDurationChanged(duration);

      // Não há buffer real, então usa uma estimativa
      final buffered = position + const Duration(seconds: 10);
      onBufferedChanged(buffered);
    });

    // Inicializa com lista vazia de qualidades e Auto como padrão
    onQualitiesUpdated([]);
    onQualityChanged('Auto');
  }

  @override
  void play() => _controller?.play();

  @override
  void pause() => _controller?.pause();

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
