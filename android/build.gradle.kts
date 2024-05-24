//buildscript {
//    repositories {
//        google()
//        mavenCentral()
//    }
//
//    dependencies {
//        classpath("com.android.tools.build:gradle:7.3.0")
//        classpath ("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
//    }
//}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://www.jitpack.io")
    }
}

rootProject.setBuildDir("../build")
subprojects {
    project.setBuildDir("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

task<Delete>("clean") {
    delete(rootProject.buildDir)
}
