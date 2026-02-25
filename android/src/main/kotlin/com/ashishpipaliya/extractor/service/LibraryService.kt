package com.ashishpipaliya.extractor.service

import android.content.Context
import com.ashishpipaliya.extractor.generated.InitConfig
import com.ashishpipaliya.extractor.generated.InitResult
import com.ashishpipaliya.extractor.generated.VersionInfo
import com.yausername.aria2c.Aria2c
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.os.Handler
import android.os.Looper

/**
 * Service responsible for library initialization and version management
 * Follows Single Responsibility Principle
 */
class LibraryService(private val context: Context) {

    private val scope = CoroutineScope(Dispatchers.Main)
    private val mainHandler = Handler(Looper.getMainLooper())
    @Volatile
    private var initialized = false

    fun initialize(config: InitConfig, callback: (Result<InitResult>) -> Unit) {
        // Run initialization on main thread as required by youtubedl-android
        mainHandler.post {
            scope.launch {
                try {
                    // Initialize YoutubeDL (required) - must be on main thread
                    YoutubeDL.getInstance().init(context)

                    // Initialize FFmpeg if enabled
                    if (config.enableFFmpeg) {
                        FFmpeg.getInstance().init(context)
                    }

                    // Initialize Aria2c if enabled
                    if (config.enableAria2c) {
                        Aria2c.getInstance().init(context)
                    }

                    initialized = true

                    callback(Result.success(InitResult(success = true, errorMessage = null)))
                } catch (e: Exception) {
                    initialized = false
                    callback(
                        Result.success(
                            InitResult(
                                success = false,
                                errorMessage = e.message ?: "Unknown initialization error"
                            )
                        )
                    )
                }
            }
        }
    }

    fun getVersion(callback: (Result<VersionInfo>) -> Unit) {
        scope.launch {
            try {
                // Get actual yt-dlp version by executing --version command
                val youtubeDlVersion = withContext(Dispatchers.IO) {
                    try {
                        val request = com.yausername.youtubedl_android.YoutubeDLRequest(emptyList())
                        request.addOption("--version")
                        val response = YoutubeDL.getInstance().execute(request)
                        val version = response.out.trim()
                        "yt-dlp $version"
                    } catch (e: Exception) {
                        // Fallback to bundled version if command fails
                        "yt-dlp 2025.11.12 (bundled in library v0.18.1)"
                    }
                }
                
                val ffmpegVersion = "FFmpeg 6.0 (bundled)"
                val pythonVersion = "Python 3.8 (bundled)"

                callback(
                    Result.success(
                        VersionInfo(
                            youtubeDlVersion = youtubeDlVersion,
                            ffmpegVersion = ffmpegVersion,
                            pythonVersion = pythonVersion
                        )
                    )
                )
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    fun isInitialized(): Boolean = initialized
}
