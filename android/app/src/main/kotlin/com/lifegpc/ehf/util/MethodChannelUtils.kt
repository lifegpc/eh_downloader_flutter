package com.lifegpc.ehf.util

import android.util.Log
import com.lifegpc.ehf.annotation.ChannelMethod
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Method
import java.lang.reflect.Modifier

object MethodChannelUtils {
    @JvmStatic
    fun registerMethodChannel(
        channelName: String,
        flutterEngine: FlutterEngine,
        obj: Any,
        ignoreNotImplemented: Boolean = true
    ) {
        val methodsMapping = mutableMapOf<String, Method>()
        val methods = obj::class.java.declaredMethods
        methods.forEach {
            val annotation = it.getAnnotation(ChannelMethod::class.java) ?: return@forEach
            val methodName = annotation.methodName.takeIf(String::isNotBlank) ?: it.name
            methodsMapping[methodName] = it
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            val invokeMethodName = call.method
            val targetMethod = methodsMapping[invokeMethodName]
            if (targetMethod == null) {
                Log.w("MethodChannel", "$channelName/$invokeMethodName not implemented.")
                if (!ignoreNotImplemented) {
                    result.notImplemented()
                } else {
                    result.error("Not implemented", null, null)
                }
                return@setMethodCallHandler
            } else {
                val argv = call.arguments?.takeIf { it is List<*> } as List<*>?
                    ?: return@setMethodCallHandler result.error("Argument must be List", null, null)
                val argTypes = targetMethod.parameterTypes
                val targetArgc = argTypes.size

                val invokeTargetObject =
                    if (Modifier.isStatic(targetMethod.modifiers)) null else obj
                targetMethod.isAccessible = true

                if (targetArgc == argv.size) {
                    try {
                        val res = targetMethod.invoke(invokeTargetObject, *(argv.toTypedArray()))
                        if (res is Unit) {
                            result.success(null)
                        } else {
                            result.success(res)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("Error", e.toString(), e.stackTraceToString())
                    }
                } else if (targetArgc == argv.size + 1 && argTypes[0] == MethodChannel.Result::class.java) {
                    try {
                        val responseManually =
                            targetMethod.getAnnotation(ChannelMethod::class.java)!!.responseManually
                        val res =
                            targetMethod.invoke(invokeTargetObject, result, *(argv.toTypedArray()))
                        if (!responseManually) {
                            if (res is Unit) {
                                result.success(null)
                            } else {
                                result.success(res)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("Error", e.toString(), e.stackTraceToString())
                    }
                } else {
                    result.error(
                        "Error",
                        "Parameter count error, required: $targetArgc, found: $argv",
                        null
                    )
                }
            }
        }
    }
}