import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/player_theme.dart';
import '../widgets/player_controls.dart';

class FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onExitFullscreen;
  final Function(Duration) onSeek;
  final Function(double) onVolumeChanged;
  final Function(double) onSpeedChanged;
  final Future<VideoPlayerController?> Function(String?) onQualityChanged;
  final VoidCallback onPlayPause;
  final bool isPlaying;
  final double volume;
  final double playbackSpeed;
  final List<String> qualities;
  final String? currentQuality;

  const FullscreenVideoPage({
    super.key,
    required this.controller,
    required this.onExitFullscreen,
    required this.onSeek,
    required this.onVolumeChanged,
    required this.onSpeedChanged,
    required this.onQualityChanged,
    required this.onPlayPause,
    required this.isPlaying,
    required this.volume,
    required this.playbackSpeed,
    required this.qualities,
    required this.currentQuality,
  });

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  bool _isBeingReplaced = false;
  late VideoPlayerController _controller;
  late bool _isPlaying;
  late double _volume;
  late double _playbackSpeed;
  late String? _currentQuality;
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _isPlaying = widget.isPlaying;
    _volume = widget.volume;
    _playbackSpeed = widget.playbackSpeed;
    _currentQuality = widget.currentQuality;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      });
    });

    _initializeFuture = _controller.value.isInitialized
        ? Future.value()
        : _controller.initialize();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant FullscreenVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onControllerUpdate);
      _controller = widget.controller;
      _controller.addListener(_onControllerUpdate);
      setState(() {
        _initializeFuture = _controller.value.isInitialized
            ? Future.value()
            : _controller.initialize();
      });
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!_isBeingReplaced) {
      widget.onExitFullscreen();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Evita referenciar o controller se o widget estiver sendo substituído
    if (_isBeingReplaced) {
      return Container();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder(
                future: _initializeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    );
                  }
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PlayerControls(
                  isPlaying: _isPlaying,
                  duration: _controller.value.duration,
                  position: _controller.value.position,
                  buffered: _controller.value.buffered.isNotEmpty
                      ? _controller.value.buffered.last.end
                      : _controller.value.position,
                  volume: _volume,
                  playbackSpeed: _playbackSpeed,
                  qualities: widget.qualities,
                  currentQuality: _currentQuality,
                  isFullscreen: true,
                  theme: const PlayerTheme(),
                  onPlayPause: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                    widget.onPlayPause();
                  },
                  onToggleFullscreen: () => Navigator.of(context).pop(),
                  onSeek: (position) {
                    widget.onSeek(position);
                  },
                  onVolumeChanged: (vol) {
                    setState(() {
                      _volume = vol;
                    });
                    widget.onVolumeChanged(vol);
                  },
                  onSpeedChanged: (speed) {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    widget.onSpeedChanged(speed);
                  },
                  onQualityChanged: (quality) async {
                    // Se quality for nula, não realiza a troca
                    if (quality == null) return;
                    final currentPosition = _controller.value.position;
                    final wasPlaying = _isPlaying;
                    // Remove o listener para evitar chamadas durante a transição
                    _controller.removeListener(_onControllerUpdate);
                    // Chama o callback que retorna o novo controller para a qualidade selecionada
                    VideoPlayerController? newController =
                        await widget.onQualityChanged(quality);
                    newController ??= _controller;
                    await newController.pause();
                    await Future.delayed(const Duration(seconds: 1));
                    await newController.seekTo(currentPosition);
                    if (wasPlaying) {
                      newController.play();
                    }
                    setState(() {
                      _isBeingReplaced = true;
                    });

                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => FullscreenVideoPage(
                          controller: newController!,
                          onExitFullscreen: widget.onExitFullscreen,
                          onSeek: widget.onSeek,
                          onVolumeChanged: widget.onVolumeChanged,
                          onSpeedChanged: widget.onSpeedChanged,
                          onQualityChanged: widget.onQualityChanged,
                          onPlayPause: widget.onPlayPause,
                          isPlaying: wasPlaying,
                          volume: _volume,
                          playbackSpeed: _playbackSpeed,
                          qualities: widget.qualities,
                          currentQuality: quality,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
