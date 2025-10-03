import 'dart:developer';

import 'package:http/http.dart' as http;

/// Represents a video quality variant found in an M3U8 playlist.
/// 
/// Each quality variant typically corresponds to a different resolution
/// and bitrate combination available in the HLS stream.
class VideoQuality {
  /// Display name for this quality (e.g., "720p", "1080p").
  final String qualityName;
  
  /// Resolution string in format "widthxheight" (e.g., "1280x720").
  final String resolution;
  
  /// Relative URL path to this quality's playlist file.
  final String relativeUrl;
  
  /// Bandwidth requirement in bits per second for this quality.
  final int bandwidth;

  /// Creates a new video quality instance.
  VideoQuality({
    required this.qualityName,
    required this.resolution,
    required this.relativeUrl,
    required this.bandwidth,
  });
}

/// Service class for parsing M3U8 playlists and extracting video quality information.
/// 
/// This service downloads and parses HLS master playlists to discover
/// available video quality variants with their resolutions and bitrates.
class M3u8QualityService {
  /// Extracts a quality name from a resolution string.
  /// 
  /// Converts resolution strings like "1280x720" to quality names like "720p".
  String _extractQualityFromResolution(String resolution) {
    final height = resolution.split('x').last;
    return '${height}p';
  }

  /// Fetches and parses video qualities from an M3U8 playlist URL.
  /// 
  /// Downloads the master playlist from [url] and extracts all available
  /// quality variants with their metadata.
  /// 
  /// Returns a list of [VideoQuality] objects, or throws an exception
  /// if the playlist cannot be downloaded or parsed.
  Future<List<VideoQuality>> fetchQualities(String url) async {
    // print('Fetching qualities from URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Failed to load M3U8 file");
    }
    final content = response.body;
    // print('M3U8 content:\n$content');

    // Dois padrões de regex para lidar com ambos os formatos
    final patterns = [
      // Padrão 1: Com NAME
      r'#EXT-X-STREAM-INF:[^\n]*BANDWIDTH=(\d+)[^\n]*RESOLUTION=([\dx]+)[^\n]*NAME="([^"]+)"[^\n]*\n([^\n]+)',
      // Padrão 2: Sem NAME
      r'#EXT-X-STREAM-INF:[^\n]*BANDWIDTH=(\d+)[^\n]*RESOLUTION=([\dx]+)[^\n]*\n([^\n]+)'
    ];

    List<VideoQuality> qualities = [];
    bool matchFound = false;

    // Tenta cada padrão até encontrar matches
    for (final pattern in patterns) {
      // print('Trying pattern: $pattern');
      RegExp exp = RegExp(pattern, multiLine: true);
      Iterable<RegExpMatch> matches = exp.allMatches(content);

      if (matches.isNotEmpty) {
        matchFound = true;
        // print('Found ${matches.length} matches with pattern');

        for (final m in matches) {
          final bandwidth = int.tryParse(m.group(1)?.trim() ?? "0") ?? 0;
          final resolution = m.group(2)?.trim() ?? "";

          // Se tem NAME (padrão 1), usa m.group(3) para name e m.group(4) para URL
          // Se não tem NAME (padrão 2), usa resolution para name e m.group(3) para URL
          final bool hasName = m.groupCount >= 4;
          final name = hasName ? m.group(3)?.trim() : null;
          final relativeUrl = hasName ? m.group(4)?.trim() : m.group(3)?.trim();
          // print('URL é: $relativeUrl');

          final qualityName = name ?? _extractQualityFromResolution(resolution);

          qualities.add(VideoQuality(
            qualityName: qualityName,
            resolution: resolution,
            relativeUrl: relativeUrl ?? "",
            bandwidth: bandwidth,
          ));
        }
        break; // Se encontrou matches, para de tentar outros padrões
      }
    }

    if (!matchFound) {
      //print('No matches found with any pattern');
    }

    // print('\nFinal qualities list:');
    for (var q in qualities) {
      log('Quality: ${q.qualityName}, Resolution: ${q.resolution}, URL: ${q.relativeUrl}');
    }
    return qualities;
  }
}
