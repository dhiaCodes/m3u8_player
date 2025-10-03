import 'package:flutter/material.dart';
import '../services/m3u8_quality_service.dart';

class QualitySelector extends StatelessWidget {
  final List<VideoQuality> qualities;
  final ValueChanged<VideoQuality?> onQualitySelected;
  final VideoQuality? selectedQuality;

  const QualitySelector({
    super.key,
    required this.qualities,
    required this.onQualitySelected,
    this.selectedQuality,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<VideoQuality>(
      value: selectedQuality,
      hint: const Text('Selecione a Qualidade'),
      items: [
        const DropdownMenuItem<VideoQuality>(
          value: null,
          child: Text("Auto"),
        ),
        ...qualities.map((q) => DropdownMenuItem<VideoQuality>(
              value: q,
              child: Text(q.qualityName),
            )),
      ],
      onChanged: onQualitySelected,
    );
  }
}
