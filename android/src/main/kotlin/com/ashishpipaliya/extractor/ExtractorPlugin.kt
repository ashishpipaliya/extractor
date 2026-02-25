package com.ashishpipaliya.extractor

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import com.ashishpipaliya.extractor.core.YoutubeDLManager
import com.ashishpipaliya.extractor.generated.YoutubeDLApi

/**
 * Main plugin class that handles Flutter engine lifecycle
 */
class ExtractorPlugin : FlutterPlugin {
    private var youtubeDLManager: YoutubeDLManager? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupPlugin(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        teardownPlugin()
    }

    private fun setupPlugin(context: Context, messenger: BinaryMessenger) {
        youtubeDLManager = YoutubeDLManager(context, messenger)
        YoutubeDLApi.setUp(messenger, youtubeDLManager)
    }

    private fun teardownPlugin() {
        youtubeDLManager?.cleanup()
        youtubeDLManager = null
    }
}
