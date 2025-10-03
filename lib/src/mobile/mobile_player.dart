import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../player_interface.dart';
import 'dart:async';
import '../services/m3u8_quality_service.dart';

/// Mobile implementation of the M3U8 player using Flutter's video_player package.
/// 
/// This implementation provides native video playback capabilities for Android and iOS
/// platforms with features like quality selection, fullscreen support, and
/// completion tracking.
class M3u8Player implements PlayerInterface {
  /// The underlying video player controller.
  VideoPlayerController? _controller;
  
  /// Callback fired when available qualities are updated.
  final Function(List<String>) onQualitiesUpdated;
  
  /// Callback fired when the current quality changes.
  final Function(String) onQualityChanged;
  
  /// Callback fired when the video duration changes.
  final Function(Duration) onDurationChanged;
  
  /// Callback fired when the playback position changes.
  final Function(Duration) onPositionChanged;
  
  /// Callback fired when the buffered duration changes.
  final Function(Duration) onBufferedChanged;
  
  /// Callback fired when fullscreen state changes.
  final Function(bool)? onFullscreenChanged;
  
  /// Whether the video has reached the completion percentage.
  bool _hasCompleted = false;
  
  /// The percentage of video completion to trigger the onCompleted callback.
  double _completedPercentage = 1.0;
  
  /// Callback fired when the video reaches the completion percentage.
  Function()? _onCompleted;
  
  /// The original M3U8 URL.
  String _originalUrl = "";
  
  /// List of available video qualities.
  List<VideoQuality>? _qualities;
  
  /// The current build context for UI operations.
  BuildContext? _context;
  
  /// Gets the current build context.
  BuildContext? get context => _context;
  
  /// Whether the video is currently playing.
  bool _isPlaying = false;
  
  /// Gets whether the video is currently playing.
  bool get isPlaying => _isPlaying;
  
  /// The currently selected quality.
  String? _currentQuality;
  
  /// Gets the currently selected quality, defaulting to "Auto".
  String? get currentQuality => _currentQuality ?? "Auto";
  /// Creates a new M3U8 player instance.
  /// 
  /// Parameters:
  /// - [onQualitiesUpdated]: Called when available qualities are discovered
  /// - [onQualityChanged]: Called when the selected quality changes
  /// - [onDurationChanged]: Called when the video duration is available
  /// - [onPositionChanged]: Called when the playback position updates
  /// - [onBufferedChanged]: Called when the buffered duration changes
  /// - [onFullscreenChanged]: Called when fullscreen state changes
  /// - [onCompleted]: Called when video reaches completion percentage
  /// - [completedPercentage]: Completion threshold (0.0 to 1.0)
  /// - [context]: Build context for UI operations
  M3u8Player({
    required this.onQualitiesUpdated,
    required this.onQualityChanged,
    required this.onDurationChanged,
    required this.onPositionChanged,
    required this.onBufferedChanged,
    this.onFullscreenChanged,
    Function()? onCompleted,
    double completedPercentage = 1.0,
    BuildContext? context,
  }) : _context = context {
    _onCompleted = onCompleted;
    _completedPercentage = completedPercentage;

    _controller = VideoPlayerController.networkUrl(Uri.parse(''))
      ..setVolume(1.0);

    _controller?.addListener(() {
      final position = _controller?.value.position ?? Duration.zero;
      onPositionChanged(position);

      final duration = _controller?.value.duration ?? Duration.zero;
      onDurationChanged(duration);

      final buffered = position + const Duration(seconds: 10);
      onBufferedChanged(buffered);

      if (!_hasCompleted &&
          duration.inMilliseconds > 0 &&
          position.inMilliseconds >=
              (_completedPercentage * duration.inMilliseconds).toInt()) {
        _hasCompleted = true;
        _onCompleted?.call();
      }
    });

    onQualitiesUpdated([]);
    onQualityChanged('Auto');
  }

  /// Updates the build context for UI operations.
  void updateContext(BuildContext context) {
    _context = context;
  }

  @override
  VideoPlayerController get controller {
    if (_controller == null) {
      throw StateError('Controller has not been initialized');
    }
    return _controller!;
  }

  @override
  String get viewId => '';

  @override
  Future<void> initialize(String url) async {
    _originalUrl = url;
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
          position.inMilliseconds >=
              (_completedPercentage * duration.inMilliseconds).toInt()) {
        _hasCompleted = true;
        _onCompleted?.call();
      }
    });

    onQualitiesUpdated([]);
    onQualityChanged('Auto');

    M3u8QualityService().fetchQualities(url).then((qualities) {
      _qualities = qualities;
      _qualities!.sort((a, b) {
        int aVal = int.tryParse(a.qualityName) ?? 0;
        int bVal = int.tryParse(b.qualityName) ?? 0;
        return bVal.compareTo(aVal);
      });
      final qualitiesDesc = _qualities!.map((q) => q.qualityName).toList();
      qualitiesDesc.insert(0, "Auto");
      onQualitiesUpdated(qualitiesDesc);
    }).catchError((error) {
      onQualitiesUpdated(["Auto"]);
    });
  }

  @override
  void play() {
    _controller?.play();
    WakelockPlus.enable();
    _isPlaying = true;
  }

  @override
  void pause() {
    _controller?.pause();
    WakelockPlus.disable();
    _isPlaying = false;
  }

  @override
  void seekTo(Duration position) => _controller?.seekTo(position);

  @override
  void setVolume(double volume) => _controller?.setVolume(volume);

  @override
  void setPlaybackSpeed(double speed) => _controller?.setPlaybackSpeed(speed);

  @override
  void setQuality(String quality) async {
    if (quality == "Auto") {
      if (_controller != null) {
        final currentPosition = _controller!.value.position;
        await _controller?.pause();
        await _controller?.dispose();
        _controller = VideoPlayerController.networkUrl(Uri.parse(_originalUrl));
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
              position.inMilliseconds >=
                  (_completedPercentage * duration.inMilliseconds).toInt()) {
            _hasCompleted = true;
            _onCompleted?.call();
          }
        });
        await _controller?.seekTo(currentPosition);
        _controller?.play();
        onQualityChanged("Auto");
      }
      return;
    }

    if (_qualities == null) return;
    VideoQuality? selected;
    try {
      selected = _qualities!.firstWhere((q) => q.qualityName == quality);
    } catch (e) {
      return;
    }

    final originalUri = Uri.parse(_originalUrl);
    final basePath =
        originalUri.path.substring(0, originalUri.path.lastIndexOf('/') + 1);
    final baseUri = originalUri.replace(path: basePath);
    final newUrl = baseUri.resolve(selected.relativeUrl).toString();

    final currentPosition = _controller!.value.position;
    await _controller?.pause();
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(newUrl));
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
          position.inMilliseconds >=
              (_completedPercentage * duration.inMilliseconds).toInt()) {
        _hasCompleted = true;
        _onCompleted?.call();
      }
    });
    await _controller?.seekTo(currentPosition);
    _controller?.play();
    onQualityChanged(selected.qualityName);
    _currentQuality = selected.qualityName;
  }

  @override
  void enterFullscreen() {
    if (onFullscreenChanged != null) {
      onFullscreenChanged!(true);
    }
  }

  @override
  void exitFullscreen() {
    if (onFullscreenChanged != null) {
      onFullscreenChanged!(false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
