package com.graceedit.graceedit

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Native thumbnail provider backed by MediaMetadataRetriever.
 * Channel: graceedit/thumbnails :: frame(path, timeMs, maxWidth, outPath) -> outPath?
 */
class ThumbnailPlugin(engine: FlutterEngine) {
    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "graceedit/thumbnails")
            .setMethodCallHandler { call, result ->
                if (call.method == "frame") {
                    val path = call.argument<String>("path")
                    val timeMs = (call.argument<Int>("timeMs") ?: 1000).toLong()
                    val maxWidth = call.argument<Int>("maxWidth") ?: 320
                    val outPath = call.argument<String>("outPath")
                    if (path == null || outPath == null) {
                        result.error("BAD_ARGS", "path and outPath required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val out = extractFrame(path, timeMs * 1000L, maxWidth, outPath)
                        if (out != null) result.success(out) else result.error(
                            "NO_FRAME", "Could not extract frame from $path", null
                        )
                    } catch (e: Exception) {
                        result.error("EXTRACT_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun extractFrame(
        path: String, timeUs: Long, maxWidth: Int, outPath: String
    ): String? {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(path)
            val raw: Bitmap =
                retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                    ?: return null
            val scaled: Bitmap = if (raw.width > maxWidth) {
                val ratio = maxWidth.toFloat() / raw.width.toFloat()
                Bitmap.createScaledBitmap(
                    raw, maxWidth, (raw.height * ratio).toInt(), true
                )
            } else {
                raw
            }
            FileOutputStream(File(outPath)).use { out ->
                scaled.compress(Bitmap.CompressFormat.JPEG, 75, out)
            }
            if (scaled !== raw) raw.recycle()
            return outPath
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }
}
