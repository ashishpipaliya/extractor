# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-25

### 🎉 Major Release - Complete Rewrite

This is a complete rewrite of the plugin with production-ready architecture and comprehensive features.

### ✨ Added

#### Core Features
- **Native Implementation**: Complete rewrite using youtubedl-android v0.18.1 with yt-dlp
- **Type-Safe Communication**: Pigeon for compile-time type safety between Dart and native code
- **Clean Architecture**: SOLID principles with service layer pattern (LibraryService, UpdateService, InfoService, DownloadService)
- **Video Downloads**: Download videos from 1000+ websites with quality selection
- **Audio Extraction**: Extract audio with format conversion (MP3, M4A, WAV, FLAC, AAC, OPUS)
- **Video Information**: Get comprehensive metadata (title, duration, formats, thumbnails, uploader)
- **Format Selection**: Choose quality, resolution, codec with advanced format strings
- **Subtitle Support**: Download and embed subtitles in multiple languages
- **Thumbnail Embedding**: Embed video thumbnails in audio files
- **Metadata Embedding**: Add title, artist, album information
- **Aria2c Integration**: Faster downloads with external downloader
- **Progress Tracking**: Real-time progress updates with ETA
- **Download Management**: Cancel downloads with process ID tracking
- **Update System**: Update yt-dlp to latest stable version
- **Version Information**: Get yt-dlp, FFmpeg, and Python versions
- **Log Streaming**: Real-time yt-dlp output logs via stream

#### Advanced Features
- **Download Templates**: Pre-configured presets (Best Quality, 1080p, 720p, 480p, Audio Only, Small Size)
- **Custom Format Strings**: Advanced format selection with yt-dlp syntax
- **Custom Options**: Pass any yt-dlp command-line option
- **Playlist Support**: Download entire playlists or individual videos
- **Chapter Support**: Preserve video chapters
- **Multi-language Subtitles**: Download subtitles in any language
- **Video+Audio Merging**: Automatically merge best video and audio using FFmpeg

#### Developer Experience
- **FormatHelper Utilities**: Helper methods for format filtering and selection
- **Stream-based Updates**: Progress, state changes, errors, and logs via Dart streams
- **Thread Safety**: Proper threading with Kotlin coroutines
- **Error Handling**: Comprehensive error handling and reporting

#### Example App
- **Material Design 3**: Modern UI with dynamic colors
- **Three-Page Layout**: Main, Downloads, and Settings tabs
- **Quality Selection**: List and select video qualities with format details
- **Smart Downloads**: Automatic video+audio merging for best quality
- **Downloads Manager**: View active downloads with progress tracking
- **Settings Page**: Version info, update button, plugin information
- **Integrated Logs**: Real-time yt-dlp logs display

### 🔧 Changed
- **Breaking**: Complete API redesign - not compatible with previous versions
- **Breaking**: Minimum Android SDK raised to API 24 (Android 7.0)
- **Breaking**: Removed web scraping approach in favor of native yt-dlp
- **Breaking**: New initialization method with FFmpeg and Aria2c options
- **Breaking**: New download request model with comprehensive options
- **Improved**: Better error messages and debugging information
- **Improved**: More efficient video info extraction
- **Improved**: Better format selection logic

### 📚 Documentation
- **Complete README**: Comprehensive guide with features, installation, usage, and API reference
- **API Documentation**: Full API reference merged into README
- **Example Documentation**: Detailed example app guide
- **Contributing Guide**: Guidelines for contributors

### 🐛 Fixed
- Fixed version display to show actual yt-dlp version instead of hardcoded value
- Fixed quality display to show format details instead of "Unknown"
- Fixed format selection to properly merge video and audio
- Fixed progress tracking for multiple concurrent downloads
- Fixed download cancellation

### 🔒 Security
- Scoped storage support for Android 10+
- Type-safe communication prevents runtime errors
- Proper permission handling

### ⚠️ Platform Support
- **Android**: ✅ Fully supported (API 24+)
- **iOS**: 💡 Open for contributions (see README for details)

### 📦 Dependencies
- youtubedl-android: v0.18.1
- yt-dlp: 2025.11.12+ (bundled, updatable)
- FFmpeg: 6.0 (bundled)
- Python: 3.8 (bundled)
- Pigeon: ^22.7.0

### 🙏 Credits
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The amazing video downloader
- [youtubedl-android](https://github.com/yausername/youtubedl-android) - Android port
- [Seal](https://github.com/JunkFood02/Seal) - Design inspiration

---

## [0.0.3] - 2022-05-09 
* Readme Update

## [0.0.2] - 2022-05-09
* Update example app
* Update documentation

## [0.0.1] - 2022-05-08
* Initial release
