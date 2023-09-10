package com.lifegpc.ehf.util

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.core.content.FileProvider
import com.lifegpc.ehf.MyApplication
import com.lifegpc.ehf.annotation.ChannelMethod
import java.io.File
import java.util.UUID

object ClipboardUtils {
    private const val AUTHORITY = "com.lifegpc.ehf.ClipboardImageProvider"

    @ChannelMethod
    fun copyImageToClipboard(mimeType: String, byteArray: ByteArray) {
        val file = saveToImageCache(mimeType, byteArray)
        val uri = FileProvider.getUriForFile(MyApplication.applicationContext, AUTHORITY, file)

        val cbm =
            MyApplication.applicationContext.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clipData =
            ClipData.newUri(MyApplication.applicationContext.contentResolver, "image", uri)
        cbm.setPrimaryClip(clipData)
    }

    private fun saveToImageCache(mimeType: String, byteArray: ByteArray): File {
        val dir = File(MyApplication.applicationContext.cacheDir, "images")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        val name = UUID.randomUUID().toString()

        val file = File(dir, "$name.${mimeTypeToExtName(mimeType)}")

        file.outputStream().use {
            it.write(byteArray)
        }

        return file
    }

    private fun mimeTypeToExtName(mimeType: String) = when (mimeType) {
        "image/png" -> "png"
        "image/jpeg" -> "jpeg"
        "image/gif" -> "gif"
        else -> throw IllegalArgumentException("$mimeType is not supported")
    }
}