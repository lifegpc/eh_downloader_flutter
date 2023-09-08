package com.lifegpc.ehf.annotation

@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
/**
 * @param methodName
 * @param responseManually 是否需要手动返回
 * 若为 true 则实现方法中需要手动调用 [io.flutter.plugin.common.MethodChannel.Result.success] 等方法
 * 否则，则会将实现方法的返回值返回给 [io.flutter.plugin.common.MethodChannel.Result]
 */
annotation class ChannelMethod(
    val methodName:String="",
    val responseManually:Boolean=false
)
