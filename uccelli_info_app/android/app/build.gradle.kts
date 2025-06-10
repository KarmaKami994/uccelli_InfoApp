import java.util.Properties
import java.io.FileInputStream

// Lade die Keystore-Properties, falls die Datei existiert (für lokale Builds)
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

fun localProperties(): Properties {
    val properties = Properties()
    val localPropertiesFile = project.rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(localPropertiesFile.inputStream())
    }
    return properties
}

val flutterVersionCode: String? by localProperties()
val flutterVersionName: String? by localProperties()

android {
    namespace = "com.example.uccelli_info_app"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.uccelli_info_app"
        minSdk = 21
        targetSdk = 33
        versionCode = flutterVersionCode?.toInt() ?: 1
        versionName = flutterVersionName ?: "1.0"
    }

    // Signing-Konfiguration für Release-Builds
    signingConfigs {
        create("release") {
            // Lese Werte aus keystore.properties oder aus GitHub Secrets (CI-Umgebungsvariablen)
            // HIER WURDE DER PFAD ANGEPASST
            storeFile = file(System.getenv("KEYSTORE_FILE") ?: keystoreProperties["storeFile"] as String? ?: "../upload-keystore.jks")
            storePassword = System.getenv("KEY_STORE_PASSWORD") ?: keystoreProperties["storePassword"] as String?
            keyAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties["keyAlias"] as String?
            keyPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {}
