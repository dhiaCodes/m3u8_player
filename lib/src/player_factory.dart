import 'player_interface.dart';
import 'player_impl.dart';

PlayerInterface createPlayer({
  required Function(List<String>) onQualitiesUpdated,
  required Function(String) onQualityChanged,
  required Function(Duration) onDurationChanged,
  required Function(Duration) onPositionChanged,
  required Function(Duration) onBufferedChanged,
  Function(bool)? onFullscreenChanged,
  Function()? onCompleted,
  double completedPercentage = 1.0,
}) {
  return M3u8Player(
    onQualitiesUpdated: onQualitiesUpdated,
    onQualityChanged: onQualityChanged,
    onDurationChanged: onDurationChanged,
    onPositionChanged: onPositionChanged,
    onBufferedChanged: onBufferedChanged,
    onFullscreenChanged: onFullscreenChanged,
    onCompleted: onCompleted,
    completedPercentage: completedPercentage,
  );
}
