/// Abstract interface defining the contract for M3U8 player implementations.
/// 
/// This interface ensures consistent behavior across different platforms
/// (web and mobile) while allowing platform-specific optimizations.
abstract class PlayerInterface {
  /// Initializes the player with the given HLS stream URL.
  /// 
  /// This method should be called before any other player operations.
  /// It sets up the underlying player implementation and prepares it for playback.
  Future<void> initialize(String url);
  
  /// Starts or resumes video playback.
  void play();
  
  /// Pauses video playback.
  void pause();
  
  /// Seeks to the specified position in the video.
  /// 
  /// The [position] parameter specifies the target playback position.
  void seekTo(Duration position);
  
  /// Sets the audio volume level.
  /// 
  /// The [volume] parameter should be between 0.0 (muted) and 1.0 (full volume).
  void setVolume(double volume);
  
  /// Sets the playback speed multiplier.
  /// 
  /// The [speed] parameter determines playback rate (e.g., 0.5 for half speed, 2.0 for double speed).
  void setPlaybackSpeed(double speed);
  
  /// Changes the video quality to the specified level.
  /// 
  /// The [quality] parameter should be one of the available qualities or "Auto" for automatic selection.
  void setQuality(String quality);
  
  /// Releases all resources and cleans up the player instance.
  /// 
  /// This method should be called when the player is no longer needed.
  void dispose();

  /// Gets the underlying platform-specific controller object.
  /// 
  /// Returns a VideoPlayerController on mobile platforms, or null on web.
  dynamic get controller;

  /// Gets the unique view identifier used for platform view registration.
  /// 
  /// This is primarily used on web platforms for HTML element integration.
  String get viewId;

  /// Enters fullscreen mode.
  void enterFullscreen();
  
  /// Exits fullscreen mode.
  void exitFullscreen();
}
