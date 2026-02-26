import '../generated/youtube_dl_api.g.dart';

/// Helper class for working with video formats
class FormatHelper {
  /// Get the best video format
  static VideoFormat? getBestVideo(List<VideoFormat?>? formats) {
    if (formats == null || formats.isEmpty) return null;

    final videoFormats = formats
        .where((f) => f?.vcodec != null && f?.vcodec != 'none')
        .whereType<VideoFormat>()
        .toList();

    if (videoFormats.isEmpty) return null;

    return videoFormats.reduce((a, b) {
      final aHeight = a.height ?? 0;
      final bHeight = b.height ?? 0;
      return aHeight > bHeight ? a : b;
    });
  }

  /// Get the best audio format
  static VideoFormat? getBestAudio(List<VideoFormat?>? formats) {
    if (formats == null || formats.isEmpty) return null;

    final audioFormats = formats
        .where((f) => f?.acodec != null && f?.acodec != 'none')
        .whereType<VideoFormat>()
        .toList();

    if (audioFormats.isEmpty) return null;

    return audioFormats.reduce((a, b) {
      final aTbr = a.tbr ?? 0;
      final bTbr = b.tbr ?? 0;
      return aTbr > bTbr ? a : b;
    });
  }

  /// Get formats by resolution
  static List<VideoFormat> getFormatsByResolution(
    List<VideoFormat?>? formats,
    int minHeight,
    int maxHeight,
  ) {
    if (formats == null) return [];

    return formats
        .where((f) {
          final height = f?.height;
          return height != null && height >= minHeight && height <= maxHeight;
        })
        .cast<VideoFormat>()
        .toList();
  }

  /// Get audio-only formats
  static List<VideoFormat> getAudioFormats(List<VideoFormat?>? formats) {
    if (formats == null) return [];

    return formats
        .where((f) =>
            f?.acodec != null &&
            f?.acodec != 'none' &&
            (f?.vcodec == null || f?.vcodec == 'none'))
        .cast<VideoFormat>()
        .toList();
  }

  /// Get video-only formats
  static List<VideoFormat> getVideoFormats(List<VideoFormat?>? formats) {
    if (formats == null) return [];

    return formats
        .where((f) =>
            f?.vcodec != null &&
            f?.vcodec != 'none' &&
            (f?.acodec == null || f?.acodec == 'none'))
        .cast<VideoFormat>()
        .toList();
  }

  /// Format file size to human-readable string
  static String formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';

    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// Format resolution
  static String formatResolution(VideoFormat format) {
    if (format.resolution != null) return format.resolution!;
    if (format.width != null && format.height != null) {
      return '${format.width}x${format.height}';
    }
    if (format.height != null) return '${format.height}p';
    return 'Unknown';
  }

  /// Get format description
  static String getFormatDescription(VideoFormat format) {
    final parts = <String>[];

    if (format.formatNote != null) {
      parts.add(format.formatNote!);
    }

    final resolution = formatResolution(format);
    if (resolution != 'Unknown') {
      parts.add(resolution);
    }

    if (format.ext != null) {
      parts.add(format.ext!);
    }

    if (format.filesize != null) {
      parts.add(formatFileSize(format.filesize));
    }

    return parts.join(' • ');
  }
}
