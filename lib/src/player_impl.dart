/// Platform-specific player implementation exports.
///
/// This file uses conditional imports to export the appropriate player
/// implementation based on the target platform:
/// - On mobile platforms: exports the video_player-based implementation
/// - On web platforms: exports the HLS.js-based implementation
///
/// This allows the same import statement to work across all platforms
/// while using the most appropriate implementation for each environment.
library;

export 'mobile/mobile_player.dart' if (dart.library.html) 'web/web_player.dart';
