package com.graceedit.graceedit

import android.content.Context
import android.graphics.Bitmap
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * Native thumbnail and waveform provider.
 *
 * Channel: graceedit/thumbnails
 *  - frame(path, timeMs, maxWidth, outPath) -> outPath?
 *  - waveform(path, buckets) -> List<Double>
 *
 * The heavy media work runs on a dedicated background thread: the platform
 * method-channel handler is otherwise executed on the UI thread, which caused
 * "Application Not Responding" while decoding frames.
 */
class ThumbnailPlugin(
    private val context: Context,
    engine: FlutterEngine,
) {
    // Deux files séparées : le décodage complet d'une waveform (jusqu'à
    // 15 s) ne doit jamais bloquer l'extraction des vignettes.
    private val frameWorker = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "graceedit-thumbnails").apply { isDaemon = true }
    }
    private val waveWorker = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "graceedit-waveforms").apply { isDaemon = true }
    }
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "graceedit/thumbnails")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "frame" -> {
                        val path = call.argument<String>("path")
                        val timeMs = (call.argument<Int>("timeMs") ?: 1000).toLong()
                        val maxWidth = call.argument<Int>("maxWidth") ?: 320
                        val outPath = call.argument<String>("outPath")
                        if (path == null || outPath == null) {
                            result.error("BAD_ARGS", "path and outPath required", null)
                            return@setMethodCallHandler
                        }
                        frameWorker.execute {
                            try {
                                val out = extractFrame(path, timeMs * 1000L, maxWidth, outPath)
                                mainHandler.post {
                                    if (out != null) {
                                        result.success(out)
                                    } else {
                                        result.error(
                                            "NO_FRAME",
                                            "Could not extract frame from $path",
                                            null,
                                        )
                                    }
                                }
                            } catch (e: Exception) {
                                mainHandler.post {
                                    result.error("EXTRACT_FAILED", e.message, null)
                                }
                            }
                        }
                    }

                    "waveform" -> {
                        val path = call.argument<String>("path")
                        val buckets = (call.argument<Int>("buckets") ?: 120)
                            .coerceIn(8, 512)
                        if (path == null) {
                            result.error("BAD_ARGS", "path required", null)
                            return@setMethodCallHandler
                        }
                        waveWorker.execute {
                            try {
                                val values = extractWaveform(path, buckets)
                                Log.d(
                                    "GraceEdit",
                                    "waveform $path -> ${values.size} valeurs",
                                )
                                mainHandler.post { result.success(values) }
                            } catch (e: Exception) {
                                Log.w("GraceEdit", "waveform échouée pour $path", e)
                                mainHandler.post {
                                    result.error("WAVEFORM_FAILED", e.message, null)
                                }
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ------------------------------------------------------------------ frame

    private fun extractFrame(
        path: String,
        timeUs: Long,
        maxWidth: Int,
        outPath: String,
    ): String? {
        val retriever = MediaMetadataRetriever()
        try {
            setDataSource(retriever, path)
            // Décoder directement à la taille d'affichage évite de décoder une
            // image 1080p puis de la réduire : sur un appareil modeste, cela
            // divise le temps d'extraction par plusieurs.
            val srcWidth = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                ?.toIntOrNull() ?: 0
            val srcHeight = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                ?.toIntOrNull() ?: 0
            val rotation = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                ?.toIntOrNull() ?: 0
            val orientedWidth = if (rotation == 90 || rotation == 270) {
                srcHeight
            } else {
                srcWidth
            }
            val orientedHeight = if (rotation == 90 || rotation == 270) {
                srcWidth
            } else {
                srcHeight
            }
            val dstWidth = if (orientedWidth > 0) {
                min(maxWidth, orientedWidth)
            } else {
                maxWidth
            }
            val dstHeight = if (orientedWidth > 0 && orientedHeight > 0) {
                max(
                    1,
                    (orientedHeight.toDouble() * dstWidth / orientedWidth).toInt(),
                )
            } else {
                0
            }
            val raw: Bitmap = if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1 &&
                dstHeight > 0
            ) {
                retriever.getScaledFrameAtTime(
                    timeUs,
                    MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                    dstWidth,
                    dstHeight,
                )
            } else {
                retriever.getFrameAtTime(
                    timeUs,
                    MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                )
            } ?: return null
            val scaled: Bitmap = if (raw.width > maxWidth) {
                val ratio = maxWidth.toFloat() / raw.width.toFloat()
                Bitmap.createScaledBitmap(
                    raw,
                    maxWidth,
                    max(1, (raw.height * ratio).toInt()),
                    true,
                )
            } else {
                raw
            }
            val out = File(outPath)
            out.parentFile?.mkdirs()
            FileOutputStream(out).use { stream ->
                scaled.compress(Bitmap.CompressFormat.JPEG, 75, stream)
            }
            if (scaled !== raw) raw.recycle()
            return outPath
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
                // Rien à faire : le libérer ne doit jamais masquer l'erreur réelle.
            }
        }
    }

    // --------------------------------------------------------------- waveform

    /**
     * Decodes the first audio track and returns [buckets] RMS amplitudes in
     * 0..1. Returns an empty list when the media has no audio track.
     */
    private fun extractWaveform(path: String, buckets: Int): List<Double> {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        try {
            setDataSource(extractor, path)
            var audioTrack = -1
            var format: MediaFormat? = null
            for (i in 0 until extractor.trackCount) {
                val candidate = extractor.getTrackFormat(i)
                val mime = candidate.getString(MediaFormat.KEY_MIME) ?: continue
                if (mime.startsWith("audio/")) {
                    audioTrack = i
                    format = candidate
                    break
                }
            }
            if (audioTrack < 0 || format == null) {
                Log.d(
                    "GraceEdit",
                    "waveform: aucune piste audio dans $path " +
                        "(${extractor.trackCount} pistes)",
                )
                return emptyList()
            }

            val durationUs = if (format.containsKey(MediaFormat.KEY_DURATION)) {
                format.getLong(MediaFormat.KEY_DURATION)
            } else {
                0L
            }
            extractor.selectTrack(audioTrack)

            val mime = format.getString(MediaFormat.KEY_MIME) ?: return emptyList()
            // Le PCM (WAV) n'a pas besoin de MediaCodec : le décodeur « raw »
            // de l'émulateur échoue sur certaines configurations et renvoie
            // une waveform plate. On lit directement les échantillons.
            if (mime == "audio/raw") {
                return extractPcmWaveform(extractor, format, buckets, durationUs)
            }
            codec = MediaCodec.createDecoderByType(mime)
            codec.configure(format, null, null, 0)
            codec.start()

            val sums = DoubleArray(buckets)
            val counts = IntArray(buckets)
            var maxTimeUs = 0L
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false
            val deadline = System.currentTimeMillis() + 15_000

            while (!outputDone && System.currentTimeMillis() < deadline) {
                if (!inputDone) {
                    val inIndex = codec.dequeueInputBuffer(10_000)
                    if (inIndex >= 0) {
                        val buffer = codec.getInputBuffer(inIndex) ?: ByteBuffer.allocate(0)
                        val size = extractor.readSampleData(buffer, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(
                                inIndex,
                                0,
                                0,
                                0,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                            )
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(
                                inIndex,
                                0,
                                size,
                                extractor.sampleTime,
                                0,
                            )
                            extractor.advance()
                        }
                    }
                }

                val outIndex = codec.dequeueOutputBuffer(info, 10_000)
                if (outIndex >= 0) {
                    val buffer = codec.getOutputBuffer(outIndex)
                    if (buffer != null && info.size > 0) {
                        buffer.position(info.offset)
                        buffer.limit(info.offset + info.size)
                        val samples = buffer.order(ByteOrder.LITTLE_ENDIAN).asShortBuffer()
                        val timeUs = if (info.presentationTimeUs > 0) {
                            info.presentationTimeUs
                        } else {
                            maxTimeUs
                        }
                        maxTimeUs = max(maxTimeUs, timeUs)
                        val total = if (durationUs > 0) durationUs else maxTimeUs
                        var bucket = if (total > 0) {
                            ((timeUs.toDouble() / total) * buckets).toInt()
                        } else {
                            0
                        }
                        if (bucket >= buckets) bucket = buckets - 1
                        if (bucket < 0) bucket = 0
                        var sum = 0.0
                        var count = 0
                        while (samples.hasRemaining()) {
                            val sample = samples.get().toDouble() / Short.MAX_VALUE
                            sum += sample * sample
                            count++
                        }
                        if (count > 0) {
                            sums[bucket] += sum
                            counts[bucket] += count
                        }
                    }
                    codec.releaseOutputBuffer(outIndex, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        outputDone = true
                    }
                } else if (outIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    // Rien à faire : le format de sortie PCM est déjà exploitable.
                }
            }

            val rms = DoubleArray(buckets) { i ->
                if (counts[i] == 0) 0.0 else sqrt(sums[i] / counts[i])
            }
            val peak = rms.maxOrNull() ?: 0.0
            if (peak <= 0.0) return List(buckets) { 0.0 }
            return rms.map { (it / peak).coerceIn(0.0, 1.0) }
        } finally {
            try {
                codec?.stop()
            } catch (_: Exception) {
                // Le codec peut déjà être arrêté : on continue la libération.
            }
            try {
                codec?.release()
            } catch (_: Exception) {
                // Idem.
            }
            extractor.release()
        }
    }

    /**
     * Calcule la waveform d'une piste PCM brute (WAV) sans passer par un
     * décodeur : MediaExtractor fournit directement les échantillons.
     */
    private fun extractPcmWaveform(
        extractor: MediaExtractor,
        format: MediaFormat,
        buckets: Int,
        durationUs: Long,
    ): List<Double> {
        val encoding = if (format.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
            format.getInteger(MediaFormat.KEY_PCM_ENCODING)
        } else {
            AudioFormat.ENCODING_PCM_16BIT
        }
        val sums = DoubleArray(buckets)
        val counts = IntArray(buckets)
        val buffer = ByteBuffer.allocate(256 * 1024).order(ByteOrder.LITTLE_ENDIAN)
        var lastTimeUs = 0L
        // Même garde-fou que le décodage MediaCodec : un fichier PCM
        // démesuré ne doit pas monopoliser la file des waveforms.
        val deadline = System.currentTimeMillis() + 15_000
        while (System.currentTimeMillis() < deadline) {
            buffer.clear()
            val size = extractor.readSampleData(buffer, 0)
            if (size < 0) break
            val timeUs = extractor.sampleTime
            if (timeUs > lastTimeUs) lastTimeUs = timeUs
            buffer.position(0)
            buffer.limit(size)
            val total = if (durationUs > 0) durationUs else lastTimeUs + 1
            var bucket = ((timeUs.toDouble() / total) * buckets).toInt()
            if (bucket >= buckets) bucket = buckets - 1
            if (bucket < 0) bucket = 0

            var sum = 0.0
            var count = 0
            when (encoding) {
                AudioFormat.ENCODING_PCM_FLOAT -> {
                    val floats = buffer.asFloatBuffer()
                    while (floats.hasRemaining()) {
                        val sample = floats.get().toDouble()
                        sum += sample * sample
                        count++
                    }
                }

                AudioFormat.ENCODING_PCM_8BIT -> {
                    while (buffer.hasRemaining()) {
                        val sample = ((buffer.get().toInt() and 0xFF) - 128) / 128.0
                        sum += sample * sample
                        count++
                    }
                }

                else -> {
                    val shorts = buffer.asShortBuffer()
                    while (shorts.hasRemaining()) {
                        val sample = shorts.get().toDouble() / Short.MAX_VALUE
                        sum += sample * sample
                        count++
                    }
                }
            }
            if (count > 0) {
                sums[bucket] += sum
                counts[bucket] += count
            }
            extractor.advance()
        }

        val rms = DoubleArray(buckets) { i ->
            if (counts[i] == 0) 0.0 else sqrt(sums[i] / counts[i])
        }
        val peak = rms.maxOrNull() ?: 0.0
        if (peak <= 0.0) return List(buckets) { 0.0 }
        return rms.map { (it / peak).coerceIn(0.0, 1.0) }
    }

    // ------------------------------------------------------------------ source

    private fun setDataSource(retriever: MediaMetadataRetriever, path: String) {
        if (path.startsWith("content://") || path.startsWith("file://")) {
            retriever.setDataSource(context, Uri.parse(path))
        } else {
            retriever.setDataSource(path)
        }
    }

    private fun setDataSource(extractor: MediaExtractor, path: String) {
        if (path.startsWith("content://") || path.startsWith("file://")) {
            extractor.setDataSource(context, Uri.parse(path), null)
        } else {
            extractor.setDataSource(path)
        }
    }
}
