/// SPLASH SCREEN SETUP GUIDE
/// =========================
///
/// Panduan lengkap membuat dan setup splash screen untuk notes app

/*

════════════════════════════════════════════════════════════════════════════════
SPLASH SCREEN APA ITU?
════════════════════════════════════════════════════════════════════════════════

Splash Screen = layar pertama yang muncul saat app dibuka.

Fungsi:
  - Brand/logo display
  - Loading indicator
  - Pre-load data sebelum main app
  - Professional appearance
  - Better UX (tidak langsung menampilkan UI kosong)

Timing: Biasanya 1-3 detik, bisa disesuaikan


════════════════════════════════════════════════════════════════════════════════
STEP 1 - UNDERSTAND SPLASH SCREEN TYPES
════════════════════════════════════════════════════════════════════════════════

Type 1: Native Splash (Android/iOS default)
  - Fastest loading
  - Set di native configuration
  - Muncul sebelum Dart VM run
  - Cocok untuk branding sederhana

Type 2: Flutter Splash (dalam Dart code)
  - Full customization
  - Muncul setelah app start
  - Bisa animasi complex
  - Cocok untuk loading logic


Untuk project ini: Kombinasi both (native + Flutter untuk smooth transition)


════════════════════════════════════════════════════════════════════════════════
STEP 2 - SETUP NATIVE SPLASH (ANDROID)
════════════════════════════════════════════════════════════════════════════════

2.1 Create splash screen drawable

File: android/app/src/main/res/drawable/splash.xml

Content:
  <?xml version="1.0" encoding="utf-8"?>
  <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Background color -->
    <item android:drawable="@color/splash_background"/>
    
    <!-- Logo/icon centered -->
    <item>
      <bitmap
        android:src="@drawable/splash_logo"
        android:gravity="center"/>
    </item>
  </layer-list>

Note: splash_logo harus ada di drawable folder


2.2 Create splash colors

File: android/app/src/main/res/values/colors.xml

Content:
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <color name="splash_background">#FFFFFF</color>
    <color name="app_primary">#2196F3</color>
  </resources>

Atau update existing colors.xml dengan add:
  <color name="splash_background">#FFFFFF</color>


2.3 Create splash theme

File: android/app/src/main/res/values/styles.xml

Content:
  <?xml version="1.0" encoding="utf-8"?>
  <resources>
    <style name="SplashTheme" parent="Theme.AppCompat.Light.NoActionBar">
      <item name="android:windowFullscreen">true</item>
      <item name="android:windowBackground">@drawable/splash</item>
    </style>
    
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoActionBar">
      <item name="android:windowNoTitle">true</item>
      <item name="android:windowActionBar">false</item>
    </style>
  </resources>


2.4 Create splash activity

File: android/app/src/main/java/com/example/app1/SplashActivity.java

Content:
  package com.example.app1;
  
  import android.content.Intent;
  import android.os.Bundle;
  import androidx.appcompat.app.AppCompatActivity;
  
  public class SplashActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      
      // Immediately start MainActivity
      Intent intent = new Intent(this, MainActivity.class);
      startActivity(intent);
      finish();
    }
  }

Or simpler: Gunakan package flutter_native_splash (lihat STEP 4)


2.5 Update AndroidManifest.xml

File: android/app/src/main/AndroidManifest.xml

Find:
  <activity
    android:name=".MainActivity"
    android:theme="@style/LaunchTheme"
    ...>

Change to:
  <activity
    android:name=".SplashActivity"
    android:theme="@style/SplashTheme"
    android:exported="true">
    <intent-filter>
      <action android:name="android.intent.action.MAIN"/>
      <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
  </activity>
  
  <activity
    android:name=".MainActivity"
    android:theme="@style/NormalTheme"
    android:exported="true"/>


════════════════════════════════════════════════════════════════════════════════
STEP 3 - SETUP NATIVE SPLASH (iOS)
════════════════════════════════════════════════════════════════════════════════

3.1 Open Xcode project

Command:
  open ios/Runner.xcworkspace

3.2 Open LaunchScreen.storyboard

Di Xcode sidebar:
  1. Click Runner project
  2. Double-click LaunchScreen.storyboard
  3. Edit design canvas


3.3 Setup splash design

Design options:

Option A: Minimal (color + app name)
  - Add ImageView dengan app icon
  - Add Label dengan app name
  - Center both elements
  - Set background color

Option B: Logo + branding
  - Add ImageView dengan logo image
  - Resize & position di center top
  - Add app name label di center
  - Add tagline label di center bottom

Option C: Full background
  - Add ImageView dengan background image
  - Set to stretch (Aspect Fill)
  - Add icon/logo on top


3.4 Set constraints

Untuk responsive layout:
  1. Select element
  2. Use constraints untuk center
  3. Set alignment to HorizontalCenter & VerticalCenter

Option: Gunakan Aspect Fit agar scale dengan device


3.5 Add dynamic colors (optional)

Xcode 12+:
  1. Select View
  2. Attributes inspector
  3. Set background color dengan dynamic (light/dark mode)


════════════════════════════════════════════════════════════════════════════════
STEP 4 - AUTOMATED SPLASH SETUP (RECOMMENDED)
════════════════════════════════════════════════════════════════════════════════

Gunakan package: flutter_native_splash

Ini lebih mudah than manual setup.


4.1 Add package

Command:
  flutter pub add flutter_native_splash

Atau edit pubspec.yaml:
  dev_dependencies:
    flutter_native_splash: ^2.3.0


4.2 Create configuration file

File: flutter_native_splash.yaml (di project root)

Minimal config:
  flutter_native_splash:
    color: "#FFFFFF"
    image: assets/splash/splash_logo.png
    color_dark: "#1F1F1F"
    image_dark: assets/splash/splash_logo_dark.png
    android_12:
      image: assets/splash/splash_logo.png
      icon_background_color: "#FFFFFF"
    web: false


Full config dengan options:
  flutter_native_splash:
    # Background
    color: "#FFFFFF"
    color_dark: "#1F1F1F"
    
    # Logo image
    image: assets/splash/splash_logo.png
    image_dark: assets/splash/splash_logo_dark.png
    
    # Android specific
    android: true
    android_12:
      image: assets/splash/splash_logo.png
      icon_background_color: "#FFFFFF"
    
    # iOS specific
    ios: true
    
    # Web
    web: false
    
    # Animation (optional)
    android_gravity: center
    
    # Fullscreen
    full_screen: false
    
    # Branding
    branding: assets/secondary_branding.png
    branding_dark: assets/secondary_branding_dark.png


4.3 Prepare splash image

Path: assets/splash/splash_logo.png
Size: 1024x1024 pixels (akan auto-resize)
Format: PNG transparent background recommended


4.4 Run splash generation

Command:
  dart run flutter_native_splash:create

Output akan:
  - Generate Android drawable files
  - Generate iOS files
  - Update AndroidManifest.xml
  - Update iOS project

4.5 Verify

Check files:
  - Android: android/app/src/main/res/drawable (various)/splash (files).xml
  - iOS: ios/Runner/Base.lproj/LaunchScreen.storyboard


════════════════════════════════════════════════════════════════════════════════
STEP 5 - FLUTTER SPLASH SCREEN IN-APP
════════════════════════════════════════════════════════════════════════════════

Native splash hanya untuk branding.
Untuk loading logic, buat Flutter splash screen.


5.1 Create splash screen widget

File: lib/screens/splash_screen.dart

Simple example:

  import 'package:flutter/material.dart';
  
  class SplashScreen extends StatefulWidget {
    const SplashScreen({Key key}) : super(key: key);
  
    @override
    State<SplashScreen> createState() => _SplashScreenState();
  }
  
  class _SplashScreenState extends State<SplashScreen> {
    @override
    void initState() {
      super.initState();
      _navigateToHome();
    }
  
    _navigateToHome() async {
      await Future.delayed(Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app_logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 20),
              Text(
                'Notes App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
  }


5.2 Integration ke main.dart

Update main route:

  MaterialApp(
    home: SplashScreen(),
    routes: {
      '/home': (context) => HomeScreen(),
      '/login': (context) => LoginScreen(),
    },
  )


5.3 Dengan BLoC (untuk async operations)

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

Dan listen ke auth state:

  BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthenticatedState) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (state is UnauthenticatedState) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    },
    child: SplashScreen(),
  )


════════════════════════════════════════════════════════════════════════════════
STEP 6 - SPLASH WITH ANIMATION
════════════════════════════════════════════════════════════════════════════════

6.1 Animated logo example

  class _SplashScreenState extends State<SplashScreen>
      with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _animation;
  
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: Duration(milliseconds: 1500),
        vsync: this,
      );
  
      _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
  
      _controller.forward();
      _navigateToHome();
    }
  
    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/app_logo.png', width: 120),
                  SizedBox(height: 20),
                  Text('Notes App'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }


6.2 Loading bar animation

  LinearProgressIndicator(
    value: _animation.value,
    minHeight: 3,
  )


════════════════════════════════════════════════════════════════════════════════
STEP 7 - SPLASH SCREEN ASSET PREPARATION
════════════════════════════════════════════════════════════════════════════════

Asset requirements:

Folder structure:
  assets/
  └── splash/
      ├── splash_logo.png (1024x1024)
      ├── splash_logo_dark.png (1024x1024, untuk dark mode)
      └── splash_background.png (optional, full screen background)

Image specs:
  - Logo: 512x512 - 1024x1024 pixels
  - Format: PNG transparent background
  - Dark mode version: Optional tapi recommended
  - Background: Full device width/height

Update pubspec.yaml:

  flutter:
    assets:
      - assets/
      - assets/splash/
      - assets/app_logo.png


════════════════════════════════════════════════════════════════════════════════
STEP 8 - COMPLETE SETUP EXAMPLE
════════════════════════════════════════════════════════════════════════════════

8.1 Directory structure

  app1/
  ├── pubspec.yaml
  ├── flutter_native_splash.yaml
  ├── assets/
  │   └── splash/
  │       ├── splash_logo.png
  │       └── splash_logo_dark.png
  ├── lib/
  │   ├── main.dart
  │   └── screens/
  │       └── splash_screen.dart
  ├── android/
  │   └── app/
  │       └── src/main/
  │           ├── res/
  │           │   ├── drawable/
  │           │   │   └── splash_logo.png
  │           │   ├── values/
  │           │   │   └── colors.xml
  │           │   └── values-night/
  │           │       └── colors.xml
  │           └── AndroidManifest.xml
  └── ios/
      └── Runner/
          ├── Assets.xcassets/
          └── Base.lproj/
              └── LaunchScreen.storyboard


8.2 pubspec.yaml update

Add:
  dev_dependencies:
    flutter_native_splash: ^2.3.0
  
  flutter:
    assets:
      - assets/
      - assets/splash/


8.3 Run all setup

Commands:
  1. flutter pub get
  2. dart run flutter_native_splash:create
  3. flutter clean
  4. flutter run


════════════════════════════════════════════════════════════════════════════════
STEP 9 - TESTING SPLASH SCREEN
════════════════════════════════════════════════════════════════════════════════

9.1 Android testing

Command:
  flutter run

Verify:
  - Splash muncul saat app start
  - Logo visible & centered
  - Splash duration ~1-2 detik
  - Smooth transition ke home
  - No lag atau flicker


9.2 iOS testing

Command:
  flutter run -i

Atau:
  open -a Simulator
  flutter run


Verify:
  - Same checklist sebagai Android
  - Check di portrait & landscape
  - Test sa dark mode (swipe down control center)


9.3 Platform-specific testing

Android emulator:
  flutter emulators --launch Pixel_3
  flutter run

iOS simulator:
  xcrun simctl erase all
  flutter run -i


════════════════════════════════════════════════════════════════════════════════
STEP 10 - CUSTOMIZATION & STYLING
════════════════════════════════════════════════════════════════════════════════

10.1 Change splash duration

In Flutter splash screen:

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2));  // 2 detik
    Navigator.pushReplacementNamed(context, '/home');
  }


10.2 Add branded colors

In flutter_native_splash.yaml:

  flutter_native_splash:
    color: "#2196F3"  // App primary color
    color_dark: "#1B1B1B"  # Dark mode


10.3 Add loading text

In Flutter widget:

  Text(
    'Loading...',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
  )


10.4 Add version text

  Text(
    'v1.0.0',
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    ),
  )


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Problem: Splash tidak muncul, langsung ke home

Solution:
  - Check AndroidManifest.xml launcher activity
  - Pastikan SplashActivity di manifest
  - Verify native splash file ada
  - Run flutter clean


Problem: Splash image blurry

Solution:
  - Gunakan image yang lebih besar (1024x1024 minimum)
  - Check image asset path correct
  - Buat multiple density images


Problem: Splash too long/short

Solution:
  - Adjust duration di SplashScreen initState
  - Default: 1000-2000 milliseconds recommended


Problem: Dark mode tidak work

Solution:
  - Create colors-night/colors.xml
  - Create splash_logo_dark.png
  - Setup flutter_native_splash.yaml dengan color_dark & image_dark


Problem: Transition jadi jerky

Solution:
  - Pastikan app initialization cepat
  - Jangan load heavy data di splash
  - Use background isolates untuk pre-loading


════════════════════════════════════════════════════════════════════════════════
CHECKLIST - SPLASH SCREEN SETUP
════════════════════════════════════════════════════════════════════════════════

□ Created splash logo image (1024x1024 PNG)
□ Created splash_logo_dark.png untuk dark mode
□ Added flutter_native_splash package
□ Created flutter_native_splash.yaml config
□ Ran dart run flutter_native_splash:create
□ Verified Android drawable files created
□ Verified iOS LaunchScreen.storyboard updated
□ Created SplashScreen widget di lib/screens/
□ Updated main.dart with SplashScreen as home
□ Setup asset paths di pubspec.yaml
□ Tested on Android emulator
□ Tested on iOS simulator
□ Checked splash duration (1-2 detik)
□ Verified smooth transition ke home
□ Tested dark mode splash
□ No crash atau error logs


════════════════════════════════════════════════════════════════════════════════
QUICK SUMMARY - SPLASH SCREEN SETUP
════════════════════════════════════════════════════════════════════════════════

Fastest way (automated):

1. Create splash logo: 1024x1024 PNG
   Save as: assets/splash/splash_logo.png

2. Add package:
   flutter pub add flutter_native_splash

3. Create flutter_native_splash.yaml:
   flutter_native_splash:
     color: "#FFFFFF"
     image: assets/splash/splash_logo.png

4. Generate splash:
   dart run flutter_native_splash:create

5. Create SplashScreen widget:
   lib/screens/splash_screen.dart

6. Update main.dart:
   home: SplashScreen(),

7. Test:
   flutter clean
   flutter run

Done! ✅

*/
