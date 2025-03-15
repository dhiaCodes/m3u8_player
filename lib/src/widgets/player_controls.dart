import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player_theme.dart';

/// Widget principal de controles do player.
class PlayerControls extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final Duration buffered;
  final double volume;
  final double playbackSpeed;
  final List<String> qualities;
  final String? currentQuality;
  final bool isFullscreen;
  final PlayerTheme theme;

  final VoidCallback onPlayPause;
  final VoidCallback onToggleFullscreen;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<String?> onQualityChanged;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.buffered,
    required this.volume,
    required this.playbackSpeed,
    required this.qualities,
    required this.currentQuality,
    required this.isFullscreen,
    required this.theme,
    required this.onPlayPause,
    required this.onToggleFullscreen,
    required this.onSeek,
    required this.onVolumeChanged,
    required this.onSpeedChanged,
    required this.onQualityChanged,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _showControls = true;
  bool _isDragging = false;
  Timer? _hideTimer;

  /// Opções de velocidade.
  final List<double> _speedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Inicia (ou reinicia) o timer que esconde os controles após 3s.
  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!_isDragging) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  /// Chamado quando o usuário inicia o "drag" no slider de progresso.
  void _handleDragStart() {
    setState(() => _isDragging = true);
    _hideTimer?.cancel();
  }

  /// Chamado quando o usuário finaliza o "drag" no slider de progresso.
  void _handleDragEnd() {
    setState(() => _isDragging = false);
    _startHideTimer();
  }

  /// Formata o [Duration] em "mm:ss" ou "hh:mm:ss" quando há horas.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  /// Botão de velocidade (PopupMenu) que mostra as opções de playbackSpeed.
  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      tooltip: 'Velocidade de reprodução',
      onSelected: widget.onSpeedChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: widget.theme.backgroundColor.withOpacity(0.95),
      offset: const Offset(0, -10),
      itemBuilder: (context) => _speedOptions.map((speed) {
        final isSelected = speed == widget.playbackSpeed;
        return PopupMenuItem(
          value: speed,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${speed}x',
                style: TextStyle(
                  color: isSelected
                      ? widget.theme.primaryColor
                      : widget.theme.primaryColor.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: widget.theme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.speed,
              color: widget.theme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.playbackSpeed}x',
              style: TextStyle(
                color: widget.theme.primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão de seleção de qualidade (PopupMenu) que mostra [qualities].
  Widget _buildQualityButton() {
    if (widget.qualities.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Qualidade',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: widget.theme.backgroundColor.withOpacity(0.95),
      offset: const Offset(0, -10),
      onSelected: widget.onQualityChanged,
      itemBuilder: (context) => widget.qualities.map((quality) {
        final isSelected = quality == widget.currentQuality;
        return PopupMenuItem(
          value: quality,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quality,
                style: TextStyle(
                  color: isSelected
                      ? widget.theme.primaryColor
                      : widget.theme.primaryColor.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: widget.theme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.settings,
              color: widget.theme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              widget.currentQuality ?? 'Auto',
              style: TextStyle(
                color: widget.theme.primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barra de progresso (com buffer) + Slider (só o thumb).
  Widget _buildProgressBar() {
    final totalMs = widget.duration.inMilliseconds.toDouble();
    final positionMs = widget.position.inMilliseconds.toDouble();
    final bufferedMs = widget.buffered.inMilliseconds.toDouble();

    // Garante que não passe do total
    final clampedPositionMs = positionMs.clamp(0.0, totalMs);
    final clampedBufferedMs = bufferedMs.clamp(0.0, totalMs);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Slider de buffer (sem thumb)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: widget.theme.bufferColor,
                inactiveTrackColor: widget.theme.backgroundColor,
                thumbColor: Colors.transparent,
                overlayColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: clampedBufferedMs,
                max: totalMs,
                onChanged: null, // Desabilita interação
              ),
            ),
            // Slider de progresso (com thumb)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: widget.theme.progressColor,
                inactiveTrackColor: Colors.transparent,
                thumbColor: widget.theme.primaryColor,
                overlayColor: widget.theme.primaryColor.withOpacity(0.3),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  elevation: 2,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 0,
                ),
              ),
              child: Slider(
                value: clampedPositionMs,
                max: totalMs,
                onChangeStart: (_) => _handleDragStart(),
                onChangeEnd: (_) => _handleDragEnd(),
                onChanged: (value) {
                  widget.onSeek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Constrói a "linha" com os valores de tempo (posição atual e duração total).
  Widget _buildTimeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              _formatDuration(widget.position),
              style: TextStyle(color: widget.theme.primaryColor),
            ),
          ),
          Expanded(
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProgressBar(),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              _formatDuration(widget.duration),
              style: TextStyle(color: widget.theme.primaryColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a "linha" com botões de play/pause, volume, velocidade, fullscreen etc.
  Widget _buildControlRow() {
    return Row(
      children: [
        // Botão Play/Pause
        IconButton(
          icon: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            color: widget.theme.primaryColor,
            size: widget.theme.iconSize,
          ),
          onPressed: widget.onPlayPause,
        ),

        // Volume
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  widget.volume == 0
                      ? Icons.volume_off
                      : widget.volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  color: widget.theme.primaryColor,
                  size: widget.theme.iconSize,
                ),
                onPressed: () {
                  // Mute / unmute
                  widget.volume > 0
                      ? widget.onVolumeChanged(0)
                      : widget.onVolumeChanged(1);
                },
              ),
            ),
            SizedBox(
              width: 100,
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: widget.theme.primaryColor,
                  inactiveTrackColor: widget.theme.bufferColor,
                  thumbColor: widget.theme.primaryColor,
                  overlayColor: widget.theme.primaryColor.withOpacity(0.3),
                  trackHeight: 4.0,
                ),
                child: Slider(
                  value: widget.volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: widget.onVolumeChanged,
                ),
              ),
            ),
          ],
        ),

        const Spacer(),

        // Botão de velocidade
        _buildSpeedButton(),

        // Botão de qualidade (se houver)
        if (widget.qualities.isNotEmpty) _buildQualityButton(),

        // Botão de fullscreen
        IconButton(
          icon: Icon(
            widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: widget.theme.primaryColor,
            size: widget.theme.iconSize,
          ),
          onPressed: widget.onToggleFullscreen,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        setState(() => _showControls = true);
        _startHideTimer();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) {
          setState(() => _showControls = true);
          _startHideTimer();
        },
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTimeRow(),
                _buildControlRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
