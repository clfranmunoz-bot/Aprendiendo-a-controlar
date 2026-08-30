package com.example.aprender_a_controlar

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.aprender_a_controlar/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImage") {
                val imagePath = call.argument<String>("path")
                if (imagePath != null) {
                    val success = saveImageToGallery(this, imagePath)
                    if (success) {
                        result.success(true)
                    } else {
                        result.error("SAVE_FAILED", "Failed to save image to gallery", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Image path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(context: Context, imagePath: String): Boolean {
        val file = File(imagePath)
        if (!file.exists()) return false

        val filename = "Bandeja_${System.currentTimeMillis()}.jpg"
        var outputStream: OutputStream? = null
        var imageUri: Uri? = null

        try {
            val contentResolver = context.contentResolver
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, filename)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/AprenderAControlar")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
            }

            imageUri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            if (imageUri == null) return false

            outputStream = contentResolver.openOutputStream(imageUri)
            if (outputStream == null) return false

            val inputStream = FileInputStream(file)
            val buffer = ByteArray(1024)
            var bytesRead: Int
            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                outputStream.write(buffer, 0, bytesRead)
            }
            inputStream.close()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
                contentResolver.update(imageUri, contentValues, null, null)
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            if (imageUri != null) {
                try {
                    context.contentResolver.delete(imageUri, null, null)
                } catch (ignored: Exception) {}
            }
            return false
        } finally {
            outputStream?.close()
        }
    }
}
