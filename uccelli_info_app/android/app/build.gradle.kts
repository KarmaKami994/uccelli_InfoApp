// Dieser Block sagt Gradle, wo es die Bibliothek zum Lesen von YAML-Dateien findet.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.yaml:snakeyaml:2.2")
    }
}

import java.util.Properties
import java.io.FileInputStream
import org.yaml.snakeyaml.Yaml

// --- FINALE VERSIONSLOGIK ---
// Priorisiert die vom Flutter-Tool bereitgestellte Version, mit Fallback auf pubspec.yaml für CI.

// 1. Versuche, die Version aus local.properties zu lesen (Standard für `flutter run`)
val localProperties = Properties()
val localPropertiesFile = project.rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}
val flutterVersionName = localProperties.getProperty("flutter.versionName")
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")

// 2. Lese die Version aus pubspec.yaml als Fallback
fun getPubspecVersion(): Pair<String, Int> {
    val pubspecFile = rootProject.file("../pubspec.yaml")
    val pubspecMap = Yaml().load<Map<String, Any>>(pubspecFile.inputStream())
    val versionString = pubspecMap["version"] as String
    return versionString.split("+").let {
        val name = it[0]
        val code = it.getOrNull(1)?.toInt() ?: 1
        name to code
    }
}
val (pubspecVersionName, pubspecVersionCode) = getPubspecVersion()

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


android {
    namespace = "com.example.uccelli_info_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
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
        // Verwende die robuste Versionslogik
        versionCode = flutterVersionCode?.toInt() ?: pubspecVersionCode
        versionName = flutterVersionName ?: pubspecVersionName
    }

    // Signing-Konfiguration für Release-Builds
    signingConfigs {
        create("release") {
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
