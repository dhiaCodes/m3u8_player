import 'package:flutter/material.dart';

/// Visual theme configuration for the M3U8 player.
/// 
/// This class defines the visual appearance of the player controls,
/// including colors and sizes for various UI elements.
class PlayerTheme {
  /// Primary color used for icons and text elements.
  final Color primaryColor;

  /// Background color of the control overlay.
  final Color backgroundColor;

  /// Color of the progress bar indicating playback progress.
  final Color progressColor;

  /// Color of the buffer indicator showing buffered content.
  final Color bufferColor;

  /// Size of the control icons in logical pixels.
  final double iconSize;

  /// Creates a new player theme configuration.
  /// 
  /// All parameters are optional and will use sensible defaults if not specified.
  const PlayerTheme({
    this.primaryColor = Colors.white,
    this.backgroundColor = Colors.black54,
    this.progressColor = Colors.red,
    this.bufferColor = Colors.white24,
    this.iconSize = 24.0,
  });
} 