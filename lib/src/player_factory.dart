import 'player_interface.dart';
import 'player_impl.dart';

/// Factory function that creates the appropriate player implementation for the current platform.
/// 
/// This function automatically selects between the web-based HLS.js implementation
/// and the mobile video_player implementation based on the runtime environment.
/// 
/// Parameters:
/// - [onQualitiesUpdated]: Callback fired when available qualities are discovered
/// - [onQualityChanged]: Callback fired when the selected quality changes  
/// - [onDurationChanged]: Callback fired when video duration is determined
/// - [onPositionChanged]: Callback fired when playback position updates
/// - [onBufferedChanged]: Callback fired when buffered duration changes
/// - [onCompleted]: Optional callback fired when video reaches completion threshold
/// - [completedPercentage]: Completion threshold between 0.0 and 1.0
/// 
/// Returns a [PlayerInterface] implementation suitable for the current platform.
PlayerInterface createPlayer({
  required Function(List<String>) onQualitiesUpdated,
  required Function(String) onQualityChanged,
  required Function(Duration) onDurationChanged,
  required Function(Duration) onPositionChanged,
  required Function(Duration) onBufferedChanged,
  Function()? onCompleted,
  double completedPercentage = 1.0,
}) {
  return M3u8Player(
    onQualitiesUpdated: onQualitiesUpdated,
    onQualityChanged: onQualityChanged,
    onDurationChanged: onDurationChanged,
    onPositionChanged: onPositionChanged,
    onBufferedChanged: onBufferedChanged,
    onCompleted: onCompleted,
    completedPercentage: completedPercentage,
  );
}
