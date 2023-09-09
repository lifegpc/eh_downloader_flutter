package com.lifegpc.ehf.data.litepal

import org.litepal.crud.LitePalSupport

class ClipboardImageItem(
    val uuid:String,
    val mimeType:String
):LitePalSupport() {
    val id:Long=0
}