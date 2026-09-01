import java.util.Base64
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials, loaded from android/key.properties (gitignored,
// not committed). See android/key.properties for the format. Absent on CI/other
// machines that don't hold the upload keystore - release builds there will fail
// signing, which is expected; debug/profile builds are unaffected.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

/**
 * Decodes the `dart-defines` Gradle property that Flutter forwards from
 * `--dart-define` flags (a comma-separated list of base64-encoded
 * `KEY=VALUE` pairs) into a plain map.
 */
fun dartDefines(): Map<String, String> {
    val raw = project.findProperty("dart-defines") as String? ?: return emptyMap()
    return raw.split(",").associate { entry ->
        val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
        val separator = decoded.indexOf("=")
        if (separator == -1) decoded to "" else decoded.substring(0, separator) to decoded.substring(separator + 1)
    }
}

// The app's environment: dev, staging or prod, selected at build/run time
// via `--dart-define=APP_ENV=<env>` (defaults to prod). This is NOT an
// Android product flavor - there's only one build variant of this app, just
// pointed at a different environment. See lib/config/app_env.dart.
val appEnv = dartDefines()["APP_ENV"] ?: "prod"

fun appNameForEnv(env: String) = when (env) {
    "dev" -> "NF Ninja Dev"
    "staging" -> "NF Ninja Stg"
    else -> "Nightfall Ninja"
}

android {
    namespace = "com.shashphantomgames.nightfallninja"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        // Required for the per-environment resValue("string", "app_name", ...) below.
        resValues = true
    }

    defaultConfig {
        applicationId = "com.shashphantomgames.nightfallninja"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // dev/staging get a distinguishing app id suffix, version suffix and
        // app name so they can be installed side-by-side with prod.
        if (appEnv != "prod") {
            applicationIdSuffix = ".$appEnv"
            versionNameSuffix = "-$appEnv"
        }
        resValue("string", "app_name", appNameForEnv(appEnv))
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Uses the upload keystore from android/key.properties when present
            // (required for Play Store uploads). Falls back to debug signing so
            // `flutter run --release` still works on machines without it.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
