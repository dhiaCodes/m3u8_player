import 'player_theme.dart';

/// Configuration class for the M3U8 player.
/// 
/// This class contains all the settings and callbacks needed to configure
/// the player behavior, appearance, and event handling.
class PlayerConfig {
  /// The HLS stream URL to play.
  final String url;

  /// Whether to start playing automatically when initialized.
  final bool autoPlay;

  /// Whether to loop the video when it reaches the end.
  final bool loop;

  /// Initial playback position in seconds.
  final int startPosition;

  /// Whether to enable progress update callbacks.
  final bool enableProgressCallback;

  /// Interval in seconds between progress callback invocations.
  final int progressCallbackInterval;

  /// Completion percentage threshold (0.0 to 1.0) to trigger onCompleted callback.
  /// 
  /// For example, 0.95 means the callback will fire when 95% of the video is watched.
  final double completedPercentage;

  /// Callback fired periodically with the current playback position.
  final void Function(Duration position)? onProgressUpdate;

  /// Callback fired when fullscreen mode is toggled.
  final Function(bool)? onFullscreenChanged;

  /// Callback fired when the video reaches the completion percentage.
  final Function()? onCompleted;

  /// Visual theme configuration for the player.
  final PlayerTheme theme;

  /// Creates a new player configuration.
  /// 
  /// The [url] parameter is required and must be a valid HLS stream URL.
  /// All other parameters are optional with sensible defaults.
  const PlayerConfig({
    required this.url,
    this.autoPlay = false,
    this.loop = false,
    this.startPosition = 0,
    this.enableProgressCallback = false,
    this.progressCallbackInterval = 1,
    this.onProgressUpdate,
    this.onFullscreenChanged,
    this.onCompleted,
    this.completedPercentage = 1.0,
    this.theme = const PlayerTheme(),
  });
}