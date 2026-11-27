allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Plugins that still compile against an old Android API (agora_rtc_engine uses 31) cannot build against the
// newer AndroidX libraries they pull in, which need 34+. Raise any plugin below the app's level to it.
subprojects {
    val raise: Project.() -> Unit = {
        val android = extensions.findByName("android")
        if (android is com.android.build.gradle.LibraryExtension && (android.compileSdk ?: 0) < 36) {
            android.compileSdk = 36
        }
    }
    if (state.executed) raise() else afterEvaluate { raise() }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
