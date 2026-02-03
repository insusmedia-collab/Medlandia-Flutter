plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    //implementation("xpp3:xpp3:1.1.4c")
    //implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    // or alternatively:
    //implementation('xpp3:xpp3:1.1.4c')
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}

android {
    namespace = "org.insus.medlandia"
    compileSdk = 36
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = "pcnc178060418911"
            keyAlias = "key0"
            keyPassword = "pcnc178060418911"
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.insus.medlandia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        //minSdkVersion(23)
    }

    buildTypes {
         
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
            

            //isMinifyEnabled = false
            // Enables resource shrinking.
            //isShrinkResources = false

            //proguardFiles(
                // Default file with automatically generated optimization rules.
                //getDefaultProguardFile("proguard-android-optimize.txt"),"proguard-rules.pro"
            //)
        }
    }
}

flutter {
    source = "../.."
}
