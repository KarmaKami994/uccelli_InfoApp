// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.uccelli_info_app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.uccelli_info_app"
        minSdk        = flutter.minSdkVersion
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    // Release signing, picks up the keystore you decode in CI:
    signingConfigs {
        create("release") {
            // your workflow writes this file for us:
            storeFile     = file("uccelli-release.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias      = "upload"        // adjust if your alias differs
            keyPassword   = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig    = signingConfigs.getByName("release")
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        // debug stays default
    }

    // Java 11 + core-library desugaring
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    // Align with your plugins
    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}

dependencies {
    // for Java 8+ library support
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
