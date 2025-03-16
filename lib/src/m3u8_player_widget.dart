import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'models/player_config.dart';
import 'widgets/player_controls.dart';
import 'dart:async';
import 'player_interface.dart';
import 'player_factory.dart';
import 'player_impl.dart';
//import 'mobile/mobile_player.dart';
//import 'web/web_player.dart' if (dart.library.io) 'stubs/web_stub.dart';

/// Widget principal do player M3U8
class M3u8PlayerWidget extends StatefulWidget {
  /// Configuração do player
  final PlayerConfig config;

  const M3u8PlayerWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<M3u8PlayerWidget> createState() => _M3u8PlayerWidgetState();
}

class _M3u8PlayerWidgetState extends State<M3u8PlayerWidget> with WidgetsBindingObserver {
  late PlayerInterface _player;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  List<String> _qualities = [];
  String? _currentQuality;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
    _setupProgressCallback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(
        _isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    }
  }

  void _setupProgressCallback() {
    _progressTimer?.cancel();
    if (widget.config.enableProgressCallback && widget.config.onProgressUpdate != null) {
      _progressTimer = Timer.periodic(
        Duration(seconds: widget.config.progressCallbackInterval),
        (_) {
          widget.config.onProgressUpdate!(_position);
        },
      );
    }
  }

  Future<void> _initializePlayer() async {
    _player = createPlayer(
      onQualitiesUpdated: (qualities) {
        setState(() => _qualities = qualities);
      },
      onQualityChanged: (quality) {
        setState(() => _currentQuality = quality);
      },
      onDurationChanged: (duration) {
        setState(() => _duration = duration);
      },
      onPositionChanged: (position) {
        setState(() => _position = position);
      },
      onBufferedChanged: (buffered) {
        setState(() => _buffered = buffered);
      },
      onFullscreenChanged: (isFullscreen) {
        setState(() => _isFullScreen = isFullscreen);
        if (widget.config.onFullscreenChanged != null) {
          widget.config.onFullscreenChanged!(isFullscreen);
        }
      },
      onCompleted: widget.config.onCompleted,
      completedPercentage: widget.config.completedPercentage,
    );

    await _player.initialize(widget.config.url);
    setState(() => _isInitialized = true);

    if (widget.config.startPosition > 0) {
      _player.seekTo(Duration(seconds: widget.config.startPosition));
    }

    if (widget.config.autoPlay && !kIsWeb) {
      _playPause();
    }
  }

  void _playPause() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  void _toggleFullScreen() {
    if (kIsWeb) {
      final webPlayer = _player as M3u8Player;
      if (!_isFullScreen) {
        webPlayer.enterFullscreen();
      } else {
        webPlayer.exitFullscreen();
      }
    } else {
      setState(() => _isFullScreen = !_isFullScreen);
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
      if (widget.config.onFullscreenChanged != null) {
        widget.config.onFullscreenChanged!(_isFullScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return kIsWeb ? _buildWebPlayer() : _buildMobilePlayer();
  }

  Widget _buildWebPlayer() {
    final webPlayer = _player as M3u8Player;
    final content = Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(viewType: webPlayer.viewId),
        GestureDetector(
          onTap: _playPause,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        if (!_isPlaying)
          IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildControls(),
        ),
      ],
    );

    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: content,
      ),
    );
  }

  Widget _buildMobilePlayer() {
    final mobilePlayer = _player as M3u8Player;
    final videoSize = mobilePlayer.controller.value.size;
    final playerWidget = _isFullScreen
      ? Center(
          child: AspectRatio(
            aspectRatio: videoSize.width / videoSize.height,
            child: VideoPlayer(mobilePlayer.controller),
          ),
        )
      : SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(mobilePlayer.controller),
            ),
          ),
        );

    final content = Stack(
      fit: StackFit.expand,
      children: [
        playerWidget,
        GestureDetector(
          onTap: _playPause,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        if (!_isPlaying)
          IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildControls(),
        ),
      ],
    );

    return Container(
      color: Colors.black,
      child: _isFullScreen 
        ? content 
        : AspectRatio(
            aspectRatio: 16 / 9,
            child: content,
          ),
    );
  }

  Widget _buildControls() {
    return PlayerControls(
      isPlaying: _isPlaying,
      isFullscreen: _isFullScreen,
      duration: _duration,
      position: _position,
      buffered: _buffered,
      volume: _volume,
      playbackSpeed: _playbackSpeed,
      qualities: _qualities,
      currentQuality: _currentQuality,
      theme: widget.config.theme,
      onPlayPause: _playPause,
      onSeek: _player.seekTo,
      onVolumeChanged: (volume) {
        setState(() => _volume = volume);
        _player.setVolume(volume);
      },
      onSpeedChanged: (speed) {
        setState(() => _playbackSpeed = speed);
        _player.setPlaybackSpeed(speed);
      },
      onQualityChanged: (quality) {
        if (quality != null) {
          _player.setQuality(quality);
        }
      },
      onToggleFullscreen: _toggleFullScreen,
    );
  }
} 