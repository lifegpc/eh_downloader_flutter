package com.lifegpc.ehf.platform

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
                // 传入的参数值
                val argv = if (call.arguments == null) {
                    null
                } else if (call.arguments is List<*>) {
                    call.arguments as List<*>
                } else {
                    return@setMethodCallHandler result.error(
                        "Argument must be nullable list",
                        null,
                        null
                    )
                }

                try {
                    if (targetMethod.getChannelMethodAnnotation().responseManually) {
                        // 若手动返回，传入参数的第一个参数为 flutter 的 result 引用，用来返回给 flutter 结果
                        val arg = arrayListOf(result) + (argv ?: emptyList())
                        invokeNativeMethod(targetMethod, arg, obj)
                    } else {
                        val invokeResult = invokeNativeMethod(targetMethod, argv, obj)
                        if (invokeResult == Unit) {
                            result.success(null)
                        } else {
                            result.success(invokeResult)
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error(e.javaClass.name, e.localizedMessage, e.stackTraceToString())
                }
            }
        }
    }

    private fun invokeNativeMethod(
        method: Method,
        args: List<Any?>?,
        instance: Any?
    ): Any? {
        method.isAccessible = true
        return if (method.isStaticMethod()) { // 静态方法调用
            if (args == null) {
                method.invoke(null)
            } else {
                method.invoke(null, *args.toTypedArray())
            }
        } else { // 非静态方法调用
            if (args == null) {
                method.invoke(instance)
            } else {
                method.invoke(instance, *args.toTypedArray())
            }
        }
    }

    /**
     * 判断方法是否为静态方法
     * @receiver Method
     * @return Boolean
     */
    private fun Method.isStaticMethod(): Boolean = Modifier.isStatic(this.modifiers)

    private fun Method.getChannelMethodAnnotation(): ChannelMethod {
        return this.annotations.first { it is ChannelMethod } as ChannelMethod
    }
}