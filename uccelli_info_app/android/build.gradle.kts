// android/build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// 1) Make the Google Services plugin available to your build
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle plugin (if not already provided via settings/pluginManagement)
        classpath("com.android.tools.build:gradle:7.4.2")
        // Firebase Google Services plugin (ENTFERNT)
    }
}

// 2) Keep your existing repositories for all projects
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3) Your existing custom build directory logic
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

// 4) “clean” task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
