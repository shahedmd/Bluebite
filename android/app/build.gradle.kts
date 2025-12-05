plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // FlutterFire
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bluebite"
    compileSdk = 35 // Required by path_provider_android & other plugins

    defaultConfig {
        applicationId = "com.example.bluebite"
        minSdk = 24          // Android 7
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true  // Low-RAM / many methods
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    packagingOptions {
        resources.excludes.add("META-INF/DEPENDENCIES")
        resources.excludes.add("META-INF/LICENSE")
        resources.excludes.add("META-INF/LICENSE.txt")
        resources.excludes.add("META-INF/NOTICE")
        resources.excludes.add("META-INF/NOTICE.txt")
    }
}

flutter {
    source = "../.."
}
