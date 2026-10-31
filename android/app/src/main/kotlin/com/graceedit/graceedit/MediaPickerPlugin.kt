package com.graceedit.graceedit

import android.content.Intent
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

/**
 * Sélecteur du système uniquement (ACTION_OPEN_DOCUMENT) : aucun balayage du
 * stockage, aucune permission de médias, aucune copie des fichiers choisis.
 * Les URIs sont persistables pour que les projets les retrouvent au relancement.
 *
 * Chaîne graceedit/picker :
 *  - pick{kind: video|audio|image, multiple} -> [média]
 *  - describe{uri} -> média | null
 */
class MediaPickerPlugin(
    private val activity: ComponentActivity,
    engine: FlutterEngine,
) {
    private var pending: MethodChannel.Result? = null
    private var pendingKind = "video"

    private val launcher =
        activity.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            val callback = pending ?: return@registerForActivityResult
            pending = null
            if (result.resultCode != ComponentActivity.RESULT_OK) {
                callback.success(emptyList<Map<String, Any?>>())
                return@registerForActivityResult
            }
            val intent = result.data
            val uris = mutableListOf<Uri>()
            if (intent != null) {
                val clip = intent.clipData
                if (clip != null) {
                    for (index in 0 until clip.itemCount) {
                        clip.getItemAt(index).uri?.let { uris.add(it) }
                    }
                } else {
                    intent.data?.let { uris.add(it) }
                }
            }
            val described = mutableListOf<Map<String, Any?>>()
            for (uri in uris) {
                // Le droit de lecture survit aux redémarrages : le projet
                // référence le fichier sans jamais le copier.
                try {
                    activity.contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                } catch (_: SecurityException) {
                    // Certains fournisseurs ne l'accordent pas : on continue,
                    // la lecture reste possible tant que l'URI est valide.
                }
                described.add(describe(uri) ?: unsupported(uri))
            }
            callback.success(described)
        }

    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "graceedit/picker")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pick" -> {
                        if (pending != null) {
                            result.error("BUSY", "Un sélecteur est déjà ouvert.", null)
                            return@setMethodCallHandler
                        }
                        pendingKind = call.argument<String>("kind") ?: "video"
                        val multiple = call.argument<Boolean>("multiple") ?: true
                        pending = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = when (pendingKind) {
                                "audio" -> "audio/*"
                                "image" -> "image/*"
                                else -> "video/*"
                            }
                            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
                            addFlags(
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                            )
                        }
                        try {
                            launcher.launch(intent)
                        } catch (e: Exception) {
                            pending = null
                            result.error(
                                "NO_PICKER",
                                e.message ?: "Aucun sélecteur de fichiers disponible.",
                                null,
                            )
                        }
                    }
                    "describe" -> {
                        val raw = call.argument<String>("uri")
                        if (raw == null) {
                            result.error("BAD_ARGS", "uri requis", null)
                        } else {
                            try {
                                result.success(describe(Uri.parse(raw)))
                            } catch (e: Exception) {
                                result.error("UNREADABLE", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun unsupported(uri: Uri): Map<String, Any?> = mapOf(
        "uri" to uri.toString(),
        "name" to (displayName(uri) ?: uri.lastPathSegment ?: ""),
        "mimeType" to (activity.contentResolver.getType(uri) ?: ""),
        "sizeBytes" to (sizeOf(uri) ?: 0L),
        "durationMs" to 0,
        "width" to 0,
        "height" to 0,
        "supported" to false,
    )

    private fun displayName(uri: Uri): String? {
        if (uri.scheme != "content") return uri.lastPathSegment
        return try {
            activity.contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getString(0) else null
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun sizeOf(uri: Uri): Long? {
        if (uri.scheme != "content") return null
        return try {
            activity.contentResolver.query(
                uri,
                arrayOf(OpenableColumns.SIZE),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getLong(0) else null
            }
        } catch (_: Exception) {
            null
        }
    }

    /**
     * Type effectif du média. Certains fournisseurs (nuages, gestionnaires
     * de fichiers) renvoient un type vide ou `application/octet-stream`
     * pour des images parfaitement lisibles (HEIC, AVIF, WebP…) : on se
     * rabat alors sur l'extension du nom, puis sur le décodage lui-même.
     */
    private fun effectiveMime(uri: Uri, name: String, raw: String): String {
        if (raw.isNotEmpty() && raw != "application/octet-stream") return raw
        val extension = name.substringAfterLast('.', "").lowercase()
        val byExtension = android.webkit.MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(extension)
        return byExtension ?: raw
    }

    /** Métadonnées réelles du média ; null si le fichier est illisible. */
    private fun describe(uri: Uri): Map<String, Any?>? {
        val name = displayName(uri) ?: uri.lastPathSegment ?: ""
        var mime = effectiveMime(uri, name, activity.contentResolver.getType(uri) ?: "")
        var durationMs = 0L
        var width = 0
        var height = 0
        var capturedAt: Long? = null

        // Une image se reconnaît à son décodage, pas seulement à son type
        // déclaré : c'est ce qui rejetait les formats dont le fournisseur
        // n'annonçait pas le MIME.
        val looksImage = mime.startsWith("image/") ||
            !(mime.startsWith("video/") || mime.startsWith("audio/"))
        if (looksImage) {
            var decodedMime: String? = null
            try {
                val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                activity.contentResolver.openInputStream(uri)?.use {
                    BitmapFactory.decodeStream(it, null, options)
                }
                width = options.outWidth
                height = options.outHeight
                decodedMime = options.outMimeType
            } catch (_: Exception) {
                width = 0
                height = 0
            }
            if (width > 0 && height > 0) {
                if (!mime.startsWith("image/") && !decodedMime.isNullOrEmpty()) {
                    mime = decodedMime
                }
                return mediaMap(uri, name, mime, 0L, width, height, null)
            }
            if (mime.startsWith("image/")) return null
        }
        run {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(activity, uri)
                durationMs = retriever
                    .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                    ?.toLongOrNull() ?: 0L
                width = retriever
                    .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                    ?.toIntOrNull() ?: 0
                height = retriever
                    .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                    ?.toIntOrNull() ?: 0
                val rotation = retriever
                    .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                    ?.toIntOrNull() ?: 0
                if (rotation == 90 || rotation == 270) {
                    val swap = width
                    width = height
                    height = swap
                }
                capturedAt = parseDate(
                    retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE),
                )
            } catch (_: Exception) {
                return null
            } finally {
                try {
                    retriever.release()
                } catch (_: Exception) {
                }
            }
            if (durationMs <= 0) return null
        }

        // Type toujours inconnu mais métadonnées réelles : la présence
        // d'une image tranche entre vidéo et audio.
        if (!mime.startsWith("video/") && !mime.startsWith("audio/")) {
            mime = if (width > 0 && height > 0) "video/mp4" else "audio/mpeg"
        }
        return mediaMap(uri, name, mime, durationMs, width, height, capturedAt)
    }

    private fun mediaMap(
        uri: Uri,
        name: String,
        mime: String,
        durationMs: Long,
        width: Int,
        height: Int,
        capturedAt: Long?,
    ): Map<String, Any?> {
        val supported = mime.startsWith("video/") ||
            mime.startsWith("audio/") ||
            mime.startsWith("image/")
        return mapOf(
            "uri" to uri.toString(),
            "name" to name,
            "mimeType" to mime,
            "sizeBytes" to (sizeOf(uri) ?: 0L),
            "durationMs" to durationMs,
            "width" to width,
            "height" to height,
            "capturedAt" to capturedAt,
            "supported" to supported,
        )
    }

    private fun parseDate(raw: String?): Long? {
        if (raw.isNullOrBlank()) return null
        val time = try {
            val format = SimpleDateFormat("yyyyMMdd'T'HHmmss.SSS'Z'", Locale.US)
            format.timeZone = TimeZone.getTimeZone("UTC")
            format.parse(raw)?.time
        } catch (_: Exception) {
            null
        } ?: return null
        // Sans date, certains fichiers renvoient l'époque CoreMedia
        // (1er janvier 1904) : ce n'est pas une date réelle, on ne l'affiche
        // pas. Une date dans le futur n'en est pas une non plus.
        val plausible = time >= 946684800000L && time <= System.currentTimeMillis() + 86_400_000L
        return if (plausible) time else null
    }
}
