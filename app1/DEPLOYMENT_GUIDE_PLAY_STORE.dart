/// DEPLOYMENT GUIDE - STEP BY STEP
/// ================================
///
/// Panduan lengkap deploy ke Google Play Store

/*

════════════════════════════════════════════════════════════════════════════════
STEP 1 - PREPARE ANDROID BUILD
════════════════════════════════════════════════════════════════════════════════

1.1 Update pubspec.yaml
  Buka: pubspec.yaml
  Cari line: version: 1.0.0+1
  
  Increment version sesuai semantic versioning:
  - Major: breaking changes (2.0.0)
  - Minor: new features, backwards compatible (1.1.0)
  - Patch: bug fixes (1.0.1)
  - Build number: increment untuk each build (1.0.0+2)

1.2 Update Android app version
  Buka: android/app/build.gradle
  Cari section: android { ... defaultConfig { ... } ... }
  
  Update ini:
  versionCode 1      ← Increment this for each release
  versionName "1.0"  ← Match pubspec.yaml version

1.3 Update app name (opsional)
  Buka: android/app/src/main/AndroidManifest.xml
  Cari: android:label="@string/app_label"
  
  Atau buka: android/app/src/main/res/values/strings.xml
  Update: <string name="app_label">Notes App</string>

1.4 Verify package name
  Buka: android/app/build.gradle
  Pastikan: applicationId "com.yourname.notesapp"
  
  PENTING: Tidak boleh berubah setelah publish (permanent)


════════════════════════════════════════════════════════════════════════════════
STEP 2 - SETUP ANDROID KEYSTORE (FIRST TIME ONLY)
════════════════════════════════════════════════════════════════════════════════

Hanya perlu dilakukan 1x untuk release pertama.

2.1 Generate keystore
  Jalankan di terminal:
  keytool -genkey -v -keystore ~/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10950 \
    -alias upload

  Pertanyaan yang muncul:
  - Keystore password: [create strong password]
  - First/last name: Your Name
  - Organization: Your Company
  - Country: ID
  - Password (again): [confirm password]

  Atau di Windows (gunakan path dengan backslash):
  keytool -genkey -v -keystore C:\Users\YourName\upload-keystore.jks ^
    -keyalg RSA -keysize 2048 -validity 10950 ^
    -alias upload

2.2 Save keystore location & password
  Simpan file di lokasi aman:
  ~/upload-keystore.jks (atau C:\Users\YourName\upload-keystore.jks)
  
  PENTING: Jangan hilangkan password & file ini!
  Kalau hilang, tidak bisa update app di Play Store.

2.3 Configure Android signing
  Buka: android/key.properties
  Atau create file baru dengan nama itu.
  
  Isi:
  storePassword=<password dari step 2.1>
  keyPassword=<password dari step 2.1>
  keyAlias=upload
  storeFile=<path ke upload-keystore.jks>
  
  Contoh:
  storePassword=MySecurePassword123!@#
  keyPassword=MySecurePassword123!@#
  keyAlias=upload
  storeFile=/Users/yourname/upload-keystore.jks
  
  Atau Windows:
  storeFile=C:\\Users\\YourName\\upload-keystore.jks

2.4 Update android/app/build.gradle
  Buka: android/app/build.gradle
  
  Tambah di atas android { ... } block:
  
  def keystoreProperties = new Properties()
  def keystorePropertiesFile = rootProject.file('key.properties')
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
  }
  
  Lalu cari android { ... defaultConfig { ... } ... }
  
  Tambah signingConfigs section sebelum buildTypes:
  
  signingConfigs {
      release {
          keyAlias keystoreProperties['keyAlias']
          keyPassword keystoreProperties['keyPassword']
          storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
          storePassword keystoreProperties['storePassword']
      }
  }
  
  Di buildTypes, update release:
  
  release {
      signingConfig signingConfigs.release
      minifyEnabled true
      shrinkResources true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
  }


════════════════════════════════════════════════════════════════════════════════
STEP 3 - BUILD RELEASE APK & AAB
════════════════════════════════════════════════════════════════════════════════

3.1 Clean project
  Command: flutter clean

3.2 Get dependencies
  Command: flutter pub get

3.3 Build APK (untuk testing)
  Command: flutter build apk --release
  
  Output akan di: build/app/outputs/flutter-app.apk
  
  Atau build split per architecture:
  Command: flutter build apk --split-per-abi --release
  
  Output:
  - build/app/outputs/app-armeabi-v7a-release.apk (32-bit ARM)
  - build/app/outputs/app-arm64-v8a-release.apk (64-bit ARM)
  - build/app/outputs/app-x86-release.apk (Intel 32-bit)
  - build/app/outputs/app-x86_64-release.apk (Intel 64-bit)

3.4 Build AAB (untuk Play Store - RECOMMENDED)
  Command: flutter build appbundle --release
  
  Output akan di: build/app/outputs/bundle/release/app-release.aab
  
  AAB lebih baik karena:
  - Smaller download size
  - Play Store optimize untuk each device
  - Dynamic feature delivery


════════════════════════════════════════════════════════════════════════════════
STEP 4 - SETUP GOOGLE PLAY DEVELOPER ACCOUNT
════════════════════════════════════════════════════════════════════════════════

4.1 Register Play Developer Account
  Buka: https://play.google.com/apps/publish/
  
  Klik: "Sign up for Google Play Developer"
  
  Process:
  - Accept terms
  - Pay $25 (one-time)
  - Provide payment method (credit card)
  - Setup email & phone verification

4.2 Setup account information
  Setelah login ke Play Console:
  - Settings → Account information
  - Primary email address
  - Phone number

4.3 Setup developer info
  - Settings → Developer account
  - Developer name
  - Email address
  - Website (opsional)


════════════════════════════════════════════════════════════════════════════════
STEP 5 - CREATE APP DI PLAY CONSOLE
════════════════════════════════════════════════════════════════════════════════

5.1 Navigate ke app creation
  Buka: https://play.google.com/console/
  
  Klik: All apps → Create app

5.2 Basic information
  - App name: "Notes App" (atau nama app Anda)
  - Default language: English (atau Bahasa Indonesia)
  - App or game: Choose App
  - Kategori: Productivity
  - Pricing: Free

5.3 Create app
  Klik "Create app"

5.4 Accept agreements
  Checkbox: Confirm compliance
  Klik: "Create app"

5.5 Setup store listing
  Dashboard akan opened.
  
  Klik di sidebar: Main store listing
  
  Isi:
  - App name: "Notes App"
  - Short description: "Create and manage notes with ease"
  - Full description: "A simple and efficient notes app..."
  - Screenshots (upload min 2 PNG/JPG)
  - Feature graphic (1024x500)
  - App icon (512x512 PNG/JPG)
  - Category: Productivity


════════════════════════════════════════════════════════════════════════════════
STEP 6 - UPLOAD BUILD
════════════════════════════════════════════════════════════════════════════════

6.1 Navigate to internal testing
  Sidebar: Releases → Testing → Internal testing

6.2 Create release
  Klik: "Create new release"

6.3 Upload AAB
  Drag & drop atau klik untuk select:
  build/app/outputs/bundle/release/app-release.aab
  
  Upload dan wait untuk processing (1-2 minutes)

6.4 Fill release details
  - Release name: "1.0.0" atau "Initial Release"
  - Release notes: "First release of Notes App"

6.5 Review pre-launch report
  Play Console akan analyze app.
  
  Check untuk:
  - Crashes
  - Performance issues
  - Permission warnings
  - Security issues

6.6 Add internal testers (opsional)
  Klik: "Add testers"
  Enter email addresses dari testers
  Klik: "Add"

6.7 Save dan test
  Testers dapat download dari link yang diberikan.
  
  Test thoroughly sebelum production release!


════════════════════════════════════════════════════════════════════════════════
STEP 7 - CONTENT RATING QUESTIONNAIRE
════════════════════════════════════════════════════════════════════════════════

7.1 Navigate to content rating
  Sidebar: Policies → App content → Content rating

7.2 Fill questionnaire
  Answer questions tentang app content:
  
  - Does app contain fictional violence?
  - Does app contain realistic violence?
  - Does app contain sexual content?
  - Does app contain profanity?
  - Does app collect user data?
  - etc.

7.3 Save
  Klik "Save questionnaire"

7.4 Get rating certificate
  Play Console akan issue rating (PEGI, ESRB, etc.)
  
  Biasanya: 4+ (Everyone) untuk apps simple seperti Notes


════════════════════════════════════════════════════════════════════════════════
STEP 8 - CONFIGURE PRODUCTION RELEASE
════════════════════════════════════════════════════════════════════════════════

8.1 Go to production release
  Sidebar: Releases → Production

8.2 Create new release
  Klik: "Create new release"

8.3 Upload same AAB
  Upload: build/app/outputs/bundle/release/app-release.aab
  (Same file dari internal testing, atau rebuild baru dengan same version)

8.4 Fill details
  - Release name: "Version 1.0.0"
  - Release notes:
    "Initial release of Notes App
    
    Features:
    - Create, read, update, delete notes
    - Cloud sync with Firebase
    - User authentication
    - Modern UI with smooth interactions"

8.5 Review everything
  Double-check:
  - App name correct
  - Description correct
  - Screenshots good
  - App icon clear
  - Content rating appropriate


════════════════════════════════════════════════════════════════════════════════
STEP 9 - SUBMIT FOR REVIEW
════════════════════════════════════════════════════════════════════════════════

9.1 Review page
  Make sure all sections complete (no red errors)

9.2 Click "Submit for review"
  Button usually di top/bottom dari page

9.3 Confirm submission
  Dialog akan appear:
  "Are you sure you want to submit?"
  
  Klik: "Submit"

9.4 Submitted!
  Status akan change to "Submitted for review"
  
  You will receive email notification tentang:
  - App approved (available live)
  - App rejected (reason given)

9.5 Wait 24-48 hours
  Google usually review dalam 1-3 days.
  
  Check email for updates.


════════════════════════════════════════════════════════════════════════════════
STEP 10 - POST-SUBMISSION
════════════════════════════════════════════════════════════════════════════════

10.1 If approved
  Congratulations! 🎉
  
  App akan available di Play Store dalam 2-3 hours.
  
  Share link: https://play.google.com/store/apps/details?id=com.yourname.notesapp

10.2 If rejected
  Check rejection reason email.
  
  Common reasons:
  - Crashes di pre-launch testing
  - Missing permissions explanation
  - Inappropriate content rating
  - Policy violations
  
  Fix issues dan resubmit.

10.3 Monitor first day
  Check Play Console untuk:
  - Crash reports
  - Rating reviews
  - Performance metrics
  
  Fix critical bugs immediately (hotfix).

10.4 Plan next version
  - Collect user feedback dari reviews
  - Plan new features
  - Schedule next release


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Problem: "Build failed - keystore not found"
Solution: Check path di key.properties, make sure file exists

Problem: "Gradle build failed"
Solution: flutter clean ; flutter pub get ; retry

Problem: "APK too large (> 100MB)"
Solution: Use appbundle instead (smaller on Play Store)

Problem: "Pre-launch crashes reported"
Solution: Check crash report, fix bug, rebuild & resubmit

Problem: "App rejected - policy violation"
Solution: Read rejection email, fix issue, resubmit in 6 months

Problem: "Can't see app in Play Store after approval"
Solution: Wait 2-3 hours, refresh Play Store, check package name


════════════════════════════════════════════════════════════════════════════════
IMPORTANT REMINDERS
════════════════════════════════════════════════════════════════════════════════

1. NEVER lose upload-keystore.jks file
   Kalau hilang, tidak bisa update app

2. NEVER share keystore password atau file

3. Version code MUST increment setiap build
   versionCode: 1, 2, 3, 4... (never decrease)

4. Package name PERMANENT after first release
   Cannot change

5. TEST thoroughly di internal testing sebelum production

6. Respond quickly ke crash reports & reviews

7. Keep pubspec.yaml version in sync dengan Android versionName

8. Keep backup of keystore file di aman place


════════════════════════════════════════════════════════════════════════════════
SUCCESS TIMELINE
════════════════════════════════════════════════════════════════════════════════

T-1 day: Final testing, build ready
T-0 day: Create Play Developer account ($25)
T+few hours: Create app di Play Console
T+1 hour: Upload to internal testing
T+4 hours: Internal testing complete
T+6 hours: Create production release
T+7 hours: Submit for review
T+24-48 hours: Approval received ✅ or rejection received ❌
T+48-72 hours: App live di Play Store 🎉
T+ongoing: Monitor & support


════════════════════════════════════════════════════════════════════════════════
NEXT RELEASE (VERSION 2.0.0)
════════════════════════════════════════════════════════════════════════════════

Untuk update aplikasi:

1. Make code changes
2. Update pubspec.yaml version (1.1.0 atau 2.0.0)
3. Update android/app/build.gradle versionCode++
4. flutter clean ; flutter pub get
5. flutter build appbundle --release
6. Upload AAB ke Play Console (production)
7. Klik submit for review
8. Wait untuk approval

Same process, lebih cepat karena sudah setup semua.

*/
