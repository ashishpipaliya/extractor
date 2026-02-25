package com.ashishpipaliya.extractor.service

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.ashishpipaliya.extractor.generated.DownloadRequest
import com.ashishpipaliya.extractor.generated.DownloadResult
import com.ashishpipaliya.extractor.generated.OperationStatus
import com.ashishpipaliya.extractor.generated.YoutubeDLCallback
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors

/**
 * Service responsible for downloading videos
 */
class DownloadService(
    private val context: Context,
    private val messenger: BinaryMessenger
) {

    private val scope = CoroutineScope(Dispatchers.Main)
    private val executor = Executors.newCachedThreadPool()
    private val activeDownloads = ConcurrentHashMap<String, Boolean>()
    private val callback = YoutubeDLCallback(messenger)

    fun download(request: DownloadRequest, callback: (Result<DownloadResult>) -> Unit) {
        val processId = request.processId ?: generateProcessId()
        activeDownloads[processId] = true

        executor.execute {
            try {
                val youtubeDLRequest = buildRequest(request)
                
                scope.launch {
                    this@DownloadService.callback.onDownloadStateChanged(processId, "started") {}
                }

                YoutubeDL.getInstance().execute(youtubeDLRequest, processId) { progress, etaInSeconds, line ->
                    if (activeDownloads[processId] == true) {
                        scope.launch {
                            // Send progress update
                            this@DownloadService.callback.onProgress(
                                processId,
                                progress.toDouble(),
                                etaInSeconds.toLong()
                            ) {}
                            
                            // Send log message
                            if (line.isNotEmpty()) {
                                val logLevel = when {
                                    line.contains("ERROR", ignoreCase = true) -> "error"
                                    line.contains("WARNING", ignoreCase = true) -> "warning"
                                    line.contains("DEBUG", ignoreCase = true) -> "debug"
                                    else -> "info"
                                }
                                this@DownloadService.callback.onLog(processId, line, logLevel) {}
                            }
                        }
                    }
                }

                activeDownloads.remove(processId)

                // Determine output file path
                val outputPath = determineOutputPath(request)

                scope.launch {
                    this@DownloadService.callback.onDownloadStateChanged(processId, "completed") {}
                    callback(
                        Result.success(
                            DownloadResult(
                                status = OperationStatus.SUCCESS,
                                outputPath = outputPath,
                                errorMessage = null
                            )
                        )
                    )
                }
            } catch (e: Exception) {
                activeDownloads.remove(processId)
                
                scope.launch {
                    this@DownloadService.callback.onError(processId, e.message ?: "Unknown error") {}
                    callback(
                        Result.success(
                            DownloadResult(
                                status = OperationStatus.ERROR,
                                outputPath = null,
                                errorMessage = e.message ?: "Download failed"
                            )
                        )
                    )
                }
            }
        }
    }

    fun cancelDownload(processId: String, callback: (Result<Boolean>) -> Unit) {
        executor.execute {
            try {
                if (activeDownloads.containsKey(processId)) {
                    YoutubeDL.getInstance().destroyProcessById(processId)
                    activeDownloads.remove(processId)
                    
                    scope.launch {
                        this@DownloadService.callback.onDownloadStateChanged(processId, "cancelled") {}
                        callback(Result.success(true))
                    }
                } else {
                    scope.launch {
                        callback(Result.success(false))
                    }
                }
            } catch (e: Exception) {
                scope.launch {
                    callback(Result.failure(e))
                }
            }
        }
    }

    fun cleanup() {
        activeDownloads.keys.forEach { processId ->
            try {
                YoutubeDL.getInstance().destroyProcessById(processId)
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
        }
        activeDownloads.clear()
    }

    private fun buildRequest(request: DownloadRequest): YoutubeDLRequest {
        val youtubeDLRequest = YoutubeDLRequest(request.url)

        // Suppress update warning
        youtubeDLRequest.addOption("--no-update")

        // Output path and template
        val outputTemplate = request.outputTemplate ?: "%(title)s.%(ext)s"
        val fullPath = File(request.outputPath, outputTemplate).absolutePath
        youtubeDLRequest.addOption("-o", fullPath)

        // Format selection
        request.format?.let {
            youtubeDLRequest.addOption("-f", it)
        }

        // Playlist handling
        if (request.noPlaylist != false) { // Default true
            youtubeDLRequest.addOption("--no-playlist")
        }

        // Audio extraction
        if (request.extractAudio == true) {
            youtubeDLRequest.addOption("-x")
            request.audioFormat?.let {
                youtubeDLRequest.addOption("--audio-format", it)
            }
            request.audioQuality?.let {
                youtubeDLRequest.addOption("--audio-quality", it.toString())
            }
        }

        // Metadata and thumbnails
        if (request.embedThumbnail == true) {
            youtubeDLRequest.addOption("--embed-thumbnail")
        }
        if (request.embedMetadata == true) {
            youtubeDLRequest.addOption("--embed-metadata")
        }

        // Subtitles
        if (request.writeSubtitles == true) {
            youtubeDLRequest.addOption("--write-sub")
        }
        if (request.writeAutoSubtitles == true) {
            youtubeDLRequest.addOption("--write-auto-sub")
        }
        if (request.embedSubtitles == true) {
            youtubeDLRequest.addOption("--embed-subs")
        }
        request.subtitlesLang?.let {
            youtubeDLRequest.addOption("--sub-lang", it)
        }

        // Custom options
        request.customOptions?.forEach { (key, value) ->
            if (key != null && value != null) {
                youtubeDLRequest.addOption(key, value)
            } else if (key != null) {
                youtubeDLRequest.addOption(key)
            }
        }

        return youtubeDLRequest
    }

    private fun determineOutputPath(request: DownloadRequest): String {
        val outputTemplate = request.outputTemplate ?: "%(title)s.%(ext)s"
        return File(request.outputPath, outputTemplate).absolutePath
    }

    private fun generateProcessId(): String {
        return "download_${System.currentTimeMillis()}_${(0..9999).random()}"
    }
}
