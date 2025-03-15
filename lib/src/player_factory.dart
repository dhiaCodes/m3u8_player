import 'player_interface.dart';
import 'player_impl.dart';

PlayerInterface createPlayer({
  required Function(List<String>) onQualitiesUpdated,
  required Function(String) onQualityChanged,
  required Function(Duration) onDurationChanged,
  required Function(Duration) onPositionChanged,
  required Function(Duration) onBufferedChanged,
  Function(bool)? onFullscreenChanged,
}) {
  return M3u8Player( // Note o nome unificado!
    onQualitiesUpdated: onQualitiesUpdated,
    onQualityChanged: onQualityChanged,
    onDurationChanged: onDurationChanged,
    onPositionChanged: onPositionChanged,
    onBufferedChanged: onBufferedChanged,
    onFullscreenChanged: onFullscreenChanged,
  );
}
