import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'android_web_package_fallback.dart'
    if (dart.library.html) 'package:web/web.dart' as web;

import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'mobile/fullscreen_video_page.dart';
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
    super.key,
    required this.config,
  });

  @override
  State<M3u8PlayerWidget> createState() => _M3u8PlayerWidgetState();
}

class _M3u8PlayerWidgetState extends State<M3u8PlayerWidget>
    with WidgetsBindingObserver {
  late PlayerInterface _player;
  bool _isPlaying = false;
  bool _isFullScreen = false;
// New flag for ignoring orientation changes
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

  // @override
  // void didChangeMetrics() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_ignoreOrientation) {
  //       return;
  //     }
  //     final Orientation currentOrientation = MediaQuery.of(context).orientation;
  //     if (!_isFullScreen && currentOrientation == Orientation.landscape) {
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (!_isFullScreen &&
  //             !_ignoreOrientation &&
  //             MediaQuery.of(context).orientation == Orientation.landscape) {
  //           _toggleFullScreen();
  //         }
  //       });
  //     }
  //   });
  // }

  void _setupProgressCallback() {
    _progressTimer?.cancel();
    if (widget.config.enableProgressCallback &&
        widget.config.onProgressUpdate != null) {
      _progressTimer = Timer.periodic(
        Duration(seconds: widget.config.progressCallbackInterval),
        (_) {
          widget.config.onProgressUpdate!(_position);
        },
      );
    }
  }

  Future<void> _initializePlayer() async {
    log("DEBUG: Initializing player for URL: ${widget.config.url}");
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
      onCompleted: () {
        setState(() => _isPlaying = false);
        log("DEBUG: Video completed callback triggered.");
        if (widget.config.onCompleted != null) {
          widget.config.onCompleted!();
        }
      },
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
    log("DEBUG: Toggling fullscreen..");
    if (kIsWeb) {
      final webPlayer = _player as M3u8Player;
      setState(() => _isFullScreen = web.document.fullscreen);
      log("DEBUG: Toggling fullscreen. Current state: $_isFullScreen");
      if (!_isFullScreen) {
        webPlayer.enterFullscreen();
      } else {
        webPlayer.exitFullscreen();
      }
    } else {
      // For mobile: navigate to a new fullscreen page
      final mobilePlayer = _player as M3u8Player;
      setState(() => _isFullScreen = true);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (widget.config.onFullscreenChanged != null) {
        widget.config.onFullscreenChanged!(true);
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullscreenVideoPage(
            controller: mobilePlayer.controller,
            onExitFullscreen: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isFullScreen = false;
                  });
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  if (widget.config.onFullscreenChanged != null) {
                    widget.config.onFullscreenChanged!(false);
                  }
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {});
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                      // Deixe o didChangeMetrics detectar mudanças futuras para disparar o fullscreen.
                    }
                  });
                }
              });
            },
            onSeek: _player.seekTo,
            onPlayPause: _playPause,
            isPlaying: _isPlaying,
            volume: _volume,
            playbackSpeed: _playbackSpeed,
            qualities: _qualities,
            currentQuality: _currentQuality,
            onVolumeChanged: (vol) {
              setState(() => _volume = vol);
              _player.setVolume(vol);
            },
            onSpeedChanged: (speed) {
              setState(() => _playbackSpeed = speed);
              _player.setPlaybackSpeed(speed);
            },
            onQualityChanged: (quality) async {
              if (quality == null) {
                return Future.error('Quality cannot be null');
              }
              _player.setQuality(quality);
              await Future.delayed(const Duration(seconds: 1));
              return _player.controller;
            },
          ),
        ),
      );
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
              color: Colors.black.withValues(alpha: 0.5),
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
              color: Colors.black.withValues(alpha: 0.5),
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
