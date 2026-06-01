# Android Firebase Configuration Guide

Panduan lengkap untuk setup Firebase di Android.

## 📱 Prerequisites

- Google Account
- Firebase Project sudah dibuat di [Firebase Console](https://console.firebase.google.com)
- Android SDK configured

## 🔧 Step-by-Step Setup Android Firebase

### Step 1: Download google-services.json

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih Firebase Project Anda
3. Klik ⚙️ **Project Settings** (atas kiri)
4. Pilih tab **Your apps**
5. Pilih app Android Anda (package name: `com.example.app1`)
6. Klik **Download google-services.json**

### Step 2: Letakkan google-services.json

Paste file `google-services.json` ke directory:
```
android/app/google-services.json
```

**Struktur folder yang benar:**
```
android/
├── app/
│   ├── google-services.json  ← Letakkan di sini
│   ├── build.gradle.kts
│   └── src/
└── ...
```

### Step 3: Update build.gradle Files

**File: `android/build.gradle.kts`** (Project level)

Pastikan sudah ada:
```kotlin
plugins {
    id("com.android.application") version "8.0.0" apply false
    id("com.android.library") version "8.0.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.0" apply false
    
    // Tambahkan Firebase plugin
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

**File: `android/app/build.gradle.kts`** (App level)

Update dependencies:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    
    // Tambahkan Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app1"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.app1"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    
    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    
    // Firebase BOM (Bill of Materials) - Recommended
    implementation(platform("com.google.firebase:firebase-bom:32.4.0"))
    
    // Firebase libraries (tanpa versi number karena sudah ditentukan BOM)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-analytics")
    
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
```

### Step 4: Update AndroidManifest.xml

**File: `android/app/src/main/AndroidManifest.xml`**

Pastikan sudah ada:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application ...>
        <!-- Activities dan Services -->
    </application>
</manifest>
```

### Step 5: Update firebase_options.dart

Buka [Firebase Console → Project Settings → Your Apps]

Copy konfigurasi dari console dan update di `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',        // Dari console
  appId: '1:123456789:android:abcdef...',  // Dari console
  messagingSenderId: '123456789',          // Dari console
  projectId: 'your-project-id',            // Nama project
  storageBucket: 'your-project-id.appspot.com',
  authDomain: 'your-project-id.firebaseapp.com',
);
```

### Step 6: Test Configuration

Run aplikasi:
```bash
flutter clean
flutter pub get
flutter run
```

Atau gunakan Android Studio:
```bash
./gradlew build --info
```

## 📋 Troubleshooting

### 1. "google-services.json not found"

**Solusi:**
- Pastikan file ada di `android/app/google-services.json`
- Run: `flutter clean && flutter pub get`

### 2. "Plugin com.google.gms.google-services not found"

**Solusi:**
- Buka `android/build.gradle.kts`
- Pastikan ada: `id("com.google.gms.google-services") version "4.4.0" apply false`

### 3. "Failed to apply plugin 'com.google.gms.google-services'"

**Solusi:**
- Buka `android/app/build.gradle.kts`
- Pastikan ada: `id("com.google.gms.google-services")`

### 4. Build Error: "Gradle execution failed"

**Solusi:**
```bash
./gradlew clean
flutter clean
flutter pub get
flutter run
```

### 5. Firebase tidak inisialisasi

Pastikan:
1. `main.dart` sudah diupdate dengan Firebase init
2. `firebase_options.dart` sudah dikonfigurasi benar
3. App ID dan API Key benar dari Firebase Console

## ✅ Verifikasi Setup

1. Build apk:
```bash
flutter build apk --debug
```

2. Install ke device:
```bash
flutter install
```

3. Check Firebase Console untuk melihat apakah app sudah terkoneksi

4. Cek logcat:
```bash
flutter logs
```

Cari output:
```
E/FirebaseAuth: com.google.firebase.auth.FirebaseAuthException
```

Jika tidak ada error, setup berhasil! ✅

## 🔐 Enable Firebase Services

Di Firebase Console:
1. **Authentication → Sign-in method**
   - Enable: Email/Password

2. **Firestore Database**
   - Create database
   - Choose location (Asia Southeast, dll)

3. **Storage**
   - Create bucket
   - choose location

4. **Messaging** (Optional)
   - Enable untuk push notifications

## 📚 Referensi

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Services Plugin](https://developers.google.com/android/guides/google-services-plugin)
- [Firebase Console](https://console.firebase.google.com)

---

**Setup selesai! Lanjutkan dengan testing aplikasi.** 🚀
