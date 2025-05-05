// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")    // Firebase Google Services plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.uccelli_info_app"
    compileSdk = flutter.compileSdkVersion

    // Match the NDK version required by all plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // Enable core‐library desugaring (Java 8+ APIs)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.uccelli_info_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug signing config for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Your other dependencies…
    // …

    // Updated desugaring library (>= 1.2.2 required by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}
