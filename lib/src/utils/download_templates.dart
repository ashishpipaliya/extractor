import '../generated/youtube_dl_api.g.dart';

/// Helper class for download templates
class DownloadTemplates {
  /// Get format string for a download template
  static String getFormatString(DownloadTemplate template) {
    switch (template) {
      case DownloadTemplate.bestQuality:
        return 'bestvideo+bestaudio/best';

      case DownloadTemplate.audioOnly:
        return 'bestaudio/best';

      case DownloadTemplate.videoOnly:
        return 'bestvideo';

      case DownloadTemplate.video1080p:
        return 'bestvideo[height<=1080]+bestaudio/best[height<=1080]';

      case DownloadTemplate.video720p:
        return 'bestvideo[height<=720]+bestaudio/best[height<=720]';

      case DownloadTemplate.video480p:
        return 'bestvideo[height<=480]+bestaudio/best[height<=480]';

      case DownloadTemplate.smallSize:
        return 'best[filesize<100M]';
    }
  }

  /// Get custom options for a download template
  static Map<String, String>? getCustomOptions(DownloadTemplate template) {
    switch (template) {
      case DownloadTemplate.audioOnly:
        return {
          '--extract-audio': '',
          '--audio-format': 'mp3',
        };

      default:
        return null;
    }
  }

  /// Create a DownloadRequest from a template
  static DownloadRequest fromTemplate({
    required String url,
    required String outputPath,
    required DownloadTemplate template,
    String? outputTemplate,
    String? processId,
    bool embedThumbnail = true,
    bool embedMetadata = true,
  }) {
    final format = getFormatString(template);
    final customOptions = getCustomOptions(template);

    return DownloadRequest(
      url: url,
      outputPath: outputPath,
      outputTemplate: outputTemplate,
      format: format,
      extractAudio: template == DownloadTemplate.audioOnly,
      audioFormat: template == DownloadTemplate.audioOnly ? 'mp3' : null,
      embedThumbnail: embedThumbnail,
      embedMetadata: embedMetadata,
      customOptions: customOptions,
      processId: processId,
    );
  }

  /// Get description for a template
  static String getDescription(DownloadTemplate template) {
    switch (template) {
      case DownloadTemplate.bestQuality:
        return 'Best quality video with audio';
      case DownloadTemplate.audioOnly:
        return 'Audio only (MP3)';
      case DownloadTemplate.videoOnly:
        return 'Video only (no audio)';
      case DownloadTemplate.video1080p:
        return '1080p video with audio';
      case DownloadTemplate.video720p:
        return '720p video with audio';
      case DownloadTemplate.video480p:
        return '480p video with audio';
      case DownloadTemplate.smallSize:
        return 'Best quality under 100MB';
    }
  }
}

/// Advanced format selection builder
class FormatSelector {
  String? _videoCodec;
  String? _audioCodec;
  int? _maxHeight;
  int? _minHeight;
  int? _maxFilesize;
  String? _ext;
  bool _videoOnly = false;
  bool _audioOnly = false;

  /// Set video codec preference (e.g., 'h264', 'vp9', 'av01')
  FormatSelector videoCodec(String codec) {
    _videoCodec = codec;
    return this;
  }

  /// Set audio codec preference (e.g., 'aac', 'opus', 'mp3')
  FormatSelector audioCodec(String codec) {
    _audioCodec = codec;
    return this;
  }

  /// Set maximum video height
  FormatSelector maxHeight(int height) {
    _maxHeight = height;
    return this;
  }

  /// Set minimum video height
  FormatSelector minHeight(int height) {
    _minHeight = height;
    return this;
  }

  /// Set maximum file size in MB
  FormatSelector maxFilesize(int mb) {
    _maxFilesize = mb;
    return this;
  }

  /// Set file extension (e.g., 'mp4', 'webm', 'mkv')
  FormatSelector extension(String ext) {
    _ext = ext;
    return this;
  }

  /// Select video only (no audio)
  FormatSelector videoOnly() {
    _videoOnly = true;
    _audioOnly = false;
    return this;
  }

  /// Select audio only (no video)
  FormatSelector audioOnly() {
    _audioOnly = true;
    _videoOnly = false;
    return this;
  }

  /// Build the format string
  String build() {
    final filters = <String>[];

    if (_videoOnly) {
      filters.add('bestvideo');
    } else if (_audioOnly) {
      filters.add('bestaudio');
    } else {
      filters.add('bestvideo');
    }

    final conditions = <String>[];

    if (_videoCodec != null) {
      conditions.add('vcodec^=$_videoCodec');
    }
    if (_audioCodec != null) {
      conditions.add('acodec^=$_audioCodec');
    }
    if (_maxHeight != null) {
      conditions.add('height<=$_maxHeight');
    }
    if (_minHeight != null) {
      conditions.add('height>=$_minHeight');
    }
    if (_maxFilesize != null) {
      conditions.add('filesize<${_maxFilesize}M');
    }
    if (_ext != null) {
      conditions.add('ext=$_ext');
    }

    if (conditions.isNotEmpty) {
      final conditionStr = conditions.join(',');
      if (_videoOnly) {
        return 'bestvideo[$conditionStr]';
      } else if (_audioOnly) {
        return 'bestaudio[$conditionStr]';
      } else {
        return 'bestvideo[$conditionStr]+bestaudio/best';
      }
    }

    if (_videoOnly) {
      return 'bestvideo';
    } else if (_audioOnly) {
      return 'bestaudio';
    } else {
      return 'bestvideo+bestaudio/best';
    }
  }
}
