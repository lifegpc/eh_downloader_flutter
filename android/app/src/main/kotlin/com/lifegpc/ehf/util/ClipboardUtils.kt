package com.lifegpc.ehf.util

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
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
        grantUriPermissionWhenNeed(uri)
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

    /**
     * 在 Android 8/8.1系统上，手动授予所有app读取uri权限
     * @param uri
     * @see <a href="https://github.com/chromium/chromium/blob/a5a4f9bfe95e3dcd685c20192b244e0a7e6c1c06/ui/android/java/src/org/chromium/ui/base/ClipboardImpl.java">chromium</a> 中的 grantUriPermission
     */
    private fun grantUriPermissionWhenNeed(uri: Uri) {
        if (Build.VERSION.SDK_INT !in arrayOf(Build.VERSION_CODES.O, Build.VERSION_CODES.O_MR1)) {
            return
        }

        @Suppress("DEPRECATION")
        MyApplication.applicationContext.packageManager.getInstalledPackages(0).forEach {
            MyApplication.applicationContext.grantUriPermission(
                it.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        }

    }
}