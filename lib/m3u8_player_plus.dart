library m3u8_player_plus;

export 'src/m3u8_player_widget.dart';
export 'src/models/player_config.dart';
export 'src/models/player_theme.dart';
export 'src/player_interface.dart';
export 'src/mobile/mobile_player.dart'
    if (dart.library.html) 'src/web/web_player.dart';
