abstract class PlayerInterface {
  Future<void> initialize(String url);
  void play();
  void pause();
  void seekTo(Duration position);
  void setVolume(double volume);
  void setPlaybackSpeed(double speed);
  void setQuality(String quality);
  void dispose();

  /// No web, esse getter retorna o identificador para o HtmlElementView.
  /// No mobile, retorna o controller usado pelo widget VideoPlayer.
  dynamic get controller;

  /// Para web, retorna o viewId; para mobile, pode retornar uma string vazia.
  String get viewId;

  /// Métodos de fullscreen (poderão ser no-op no mobile)
  void enterFullscreen();
  void exitFullscreen();
}
