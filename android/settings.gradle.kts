pluginManagement {
    val properties1 =java.util.Properties()
    java.io.FileInputStream("local.properties").use {
        properties1.load(it)
    }
    val flutterSdkPath = properties1.getProperty("flutter.sdk")
    assert(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id ("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id ("com.android.application") version "7.3.0" apply false
    id ("org.jetbrains.kotlin.android") version "1.9.25" apply false
}

include(":app")
