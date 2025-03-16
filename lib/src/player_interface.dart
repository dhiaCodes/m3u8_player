abstract class PlayerInterface {
  Future<void> initialize(String url);
  void play();
  void pause();
  void seekTo(Duration position);
  void setVolume(double volume);
  void setPlaybackSpeed(double speed);
  void setQuality(String quality);
  void dispose();

  /// Controller usado pelo widget do player.
  dynamic get controller;

  /// Identificador para a view, usado na web e mobile.
  String get viewId;

  /// Métodos de controle de fullscreen.
  void enterFullscreen();
  void exitFullscreen();
}
