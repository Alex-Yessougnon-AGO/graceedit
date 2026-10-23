package com.graceedit.graceedit

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.OverlaySettings
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.Presentation
import androidx.media3.effect.ScaleAndRotateTransformation
import androidx.media3.effect.StaticOverlaySettings
import androidx.media3.effect.TextureOverlay
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Real video export backed by Media3 Transformer.
 *
 * Channel graceedit/export:
 * - startExport{clips:[{path,startMs,endMs,rotation}], texts:[String],
 *   width, height, outPath} -> jobId
 * - exportProgress{jobId} -> {state: queued|running|done|error|cancelled, progress: 0..1, error?}
 * - cancelExport{jobId} -> bool
 *
 * V1 scope: trim + concat + rotation + resize + baked text overlays.
 * Speed/volume/filters are preview-side in V1 and get baked in the Pro
 * export phase.
 */
class ExportPlugin(private val context: Context, engine: FlutterEngine) {

    private data class Job(
        val transformer: Transformer,
        val outPath: String,
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
                            val texts = call.argument<List<String>>("texts")
                                ?: emptyList()
                            val subtitles = call.argument<List<Map<String, Any>>>("subtitles")
                                ?: emptyList()
                            val subtitleStyle =
                                call.argument<String>("subtitleStyle") ?: "classic"
                            val outPath = call.argument<String>("outPath")
                                ?: return@setMethodCallHandler result.error(
                                    "BAD_ARGS", "outPath required", null)
                            val jobId = UUID.randomUUID().toString()
                            start(
                                jobId, clips, texts, subtitles, subtitleStyle,
                                width, height, outPath)
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
                            // Do not leave a broken half-video on the phone.
                            // The muxer may still hold the file for a moment,
                            // so unlink it just after the cancel settles.
                            mainHandler.postDelayed({
                                runCatching { File(job.outPath).delete() }
                            }, 1200)
                            result.success(true)
                        }
                    }
                    // Copies a finished export into the phone's gallery so the
                    // user really owns the file (share sheet still works).
                    "saveToGallery" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("BAD_ARGS", "path required", null)
                        } else {
                            try {
                                result.success(saveToGallery(path))
                            } catch (e: Exception) {
                                result.error(
                                    "SAVE_FAILED",
                                    e.message ?: "Enregistrement impossible.",
                                    null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun start(
        jobId: String,
        clips: List<Map<String, Any>>,
        texts: List<String>,
        subtitles: List<Map<String, Any>>,
        subtitleStyle: String,
        width: Int,
        height: Int,
        outPath: String,
    ) {
        val cues = subtitles.mapNotNull { raw ->
            val text = (raw["text"] as? String)?.trim().orEmpty()
            if (text.isEmpty()) null else SubtitleCue(
                startMs = (raw["startMs"] as? Number)?.toLong() ?: 0L,
                endMs = (raw["endMs"] as? Number)?.toLong() ?: 0L,
                text = text,
            )
        }
        // Texts sit just above the subtitle band when both are present, so
        // they never overlap on screen.
        val textEffect = buildTextEffect(texts, width, cues.isNotEmpty())
        val items = mutableListOf<EditedMediaItem>()
        var clipOffsetMs = 0L
        for (c in clips) {
            val path = c["path"] as String
            val startMs = (c["startMs"] as Number).toLong()
            val endMs = (c["endMs"] as Number).toLong()
            val rotation = (c["rotation"] as? Number)?.toInt() ?: 0
            val clipDurationMs = (endMs - startMs).coerceAtLeast(1L)
            val mediaItem = MediaItem.Builder()
                .setUri(path)
                .setClippingConfiguration(
                    MediaItem.ClippingConfiguration.Builder()
                        .setStartPositionMs(startMs)
                        .setEndPositionMs(endMs)
                        .build())
                .build()
            val videoEffects = mutableListOf<Effect>()
            if (rotation != 0) {
                videoEffects.add(
                    ScaleAndRotateTransformation.Builder()
                        .setRotationDegrees(rotation.toFloat())
                        .build())
            }
            videoEffects.add(
                Presentation.createForWidthAndHeight(
                    width, height, Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP))
            if (textEffect != null) {
                // After the resize, so the text is never cropped with the frame.
                videoEffects.add(textEffect)
            }
            // Subtitles are timed on the whole project timeline: shift each cue
            // into this clip's local presentation time.
            val localCues = cues.mapNotNull { cue ->
                val localStart = maxOf(cue.startMs, clipOffsetMs) - clipOffsetMs
                val localEnd = minOf(cue.endMs, clipOffsetMs + clipDurationMs) -
                    clipOffsetMs
                if (localEnd <= localStart) null
                else SubtitleCue(localStart, localEnd, cue.text)
            }
            if (localCues.isNotEmpty()) {
                videoEffects.add(
                    OverlayEffect(listOf(
                        SubtitleOverlay(localCues, subtitleStyle, width, height))))
            }
            items.add(
                EditedMediaItem.Builder(mediaItem)
                    .setEffects(Effects(emptyList<AudioProcessor>(), videoEffects))
                    .build())
            clipOffsetMs += clipDurationMs
        }
        val sequence = EditedMediaItemSequence.Builder(items).build()
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
                    // A failed render must never leave a truncated file behind.
                    runCatching { File(job.outPath).delete() }
                }
            })
            .build()
        job = Job(transformer, outPath)
        jobs[jobId] = job
        transformer.start(composition, outPath)
    }

    /**
     * Renders the project's text layers into one transparent bitmap placed at
     * the bottom centre of the frame — the same place the editor preview shows
     * them. Baked into every clip, so the exported file matches the preview.
     */
    private fun saveToGallery(srcPath: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw IllegalStateException(
                "L’enregistrement dans la galerie demande Android 10 ou plus récent.")
        }
        val src = File(srcPath)
        if (!src.exists()) {
            throw IllegalStateException("Fichier exporté introuvable.")
        }
        val values = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, src.name)
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.Video.Media.RELATIVE_PATH,
                    Environment.DIRECTORY_MOVIES + "/GraceEdit")
                put(MediaStore.Video.Media.IS_PENDING, 1)
            }
        }
        val resolver = context.contentResolver
        val uri = resolver.insert(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("La galerie a refusé la vidéo.")
        try {
            resolver.openOutputStream(uri)?.use { out ->
                src.inputStream().use { input -> input.copyTo(out) }
            } ?: throw IllegalStateException("Impossible d’écrire la vidéo.")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val done = ContentValues().apply {
                    put(MediaStore.Video.Media.IS_PENDING, 0)
                }
                resolver.update(uri, done, null, null)
            }
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
        return uri.toString()
    }

    private fun buildTextEffect(
        texts: List<String>,
        width: Int,
        hasSubtitles: Boolean,
    ): OverlayEffect? {
        val lines = texts.map { it.trim() }.filter { it.isNotEmpty() }
        if (lines.isEmpty()) return null
        // Keep the overlay readable: at most 4 paragraphs, newest ones last.
        val shown = if (lines.size > 4) lines.subList(lines.size - 4, lines.size) else lines
        val textSize = (width * 0.055f).coerceAtLeast(20f)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            this.textSize = textSize
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
            setShadowLayer(textSize * 0.16f, 0f, textSize * 0.08f, Color.BLACK)
        }
        val metrics = paint.fontMetrics
        val lineHeight = (metrics.descent - metrics.ascent) * 1.15f
        // Wrap like the in-app preview does: never wider than 88% of the frame.
        val maxLineWidth = width * 0.88f
        val wrapped = mutableListOf<String>()
        for (paragraph in shown) {
            var current = ""
            for (word in paragraph.split(" ")) {
                val candidate = if (current.isEmpty()) word else "$current $word"
                if (current.isEmpty() || paint.measureText(candidate) <= maxLineWidth) {
                    current = candidate
                } else {
                    wrapped.add(current)
                    current = word
                }
            }
            if (current.isNotEmpty()) wrapped.add(current)
        }
        val maxTextWidth = wrapped.maxOf { paint.measureText(it) }
        val pad = textSize * 0.4f
        val bmpWidth = (maxTextWidth + pad * 2).toInt().coerceAtLeast(1)
        val bmpHeight = (lineHeight * wrapped.size + pad * 2).toInt().coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(bmpWidth, bmpHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        wrapped.forEachIndexed { i, line ->
            val baseline = pad + (i + 1) * lineHeight - metrics.descent
            canvas.drawText(line, bmpWidth / 2f, baseline, paint)
        }
        val settings = StaticOverlaySettings.Builder()
            // The bottom edge of the text block sits at 8% of the frame height,
            // or 15% when subtitles also occupy the bottom band.
            .setOverlayFrameAnchor(0f, -1f)
            .setBackgroundFrameAnchor(0f, if (hasSubtitles) -0.70f else -0.84f)
            .build()
        val overlay: TextureOverlay =
            BitmapOverlay.createStaticBitmapOverlay(bitmap, settings)
        return OverlayEffect(listOf(overlay))
    }

    private fun pollProgress(job: Job) {
        try {
            val holder = ProgressHolder()
            if (job.transformer.getProgress(holder) ==
                Transformer.PROGRESS_STATE_AVAILABLE) {
                job.progress = (holder.progress / 100f).coerceIn(0f, 1f)
            }
        } catch (_: Exception) {
        }
    }
}

