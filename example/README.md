# Extractor Plugin Example

A comprehensive example demonstrating all features of the Extractor plugin with quality selection and download management.

## Features

### Main Page

1. **Get Video Info & List Qualities**
   - Fetches video metadata
   - Lists all available video qualities
   - Shows resolution, format, and file size for each quality
   - Automatically removes duplicate qualities

2. **Quality Selection**
   - Select any available quality by tapping
   - Visual indication of selected quality
   - Displays quality details (resolution, format, size)

3. **Download Options**
   - **Download Highest Quality (Merged)**: Automatically downloads best video and audio, then merges them using FFmpeg
   - **Download Selected Quality**: Downloads the selected quality with best audio merged
   - **Extract Audio Only (MP3)**: Extracts audio in MP3 format

4. **Real-time Logs**
   - View yt-dlp output in real-time
   - Color-coded log levels
   - Scrollable console with clear option

### Downloads Page

1. **Active Downloads**
   - Real-time progress tracking
   - Progress bar with percentage
   - ETA (estimated time remaining)
   - Cancel button for active downloads

2. **Completed Downloads**
   - List of all downloaded files
   - File path display
   - Delete option for completed downloads

3. **Download States**
   - Started (with progress)
   - Completed (green checkmark)
   - Cancelled (orange icon)
   - Error (red icon with error message)

### Settings Page

1. **Version Information**
   - Current yt-dlp version
   - FFmpeg version
   - Python version
   - Refresh button to reload versions

2. **Update yt-dlp**
   - One-click update to latest stable version
   - Shows update progress
   - Automatically refreshes version info after update

3. **Plugin Information**
   - Plugin version
   - Android library (youtubedl-android)
   - iOS library (YoutubeDL-iOS)
   - Communication method (Pigeon)

4. **Features List**
   - Complete list of supported features
   - Visual checkmarks for enabled features

5. **Actions**
   - Clear all logs
   - Clear downloads list
   - Refresh version information

6. **iOS Warning**
   - Important notice about AppStore compatibility

## How It Works

### Quality Merging

When you download a quality, the app automatically:
1. Selects the video format for your chosen quality
2. Finds the best audio format available
3. Merges them using FFmpeg (format: `video_id+audio_id/best`)
4. This ensures you get both video and audio even if the highest quality video has no audio

### Example Code

#### List All Qualities
```dart
final info = await _youtubeDL.getVideoInfo(url);

// Extract unique video qualities
final videoFormats = info.formats
    ?.where((f) => f?.vcodec != null && f?.vcodec != 'none')
    .whereType<VideoFormat>()
    .toList() ?? [];

// Sort by height (quality)
videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
```

#### Download with Quality Merging
```dart
// Get best audio to merge
final audioFormat = FormatHelper.getBestAudio(videoInfo.formats);

// Build format string
final format = '${videoFormat.formatId}+${audioFormat.formatId}/best';

final request = DownloadRequest(
  url: url,
  outputPath: dir.path,
  format: format,
  embedThumbnail: true,
  embedMetadata: true,
);

final result = await _youtubeDL.download(request);
```

#### Track Download Progress
```dart
// Listen to progress updates
_youtubeDL.onProgress.listen((progress) {
  print('${progress.progress}% (ETA: ${progress.etaInSeconds}s)');
});

// Listen to state changes
_youtubeDL.onStateChanged.listen((state) {
  print('State: ${state.state.name}');
});
```

#### Cancel Download
```dart
final cancelled = await _youtubeDL.cancelDownload(processId);
```

## UI Overview

### Main Page
- URL input field
- "Get Video Info & Qualities" button
- Video information card
- List of available qualities (selectable)
- Download buttons (Highest, Selected, Audio)
- Real-time logs console

### Downloads Page
- List of all downloads
- Progress indicators for active downloads
- Status badges (completed, cancelled, error)
- Cancel/Delete buttons
- File paths for completed downloads

### Settings Page
- Version information display
- Update yt-dlp button
- Plugin information
- Features checklist
- Action buttons (clear logs, clear downloads, refresh)
- iOS compatibility warning

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run on Android:
   ```bash
   flutter run
   ```

4. Run on iOS:
   ```bash
   flutter run
   ```
   **Note**: iOS implementation is NOT AppStore-safe.

## Key Features Demonstrated

✅ Initialize plugin with FFmpeg and Aria2c  
✅ Fetch video information  
✅ List all available qualities  
✅ Select specific quality  
✅ Download highest quality with auto-merging  
✅ Download selected quality with audio  
✅ Extract audio only (MP3)  
✅ Real-time progress tracking  
✅ Download state management  
✅ Cancel active downloads  
✅ Delete completed downloads  
✅ Real-time logs from yt-dlp  
✅ Error handling and display  
✅ Version information display  
✅ Update yt-dlp to latest version  
✅ Plugin and library information  
✅ Features checklist  

## Notes

- Downloads are saved to the app's documents directory
- FFmpeg is used to merge video and audio streams
- Progress updates appear in real-time on the Downloads page
- All downloads are tracked with unique process IDs
- The app handles video formats that don't include audio by automatically merging with best audio

## Troubleshooting

**No qualities showing?**
- Make sure you clicked "Get Video Info & Qualities" first
- Check the logs for any errors

**Download fails?**
- Try updating yt-dlp (see main README)
- Check internet connection
- Verify the URL is valid

**Merge fails?**
- Ensure FFmpeg is enabled during initialization
- Check logs for FFmpeg errors

## Learn More

- [Plugin README](../README.md) - Full plugin documentation with API reference
- [iOS Implementation](../IOS_IMPLEMENTATION.md) - iOS-specific details

