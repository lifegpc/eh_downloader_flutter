package com.lifegpc.ehf.eventbus

import android.content.Intent

data class SAFAuthEvent(
    val success: Boolean = true,
    val data: Intent?,
)