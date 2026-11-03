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
import androidx.media3.common.C
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.OverlaySettings
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.common.audio.GainProcessor
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
 * V1 scope: trim + concat + rotation + resize + baked text overlays +
 * volume/fades and background-music mixing.
 *
 * The editor preview and the exported file must agree: the same clip volume,
 * video volume, music, fades and text placement are applied here.
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
                            val audios = call.argument<List<Map<String, Any>>>("audios")
                                ?: emptyList()
                            val fit = call.argument<String>("fit") ?: "fill"
                            val outPath = call.argument<String>("outPath")
                                ?: return@setMethodCallHandler result.error(
                                    "BAD_ARGS", "outPath required", null)
                            val jobId = UUID.randomUUID().toString()
                            start(
                                jobId, clips, texts, subtitles, subtitleStyle,
                                width, height, outPath, audios, fit)
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
        audios: List<Map<String, Any>> = emptyList(),
        fit: String = "fill",
    ) {
        val cues = subtitles.mapNotNull { raw ->
            val text = (raw["text"] as? String)?.trim().orEmpty()
            if (text.isEmpty()) null else SubtitleCue(
                startMs = (raw["startMs"] as? Number)?.toLong() ?: 0L,
                endMs = (raw["endMs"] as? Number)?.toLong() ?: 0L,
                text = text,
                x = (raw["x"] as? Number)?.toDouble()?.toFloat() ?: 0.5f,
                y = (raw["y"] as? Number)?.toDouble()?.toFloat() ?: 0.5f,
                size = (raw["size"] as? Number)?.toDouble()?.toFloat() ?: 0f,
                color = (raw["color"] as? Number)?.toLong() ?: 0xFFF6F2EAL,
                opacity = (raw["opacity"] as? Number)?.toDouble()?.toFloat() ?: 1f,
                align = (raw["align"] as? String) ?: "center",
                background = raw["background"] == true,
            )
        }
        // Texts sit just above the subtitle band when both are present, so
        // they never overlap on screen.
        val textEffect = buildTextEffect(texts, width, cues.isNotEmpty())
        val layout = if (fit == "fit") {
            Presentation.LAYOUT_SCALE_TO_FIT
        } else {
            Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP
        }
        val videoVolume = (clips.firstOrNull()?.get("videoVolume") as? Number)
            ?.toFloat() ?: 1f
        val items = mutableListOf<EditedMediaItem>()
        var clipOffsetMs = 0L
        for (c in clips) {
            val path = c["path"] as String
            val startMs = (c["startMs"] as Number).toLong()
            val endMs = (c["endMs"] as Number).toLong()
            val rotation = (c["rotation"] as? Number)?.toInt() ?: 0
            val clipVolume = ((c["volume"] as? Number)?.toFloat() ?: 1f)
                .coerceIn(0f, 1f)
            val speed = ((c["speed"] as? Number)?.toFloat() ?: 1f)
                .coerceIn(0.25f, 4f)
            // Durée sur la timeline : durée du média divisée par la vitesse.
            val clipDurationMs = ((endMs - startMs) / speed).toLong()
                .coerceAtLeast(1L)
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
                Presentation.createForWidthAndHeight(width, height, layout))
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
                else cue.copy(startMs = localStart, endMs = localEnd)
            }
            if (localCues.isNotEmpty()) {
                videoEffects.add(
                    OverlayEffect(listOf(
                        SubtitleOverlay(localCues, subtitleStyle, width, height))))
            }
            val fadeInMs = (c["fadeInMs"] as? Number)?.toLong() ?: 0L
            val fadeOutMs = (c["fadeOutMs"] as? Number)?.toLong() ?: 0L
            if (fadeInMs > 0 || fadeOutMs > 0) {
                // Fondu depuis/vers le noir (ou le blanc), synchronisé
                // avec le son.
                videoEffects.add(
                    OverlayEffect(listOf(
                        FadeOverlay(
                            clipDurationMs, fadeInMs, fadeOutMs,
                            if (c["fadeInWhite"] == true) {
                                Color.WHITE
                            } else {
                                Color.BLACK
                            },
                            if (c["fadeOutWhite"] == true) {
                                Color.WHITE
                            } else {
                                Color.BLACK
                            },
                        ))))
            }
            when (c["zoom"] as? String) {
                "in" -> videoEffects.add(
                    ZoomTransformation(clipDurationMs, 1f, 1.15f))
                "out" -> videoEffects.add(
                    ZoomTransformation(clipDurationMs, 1.15f, 1f))
            }
            val audioProcessors = mutableListOf<AudioProcessor>()
            if (speed != 1f) {
                // Même effet de vitesse que l'aperçu (video_player).
                // Transformer ajuste aussi les horodatages audio via son
                // SpeedChangingMediaSource interne (vérifié à l'export :
                // la durée du fichier suit la vitesse demandée).
                videoEffects.add(
                    androidx.media3.effect.SpeedChangeEffect(speed))
            }
            val gain = clipVolume * videoVolume
            if (gain < 0.999f || fadeInMs > 0 || fadeOutMs > 0) {
                audioProcessors.add(
                    RampGainProcessor(
                        gain,
                        fadeInMs * 1000L,
                        fadeOutMs * 1000L,
                        clipDurationMs * 1000L))
            }
            items.add(
                EditedMediaItem.Builder(mediaItem)
                    .setEffects(Effects(audioProcessors, videoEffects))
                    .build())
            clipOffsetMs += clipDurationMs
        }
        val sequence = EditedMediaItemSequence.Builder(items).build()
        val sequences = mutableListOf(sequence)
        val projectDurationMs = clipOffsetMs
        // Une séquence audio par élément ajouté : Media3 mélange le son de
        // toutes les séquences (musique + son d'origine).
        for (a in audios) {
            val path = a["path"] as? String ?: continue
            val startMs = ((a["startMs"] as? Number)?.toLong() ?: 0L)
                .coerceIn(0L, projectDurationMs)
            val trimStartMs = (a["trimStartMs"] as? Number)?.toLong() ?: 0L
            var trimEndMs = (a["trimEndMs"] as? Number)?.toLong() ?: 0L
            // Le son ne joue jamais au-delà de la fin du projet.
            trimEndMs = minOf(trimEndMs, trimStartMs + (projectDurationMs - startMs))
            if (trimEndMs - trimStartMs < 100L) continue
            val volume = ((a["volume"] as? Number)?.toFloat() ?: 1f)
                .coerceIn(0f, 1f)
            val fadeInMs = (a["fadeInMs"] as? Number)?.toLong() ?: 0L
            val fadeOutMs = (a["fadeOutMs"] as? Number)?.toLong() ?: 0L
            val musicItem = MediaItem.Builder()
                .setUri(path)
                .setClippingConfiguration(
                    MediaItem.ClippingConfiguration.Builder()
                        .setStartPositionMs(trimStartMs)
                        .setEndPositionMs(trimEndMs)
                        .build())
                .build()
            val durationUs = (trimEndMs - trimStartMs) * 1000L
            val gainProcessor = RampGainProcessor(
                    volume,
                    fadeInMs * 1000L,
                    fadeOutMs * 1000L,
                    durationUs)
            val musicEdited = EditedMediaItem.Builder(musicItem)
                .setRemoveVideo(true)
                .setEffects(Effects(listOf(gainProcessor), emptyList()))
                .build()
            val builder = EditedMediaItemSequence.Builder(setOf(C.TRACK_TYPE_AUDIO))
            if (startMs > 0) builder.addGap(startMs * 1000L)
            builder.addItem(musicEdited)
            sequences.add(builder.build())
        }
        val composition = if (sequences.size == 1) {
            Composition.Builder(listOf(sequence)).build()
        } else {
            Composition.Builder(sequences).build()
        }

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

