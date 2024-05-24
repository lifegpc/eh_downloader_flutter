plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lifegpc.ehf"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }


    sourceSets {
        getByName("main") {
            java {
                srcDirs("src/main/kotlin")
            }
        }
    }

    defaultConfig {
        applicationId = "com.lifegpc.ehf"
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode()
        versionName = flutter.versionName()
    }

    signingConfigs {
        maybeCreate("release").apply {
            val keystoreFile = File("keystore.jks")
            if (!keystoreFile.exists()) return@apply
            val keyAliasEnv = System.getenv("SIGNING_KEY_ALIAS") ?: return@apply
            val keystorePasswordEnv = System.getenv("SIGNING_STORE_PASSWORD") ?: return@apply
            val keyPasswordEnv = System.getenv("SIGNING_STORE_PASSWORD") ?: return@apply

            storeFile = keystoreFile
            storePassword = keystorePasswordEnv
            keyAlias = keyAliasEnv
            keyPassword = keyPasswordEnv
        }
    }

    buildTypes {
        release {
            signingConfig = if (System.getenv("CI") == "true") {
                signingConfigs["release"]
            } else {
                signingConfigs["debug"]
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(libs.mmkv.ktx)
    implementation(libs.eventbus)
    implementation(libs.documentfile)
}
