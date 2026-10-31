package com.graceedit.graceedit

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaCodecList
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StatFs
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Capacités réelles de l'appareil et actions système. Aucune donnée n'est
 * envoyée : tout est calculé localement.
 *
 * Chaîne graceedit/system.
 */
class SystemPlugin(
    private val activity: ComponentActivity,
    engine: FlutterEngine,
) {
    private var pendingPermission: MethodChannel.Result? = null

    private val permissionLauncher =
        activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) {
            val callback = pendingPermission
            pendingPermission = null
            callback?.success(notificationsAllowed())
        }

    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "graceedit/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "storage" -> result.success(storageInfo())
                    "capabilities" -> result.success(capabilities())
                    "notificationsAllowed" -> result.success(notificationsAllowed())
                    "requestNotifications" -> requestNotifications(result)
                    "openGallery" -> {
                        val raw = call.argument<String>("uri")
                        if (raw == null) {
                            result.error("BAD_ARGS", "uri requis", null)
                        } else {
                            try {
                                openGallery(Uri.parse(raw))
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("NO_VIEWER", e.message, null)
                            }
                        }
                    }
                    "openAppSettings" -> {
                        activity.startActivity(
                            Intent(
                                android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", activity.packageName, null),
                            ),
                        )
                        result.success(true)
                    }
                    "copyImage" -> {
                        val raw = call.argument<String>("uri")
                        val outPath = call.argument<String>("outPath")
                        val maxWidth = call.argument<Int>("maxWidth") ?: 1280
                        if (raw == null || outPath == null) {
                            result.error("BAD_ARGS", "uri et outPath requis", null)
                        } else {
                            try {
                                result.success(copyImage(Uri.parse(raw), outPath, maxWidth))
                            } catch (e: Exception) {
                                android.util.Log.e("GraceEdit", "copyImage $raw -> $outPath", e)
                                result.error("COPY_FAILED", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun storageInfo(): Map<String, Any> {
        val stat = StatFs(Environment.getExternalStorageDirectory().absolutePath)
        return mapOf(
            "freeBytes" to stat.availableBytes,
            "totalBytes" to stat.totalBytes,
        )
    }

    private fun capabilities(): Map<String, Any> {
        var supports1080p = false
        try {
            val codecs = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            for (info in codecs.codecInfos) {
                if (!info.isEncoder) continue
                if (info.supportedTypes.none { it.startsWith("video/") }) continue
                val caps = try {
                    info.getCapabilitiesForType("video/avc")
                } catch (_: Exception) {
                    continue
                }
                val video = caps.videoCapabilities ?: continue
                if (video.isSizeSupported(1920, 1080)) {
                    supports1080p = true
                    break
                }
            }
        } catch (_: Exception) {
            // Appareil sans encodeur interrogeable : qualité Standard only.
        }
        return mapOf(
            "supports1080p" to supports1080p,
            "sdkInt" to Build.VERSION.SDK_INT,
            "deviceModel" to "${Build.MANUFACTURER} ${Build.MODEL}".trim(),
        )
    }

    private fun notificationsAllowed(): Boolean =
        NotificationManagerCompat.from(activity).areNotificationsEnabled()

    private fun requestNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(notificationsAllowed())
            return
        }
        if (notificationsAllowed()) {
            result.success(true)
            return
        }
        if (pendingPermission != null) {
            result.error("BUSY", "Demande déjà en cours.", null)
            return
        }
        pendingPermission = result
        try {
            permissionLauncher.launch("android.permission.POST_NOTIFICATIONS")
        } catch (e: Exception) {
            pendingPermission = null
            result.error("REQUEST_FAILED", e.message, null)
        }
    }

    private fun openGallery(uri: Uri) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "video/mp4")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        activity.startActivity(intent)
    }

    /** Copie une image choisie dans le projet, réduite à [maxWidth]. */
    private fun copyImage(uri: Uri, outPath: String, maxWidth: Int): String {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        // Le décodage des bornes renvoie toujours un bitmap null : tester le
        // résultat de `use` revenait à rejeter toutes les images.
        val boundsStream = activity.contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("Image illisible.")
        boundsStream.use { BitmapFactory.decodeStream(it, null, bounds) }
        if (bounds.outWidth <= 0) throw IllegalStateException("Image illisible.")

        var sample = 1
        while (bounds.outWidth / (sample * 2) >= maxWidth) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        var decoded: Bitmap = activity.contentResolver.openInputStream(uri)?.use {
            BitmapFactory.decodeStream(it, null, options)
        } ?: decodeWithImageDecoder(uri, maxWidth)
        ?: throw IllegalStateException("Image illisible.")

        // Orientation EXIF : sans elle, une photo portrait choisie en
        // couverture s'affichait couchée (HEIC des appareils récents
        // notamment, que BitmapFactory décode sans appliquer la rotation).
        val oriented = applyExifOrientation(uri, decoded)
        if (oriented !== decoded) {
            decoded.recycle()
            decoded = oriented
        }

        val scaled = if (decoded.width > maxWidth) {
            val ratio = maxWidth.toFloat() / decoded.width
            Bitmap.createScaledBitmap(
                decoded,
                maxWidth,
                (decoded.height * ratio).toInt().coerceAtLeast(1),
                true,
            )
        } else {
            decoded
        }
        File(outPath).parentFile?.mkdirs()
        FileOutputStream(File(outPath)).use { output ->
            scaled.compress(Bitmap.CompressFormat.JPEG, 90, output)
        }
        if (scaled !== decoded) decoded.recycle()
        scaled.recycle()
        return outPath
    }

    /** Repli API 28+ quand BitmapFactory ne sait pas décoder le format. */
    private fun decodeWithImageDecoder(uri: Uri, maxWidth: Int): Bitmap? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return null
        return try {
            val source = android.graphics.ImageDecoder.createSource(
                activity.contentResolver,
                uri,
            )
            android.graphics.ImageDecoder.decodeBitmap(source) { decoder, info, _ ->
                val size = info.size
                if (size.width > maxWidth) {
                    val ratio = maxWidth.toFloat() / size.width
                    decoder.setTargetSize(
                        maxWidth,
                        (size.height * ratio).toInt().coerceAtLeast(1),
                    )
                }
                decoder.allocator = android.graphics.ImageDecoder.ALLOCATOR_SOFTWARE
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun applyExifOrientation(uri: Uri, bitmap: Bitmap): Bitmap {
        val orientation = try {
            activity.contentResolver.openInputStream(uri)?.use { stream ->
                android.media.ExifInterface(stream).getAttributeInt(
                    android.media.ExifInterface.TAG_ORIENTATION,
                    android.media.ExifInterface.ORIENTATION_NORMAL,
                )
            } ?: android.media.ExifInterface.ORIENTATION_NORMAL
        } catch (_: Exception) {
            android.media.ExifInterface.ORIENTATION_NORMAL
        }
        val matrix = android.graphics.Matrix()
        when (orientation) {
            android.media.ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            android.media.ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            android.media.ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            android.media.ExifInterface.ORIENTATION_FLIP_HORIZONTAL ->
                matrix.postScale(-1f, 1f)
            android.media.ExifInterface.ORIENTATION_FLIP_VERTICAL ->
                matrix.postScale(1f, -1f)
            android.media.ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            android.media.ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.postScale(-1f, 1f)
            }
            else -> return bitmap
        }
        return try {
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (_: Exception) {
            bitmap
        }
    }
}
