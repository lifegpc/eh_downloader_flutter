package com.lifegpc.ehf

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import com.lifegpc.ehf.annotation.ChannelMethod
import com.lifegpc.ehf.eventbus.SAFAuthEvent
import com.lifegpc.ehf.platform.ClipboardPlugin
import com.lifegpc.ehf.platform.MethodChannelUtils
import com.lifegpc.ehf.platform.SAFPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import org.greenrobot.eventbus.EventBus

class MainActivity : FlutterFragmentActivity() {

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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val lp=window.attributes
            lp.layoutInDisplayCutoutMode=WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            window.attributes=lp
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

    @ChannelMethod(methodName = "setFullscreenMode")
    @Suppress("unused")
    private fun setFullscreenMode(value: Boolean) {
        // api 23
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowController = window.insetsController
            if (value) {
                windowController?.hide(WindowInsets.Type.statusBars())
                windowController?.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            } else {
                windowController?.show(WindowInsets.Type.statusBars())
            }
        } else {
            @Suppress("DEPRECATION")
            if (value){
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
            }else{
                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
            }
        }
    }

    @ChannelMethod(methodName = "deviceName")
    @Suppress("unused")
    private fun getDeviceName(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME)
                ?: Settings.System.getString(contentResolver, Settings.Global.DEVICE_NAME)
                ?: Build.MODEL
        } else {
            Build.MODEL
        }
    }
}
