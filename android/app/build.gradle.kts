plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lifegpc.ehf"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
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
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        maybeCreate("release").apply {
            val keystoreFile = File(projectDir, "keystore.jks")
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
