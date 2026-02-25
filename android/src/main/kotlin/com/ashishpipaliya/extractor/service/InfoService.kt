package com.ashishpipaliya.extractor.service

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.ashishpipaliya.extractor.generated.VideoInfo
import com.ashishpipaliya.extractor.mapper.VideoInfoMapper
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.Executors

/**
 * Service responsible for fetching video information
 */
class InfoService(private val context: Context) {

    private val scope = CoroutineScope(Dispatchers.Main)
    private val mapper = VideoInfoMapper()
    private val executor = Executors.newSingleThreadExecutor()

    fun getVideoInfo(url: String, callback: (Result<VideoInfo>) -> Unit) {
        // Execute on background thread but youtubedl calls are thread-safe
        executor.execute {
            try {
                val request = YoutubeDLRequest(url)
                // Suppress update warning
                request.addOption("--no-update")
                
                val info = YoutubeDL.getInstance().getInfo(request)
                val videoInfo = mapper.map(info)

                scope.launch {
                    callback(Result.success(videoInfo))
                }
            } catch (e: Exception) {
                scope.launch {
                    callback(Result.failure(e))
                }
            }
        }
    }

    fun getVideoInfoWithOptions(
        url: String,
        options: Map<String?, String?>,
        callback: (Result<VideoInfo>) -> Unit
    ) {
        executor.execute {
            try {
                val request = YoutubeDLRequest(url)
                
                // Suppress update warning
                request.addOption("--no-update")
                
                // Apply custom options
                options.forEach { (key, value) ->
                    if (key != null && value != null) {
                        request.addOption(key, value)
                    } else if (key != null) {
                        request.addOption(key)
                    }
                }

                val info = YoutubeDL.getInstance().getInfo(request)
                val videoInfo = mapper.map(info)

                scope.launch {
                    callback(Result.success(videoInfo))
                }
            } catch (e: Exception) {
                scope.launch {
                    callback(Result.failure(e))
                }
            }
        }
    }
}
