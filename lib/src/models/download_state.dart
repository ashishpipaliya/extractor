/// Represents the state of a download
class DownloadState {
  /// Unique identifier for the download process
  final String processId;

  /// Current state of the download
  final DownloadStateType state;

  DownloadState({
    required this.processId,
    required this.state,
  });

  @override
  String toString() => 'DownloadState(processId: $processId, state: $state)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadState &&
          runtimeType == other.runtimeType &&
          processId == other.processId &&
          state == other.state;

  @override
  int get hashCode => processId.hashCode ^ state.hashCode;
}

/// Types of download states
enum DownloadStateType {
  /// Download has started
  started,

  /// Download completed successfully
  completed,

  /// Download was cancelled
  cancelled,

  /// Unknown state
  unknown,
}
