import java.util.Properties
import java.io.FileInputStream

// Lade die Keystore-Properties, falls die Datei existiert (für lokale Builds)
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Lese die Version aus der von Flutter generierten local.properties-Datei.
// Dies ist die Standardmethode und funktioniert sowohl lokal als auch in CI/CD.
val localProperties = Properties()
val localPropertiesFile = project.rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    throw GradleException("flutter.versionCode not found. Please run 'flutter pub get' in your project directory.")
}

val flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    throw GradleException("flutter.versionName not found. Please run 'flutter pub get' in your project directory.")
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
        // Lese die Version aus local.properties.
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
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
