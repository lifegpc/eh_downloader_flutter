package com.lifegpc.ehf.data.mmkv

import com.dylanc.mmkv.MMKVOwner
import com.dylanc.mmkv.mmkvString

object SAFSettings : MMKVOwner(mmapID = "SAFSettings") {
    var authorizedUri by mmkvString("")
}