/** One text cue on the exported timeline (milliseconds). */
private data class SubtitleCue(
    val startMs: Long,
    val endMs: Long,
    val text: String,
    val x: Float = 0.5f,
    val y: Float = 0.5f,
    val size: Float = 0f,
    val color: Long = 0xFFF6F2EA,
    val opacity: Float = 1f,
    val align: String = "center",
    val background: Boolean = false,
)

/**
 * Gain constant avec rampes linéaires d'entrée et de sortie, appliqué
 * directement sur les échantillons PCM 16 bits. Même courbe que
 * `PreviewAudioEngine.gainFor` côté Dart, pour que l'export sonne comme
 * l'aperçu.
 *
 * Processeur maison plutôt que le `GainProcessor` de Media3 : avec un
 * `GainProvider` à rampes, son `queueInput` bouclait sans consommer les
 * tampons (export bloqué à 10 %, thread Transformer en boucle — constaté
 * par dump de threads sur émulateur).
 */
private class RampGainProcessor(
    private val gain: Float,
    private val fadeInUs: Long,
    private val fadeOutUs: Long,
    private val durationUs: Long,
) : androidx.media3.common.audio.BaseAudioProcessor() {

    private var framesProcessed = 0L

    override fun onConfigure(
        inputAudioFormat: AudioProcessor.AudioFormat,
    ): AudioProcessor.AudioFormat {
        if (inputAudioFormat.encoding != C.ENCODING_PCM_16BIT) {
            throw AudioProcessor.UnhandledAudioFormatException(inputAudioFormat)
        }
        return inputAudioFormat
    }

    override fun queueInput(inputBuffer: java.nio.ByteBuffer) {
        val size = inputBuffer.remaining()
        if (size == 0) return
        val outputBuffer = replaceOutputBuffer(size)
        val input = inputBuffer
            .order(java.nio.ByteOrder.LITTLE_ENDIAN)
            .asShortBuffer()
        val output = outputBuffer
            .order(java.nio.ByteOrder.LITTLE_ENDIAN)
            .asShortBuffer()
        val channels = inputAudioFormat.channelCount.coerceAtLeast(1)
        val sampleRate = inputAudioFormat.sampleRate
        var index = 0
        while (input.hasRemaining()) {
            val frame = framesProcessed + index / channels
            val factor = factorAtFrame(frame, sampleRate)
            val sample = input.get()
            output.put(
                (sample * factor)
                    .toInt()
                    .coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
                    .toShort(),
            )
            index++
        }
        framesProcessed += index / channels
        inputBuffer.position(inputBuffer.limit())
        outputBuffer.flip()
    }

    private fun factorAtFrame(frame: Long, sampleRate: Int): Float {
        var value = gain
        if (sampleRate <= 0) return value.coerceIn(0f, 1f)
        val positionUs = frame * 1_000_000L / sampleRate
        if (fadeInUs > 0 && positionUs < fadeInUs) {
            value *= (positionUs.toDouble() / fadeInUs).toFloat()
        }
        if (fadeOutUs > 0 && durationUs > 0) {
            val remaining = durationUs - positionUs
            if (remaining < fadeOutUs) {
                value *= (remaining.toDouble() / fadeOutUs)
                    .toFloat()
                    .coerceIn(0f, 1f)
            }
        }
        return value.coerceIn(0f, 1f)
    }

    override fun onFlush() {
        framesProcessed = 0
    }

    override fun onReset() {
        framesProcessed = 0
    }
}

