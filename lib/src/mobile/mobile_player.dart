import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../player_interface.dart';
import 'dart:async';
import '../services/m3u8_quality_service.dart';

class M3u8Player implements PlayerInterface {
  VideoPlayerController? _controller;
  final Function(List<String>) onQualitiesUpdated;
  final Function(String) onQualityChanged;
  final Function(Duration) onDurationChanged;
  final Function(Duration) onPositionChanged;
  final Function(Duration) onBufferedChanged;
  final Function(bool)? onFullscreenChanged;
  bool _hasCompleted = false;
  double _completedPercentage = 1.0;
  Function()? _onCompleted;
  String _originalUrl = "";
  List<VideoQuality>? _qualities;
  BuildContext? _context;
  BuildContext? get context => _context;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  String? _currentQuality;
  String? get currentQuality => _currentQuality ?? "Auto";
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

  void updateContext(BuildContext context) {
    _context = context;
  }

  @override
  VideoPlayerController get controller {
    if (_controller == null) {
      throw StateError('Controller não foi inicializado');
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
