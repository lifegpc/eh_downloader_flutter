package com.lifegpc.ehf.platform

import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import com.anggrayudi.storage.file.makeFile
import com.anggrayudi.storage.file.openOutputStream
import com.lifegpc.ehf.MainActivity
import com.lifegpc.ehf.annotation.ChannelMethod
import com.lifegpc.ehf.data.mmkv.SAFSettings
import com.lifegpc.ehf.eventbus.SAFAuthEvent
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe

class SAFPlugin(private val activity: MainActivity) {
    private var safAuthorizationResult: MethodChannel.Result? = null
    private val fdMap = mutableMapOf<Int, DocumentFile>()
    private var onSAFAuthSuccess: (() -> Unit)? = null
    private var onSAFAuthFailed: (() -> Unit)? = null

    companion object {
        const val safAuthorizationCode = 0x10086
    }

    init {
        EventBus.getDefault().register(this)
    }

    @Subscribe
    @Suppress("unused")
    fun onSAFAuthResult(event: SAFAuthEvent) {
        if (!event.success) {
            onSAFAuthFailed?.invoke()
            onSAFAuthFailed = null
            return
        }

        val data = event.data!!
        val authUri = data.data!!
        saveSAFPermission(authUri)
        onSAFAuthSuccess?.invoke()
        onSAFAuthSuccess = null
    }

    @ChannelMethod(responseManually = true)
    @Suppress("unused")
    private fun saveFile(
        channelResult: MethodChannel.Result,
        filename: String,
        dir: String,
        mimeType: String,
        content: ByteArray
    ) {
        this.safAuthorizationResult = channelResult
        if (!checkSafPermission()) {
            onSAFAuthSuccess = {
                doWriteFile(filename, dir, mimeType, content)
                channelResult.success(null)
            }
            onSAFAuthFailed = {
                channelResult.error("Permission denied", null, null)
            }
            authSAF()
        } else {
            doWriteFile(filename, dir, mimeType, content)
            channelResult.success(null)
        }
    }

    @ChannelMethod(responseManually = true)
    @Suppress("unused")
    private fun openFile(
        channelResult: MethodChannel.Result,
        filenameWithoutExtension: String,
        dir: String,
        mimeType: String,
    ) {
        if (!checkSafPermission()) {
            onSAFAuthSuccess = {
                channelResult.success(doOpenFile(filenameWithoutExtension, mimeType, dir))
            }
            onSAFAuthFailed = {
                channelResult.error("Permission denied", null, null)
            }
            authSAF()
        } else {
            channelResult.success(doOpenFile(filenameWithoutExtension, mimeType, dir))
        }
    }

    private fun doOpenFile(filenameWithoutExtension: String, mimeType: String, dir: String): Int {
        var documentFile =
            DocumentFile.fromTreeUri(activity, Uri.parse(SAFSettings.authorizedUri))!!
        documentFile = createFileRecursively(documentFile, dir)

        val f = documentFile.makeFile(activity, filenameWithoutExtension, mimeType)!!

        val id = f.hashCode()
        fdMap[id] = f
        return id
    }

    /**
     * 写入文件
     * @param id Int
     * @param bytes ByteArray
     * @return Int 写入的字节数
     */
    @ChannelMethod
    @Suppress("unused")
    private fun writeFile(id: Int, bytes: ByteArray, append: Boolean): Int {
        val f = fdMap[id]!!
        f.openOutputStream(activity, append)!!.use {
            it.write(bytes)
        }
        return bytes.size
    }

    @ChannelMethod
    @Suppress("unused")
    private fun closeFile(id: Int) {
        fdMap.remove(id)
    }

    private fun createFileRecursively(base: DocumentFile, dir: String): DocumentFile {
        var file = base
        val pathPart = dir.split('/', '\\')
        pathPart.forEach {
            if (it.isNotEmpty()) {
                file = file.createDirectory(it)!!
            }
        }
        return file
    }

    /**
     * 写入文件
     * @param filename String
     * @param dir String
     * @param mimeType String
     * @param content ByteArray
     */
    private fun doWriteFile(filename: String, dir: String, mimeType: String, content: ByteArray) {
        var documentDir = DocumentFile.fromTreeUri(activity, Uri.parse(SAFSettings.authorizedUri))!!
        documentDir = createFileRecursively(documentDir, dir)

        val filenameWithoutExtension = if (filename.indexOf('.') != -1) {
            filename.substring(0, filename.lastIndexOf('.'))
        } else {
            filename
        }
        val file = documentDir.createFile(mimeType, filenameWithoutExtension)!!
        val uri = file.uri
        activity.contentResolver.openOutputStream(uri)!!.use {
            it.write(content)
        }
    }

    private fun authSAF() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        activity.startActivityForResult(intent, safAuthorizationCode)
    }

    // 保存权限
    private fun saveSAFPermission(uri: Uri) {
        val takeFlags =
            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        activity.contentResolver.takePersistableUriPermission(uri, takeFlags)
        SAFSettings.authorizedUri = uri.toString()
    }

    private fun checkSafPermission(): Boolean {
        val dir = SAFSettings.authorizedUri
        if (dir.isBlank()) return false

        val uri = Uri.parse(dir)

        return try {
            val flags =
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity.contentResolver.takePersistableUriPermission(uri, flags)
            DocumentFile.fromTreeUri(activity, uri)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}