import 'dart:async';
import 'generated/youtube_dl_api.g.dart';
import 'models/download_progress.dart';
import 'models/download_state.dart';

/// Main Flutter API for YouTube-DL operations
/// Provides a clean, type-safe interface with proper error handling
class YoutubeDLFlutter {
  YoutubeDLFlutter._();

  static final YoutubeDLFlutter _instance = YoutubeDLFlutter._();
  static YoutubeDLFlutter get instance => _instance;

  final YoutubeDLApi _api = YoutubeDLApi();
  final _CallbackHandler _callbackHandler = _CallbackHandler();

  /// Stream of download progress updates
  Stream<DownloadProgress> get onProgress =>
      _callbackHandler.progressController.stream;

  /// Stream of download state changes
  Stream<DownloadState> get onStateChanged =>
      _callbackHandler.stateController.stream;

  /// Stream of download errors
  Stream<DownloadError> get onError => _callbackHandler.errorController.stream;

  /// Stream of log messages from yt-dlp, FFmpeg, and Python
  Stream<LogMessage> get onLog => _callbackHandler.logController.stream;

  /// Initialize the library
  ///
  /// [enableFFmpeg] - Enable FFmpeg for audio extraction and conversion
  /// [enableAria2c] - Enable Aria2c for faster downloads
  ///
  /// Returns [InitResult] with success status and optional error message
  Future<InitResult> initialize({
    bool enableFFmpeg = true,
    bool enableAria2c = false,
  }) async {
    try {
      YoutubeDLCallback.setUp(_callbackHandler);

      final config = InitConfig(
        enableFFmpeg: enableFFmpeg,
        enableAria2c: enableAria2c,
      );

      return await _api.initialize(config);
    } catch (e) {
      return InitResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Get version information for youtube-dl, ffmpeg, and python
  Future<VersionInfo> getVersion() async {
    return await _api.getVersion();
  }

  /// Update youtube-dl binary
  ///
  /// [channel] - Update channel (stable or nightly)
  Future<UpdateResult> updateYoutubeDL({
    UpdateChannel channel = UpdateChannel.stable,
  }) async {
    return await _api.updateYoutubeDL(channel);
  }

  /// Get video information without downloading
  ///
  /// [url] - Video URL
  Future<VideoInfo> getVideoInfo(String url) async {
    return await _api.getVideoInfo(url);
  }

  /// Get video information with custom options
  ///
  /// [url] - Video URL
  /// [options] - Custom youtube-dl options (e.g., {'--format': 'best'})
  Future<VideoInfo> getVideoInfoWithOptions(
    String url,
    Map<String, String> options,
  ) async {
    return await _api.getVideoInfoWithOptions(url, options);
  }

  /// Download a video
  ///
  /// Returns [DownloadResult] with status and output path
  Future<DownloadResult> download(DownloadRequest request) async {
    return await _api.download(request);
  }

  /// Cancel an active download
  ///
  /// [processId] - Process ID of the download to cancel
  ///
  /// Returns true if successfully cancelled
  Future<bool> cancelDownload(String processId) async {
    return await _api.cancelDownload(processId);
  }

  /// Check if library is initialized
  Future<bool> isInitialized() async {
    return await _api.isInitialized();
  }

  /// Dispose resources
  void dispose() {
    _callbackHandler.dispose();
  }
}

/// Internal callback handler for progress and state updates
class _CallbackHandler extends YoutubeDLCallback {
  final progressController = StreamController<DownloadProgress>.broadcast();
  final stateController = StreamController<DownloadState>.broadcast();
  final errorController = StreamController<DownloadError>.broadcast();
  final logController = StreamController<LogMessage>.broadcast();

  @override
  void onProgress(String processId, double progress, int etaInSeconds) {
    progressController.add(DownloadProgress(
      processId: processId,
      progress: progress,
      etaInSeconds: etaInSeconds,
    ));
  }

  @override
  void onDownloadStateChanged(String processId, String state) {
    final downloadState = _parseState(state);
    stateController.add(DownloadState(
      processId: processId,
      state: downloadState,
    ));
  }

  @override
  void onError(String processId, String error) {
    errorController.add(DownloadError(
      processId: processId,
      error: error,
    ));
  }

  @override
  void onLog(String processId, String message, String level) {
    logController.add(LogMessage(
      processId: processId,
      message: message,
      level: _parseLogLevel(level),
      timestamp: DateTime.now(),
    ));
  }

  DownloadStateType _parseState(String state) {
    switch (state.toLowerCase()) {
      case 'started':
        return DownloadStateType.started;
      case 'completed':
        return DownloadStateType.completed;
      case 'cancelled':
        return DownloadStateType.cancelled;
      default:
        return DownloadStateType.unknown;
    }
  }

  LogLevel _parseLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'info':
        return LogLevel.info;
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'debug':
        return LogLevel.debug;
      default:
        return LogLevel.info;
    }
  }

  void dispose() {
    progressController.close();
    stateController.close();
    errorController.close();
    logController.close();
  }
}

/// Download error information
class DownloadError {
  final String processId;
  final String error;

  DownloadError({
    required this.processId,
    required this.error,
  });

  @override
  String toString() => 'DownloadError(processId: $processId, error: $error)';
}

/// Log message from yt-dlp, FFmpeg, or Python runtime
class LogMessage {
  final String processId;
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogMessage({
    required this.processId,
    required this.message,
    required this.level,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LogMessage(processId: $processId, level: $level, message: $message)';
}

/// Log level enum
enum LogLevel {
  info,
  warning,
  error,
  debug,
}
