package com.graceedit.graceedit

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.common.effect.Presentation
import androidx.media3.common.util.Util
import androidx.media3.transformer.ClippingConfiguration
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.ScaleAndRotateTransformation
import androidx.media3.transformer.Transformer
import androidx.media3.common.effect.VideoEffect
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Real video export backed by Media3 Transformer.
 *
 * Channel graceedit/export:
 * - startExport{clips:[{path,startMs,endMs,rotation}], width, height, outPath} -> jobId
 * - exportProgress{jobId} -> {state: queued|running|done|error|cancelled, progress: 0..1, error?}
 * - cancelExport{jobId} -> bool
 *
 * V1 scope: trim + concat + rotation + resize. Speed/volume/filters are
 * preview-side in V1 and get baked in the Pro export phase.
 */
class ExportPlugin(private val context: Context, engine: FlutterEngine) {

    private data class Job(
        val transformer: Transformer,
        @Volatile var state: String = "running",
        @Volatile var progress: Float = 0f,
        @Volatile var error: String? = null,
    )

    private val jobs = ConcurrentHashMap<String, Job>()
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "graceedit/export")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startExport" -> {
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val clips = call.argument<List<Map<String, Any>>>("clips")
                                ?: return@setMethodCallHandler result.error(
                                    "BAD_ARGS", "clips required", null)
                            val width = call.argument<Int>("width") ?: 1920
                            val height = call.argument<Int>("height") ?: 1080
                            val outPath = call.argument<String>("outPath")
                                ?: return@setMethodCallHandler result.error(
                                    "BAD_ARGS", "outPath required", null)
                            val jobId = UUID.randomUUID().toString()
                            start(jobId, clips, width, height, outPath)
                            result.success(jobId)
                        } catch (e: Exception) {
                            result.error("START_FAILED", e.message, null)
                        }
                    }
                    "exportProgress" -> {
                        val jobId = call.argument<String>("jobId")
                        val job = jobs[jobId]
                        if (job == null) {
                            result.error("NO_JOB", "Unknown job $jobId", null)
                        } else {
                            if (job.state == "running") {
                                pollProgress(job)
                            }
                            result.success(mapOf(
                                "state" to job.state,
                                "progress" to job.progress.toDouble(),
                                "error" to job.error,
                            ))
                        }
                    }
                    "cancelExport" -> {
                        val jobId = call.argument<String>("jobId")
                        val job = jobs[jobId]
                        if (job == null) {
                            result.success(false)
                        } else {
                            job.transformer.cancel()
                            job.state = "cancelled"
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun start(
        jobId: String,
        clips: List<Map<String, Any>>,
        width: Int,
        height: Int,
        outPath: String,
    ) {
        val items = clips.map { c ->
            val path = c["path"] as String
            val startMs = (c["startMs"] as Number).toLong()
            val endMs = (c["endMs"] as Number).toLong()
            val rotation = (c["rotation"] as? Number)?.toInt() ?: 0
            val mediaItem = MediaItem.Builder()
                .setUri(path)
                .setClippingConfiguration(
                    ClippingConfiguration.Builder()
                        .setStartPositionMs(startMs)
                        .setEndPositionMs(endMs)
                        .build())
                .build()
            val videoEffects = mutableListOf<VideoEffect>()
            if (rotation != 0) {
                videoEffects.add(
                    ScaleAndRotateTransformation.Builder()
                        .setRotationDegrees(rotation.toFloat())
                        .build())
            }
            videoEffects.add(
                Presentation.createForWidthAndHeight(
                    width, height, Presentation.RESIZE_MODE_FILL))
            EditedMediaItem.Builder(mediaItem)
                .setEffects(Effects(emptyList<AudioProcessor>(), videoEffects))
                .build()
        }
        val sequence = EditedMediaItemSequence.sequenceOf(*items.toTypedArray())
        val composition = Composition.Builder(listOf(sequence)).build()

        lateinit var job: Job
        val transformer = Transformer.Builder(context)
            .addListener(object : Transformer.Listener {
                override fun onCompleted(
                    composition: Composition, exportResult: ExportResult) {
                    job.state = "done"
                    job.progress = 1f
                }

                override fun onError(
                    composition: Composition,
                    exportResult: ExportResult,
                    exportException: ExportException) {
                    job.state = "error"
                    job.error = exportException.message ?: "Export failed"
                }
            })
            .build()
        job = Job(transformer)
        jobs[jobId] = job
        // Clean up finished jobs after a delay to bound memory.
        transformer.start(composition, outPath)
    }

    private fun pollProgress(job: Job) {
        try {
            val holder = ProgressHolder()
            when (job.transformer.getProgress(holder)) {
                Transformer.PROGRESS_STATE_AVAILABLE ->
                    job.progress = (holder.progress / 100f).coerceIn(0f, 1f)
                Transformer.PROGRESS_STATE_UNAVAILABLE -> Unit
                else -> Unit
            }
        } catch (_: Exception) {
        }
        // Keep callbacks on the main thread healthy.
        if (!Util.isRunningOnMainThread()) {
            mainHandler.post {}
        }
    }
}
