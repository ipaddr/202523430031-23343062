/// APP ICONS SETUP GUIDE
/// ====================
///
/// Panduan lengkap membuat dan setup app icons untuk Android & iOS

/*

════════════════════════════════════════════════════════════════════════════════
STEP 1 - UNDERSTAND APP ICON REQUIREMENTS
════════════════════════════════════════════════════════════════════════════════

Android Icon Requirements:
  - Format: PNG (transparent background recommended)
  - Size: Multiple sizes (ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
  - Main size: 192x192 pixels (xxxhdpi)
  - Color depth: RGBA (with alpha channel for transparency)
  - No rounded corners (system will apply)

iOS Icon Requirements:
  - Format: PNG
  - Size: Multiple sizes (20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 120x120, 152x152, 167x167, 180x180)
  - Color depth: RGBA
  - Rounded corners: iOS akan auto-apply
  - Safe area: Keep important content dalam 20% dari edges

Material Design Guidelines:
  - Use simple shapes
  - Avoid too much detail
  - Design in 192x192 minimum
  - Test at small sizes
  - Consistent with brand


════════════════════════════════════════════════════════════════════════════════
STEP 2 - CREATE APP ICON
════════════════════════════════════════════════════════════════════════════════

OPTION 1 - Using Online Tools (Easiest)

Tool: https://www.canva.com/
  1. Go to Canva.com
  2. Search "App Icon"
  3. Choose template (1080x1080 size)
  4. Design your icon dengan:
     - Simple shapes
     - Solid colors atau gradients
     - Your app name/theme
  5. Export sebagai PNG

Tool: https://romannurik.github.io/AndroidAssetStudio/
  1. Go to Android Asset Studio
  2. Page: Icon Generator → Launcher Icons
  3. Upload icon (min 512x512)
  4. Customize colors & effects
  5. Download zip file
  6. Extract Android icons


OPTION 2 - Using Design Software

Software: Adobe Illustrator / Photoshop / GIMP (free)
  1. Create new document: 512x512 pixels (di-scale nanti)
  2. Use grid (View → Show Grid)
  3. Design icon dengan simple shapes
  4. Export as PNG dengan transparent background
  5. Test di small sizes para sure readable

Atau:
  - Figma (free + cloud): https://figma.com/
  - Affinity Designer
  - Inkscape (free)


OPTION 3 - Using Flutter Icon Generator

Flutter Flutter packages: flutter_launcher_icons

Setup:
  1. Add ke pubspec.yaml:
     dev_dependencies:
       flutter_launcher_icons: "^0.13.1"
  
  2. Create flutter_launcher_icons.yaml di root:
     flutter_launcher_icons:
       android: "launcher_icon"
       ios: true
       image_path: "assets/launcher_icon.png"
       min_sdk_android: 24

  3. Put icon image:
     Location: assets/launcher_icon.png
     Size: 512x512 minimum
     Format: PNG

  4. Run command:
     flutter pub run flutter_launcher_icons


════════════════════════════════════════════════════════════════════════════════
STEP 3 - SETUP ANDROID ICONS MANUALLY
════════════════════════════════════════════════════════════════════════════════

3.1 Create required icon sizes

Icon sizes untuk Android (dalam pixels):
  - ldpi:   36x36    (Low density)
  - mdpi:   48x48    (Medium - baseline)
  - hdpi:   72x72    (High)
  - xhdpi:  96x96    (Extra High)
  - xxhdpi: 144x144  (Extra Extra High)
  - xxxhdpi: 192x192 (Extra Extra Extra High)

Buat icon file dengan nama yang sama: ic_launcher.png

Atau gunakan Android Asset Studio untuk auto-generate.


3.2 Place icons dalam Android folders

Folder structure:
  android/app/src/main/res/
  ├── mipmap-ldpi/
  │   └── ic_launcher.png (36x36)
  ├── mipmap-mdpi/
  │   └── ic_launcher.png (48x48)
  ├── mipmap-hdpi/
  │   └── ic_launcher.png (72x72)
  ├── mipmap-xhdpi/
  │   └── ic_launcher.png (96x96)
  ├── mipmap-xxhdpi/
  │   └── ic_launcher.png (144x144)
  └── mipmap-xxxhdpi/
      └── ic_launcher.png (192x192)

3.3 Update AndroidManifest.xml

File: android/app/src/main/AndroidManifest.xml

Cari line:
  android:icon="@mipmap/ic_launcher"

Pastikan sudah correct (biasanya sudah default).


3.4 Clean & rebuild

Command:
  flutter clean
  flutter pub get
  flutter run

Android icons sekarang sudah aktif!


════════════════════════════════════════════════════════════════════════════════
STEP 4 - SETUP iOS ICONS
════════════════════════════════════════════════════════════════════════════════

4.1 Open iOS project di Xcode

Command:
  open ios/Runner.xcworkspace

Atau manual:
  1. Double-click: ios/Runner.xcworkspace
  2. Xcode akan open


4.2 Navigate to App Icon folder

Di Xcode left sidebar:
  1. Click Runner project
  2. Click Runner app
  3. Tab: Build Settings → Search "App Icon"
  4. Or: Assets.xcassets → AppIcon


4.3 Setup icon di AppIcon set

Xcode akan show grid dengan semua size:
  - 20x20 (iPhone notification)
  - 29x29 (iPhone settings)
  - 40x40 (iPhone spotlight)
  - 60x60 (iPhone app)
  - 76x76 (iPad app)
  - 83.5x83.5 (iPad pro app)
  - 120x120 (iPhone app 2x)
  - 152x152 (iPad app 2x)
  - 167x167 (iPad pro app 2x)
  - 180x180 (iPhone app 3x)

Untuk setiap size:
  1. Drag & drop icon image
  2. Xcode auto-scale ke correct size
  3. Make sure image resolution match (actual pixels, not points)

List lengkap required icons:
  iPhone Notification -20x20@2x (40x40px)
  iPhone Notification -20x20@3x (60x60px)
  iPhone Settings -29x29@2x (58x58px)
  iPhone Settings -29x29@3x (87x87px)
  iPhone Spotlight -40x40@2x (80x80px)
  iPhone Spotlight -40x40@3x (120x120px)
  iPhone App -60x60@2x (120x120px)
  iPhone App -60x60@3x (180x180px)
  iPad App -76x76@1x (76x76px)
  iPad App -76x76@2x (152x152px)
  iPad Pro App -83.5x83.5@2x (167x167px)
  App Store 1024x1024@1x (1024x1024px)

4.4 Alternative - Using Contents.json

File: ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json

Bisa edit manually, atau lebih mudah guna Xcode UI.


4.5 Verify & build

Clean & rebuild:
  flutter clean
  flutter pub get
  flutter run

iOS icons sekarang akan aktif!


════════════════════════════════════════════════════════════════════════════════
STEP 5 - AUTOMATED ICON GENERATION (RECOMMENDED)
════════════════════════════════════════════════════════════════════════════════

5.1 Add flutter_launcher_icons package

Edit pubspec.yaml:

dev_dependencies:
  flutter_launcher_icons: "^0.13.1"

atau latest version:
  flutter pub add flutter_launcher_icons --dev


5.2 Create configuration file

Create file: flutter_launcher_icons.yaml (di project root, same level sebagai pubspec.yaml)

Content:
  flutter_launcher_icons:
    android: "launcher_icon"
    ios: true
    image_path: "assets/icon/app_icon.png"
    image_path_ios: "assets/icon/app_icon_ios.png"  (opsional, specific iOS)
    min_sdk_android: 24
    # Untuk adaptive icon (Android 8+):
    adaptive_icon_background: "#FFFFFF"
    adaptive_icon_foreground: "assets/icon/foreground.png"  (opsional)

Alternative dengan minimal config:
  flutter_launcher_icons:
    android: true
    ios: true
    image_path: "assets/launcher_icon.png"


5.3 Prepare icon image

Path: assets/icon/app_icon.png (atau sesuai config)
Size: 1024x1024 pixels minimum (preferably)
Format: PNG dengan transparent background

Atau untuk adaptive icon Android:
  - app_icon.png (1024x1024)
  - foreground.png (1080x1080, untuk adaptive foreground)


5.4 Run command

Command:
  flutter pub get
  flutter pub run flutter_launcher_icons

Output akan:
  - Generate all Android icon sizes
  - Generate all iOS icon sizes
  - Update AndroidManifest.xml (jika perlu)
  - Update iOS project

5.5 Verify hasil

Check folders:
  - Android: android/app/src/main/res/mipmap-(all densities)/ic_launcher.png
  - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/

Rebuild:
  flutter clean
  flutter pub get
  flutter run


════════════════════════════════════════════════════════════════════════════════
STEP 6 - ADAPTIVE ICONS (ANDROID 8+)
════════════════════════════════════════════════════════════════════════════════

Android 8+ support adaptive icons (icon background + foreground).

6.1 Create adaptive icon files

File 1: foreground.png (1080x1080 pixels)
  - Transparent background
  - Icon image in center (safe area: center 66x66% untuk safe zone)
  - Dapat berbeda warna dari background

File 2: background.png atau color (108x1080 pixels)
  - Solid color recommended
  - Atau simple pattern

6.2 Setup adaptive icon

Di flutter_launcher_icons.yaml:
  flutter_launcher_icons:
    android: "launcher_icon"
    adaptive_icon_background: "#FFFFFF"  (atau color code)
    adaptive_icon_foreground: "assets/adaptive_icon_foreground.png"

6.3 Manual setup (tanpa package)

Edit: android/app/src/main/AndroidManifest.xml

Change:
  <section android:icon="@mipmap/ic_launcher">

To:
  <section android:icon="@mipmap-v26/ic_launcher">

Create: android/app/src/main/res/mipmap-v26/ic_launcher.xml

Content:
  <?xml version="1.0" encoding="utf-8"?>
  <adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_bg"/>
    <foreground android:drawable="@drawable/ic_launcher_fg"/>
  </adaptive-icon>

Create: android/app/src/main/res/values/colors.xml

Content:
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <color name="ic_launcher_bg">#FFFFFF</color>
  </resources>

Lalu add foreground image:
  PNG file: android/app/src/main/res/drawable/ic_launcher_fg.png


════════════════════════════════════════════════════════════════════════════════
STEP 7 - PLAY STORE ICON REQUIREMENTS
════════════════════════════════════════════════════════════════════════════════

Untuk Play Store listing, diperlukan:

1. App Icon (512x512 PNG)
   - Display di Play Store
   - Different dari launcher icon
   - Can be more detailed
   - Transparent background recommended

2. Feature Graphic (1024x500 pixels)
   - Header image di Play Store
   - tidak required tapi recommended
   - PNG/JPG format

3. Screenshots (min 2, max 8)
   - Actual app screenshots
   - Various devices recommended
   - Include text explaining features


════════════════════════════════════════════════════════════════════════════════
CHECKLIST - APP ICONS
════════════════════════════════════════════════════════════════════════════════

□ Created app icon (512x512 minimum)
□ Setup Android icons (di mipmap-(all densities) folder)
□ Setup iOS icons (di AppIcon.appiconset/)
□ Updated AndroidManifest.xml (jika perlu)
□ Ran flutter clean
□ Ran flutter pub get
□ Tested di Android emulator/device
□ Tested di iOS simulator/device
□ Icon visible di launcher
□ Icon visible di app drawer
□ No pixelation di small sizes
□ (Optional) Setup adaptive icon untuk Android 8+
□ (Optional) Used flutter_launcher_icons untuk automation


════════════════════════════════════════════════════════════════════════════════
ICON DESIGN TIPS
════════════════════════════════════════════════════════════════════════════════

✅ DO:
  - Use simple, recognizable shapes
  - Keep important content in center
  - Use 1-2 colors maximum (plus background)
  - Design for both light & dark themes
  - Test at small sizes (32x32)
  - Follow material design guidelines
  - Use consistent style dengan app

❌ DON'T:
  - Too much detail (akan jadi blur kecil)
  - Text yang terlalu kecil
  - Gradients yang kompleks
  - Multiple colors (confusing)
  - Copy copyrighted material
  - Different style dari app branding


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Problem: Icon tidak berubah setelah update

Solution:
  1. flutter clean
  2. Uninstall app dari device
  3. flutter run

Atau:
  adb uninstall com.yourcompany.notesapp
  flutter run


Problem: Icon blurry atau pixelated

Solution:
  - Icon size terlalu kecil (gunakan min 512x512)
  - Upscale icon file
  - Use vector format (.svg) then export sebagai PNG


Problem: Icon tidak round (iOS)

Solution:
  - iOS auto-rounds icon corners
  - Jangan buat icon dengan rounded corners sendiri
  - Let iOS handle rounding


Problem: Adaptive icon tidak work

Solution:
  - Min Android 8 (API 26)
  - Check AndroidManifest.xml
  - Verify adaptive_icon XML file


════════════════════════════════════════════════════════════════════════════════
QUICK SUMMARY - SETTING UP ICONS
════════════════════════════════════════════════════════════════════════════════

Fastest way (automated):

1. Create icon: 1024x1024 PNG
   Save as: assets/launcher_icon.png

2. Add package:
   flutter pub add flutter_launcher_icons --dev

3. Create flutter_launcher_icons.yaml:
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/launcher_icon.png"

4. Generate icons:
   flutter pub run flutter_launcher_icons

5. Clean & run:
   flutter clean
   flutter pub get
   flutter run

Done! ✅

*/