/**
 * Fondu depuis/vers le noir (transition « Fondu ») : un bitmap noir plein
 * cadre dont l'alpha suit la courbe de fondu au temps de présentation.
 * Même courbe que l'aperçu Flutter (_fadeOverlayFor) et que le gain audio.
 */
private class FadeOverlay(
    private val durationMs: Long,
    private val fadeInMs: Long,
    private val fadeOutMs: Long,
    private val colorIn: Int = Color.BLACK,
    private val colorOut: Int = Color.BLACK,
) : BitmapOverlay() {
    // Bitmaps immuables par niveau d'alpha (32 pas) : muter un bitmap que
    // le thread GL lit encore provoquait « Release timed out » à l'export.
    private val cache = HashMap<Int, Bitmap>()

    // L'échelle de l'overlay est relative à sa texture (64 px), pas au
    // cadre : sans ce calcul, le fondu n'était qu'un petit carré central
    // dans le fichier exporté (constaté par mesure d'image).
    private var settings: OverlaySettings = StaticOverlaySettings.Builder()
        .setScale(1f, 1f)
        .setOverlayFrameAnchor(0f, 0f)
        .setBackgroundFrameAnchor(0f, 0f)
        .build()

    override fun configure(inputSize: androidx.media3.common.util.Size) {
        super.configure(inputSize)
        settings = StaticOverlaySettings.Builder()
            .setScale(inputSize.width / 64f, inputSize.height / 64f)
            .setOverlayFrameAnchor(0f, 0f)
            .setBackgroundFrameAnchor(0f, 0f)
            .build()
    }

    override fun getBitmap(presentationTimeUs: Long): Bitmap {
        val ms = presentationTimeUs / 1000
        var alpha = 0f
        var color = colorIn
        if (fadeInMs > 0 && ms < fadeInMs) {
            alpha = maxOf(alpha, 1f - ms.toFloat() / fadeInMs)
        }
        val remaining = durationMs - ms
        if (fadeOutMs > 0 && remaining < fadeOutMs) {
            val outAlpha =
                1f - remaining.coerceAtLeast(0).toFloat() / fadeOutMs
            if (outAlpha > alpha) {
                alpha = outAlpha
                color = colorOut
            }
        }
        val level = (alpha * 32).toInt().coerceIn(0, 32)
        val key = level * 2 + if (color == Color.WHITE) 1 else 0
        return cache.getOrPut(key) {
            Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888).apply {
                eraseColor(
                    Color.argb(
                        (level * 255 / 32),
                        Color.red(color),
                        Color.green(color),
                        Color.blue(color),
                    ),
                )
            }
        }
    }

    override fun getOverlaySettings(presentationTimeUs: Long): OverlaySettings =
        settings
}

