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
