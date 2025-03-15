library m3u8_player;

export 'src/m3u8_player_widget.dart';
export 'src/models/player_config.dart';
export 'src/models/player_theme.dart';
export 'src/player_interface.dart';
export 'src/mobile/mobile_player.dart' if (dart.library.html) 'src/web/web_player.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
