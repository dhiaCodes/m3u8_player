import 'package:flutter/material.dart';
import 'player_theme.dart';

/// Configuração do player M3U8
class PlayerConfig {
  /// URL do stream HLS
  final String url;

  /// Reprodução automática
  final bool autoPlay;

  /// Loop
  final bool loop;

  /// Posição inicial em segundos
  final int startPosition;

  /// Habilita callback de progresso
  final bool enableProgressCallback;

  /// Intervalo em segundos para o callback de progresso
  final int progressCallbackInterval;

  /// Porcentagem para dar o vídeo como completo
  final double completedPercentage;

  /// Callback de atualização de progresso
  final void Function(Duration position)? onProgressUpdate;

  /// Callback de mudança de tela cheia
  final Function(bool)? onFullscreenChanged;

  /// Callback quando o vídeo alcança 95% de progresso
  final Function()? onCompleted;

  /// Tema do player
  final PlayerTheme theme;

  const PlayerConfig({
    required this.url,
    this.autoPlay = false,
    this.loop = false,
    this.startPosition = 0,
    this.enableProgressCallback = false,
    this.progressCallbackInterval = 1,
    this.onProgressUpdate,
    this.onFullscreenChanged,
    this.onCompleted,
    this.completedPercentage = 1.0,
    this.theme = const PlayerTheme(),
  });
}