/** One subtitle cue on the exported timeline (milliseconds). */
private data class SubtitleCue(
    val startMs: Long,
    val endMs: Long,
    val text: String,
)

/**
 * Time-aware subtitle overlay. Returns an empty bitmap outside every cue, and
 * a text pill while a cue is active, so subtitles are burned into the MP4 and
 * match the timing shown in the editor.
 */
private class SubtitleOverlay(
    private val cues: List<SubtitleCue>,
    private val style: String,
    private val frameWidth: Int,
    private val frameHeight: Int,
) : BitmapOverlay() {
    private val empty: Bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
    private val cache = LinkedHashMap<String, Bitmap>()
    private val settings: OverlaySettings = StaticOverlaySettings.Builder()
        .setOverlayFrameAnchor(0f, -1f)
        .setBackgroundFrameAnchor(0f, -0.93f)
        .build()

    override fun getBitmap(presentationTimeUs: Long): Bitmap {
        val ms = presentationTimeUs / 1000
        val cue = cues.firstOrNull { ms >= it.startMs && ms < it.endMs }
            ?: return empty
        cache[cue.text]?.let { return it }
        // Keep memory bounded: a project rarely shows more than a few lines.
        if (cache.size >= 4) cache.remove(cache.keys.first())
        val bitmap = render(cue.text)
        cache[cue.text] = bitmap
        return bitmap
    }

    override fun getOverlaySettings(presentationTimeUs: Long): OverlaySettings =
        settings

    private fun render(text: String): Bitmap {
        val maxWidth = frameWidth * 0.92f
        val baseSize = frameWidth * 0.045f
        val typeface = Typeface.create(
            Typeface.DEFAULT,
            if (style == "classic") Typeface.NORMAL else Typeface.BOLD)
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = baseSize
            this.typeface = typeface
            textAlign = Paint.Align.CENTER
            setShadowLayer(baseSize * 0.14f, 0f, baseSize * 0.07f, Color.BLACK)
        }
        // Wrap like the preview; only shrink when a single word is too wide.
        val lines = mutableListOf<String>()
        var current = ""
        for (word in text.split(" ")) {
            val candidate = if (current.isEmpty()) word else "$current $word"
            if (current.isEmpty() || fill.measureText(candidate) <= maxWidth) {
                current = candidate
            } else {
                lines.add(current)
                current = word
            }
        }
        if (current.isNotEmpty()) lines.add(current)
        var measured = lines.maxOf { fill.measureText(it) }
        if (measured > maxWidth) {
            fill.textSize = fill.textSize * (maxWidth / measured)
            measured = lines.maxOf { fill.measureText(it) }
        }
        val metrics = fill.fontMetrics
        val lineHeight = (metrics.descent - metrics.ascent) * 1.12f
        val pad = fill.textSize * 0.35f
        val w = (measured + pad * 2).toInt().coerceIn(1, frameWidth)
        val h = (lineHeight * lines.size + pad * 2)
            .toInt().coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        // A dark pill keeps white text readable on bright footage.
        val pill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(140, 0, 0, 0)
        }
        canvas.drawRoundRect(
            0f, 0f, w.toFloat(), h.toFloat(),
            h * 0.22f, h * 0.22f, pill)
        val stroke = if (style == "outline") Paint(fill).apply {
            this.style = Paint.Style.STROKE
            strokeWidth = fill.textSize * 0.09f
            strokeCap = Paint.Cap.ROUND
            color = Color.BLACK
        } else null
        lines.forEachIndexed { i, line ->
            val baseline = pad + (i + 1) * lineHeight - metrics.descent
            stroke?.let { canvas.drawText(line, w / 2f, baseline, it) }
            canvas.drawText(line, w / 2f, baseline, fill)
        }
        return bitmap
    }
}
