package com.lifegpc.ehf

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.documentfile.provider.DocumentFile
import com.lifegpc.ehf.annotation.ChannelMethod
import com.lifegpc.ehf.mmkv.SAFSettings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception

class MainActivity : FlutterActivity() {
    private val safAuthorizationCode = 0x10086
    private var safAuthorizationResult: MethodChannel.Result? = null
    private var afterAuthSuccess:(()->Unit)?=null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannelUtils.registerMethodChannel("lifegpc.eh_downloader_flutter/saf", flutterEngine, this)
    }

    @ChannelMethod(responseManually = true)
    private fun saveFile(
        channelResult: MethodChannel.Result,
        filename: String,
        dir: String,
        mimeType: String,
        content: ByteArray
    ) {
        this.safAuthorizationResult = channelResult
            if (!checkSafPermission()) {
                authSAF(channelResult) {
                    doWriteFile(filename, dir, mimeType, content)
                    channelResult.success(null)
                }
            } else {
                doWriteFile(filename, dir, mimeType,content)
                channelResult.success(null)
            }
    }

    private fun doWriteFile(filename: String, dir: String, mimeType: String, content: ByteArray) {
        var documentDir = DocumentFile.fromTreeUri(this, Uri.parse(SAFSettings.authorizedUri))!!
        val pathPart=dir.split('/','\\')
        pathPart.forEach {
            if (it.isNotEmpty()){
                documentDir = documentDir.createDirectory(it)!!
            }
        }

        val filenameWithoutExtension=if (filename.indexOf('.')!=-1){
            filename.substring(0,filename.lastIndexOf('.'))
        }else{
            filename
        }
        val file=documentDir.createFile(mimeType,filenameWithoutExtension)!!
        val uri=file.uri
        contentResolver.openOutputStream(uri)!!.use {
            it.write(content)
        }
    }

    private fun authSAF(result: MethodChannel.Result,onSuccess:(()->Unit)?=null) {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        startActivityForResult(intent, safAuthorizationCode)
        safAuthorizationResult = result
        this.afterAuthSuccess=onSuccess
    }

    private fun onSafAuthSuccess(data: Intent) {
        // 保存权限
        val resultData = data.data!!
        val takeFlags =
            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        contentResolver.takePersistableUriPermission(resultData, takeFlags)
        SAFSettings.authorizedUri = resultData.toString()
    }

    private fun checkSafPermission(): Boolean {
        val dir = SAFSettings.authorizedUri
        if (dir.isBlank()) return false

        val uri = Uri.parse(dir)

        return try {
            val flags =
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            contentResolver.takePersistableUriPermission(uri, flags)
            DocumentFile.fromTreeUri(this, uri)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            safAuthorizationCode -> {
                if (resultCode == Activity.RESULT_OK) {
                    // 授权成功
                    onSafAuthSuccess(data!!)
                    afterAuthSuccess?.invoke()
                } else {
                    // 授权失败
                    safAuthorizationResult?.error("Permission denied", null, null)
                    safAuthorizationResult = null
                }
                afterAuthSuccess=null
            }
        }
    }
}
