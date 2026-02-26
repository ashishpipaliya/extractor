import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/youtube_dl_api.g.dart',
  kotlinOut:
      'android/src/main/kotlin/com/ashishpipaliya/extractor/generated/YoutubeDLApi.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.ashishpipaliya.extractor.generated',
  ),
  swiftOut: 'ios/Classes/Generated/YoutubeDLApi.g.swift',
  swiftOptions: SwiftOptions(),
))

/// Represents the update channel for youtube-dl binary
enum UpdateChannel {
  stable,
}

/// Represents the status of an operation
enum OperationStatus {
  success,
  error,
  cancelled,
}

/// Configuration for initializing the library
class InitConfig {
  final bool enableFFmpeg;
  final bool enableAria2c;

  InitConfig({
    required this.enableFFmpeg,
    required this.enableAria2c,
  });
}

/// Result of initialization
class InitResult {
  final bool success;
  final String? errorMessage;

  InitResult({
    required this.success,
    this.errorMessage,
  });
}

/// Update result
class UpdateResult {
  final OperationStatus status;
  final String? version;
  final String? errorMessage;

  UpdateResult({
    required this.status,
    this.version,
    this.errorMessage,
  });
}

/// Video format information
class VideoFormat {
  final String? formatId;
  final String? formatNote;
  final String? ext;
  final String? url;
  final int? width;
  final int? height;
  final int? fps;
  final int? filesize;
  final int? tbr;
  final String? vcodec;
  final String? acodec;
  final String? resolution;

  VideoFormat({
    this.formatId,
    this.formatNote,
    this.ext,
    this.url,
    this.width,
    this.height,
    this.fps,
    this.filesize,
    this.tbr,
    this.vcodec,
    this.acodec,
    this.resolution,
  });
}

/// Video information
class VideoInfo {
  final String? id;
  final String? title;
  final String? description;
  final String? uploader;
  final String? uploaderId;
  final String? uploaderUrl;
  final String? channelId;
  final String? channelUrl;
  final int? duration;
  final int? viewCount;
  final int? likeCount;
  final String? thumbnail;
  final String? url;
  final List<VideoFormat?>? formats;
  final String? ext;
  final int? width;
  final int? height;
  final int? fps;
  final String? vcodec;
  final String? acodec;

  VideoInfo({
    this.id,
    this.title,
    this.description,
    this.uploader,
    this.uploaderId,
    this.uploaderUrl,
    this.channelId,
    this.channelUrl,
    this.duration,
    this.viewCount,
    this.likeCount,
    this.thumbnail,
    this.url,
    this.formats,
    this.ext,
    this.width,
    this.height,
    this.fps,
    this.vcodec,
    this.acodec,
  });
}

/// Download request configuration
class DownloadRequest {
  const DownloadRequest({
    required this.url,
    required this.outputPath,
    this.outputTemplate,
    this.format,
    this.noPlaylist,
    this.extractAudio,
    this.audioFormat,
    this.audioQuality,
    this.embedThumbnail,
    this.embedMetadata,
    this.embedSubtitles,
    this.subtitlesLang,
    this.writeSubtitles,
    this.writeAutoSubtitles,
    this.customOptions,
    this.processId,
  });

  final String url;
  final String outputPath;
  final String? outputTemplate;
  final String? format;
  final bool? noPlaylist;
  final bool? extractAudio;
  final String? audioFormat;
  final int? audioQuality;
  final bool? embedThumbnail;
  final bool? embedMetadata;
  final bool? embedSubtitles;
  final String? subtitlesLang;
  final bool? writeSubtitles;
  final bool? writeAutoSubtitles;
  final Map<String?, String?>? customOptions;
  final String? processId;
}

/// Download result
class DownloadResult {
  final OperationStatus status;
  final String? outputPath;
  final String? errorMessage;

  DownloadResult({
    required this.status,
    this.outputPath,
    this.errorMessage,
  });
}

/// Version information
class VersionInfo {
  final String? youtubeDlVersion;
  final String? ffmpegVersion;
  final String? pythonVersion;

  VersionInfo({
    this.youtubeDlVersion,
    this.ffmpegVersion,
    this.pythonVersion,
  });
}

/// Main API for YouTube-DL operations
@HostApi()
abstract class YoutubeDLApi {
  /// Initialize the library with configuration
  @async
  InitResult initialize(InitConfig config);

  /// Get version information
  @async
  VersionInfo getVersion();

  /// Update youtube-dl binary
  @async
  UpdateResult updateYoutubeDL(UpdateChannel channel);

  /// Get video information without downloading
  @async
  VideoInfo getVideoInfo(String url);

  /// Get video information with custom options
  @async
  VideoInfo getVideoInfoWithOptions(String url, Map<String?, String?> options);

  /// Download video
  @async
  DownloadResult download(DownloadRequest request);

  /// Cancel a download by process ID
  @async
  bool cancelDownload(String processId);

  /// Check if library is initialized (synchronous)
  bool isInitialized();
}

/// Callback API for progress updates (Flutter -> Native)
@FlutterApi()
abstract class YoutubeDLCallback {
  /// Called when download progress updates
  void onProgress(String processId, double progress, int etaInSeconds);

  /// Called when download state changes
  void onDownloadStateChanged(String processId, String state);

  /// Called when an error occurs
  void onError(String processId, String error);

  /// Called when a log message is generated
  void onLog(String processId, String message, String level);
}

/// Predefined download templates for common use cases
enum DownloadTemplate {
  /// Best quality video with audio
  bestQuality,

  /// Audio only (best quality)
  audioOnly,

  /// Video only (no audio)
  videoOnly,

  /// 1080p video with audio
  video1080p,

  /// 720p video with audio
  video720p,

  /// 480p video with audio
  video480p,

  /// Best video under 100MB
  smallSize,
}

/// Format sorting preferences
enum FormatSortOrder {
  /// Sort by quality (highest first)
  quality,

  /// Sort by file size (smallest first)
  filesize,

  /// Sort by bitrate (highest first)
  bitrate,

  /// Sort by codec preference
  codec,
}
