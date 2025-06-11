import java.util.Properties
import java.io.FileInputStream
import org.yaml.snakeyaml.Yaml

// Lade die Keystore-Properties, falls die Datei existiert (für lokale Builds)
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Lese Version aus pubspec.yaml
val pubspecFile = rootProject.file("../pubspec.yaml")
val pubspecMap = Yaml().load<Map<String, Any>>(pubspecFile.inputStream())
val versionString = pubspecMap["version"] as String
val (versionName, versionCode) = versionString.split("+").let {
    val name = it[0]
    val code = it.getOrNull(1)?.toInt() ?: 1
    name to code
}


plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}


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
        // Verwende die Version aus pubspec.yaml
        this.versionCode = versionCode
        this.versionName = versionName
    }

    // Signing-Konfiguration für Release-Builds
    signingConfigs {
        create("release") {
            // Lese Werte aus keystore.properties oder aus GitHub Secrets (CI-Umgebungsvariablen)
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