### 1. **Initialize Plugin**
```dart
final result = await _youtubeDL.initialize(
  enableFFmpeg: true,  // Enable audio extraction
  enableAria2c: true,  // Enable faster downloads
);
```

### 2. **Listen to Streams**
```dart
// Progress updates
_youtubeDL.onProgress.listen((progress) {
  print('${progress.progress}% (ETA: ${progress.etaInSeconds}s)');
});

// State changes
_youtubeDL.onStateChanged.listen((state) {
  print('State: ${state.state.name}');
});

// Errors
_youtubeDL.onError.listen((error) {
  print('Error: ${error.error}');
});

// Logs from yt-dlp
_youtubeDL.onLog.listen((log) {
  print('[${log.level.name}] ${log.message}');
});
```

### 3. **Get Video Information**
```dart
final info = await _youtubeDL.getVideoInfo(url);
print('Title: ${info.title}');
print('Duration: ${info.duration}s');
print('Formats: ${info.formats?.length}');
```

### 4. **Download Best Quality**
```dart
final request = DownloadRequest(
  url: url,
  outputPath: dir.path,
  format: 'bestvideo+bestaudio/best',
  embedThumbnail: true,
  embedMetadata: true,
);

final result = await _youtubeDL.download(request);
```

### 5. **Extract Audio (MP3)**
```dart
final request = DownloadRequest(
  url: url,
  outputPath: dir.path,
  extractAudio: true,
  audioFormat: 'mp3',
  audioQuality: 0, // Best quality
  embedThumbnail: true,
);

final result = await _youtubeDL.download(request);
```

### 6. **Download with Template**
```dart
final request = DownloadTemplates.fromTemplate(
  url: url,
  outputPath: dir.path,
  template: DownloadTemplate.video720p,
  embedThumbnail: true,
);

final result = await _youtubeDL.download(request);
```

Available templates:
- `DownloadTemplate.bestQuality` - Best video + audio
- `DownloadTemplate.audioOnly` - Audio only (MP3)
- `DownloadTemplate.videoOnly` - Video only (no audio)
- `DownloadTemplate.video1080p` - 1080p with audio
- `DownloadTemplate.video720p` - 720p with audio
- `DownloadTemplate.video480p` - 480p with audio
- `DownloadTemplate.smallSize` - Best quality under 100MB

### 7. **Custom Format Selector**
```dart
final format = FormatSelector()
    .maxHeight(1080)
    .videoCodec('h264')
    .extension('mp4')
    .build();

final request = DownloadRequest(
  url: url,
  outputPath: dir.path,
  format: format,
);
```

FormatSelector methods:
- `.maxHeight(int)` - Maximum video height
- `.minHeight(int)` - Minimum video height
- `.videoCodec(String)` - Video codec (h264, vp9, av01)
- `.audioCodec(String)` - Audio codec (aac, opus, mp3)
- `.extension(String)` - File extension (mp4, webm, mkv)
- `.maxFilesize(int)` - Maximum file size in MB
- `.videoOnly()` - Video only (no audio)
- `.audioOnly()` - Audio only (no video)

### 8. **Download with Subtitles**
```dart
final request = DownloadRequest(
  url: url,
  outputPath: dir.path,
  writeSubtitles: true,
  writeAutoSubtitles: true,
  embedSubtitles: true,
  subtitlesLang: 'en,es',
);
```

### 9. **Get Version Information**
```dart
final version = await _youtubeDL.getVersion();
print(version.youtubeDlVersion);  // yt-dlp version
print(version.ffmpegVersion);     // FFmpeg version
print(version.pythonVersion);     // Python version
```

### 10. **Update yt-dlp**
```dart
final result = await _youtubeDL.updateYoutubeDL(
  channel: UpdateChannel.stable,
);
print('Updated to: ${result.version}');
```

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to the example directory:
   ```bash
   cd example
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run on Android:
   ```bash
   flutter run
   ```

5. Run on iOS:
   ```bash
   flutter run
   ```
   **Note**: iOS implementation is NOT AppStore-safe. See [IOS_IMPLEMENTATION.md](../IOS_IMPLEMENTATION.md) for details.

## UI Overview

The example app has a single screen with:

- **Status Bar**: Shows current operation status and progress
- **URL Input**: Enter any video URL
- **Video Info Card**: Displays fetched video metadata
- **Feature Buttons**: 8 buttons demonstrating different features
- **Logs Console**: Real-time logs from yt-dlp operations

## Notes

- Downloads are saved to the app's documents directory
- All features work on both Android and iOS
- Progress updates appear in real-time
- Logs show detailed yt-dlp output
- The example uses a default YouTube video URL for testing

## Additional Features

### Format Helper
```dart
// Get best video format
final bestVideo = FormatHelper.getBestVideo(formats);

// Get best audio format
final bestAudio = FormatHelper.getBestAudio(formats);

// Filter by resolution
final hd = FormatHelper.getFormatsByResolution(formats, 720, 1080);

// Format file size
final size = FormatHelper.formatFileSize(bytes);

// Format resolution
final res = FormatHelper.formatResolution(format);
```

### Cancel Download
```dart
final cancelled = await _youtubeDL.cancelDownload(processId);
```

### Check Initialization
```dart
final isInit = await _youtubeDL.isInitialized();
```

## Troubleshooting

If you encounter issues:

1. **Android**: Make sure you have internet permission in `AndroidManifest.xml`
2. **iOS**: Check that you've added the required permissions in `Info.plist`
3. **Downloads fail**: Try updating yt-dlp using the "Update yt-dlp" button
4. **No logs**: Make sure you're listening to the `onLog` stream

## Learn More

- [Plugin README](../README.md) - Full plugin documentation with API reference
- [iOS Implementation](../IOS_IMPLEMENTATION.md) - iOS-specific details
- [Changelog](../CHANGELOG.md) - Version history
