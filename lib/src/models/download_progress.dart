/// Represents download progress information
class DownloadProgress {
  /// Unique identifier for the download process
  final String processId;

  /// Progress percentage (0.0 to 100.0)
  final double progress;

  /// Estimated time remaining in seconds
  final int etaInSeconds;

  DownloadProgress({
    required this.processId,
    required this.progress,
    required this.etaInSeconds,
  });

  /// Get progress as a fraction (0.0 to 1.0)
  double get progressFraction => progress / 100.0;

  /// Get ETA as Duration
  Duration get eta => Duration(seconds: etaInSeconds);

  @override
  String toString() =>
      'DownloadProgress(processId: $processId, progress: ${progress.toStringAsFixed(1)}%, eta: ${eta.inSeconds}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadProgress &&
          runtimeType == other.runtimeType &&
          processId == other.processId &&
          progress == other.progress &&
          etaInSeconds == other.etaInSeconds;

  @override
  int get hashCode =>
      processId.hashCode ^ progress.hashCode ^ etaInSeconds.hashCode;
}
