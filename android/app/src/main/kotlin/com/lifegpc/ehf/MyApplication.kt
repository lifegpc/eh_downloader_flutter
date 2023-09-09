package com.lifegpc.ehf

import android.app.Application
import android.content.Context

class MyApplication:Application() {
    companion object{
        @JvmStatic
        private var mApplicationContext:Context?=null
        @JvmStatic
        @get:JvmName("_applicationContext")
        val applicationContext:Context
            get() = mApplicationContext!!
    }
    override fun onCreate() {
        super.onCreate()
        mApplicationContext=applicationContext
    }
}