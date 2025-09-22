plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load MAPS_API_KEY from .env (prefer project root ../.env)
fun loadEnvVar(name: String): String {
    val candidates = listOf("../.env", ".env")
    for (path in candidates) {
        val f = rootProject.file(path)
        if (f.exists()) {
            try {
                val lines = f.readLines()
                for (line in lines) {
                    val trimmed = line.trim()
                    if (trimmed.startsWith("$name=")) {
                        var v = trimmed.substringAfter("=").trim()
                        // Strip surrounding quotes if present
                        if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith('\'') && v.endsWith('\''))) {
                            v = v.substring(1, v.length - 1)
                        }
                        return v
                    }
                }
            } catch (_: Exception) {}
        }
    }
    return System.getenv(name) ?: ""
}

android {
    namespace = "com.example.urban_flooding"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.urban_flooding"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val mapsKey = loadEnvVar("MAPS_API_KEY")
        if (mapsKey.isEmpty()) {
            println("[Warning] MAPS_API_KEY not found in .env or environment.")
        } else {
            println("[Info] Injecting MAPS_API_KEY from .env")
        }
        manifestPlaceholders["MAPS_API_KEY"] = mapsKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
