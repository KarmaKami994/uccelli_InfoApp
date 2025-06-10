// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android") // Kotlin Android Plugin
    // id("com.google.gms.google-services") // ENTFERNT: Firebase Google Services Plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.uccelli_info_app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.uccelli_info_app"
        minSdk          = flutter.minSdkVersion
        targetSdk       = flutter.targetSdkVersion
        versionCode     = flutter.versionCode
        versionName     = flutter.versionName
    }

    // Release signing
    signingConfigs {
        create("release") {
            storeFile       = file("uccelli-release.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias        = "upload"
            keyPassword     = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig   = signingConfigs.getByName("release")
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Java & Kotlin Kompatibilität
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8 // Setze auf Java 8 Kompatibilität
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "1.8" // Setze jvmTarget auf 1.8 für breitere Kompatibilität
    }

    ndkVersion = "27.0.12077973" // Beibehalten, da es im Build-Log installiert wurde
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
