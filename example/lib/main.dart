import 'package:flutter/material.dart';
import 'package:extractor/extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extractor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _youtubeDL = YoutubeDLFlutter.instance;
  final _urlController = TextEditingController(
    text: 'https://youtu.be/YY2w2JEX2xk?si=YwYTvluKwlqqs-2U',
  );

  int _currentIndex = 0;
  String _status = 'Not initialized';
  String _logs = '';
  VideoInfo? _videoInfo;
  List<VideoFormat> _availableQualities = [];
  VideoFormat? _selectedQuality;

  // Downloads tracking
  final Map<String, DownloadItem> _downloads = {};

  // Version info
  VersionInfo? _versionInfo;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializePlugin();
    _listenToStreams();
  }

  Future<void> _initializePlugin() async {
    setState(() => _status = 'Initializing...');

    final result = await _youtubeDL.initialize(
      enableFFmpeg: true,
      enableAria2c: true,
    );

    setState(() {
      _status = result.success
          ? 'Initialized successfully'
          : 'Failed: ${result.errorMessage}';
    });

    _addLog('✓ Plugin initialized');

    // Load version info
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final version = await _youtubeDL.getVersion();
      setState(() {
        _versionInfo = version;
      });
    } catch (e) {
      _addLog('✗ Failed to load version: $e');
    }
  }

  Future<void> _updateYoutubeDL() async {
    setState(() {
      _isUpdating = true;
      _status = 'Updating yt-dlp...';
    });
    _addLog('→ Updating yt-dlp...');

    try {
      final result = await _youtubeDL.updateYoutubeDL(
        channel: UpdateChannel.stable,
      );

      setState(() {
        _isUpdating = false;
        _status = result.status == OperationStatus.success
            ? 'Update complete'
            : 'Update failed';
      });

      if (result.status == OperationStatus.success) {
        _addLog('✓ Updated to: ${result.version}');
        // Reload version info
        await _loadVersionInfo();
      } else {
        _addLog('✗ Update failed: ${result.errorMessage}');
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _status = 'Error: $e';
      });
      _addLog('✗ Error: $e');
    }
  }

  void _listenToStreams() {
    // Progress updates
    _youtubeDL.onProgress.listen((progress) {
      setState(() {
        if (_downloads.containsKey(progress.processId)) {
          _downloads[progress.processId]!.progress = progress.progress;
          _downloads[progress.processId]!.eta = progress.etaInSeconds;
        }
        _status = 'Downloading: ${progress.progress.toStringAsFixed(1)}%';
      });
    });

    // State changes
    _youtubeDL.onStateChanged.listen((state) {
      setState(() {
        if (_downloads.containsKey(state.processId)) {
          _downloads[state.processId]!.state = state.state.name;
        }
      });
      _addLog('State: ${state.state.name}');
    });

    // Errors
    _youtubeDL.onError.listen((error) {
      setState(() {
        if (_downloads.containsKey(error.processId)) {
          _downloads[error.processId]!.state = 'error';
          _downloads[error.processId]!.error = error.error;
        }
      });
      _addLog('ERROR: ${error.error}');
    });

    // Logs
    _youtubeDL.onLog.listen((log) {
      _addLog('[${log.level.name}] ${log.message}');
    });
  }

  /// Get video info and list all qualities
  Future<void> _getVideoInfo() async {
    setState(() {
      _status = 'Fetching video info...';
      _availableQualities = [];
      _selectedQuality = null;
    });
    _addLog('→ Getting video info...');

    try {
      final info = await _youtubeDL.getVideoInfo(_urlController.text);

      // Extract unique video qualities (with video codec)
      final videoFormats = info.formats
              ?.where((f) => f?.vcodec != null && f?.vcodec != 'none')
              .whereType<VideoFormat>()
              .toList() ??
          [];

      // Sort by height (quality)
      videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));

      // Remove duplicates by height
      final uniqueQualities = <int, VideoFormat>{};
      for (var format in videoFormats) {
        if (format.height != null &&
            !uniqueQualities.containsKey(format.height)) {
          uniqueQualities[format.height!] = format;
        }
      }

      setState(() {
        _videoInfo = info;
        _availableQualities = uniqueQualities.values.toList();
        _status = 'Found ${_availableQualities.length} qualities';
      });

      _addLog('✓ Title: ${info.title}');
      _addLog('  Duration: ${info.duration}s');
      _addLog('  Qualities: ${_availableQualities.length}');
    } catch (e) {
      setState(() => _status = 'Error: $e');
      _addLog('✗ Error: $e');
    }
  }

  /// Download highest quality (merge video + audio if needed)
  Future<void> _downloadHighestQuality() async {
    if (_videoInfo == null) {
      _addLog('✗ Please fetch video info first');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final processId = 'download_${DateTime.now().millisecondsSinceEpoch}';

    // Use format that merges best video and audio
    final request = DownloadRequest(
      url: _urlController.text,
      outputPath: dir.path,
      outputTemplate: '%(title)s.%(ext)s',
      format: 'bestvideo+bestaudio/best',
      embedThumbnail: true,
      embedMetadata: true,
      processId: processId,
    );

    setState(() {
      _downloads[processId] = DownloadItem(
        title: _videoInfo!.title ?? 'Unknown',
        quality: 'Highest (merged)',
        processId: processId,
      );
      _status = 'Downloading highest quality...';
    });

    _addLog('→ Downloading highest quality (merging video+audio)...');

    try {
      final result = await _youtubeDL.download(request);

      setState(() {
        _downloads[processId]!.state = 'completed';
        _downloads[processId]!.outputPath = result.outputPath;
        _status = 'Download complete!';
      });

      _addLog('✓ Saved to: ${result.outputPath}');
    } catch (e) {
      setState(() {
        _downloads[processId]!.state = 'error';
        _downloads[processId]!.error = e.toString();
        _status = 'Error: $e';
      });
      _addLog('✗ Error: $e');
    }
  }

  /// Download selected quality
  Future<void> _downloadSelectedQuality() async {
    if (_selectedQuality == null) {
      _addLog('✗ Please select a quality first');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final processId = 'download_${DateTime.now().millisecondsSinceEpoch}';

    // Get best audio to merge with selected video quality
    final audioFormat = FormatHelper.getBestAudio(_videoInfo?.formats);

    // Build format string to merge video + audio
    final format = audioFormat != null
        ? '${_selectedQuality!.formatId}+${audioFormat.formatId}/best'
        : _selectedQuality!.formatId!;

    final request = DownloadRequest(
      url: _urlController.text,
      outputPath: dir.path,
      outputTemplate: '%(title)s.%(ext)s',
      format: format,
      embedThumbnail: true,
      embedMetadata: true,
      processId: processId,
    );

    final qualityLabel = '${_selectedQuality!.height}p';

    setState(() {
      _downloads[processId] = DownloadItem(
        title: _videoInfo!.title ?? 'Unknown',
        quality: qualityLabel,
        processId: processId,
      );
      _status = 'Downloading $qualityLabel...';
    });

    _addLog('→ Downloading $qualityLabel...');

    try {
      final result = await _youtubeDL.download(request);

      setState(() {
        _downloads[processId]!.state = 'completed';
        _downloads[processId]!.outputPath = result.outputPath;
        _status = 'Download complete!';
      });

      _addLog('✓ Saved to: ${result.outputPath}');
    } catch (e) {
      setState(() {
        _downloads[processId]!.state = 'error';
        _downloads[processId]!.error = e.toString();
        _status = 'Error: $e';
      });
      _addLog('✗ Error: $e');
    }
  }

  /// Download audio only
  Future<void> _downloadAudioOnly() async {
    if (_videoInfo == null) {
      _addLog('✗ Please fetch video info first');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final processId = 'download_${DateTime.now().millisecondsSinceEpoch}';

    final request = DownloadRequest(
      url: _urlController.text,
      outputPath: dir.path,
      outputTemplate: '%(title)s.%(ext)s',
      extractAudio: true,
      audioFormat: 'mp3',
      audioQuality: 0,
      embedThumbnail: true,
      processId: processId,
    );

    setState(() {
      _downloads[processId] = DownloadItem(
        title: _videoInfo!.title ?? 'Unknown',
        quality: 'Audio (MP3)',
        processId: processId,
      );
      _status = 'Extracting audio...';
    });

    _addLog('→ Extracting audio (MP3)...');

    try {
      final result = await _youtubeDL.download(request);

      setState(() {
        _downloads[processId]!.state = 'completed';
        _downloads[processId]!.outputPath = result.outputPath;
        _status = 'Audio extracted!';
      });

      _addLog('✓ Saved to: ${result.outputPath}');
    } catch (e) {
      setState(() {
        _downloads[processId]!.state = 'error';
        _downloads[processId]!.error = e.toString();
        _status = 'Error: $e';
      });
      _addLog('✗ Error: $e');
    }
  }

  /// Cancel download
  Future<void> _cancelDownload(String processId) async {
    try {
      final cancelled = await _youtubeDL.cancelDownload(processId);
      if (cancelled) {
        setState(() {
          _downloads[processId]!.state = 'cancelled';
        });
        _addLog('✓ Download cancelled: $processId');
      }
    } catch (e) {
      _addLog('✗ Failed to cancel: $e');
    }
  }

  /// Delete downloaded file
  Future<void> _deleteDownload(String processId) async {
    final download = _downloads[processId];
    if (download?.outputPath != null) {
      try {
        final file = File(download!.outputPath!);
        if (await file.exists()) {
          await file.delete();
          _addLog('✓ File deleted');
        }
      } catch (e) {
        _addLog('✗ Failed to delete: $e');
      }
    }

    setState(() {
      _downloads.remove(processId);
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs = '$message\n$_logs';
      if (_logs.length > 5000) {
        _logs = _logs.substring(0, 5000);
      }
    });
  }

  void _clearLogs() {
    setState(() => _logs = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extractor Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildMainPage(),
                _buildDownloadsPage(),
                _buildSettingsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMainPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // URL Input
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Video URL',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 16),

          // Get Info Button
          FilledButton.icon(
            onPressed: _getVideoInfo,
            icon: const Icon(Icons.info),
            label: const Text('Get Video Info & Qualities'),
          ),
          const SizedBox(height: 16),

          // Video Info
          if (_videoInfo != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _videoInfo!.title ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('Duration: ${_videoInfo!.duration}s'),
                    Text('Uploader: ${_videoInfo!.uploader ?? 'Unknown'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Available Qualities
          if (_availableQualities.isNotEmpty) ...[
            Text(
              'Available Qualities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            ...List.generate(_availableQualities.length, (index) {
              final quality = _availableQualities[index];
              final isSelected = _selectedQuality == quality;

              // Build subtitle with available info
              final parts = <String>[];

              // Add extension
              if (quality.ext != null) {
                parts.add(quality.ext!.toUpperCase());
              }

              // Add codec (simplified, e.g., "avc1.64001F" -> "AVC1")
              if (quality.vcodec != null && quality.vcodec != 'none') {
                final codec = quality.vcodec!.split('.').first.toUpperCase();
                parts.add(codec);
              }

              // Add file size or bitrate
              if (quality.filesize != null && quality.filesize! > 0) {
                final size = FormatHelper.formatFileSize(quality.filesize);
                if (size != 'Unknown') parts.add(size);
              } else if (quality.tbr != null && quality.tbr! > 0) {
                parts.add('${quality.tbr!.toInt()} kbps');
              }

              // Add FPS if available
              if (quality.fps != null && quality.fps! > 0) {
                parts.add('${quality.fps!.toInt()} fps');
              }

              final subtitle =
                  parts.isNotEmpty ? parts.join(' • ') : 'Video format';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _selectedQuality = quality);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.video_library,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${quality.height}p',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Download Buttons
            FilledButton.icon(
              onPressed: _downloadHighestQuality,
              icon: const Icon(Icons.high_quality),
              label: const Text('Download Highest Quality (Merged)'),
            ),
            const SizedBox(height: 8),

            FilledButton.icon(
              onPressed:
                  _selectedQuality != null ? _downloadSelectedQuality : null,
              icon: const Icon(Icons.download),
              label: Text(
                _selectedQuality != null
                    ? 'Download ${_selectedQuality!.height}p'
                    : 'Select Quality First',
              ),
            ),
            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _downloadAudioOnly,
              icon: const Icon(Icons.audiotrack),
              label: const Text('Extract Audio Only (MP3)'),
            ),
            const SizedBox(height: 24),
          ],

          // Logs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: SelectableText(
                _logs.isEmpty ? 'Logs will appear here...' : _logs,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsPage() {
    if (_downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a download from the Main tab',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloads.length,
      itemBuilder: (context, index) {
        final processId = _downloads.keys.elementAt(index);
        final download = _downloads[processId]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStateIcon(download.state),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            download.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            download.quality,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (download.state == 'started')
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _cancelDownload(processId),
                        tooltip: 'Cancel',
                      ),
                    if (download.state == 'completed')
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteDownload(processId),
                        tooltip: 'Delete',
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                if (download.state == 'started') ...[
                  LinearProgressIndicator(
                    value: download.progress / 100,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${download.progress.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'ETA: ${download.eta}s',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],

                // Status
                if (download.state != 'started') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getStateColor(download.state).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStateColor(download.state),
                      ),
                    ),
                    child: Text(
                      download.state.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStateColor(download.state),
                      ),
                    ),
                  ),
                ],

                // Error message
                if (download.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    download.error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],

                // Output path
                if (download.outputPath != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Saved to: ${download.outputPath}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateIcon(String state) {
    switch (state) {
      case 'started':
        return const CircularProgressIndicator();
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 32);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.orange, size: 32);
      case 'error':
        return const Icon(Icons.error, color: Colors.red, size: 32);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey, size: 32);
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Version Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Version Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_versionInfo != null) ...[
                    _buildVersionItem(
                      'yt-dlp',
                      _versionInfo!.youtubeDlVersion ?? 'Unknown',
                      Icons.download,
                    ),
                    const Divider(height: 24),
                    _buildVersionItem(
                      'FFmpeg',
                      _versionInfo!.ffmpegVersion ?? 'Unknown',
                      Icons.video_library,
                    ),
                    const Divider(height: 24),
                    _buildVersionItem(
                      'Python',
                      _versionInfo!.pythonVersion ?? 'Unknown',
                      Icons.code,
                    ),
                  ] else ...[
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Update Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.system_update,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Update yt-dlp',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep yt-dlp up to date for the best compatibility and features.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isUpdating ? null : _updateYoutubeDL,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.system_update),
                      label:
                          Text(_isUpdating ? 'Updating...' : 'Update yt-dlp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Plugin Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.extension,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Plugin Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Plugin', 'Extractor v1.0.0'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Android Library', 'youtubedl-android v0.18.1'),
                  const SizedBox(height: 12),
                  _buildInfoRow('iOS Library', 'YoutubeDL-iOS'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Communication', 'Pigeon (Type-safe)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.featured_play_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Features',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Video downloads', true),
                  _buildFeatureItem('Audio extraction (MP3)', true),
                  _buildFeatureItem('Quality selection', true),
                  _buildFeatureItem('Video+Audio merging', true),
                  _buildFeatureItem('Subtitle support', true),
                  _buildFeatureItem('FFmpeg integration', true),
                  _buildFeatureItem('Aria2c downloader', true),
                  _buildFeatureItem('Progress tracking', true),
                  _buildFeatureItem('Format templates', true),
                  _buildFeatureItem('Custom format selector', true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.build,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearLogs,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear All Logs'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _downloads.clear();
                        });
                        _addLog('✓ Downloads list cleared');
                      },
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear Downloads List'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadVersionInfo,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Version Info'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'iOS Warning',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The iOS implementation is NOT AppStore-safe. It uses YoutubeDL-iOS which includes Python runtime and may violate App Store guidelines.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String label, String version, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                version,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

class DownloadItem {
  final String title;
  final String quality;
  final String processId;
  double progress;
  int eta;
  String state;
  String? error;
  String? outputPath;

  DownloadItem({
    required this.title,
    required this.quality,
    required this.processId,
    this.progress = 0.0,
    this.eta = 0,
    this.state = 'started',
    this.error,
    this.outputPath,
  });
}
