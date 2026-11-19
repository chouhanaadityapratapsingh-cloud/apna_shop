# UI7 - fix release build (R8 missing ML Kit classes)
1. Copy android/app/proguard-rules.pro into C:\dev\apna_shop\android\app\
2. In android/app/build.gradle.kts (or build.gradle) the release build must use it:

Kotlin (build.gradle.kts):
    buildTypes {
        release {
            // keep your existing signingConfig line
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

Groovy (build.gradle):
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
3. flutter run --release
