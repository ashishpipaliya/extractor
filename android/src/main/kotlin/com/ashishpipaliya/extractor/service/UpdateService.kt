package com.ashishpipaliya.extractor.service

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.ashishpipaliya.extractor.generated.OperationStatus
import com.ashishpipaliya.extractor.generated.UpdateChannel
import com.ashishpipaliya.extractor.generated.UpdateResult
import com.yausername.youtubedl_android.YoutubeDL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.Executors

/**
 * Service responsible for updating youtube-dl binary
 */
class UpdateService(private val context: Context) {

    private val scope = CoroutineScope(Dispatchers.Main)
    private val executor = Executors.newSingleThreadExecutor()

    fun updateYoutubeDL(channel: UpdateChannel, callback: (Result<UpdateResult>) -> Unit) {
        executor.execute {
            try {
                // Only stable channel is supported
                val updateChannel = YoutubeDL.UpdateChannel.STABLE

                val status = YoutubeDL.getInstance().updateYoutubeDL(context, updateChannel)

                val result = when (status) {
                    YoutubeDL.UpdateStatus.DONE -> {
                        // Get the actual version after update
                        val version = try {
                            val request = com.yausername.youtubedl_android.YoutubeDLRequest(emptyList())
                            request.addOption("--version")
                            val response = YoutubeDL.getInstance().execute(request)
                            response.out.trim()
                        } catch (e: Exception) {
                            "Latest"
                        }
                        
                        UpdateResult(
                            status = OperationStatus.SUCCESS,
                            version = version,
                            errorMessage = null
                        )
                    }
                    YoutubeDL.UpdateStatus.ALREADY_UP_TO_DATE -> {
                        // Get current version
                        val version = try {
                            val request = com.yausername.youtubedl_android.YoutubeDLRequest(emptyList())
                            request.addOption("--version")
                            val response = YoutubeDL.getInstance().execute(request)
                            response.out.trim()
                        } catch (e: Exception) {
                            "Latest"
                        }
                        
                        UpdateResult(
                            status = OperationStatus.SUCCESS,
                            version = version,
                            errorMessage = "Already up to date"
                        )
                    }
                    else -> {
                        UpdateResult(
                            status = OperationStatus.ERROR,
                            version = null,
                            errorMessage = "Update failed"
                        )
                    }
                }

                scope.launch {
                    callback(Result.success(result))
                }
            } catch (e: Exception) {
                scope.launch {
                    callback(
                        Result.success(
                            UpdateResult(
                                status = OperationStatus.ERROR,
                                version = null,
                                errorMessage = e.message ?: "Unknown update error"
                            )
                        )
                    )
                }
            }
        }
    }
}
