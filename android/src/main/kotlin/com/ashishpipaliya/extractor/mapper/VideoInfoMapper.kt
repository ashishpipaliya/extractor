package com.ashishpipaliya.extractor.mapper

import com.ashishpipaliya.extractor.generated.VideoFormat
import com.ashishpipaliya.extractor.generated.VideoInfo
import com.yausername.youtubedl_android.mapper.VideoInfo as NativeVideoInfo
import com.yausername.youtubedl_android.mapper.VideoFormat as NativeVideoFormat

/**
 * Mapper to convert native VideoInfo to Pigeon-generated VideoInfo
 * Follows Single Responsibility Principle
 */
class VideoInfoMapper {

    fun map(nativeInfo: NativeVideoInfo): VideoInfo {
        return VideoInfo(
            id = nativeInfo.id,
            title = nativeInfo.title,
            description = nativeInfo.description,
            uploader = nativeInfo.uploader,
            uploaderId = nativeInfo.uploaderId,
            uploaderUrl = null, // Not available in native VideoInfo
            channelId = null, // Not available in native VideoInfo
            channelUrl = null, // Not available in native VideoInfo
            duration = nativeInfo.duration?.toLong(),
            viewCount = nativeInfo.viewCount?.toLong(),
            likeCount = nativeInfo.likeCount?.toLong(),
            thumbnail = nativeInfo.thumbnail,
            url = nativeInfo.url,
            formats = nativeInfo.formats?.map { mapFormat(it) },
            ext = nativeInfo.ext,
            width = nativeInfo.width?.toLong(),
            height = nativeInfo.height?.toLong(),
            fps = null, // Not available in native VideoInfo
            vcodec = null, // Not available in native VideoInfo
            acodec = null // Not available in native VideoInfo
        )
    }

    private fun mapFormat(nativeFormat: NativeVideoFormat): VideoFormat {
        return VideoFormat(
            formatId = nativeFormat.formatId,
            formatNote = nativeFormat.formatNote,
            ext = nativeFormat.ext,
            url = nativeFormat.url,
            width = nativeFormat.width?.toLong(),
            height = nativeFormat.height?.toLong(),
            fps = null, // Not available in native VideoFormat
            filesize = null, // Not available in native VideoFormat
            tbr = nativeFormat.tbr?.toLong(),
            vcodec = nativeFormat.vcodec,
            acodec = nativeFormat.acodec,
            resolution = null // Not available in native VideoFormat
        )
    }
}
