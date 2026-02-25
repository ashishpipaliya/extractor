package com.ashishpipaliya.extractor.core

import android.content.Context
import com.ashishpipaliya.extractor.generated.DownloadRequest
import com.ashishpipaliya.extractor.generated.DownloadResult
import com.ashishpipaliya.extractor.generated.InitConfig
import com.ashishpipaliya.extractor.generated.InitResult
import com.ashishpipaliya.extractor.generated.UpdateChannel
import com.ashishpipaliya.extractor.generated.UpdateResult
import com.ashishpipaliya.extractor.generated.VideoInfo
import com.ashishpipaliya.extractor.generated.VersionInfo
import com.ashishpipaliya.extractor.generated.YoutubeDLApi
import com.ashishpipaliya.extractor.service.DownloadService
import com.ashishpipaliya.extractor.service.InfoService
import com.ashishpipaliya.extractor.service.LibraryService
import com.ashishpipaliya.extractor.service.UpdateService
import io.flutter.plugin.common.BinaryMessenger

/**
 * Main manager class implementing the YoutubeDL API
 * Follows Single Responsibility Principle by delegating to specialized services
 */
class YoutubeDLManager(
    private val context: Context,
    private val messenger: BinaryMessenger
) : YoutubeDLApi {

    private val libraryService = LibraryService(context)
    private val updateService = UpdateService(context)
    private val infoService = InfoService(context)
    private val downloadService = DownloadService(context, messenger)

    override fun initialize(config: InitConfig, callback: (Result<InitResult>) -> Unit) {
        libraryService.initialize(config, callback)
    }

    override fun getVersion(callback: (Result<VersionInfo>) -> Unit) {
        libraryService.getVersion(callback)
    }

    override fun updateYoutubeDL(
        channel: UpdateChannel,
        callback: (Result<UpdateResult>) -> Unit
    ) {
        updateService.updateYoutubeDL(channel, callback)
    }

    override fun getVideoInfo(url: String, callback: (Result<VideoInfo>) -> Unit) {
        infoService.getVideoInfo(url, callback)
    }

    override fun getVideoInfoWithOptions(
        url: String,
        options: Map<String?, String?>,
        callback: (Result<VideoInfo>) -> Unit
    ) {
        infoService.getVideoInfoWithOptions(url, options, callback)
    }

    override fun download(
        request: DownloadRequest,
        callback: (Result<DownloadResult>) -> Unit
    ) {
        downloadService.download(request, callback)
    }

    override fun cancelDownload(
        processId: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        downloadService.cancelDownload(processId, callback)
    }

    override fun isInitialized(): Boolean {
        return libraryService.isInitialized()
    }

    fun cleanup() {
        downloadService.cleanup()
    }
}
