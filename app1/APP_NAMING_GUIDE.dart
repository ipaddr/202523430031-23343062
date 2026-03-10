/// APP NAMING & BRANDING GUIDE
/// ===========================
///
/// Panduan lengkap untuk set app name di Android & iOS

/*

════════════════════════════════════════════════════════════════════════════════
STEP 1 - UPDATE APP NAME DI PUBSPEC.YAML
════════════════════════════════════════════════════════════════════════════════

File: pubspec.yaml
Location: Buka file ini di project root

Cari line:
  name: app1

Ubah menjadi:
  name: notes_app    (atau nama app Anda)

Catatan:
- Gunakan huruf kecil & underscore (tidak boleh spaces atau special char)
- Ini adalah package name di pub.dev
- Tidak akan terlihat di device user

File lengkap contoh:
  name: notes_app
  description: A simple notes app untuk manage catatan
  version: 1.0.0+1
  
  environment:
    sdk: '>=2.19.0 <4.0.0'
  
  dependencies:
    flutter:
      sdk: flutter
    flutter_bloc: ^8.1.6
    ...


════════════════════════════════════════════════════════════════════════════════
STEP 2 - UPDATE APP NAME DI ANDROID
════════════════════════════════════════════════════════════════════════════════

File: android/app/src/main/AndroidManifest.xml

2.1 Buka AndroidManifest.xml

2.2 Cari line:
  android:label="@string/app_name"

2.3 Atau buka: android/app/src/main/res/values/strings.xml

2.4 Cari line:
  <string name="app_name">app1</string>

2.5 Ubah menjadi:
  <string name="app_name">Notes App</string>

2.6 Ini adalah nama yang terlihat di launcher (home screen)

Contoh file lengkap (strings.xml):
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <string name="app_name">Notes App</string>
    <string name="app_label">Notes App</string>
  </resources>


════════════════════════════════════════════════════════════════════════════════
STEP 3 - UPDATE APP NAME DI iOS
════════════════════════════════════════════════════════════════════════════════

File: ios/Runner/Info.plist

3.1 Buka Info.plist

3.2 Cari key:
  CFBundleName

3.3 Nilai saat ini mungkin: $(EXECUTABLE_NAME) atau app1

3.4 Ubah menjadi:
  Notes App  (atau nama app Anda)

Contoh XML:
  <key>CFBundleName</key>
  <string>Notes App</string>

Atau untuk app display name (tampilan panjang):
  <key>CFBundleDisplayName</key>
  <string>Notes App</string>

CATATAN iOS:
- Jika CFBundleDisplayName tidak ada, add entry baru
- CFBundleName: Internal name (harus same seperti project name)
- CFBundleDisplayName: Display name di home screen
- Max 11 characters untuk label di home screen (agar tidak truncate)


════════════════════════════════════════════════════════════════════════════════
STEP 4 - UPDATE PACKAGE NAME (ANDROID)
════════════════════════════════════════════════════════════════════════════════

PENTING: Ini untuk first-time setup only! Jangan ubah setelah publish ke Play Store.

File: android/app/build.gradle

4.1 Cari section: android { ... defaultConfig { ... } ... }

4.2 Cari line:
  applicationId "com.example.app1"

4.3 Ubah menjadi format yang lebih descriptive:
  applicationId "com.nama_anda.notes_app"

Contoh:
  android {
    namespace "com.example.app1"
    
    compileSdkVersion flutter.compileSdkVersion
    
    defaultConfig {
      applicationId "com.mycompany.notesapp"  ← Change this
      minSdkVersion flutter.minSdkVersion
      targetSdkVersion flutter.targetSdkVersion
      versionCode flutterVersionCode.toInteger()
      versionName flutterVersionName
    }
  }

Package Name Rules:
- Format: com.yourcompany.appname (reverse domain notation)
- Hanya lowercase letters, numbers, dots, underscore
- Tidak boleh mulai dengan number
- Max 81 characters
- PERMANENT setelah publish (tidak bisa diubah!)

Examples:
  ✅ com.mycompany.notesapp
  ✅ com.john.simple_notes
  ✅ com.notes.app
  ❌ com.my-company.notes (no hyphens)
  ❌ my.company.notes (must start dengan com/org/io)


════════════════════════════════════════════════════════════════════════════════
STEP 5 - VERIFY CHANGES
════════════════════════════════════════════════════════════════════════════════

5.1 Clean project
  Command: flutter clean

5.2 Get dependencies
  Command: flutter pub get

5.3 Run app
  Command: flutter run

5.4 Check hasil
  - Jalankan di emulator/device
  - Lihat home screen
  - App name harus berubah di launcher
  - Verify di app drawer


════════════════════════════════════════════════════════════════════════════════
STEP 6 - APP NAME VARIATIONS
════════════════════════════════════════════════════════════════════════════════

Some best practices untuk app naming:

SHORT NAME (2-4 characters):
  - Terlihat di home screen
  - Max 11 chars agar tidak truncate
  - Examples: "Notes", "Todo", "Calc"

FULL NAME (15-50 characters):
  - Untuk Play Store listing
  - Untuk user recognition
  - Examples: "Notes App - Simple Note Taker", "Todo List & Planner"

DESCRIPTION (untuk Play Store):
  - Short description: max 80 chars
  - Full description: max 4000 chars

Recommendations untuk Notes App:
  Short name: "Notes"
  Full name: "Notes App - Simple Note Taking"
  Description: "A simple and efficient app for creating and managing notes with cloud sync"


════════════════════════════════════════════════════════════════════════════════
STEP 7 - MULTI-LANGUAGE APP NAMES (OPTIONAL)
════════════════════════════════════════════════════════════════════════════════

Jika ingin app name berbeda untuk setiap language:

Android - Add new strings file untuk language:

File: android/app/src/main/res/values-id/strings.xml
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <string name="app_name">Aplikasi Catatan</string>
  </resources>

File: android/app/src/main/res/values-es/strings.xml
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <string name="app_name">Aplicación de Notas</string>
  </resources>

iOS - Di Info.plist:
  <key>CFBundleLocalizations</key>
  <array>
    <string>en</string>
    <string>id</string>
    <string>es</string>
  </array>

Lalu setup localization files untuk setiap language.


════════════════════════════════════════════════════════════════════════════════
CHECKLIST - APP NAMING
════════════════════════════════════════════════════════════════════════════════

□ Updated pubspec.yaml name
□ Updated android/app/src/main/res/values/strings.xml
□ Updated ios/Runner/Info.plist
□ Updated android/app/build.gradle applicationId (first time only)
□ Ran flutter clean
□ Ran flutter pub get
□ Tested di emulator/device
□ App name visible di launcher
□ No build errors
□ Verified di physical device (jika ada)


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Problem: App name tidak berubah setelah update

Solution:
  1. flutter clean
  2. flutter pub get
  3. Uninstall app dari device
  4. flutter run (fresh build)

Atau manual:
  Android emulator: Wipe data (Settings → System → Reset)
  iOS simulator: xcrun simctl erase all


Problem: Android app name panjang, truncated di launcher

Solution:
  - Keep app_name <= 11 characters
  - Atau gunakan CFBundleDisplayName untuk iOS dengan short name


Problem: Package name sudah final di Play Store

Solution:
  - TIDAK BISA DIUBAH
  - Harus create app baru dengan package name baru
  - Lalu update Android/iOS di app console


════════════════════════════════════════════════════════════════════════════════
QUICK SUMMARY
════════════════════════════════════════════════════════════════════════════════

Untuk set app name ke "Notes App":

1. Edit pubspec.yaml:
   name: notes_app

2. Edit android/app/src/main/res/values/strings.xml:
   <string name="app_name">Notes App</string>

3. Edit ios/Runner/Info.plist:
   <key>CFBundleName</key>
   <string>Notes App</string>

4. flutter clean && flutter pub get && flutter run

Done! ✅

*/
