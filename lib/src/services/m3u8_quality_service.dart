import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoQuality {
  final String qualityName;
  final String resolution;
  final String relativeUrl;
  final int bandwidth;

  VideoQuality({
    required this.qualityName,
    required this.resolution,
    required this.relativeUrl,
    required this.bandwidth,
  });
}

class M3u8QualityService {
  Future<List<VideoQuality>> fetchQualities(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Failed to load M3U8 file");
    }
    final content = response.body;
    // Regex para extrair BANDWIDTH, RESOLUTION, NAME e a URL relativa na linha seguinte
    RegExp exp = RegExp(r'#EXT-X-STREAM-INF:.*BANDWIDTH=(\d+).*RESOLUTION=([\dx]+).*NAME="([^"]+)".*\n(.*)');
    Iterable<RegExpMatch> matches = exp.allMatches(content);
    List<VideoQuality> qualities = [];
    for (final m in matches) {
      final bandwidth = int.tryParse(m.group(1)?.trim() ?? "0") ?? 0;
      final resolution = m.group(2)?.trim() ?? "";
      final qualityName = m.group(3)?.trim() ?? "";
      final relativeUrl = m.group(4)?.trim() ?? "";
      qualities.add(VideoQuality(
        qualityName: qualityName,
        resolution: resolution,
        relativeUrl: relativeUrl,
        bandwidth: bandwidth,
      ));
    }
    return qualities;
  }
}
