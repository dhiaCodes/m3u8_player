import 'package:flutter/material.dart';

/// Tema do player
class PlayerTheme {
  /// Cor primária (ícones e textos)
  final Color primaryColor;

  /// Cor de fundo dos controles
  final Color backgroundColor;

  /// Cor da barra de progresso
  final Color progressColor;

  /// Cor do buffer
  final Color bufferColor;

  /// Tamanho dos ícones
  final double iconSize;

  const PlayerTheme({
    this.primaryColor = Colors.white,
    this.backgroundColor = Colors.black54,
    this.progressColor = Colors.red,
    this.bufferColor = Colors.white24,
    this.iconSize = 24.0,
  });
} 