/**
 * Zoom animé (Ken Burns) : échelle progressive du cadre sur la durée du
 * clip, centrée. Même courbe que l'aperçu Flutter (Transform.scale).
 */
private class ZoomTransformation(
    private val durationMs: Long,
    private val fromScale: Float,
    private val toScale: Float,
) : androidx.media3.effect.MatrixTransformation {
    override fun getMatrix(presentationTimeUs: Long): android.graphics.Matrix {
        val fraction = if (durationMs <= 0) {
            0f
        } else {
            (presentationTimeUs / 1000f / durationMs).coerceIn(0f, 1f)
        }
        val scale = fromScale + (toScale - fromScale) * fraction
        return android.graphics.Matrix().apply {
            setScale(scale, scale, 0.5f, 0.5f)
        }
    }
}

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
    private val cache = HashMap<Int, Bitmap>()
    private val settings = HashMap<Int, OverlaySettings>()

    override fun getBitmap(presentationTimeUs: Long): Bitmap {
        val ms = presentationTimeUs / 1000
        val index = cues.indexOfFirst { ms >= it.startMs && ms < it.endMs }
        if (index < 0) return empty
        cache[index]?.let { return it }
        val bitmap = render(cues[index])
        cache[index] = bitmap
        return bitmap
    }

    /// Le texte est ancré exactement là où l'aperçu le montre (x, y normalisés),
    /// pas au bas du cadre comme un sous-titre.
    override fun getOverlaySettings(presentationTimeUs: Long): OverlaySettings {
        val ms = presentationTimeUs / 1000
        val index = cues.indexOfFirst { ms >= it.startMs && ms < it.endMs }
        if (index < 0) return defaultSettings
        return settings.getOrPut(index) {
            val cue = cues[index]
            StaticOverlaySettings.Builder()
                .setOverlayFrameAnchor(0f, 0f)
                .setBackgroundFrameAnchor(
                    (cue.x * 2f - 1f).coerceIn(-1f, 1f),
                    (1f - cue.y * 2f).coerceIn(-1f, 1f))
                .build()
        }
    }

    private val defaultSettings: OverlaySettings =
        StaticOverlaySettings.Builder()
            .setOverlayFrameAnchor(0f, 0f)
            .setBackgroundFrameAnchor(0f, 0f)
            .build()

    private fun render(cue: SubtitleCue): Bitmap {
        val text = cue.text
        val maxWidth = frameWidth * 0.9f
        // La taille est en dp dans un aperçu large de 360 dp (EDT-03).
        val baseSize = if (cue.size > 0f) {
            frameWidth * cue.size / 360f
        } else {
            frameWidth * 0.045f
        }
        val typeface = Typeface.create(
            Typeface.DEFAULT,
            if (style == "classic") Typeface.NORMAL else Typeface.BOLD)
        val alpha = (cue.opacity.coerceIn(0f, 1f) * 255).toInt()
        val textColor = ((cue.color.toInt() and 0x00FFFFFF) or (alpha shl 24))
        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = textColor
            textSize = baseSize
            this.typeface = typeface
            textAlign = when (cue.align) {
                "left" -> Paint.Align.LEFT
                "right" -> Paint.Align.RIGHT
                else -> Paint.Align.CENTER
            }
            if (!cue.background) {
                setShadowLayer(baseSize * 0.14f, 0f, baseSize * 0.07f, Color.BLACK)
            }
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
        val lineHeight = (metrics.descent - metrics.ascent) * 1.15f
        val pad = if (cue.background) fill.textSize * 0.4f else 0f
        val w = (measured + pad * 2).toInt().coerceAtLeast(1)
        val h = (lineHeight * lines.size + pad * 2)
            .toInt().coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        if (cue.background) {
            val pill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(140, 0, 0, 0)
            }
            canvas.drawRoundRect(
                0f, 0f, w.toFloat(), h.toFloat(),
                h * 0.22f, h * 0.22f, pill)
        }
        val stroke = if (style == "outline") Paint(fill).apply {
            this.style = Paint.Style.STROKE
            strokeWidth = fill.textSize * 0.09f
            strokeCap = Paint.Cap.ROUND
            color = Color.BLACK
        } else null
        val x = when (cue.align) {
            "left" -> pad
            "right" -> w - pad
            else -> w / 2f
        }
        lines.forEachIndexed { i, line ->
            val baseline = pad + (i + 1) * lineHeight - metrics.descent
            stroke?.let { canvas.drawText(line, x, baseline, it) }
            canvas.drawText(line, x, baseline, fill)
        }
        return bitmap
    }
}
