package com.lifegpc.ehf

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import com.lifegpc.ehf.annotation.ChannelMethod
import com.lifegpc.ehf.eventbus.SAFAuthEvent
import com.lifegpc.ehf.platform.ClipboardPlugin
import com.lifegpc.ehf.platform.MethodChannelUtils
import com.lifegpc.ehf.platform.SAFPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.greenrobot.eventbus.EventBus

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannelUtils.registerMethodChannel(
            "lifegpc.eh_downloader_flutter/saf",
            flutterEngine,
            SAFPlugin(this)
        )
        MethodChannelUtils.registerMethodChannel(
            "lifegpc.eh_downloader_flutter/clipboard",
            flutterEngine,
            ClipboardPlugin
        )
        MethodChannelUtils.registerMethodChannel(
            "lifegpc.eh_downloader_flutter/display",
            flutterEngine,
            this
        )
        MethodChannelUtils.registerMethodChannel(
            "lifegpc.eh_downloader_flutter/device",
            flutterEngine,
            this
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            SAFPlugin.safAuthorizationCode -> {
                if (resultCode == Activity.RESULT_OK) {
                    // 授权成功
                    EventBus.getDefault().post(SAFAuthEvent(true, data!!))
                } else {
                    // 授权失败
                    EventBus.getDefault().post(SAFAuthEvent(false, null))
                }
            }
        }
    }

    @ChannelMethod(methodName = "enableProtect")
    @Suppress("unused")
    private fun enableFlagSecure() {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    @ChannelMethod(methodName = "disableProtect")
    @Suppress("unused")
    private fun disableFlagSecure() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    @ChannelMethod(methodName = "deviceName")
    @Suppress("unused")
    private fun getDeviceName(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME) ?: Build.MODEL
        } else {
            Build.MODEL
        }
    }
}
