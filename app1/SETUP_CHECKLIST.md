# Firebase Setup Checklist

Status: **In Progress** ⏳

## Phase 1: Prerequisites ✅

- [ ] Google Account exists
- [ ] Firebase Project created at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Flutter environment configured
- [ ] Android SDK configured (for Android build)
- [ ] Xcode installed (for iOS build - if testing on iOS)

## Phase 2: Project Dependencies ✅

- [x] `pubspec.yaml` updated with Firebase dependencies:
  - [x] firebase_core: ^2.24.0
  - [x] firebase_auth: ^4.15.0
  - [x] cloud_firestore: ^4.14.0
  - [x] firebase_storage: ^11.5.0
  - [x] firebase_messaging: ^14.7.0
  - [x] firebase_analytics: ^10.7.0
- [x] `main.dart` updated with Firebase initialization
- [ ] Run `flutter pub get`

## Phase 3: Firebase Configuration Files ✅

- [x] `firebase_options.dart` created
- [x] `services/firebase_service.dart` created
- [x] `services/auth_service.dart` created
- [x] `services/firestore_service.dart` created
- [x] `models/models.dart` created with example models

## Phase 4: Android Setup

### Download Configuration
- [ ] Go to [Firebase Console](https://console.firebase.google.com)
- [ ] Select your project
- [ ] Go to Project Settings → Your apps → Android app
- [ ] Download `google-services.json`

### Install Configuration
- [ ] Place `google-services.json` in `android/app/`
- [ ] Update `android/build.gradle.kts` with Google Services plugin
- [ ] Update `android/app/build.gradle.kts` with Firebase dependencies
- [ ] Update `android/app/src/main/AndroidManifest.xml` with permissions

### Update firebase_options.dart
- [ ] Copy Android credentials from Firebase Console
- [ ] Update `android` constant in `firebase_options.dart`:
  - [ ] apiKey
  - [ ] appId
  - [ ] messagingSenderId
  - [ ] projectId
  - [ ] storageBucket

## Phase 5: iOS Setup (Optional)

### Download Configuration
- [ ] Go to [Firebase Console](https://console.firebase.google.com)
- [ ] Download `GoogleService-Info.plist`

### Install Configuration
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Drag `GoogleService-Info.plist` to Xcode Runner target
- [ ] Select "Copy if needed"

### Update firebase_options.dart
- [ ] Copy iOS credentials from Firebase Console
- [ ] Update `ios` constant in `firebase_options.dart`:
  - [ ] apiKey
  - [ ] appId
  - [ ] messagingSenderId
  - [ ] projectId
  - [ ] storageBucket
  - [ ] iosBundleId

## Phase 6: Web Setup (Optional)

### Update firebase_options.dart
- [ ] Copy Web credentials from Firebase Console
- [ ] Update `web` constant:
  - [ ] apiKey
  - [ ] appId
  - [ ] messagingSenderId
  - [ ] projectId
  - [ ] storageBucket
  - [ ] authDomain

## Phase 7: Verify Installation

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter run` (Android)
  - [ ] No build errors
  - [ ] App starts successfully
  - [ ] Firebase initialized correctly
- [ ] Check console logs untuk Firebase initialization message

## Phase 8: Firebase Services Configuration

### Authentication
- [ ] Go to Firebase Console → Authentication
- [ ] Enable "Email/Password" sign-in method
- [ ] Test signup/login functionality

### Firestore Database
- [ ] Go to Firebase Console → Firestore Database
- [ ] Click "Create Database"
- [ ] Choose region (Asia Southeast 1 for Indonesia)
- [ ] Choose "Start in test mode" (for development)
- [ ] Create collections for your app:
  - [ ] `users` collection
  - [ ] `posts` collection
  - [ ] Other collections as needed

### Firebase Storage (Optional)
- [ ] Go to Firebase Console → Storage
- [ ] Create bucket
- [ ] Choose region
- [ ] Test file upload/download

### Firebase Messaging (Optional)
- [ ] Go to Firebase Console → Messaging
- [ ] Enable Cloud Messaging
- [ ] Get Server API Key for push notifications

## Phase 9: Update Firestore Security Rules

**FOR DEVELOPMENT (Testing):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**FOR PRODUCTION:**
- [ ] Implement proper security rules
- [ ] Users can only access their own data
- [ ] Collections have proper access controls
- [ ] See FIREBASE_SETUP.md for examples

## Phase 10: Test Firebase Features

### Authentication Testing
- [ ] Sign up new user
- [ ] Login with credentials
- [ ] Logout functionality
- [ ] Current user retrieval
- [ ] Reset password flow

### Firestore Testing
- [ ] Create document
- [ ] Read document
- [ ] Update document
- [ ] Delete document
- [ ] List all documents
- [ ] Query with where clause
- [ ] Real-time stream updates

### Storage Testing (Optional)
- [ ] Upload file
- [ ] Get download URL
- [ ] Delete file

## Phase 11: Documentation Review

- [ ] Read FIREBASE_SETUP.md
- [ ] Read ANDROID_FIREBASE_SETUP.md
- [ ] Read EXAMPLES.md
- [ ] Read QUICK_REFERENCE.md
- [ ] Understand service architecture
- [ ] Understand model structure

## Phase 12: Customization

- [ ] Update `models.dart` for your data models
- [ ] Create custom services if needed
- [ ] Add project-specific utilities
- [ ] Update security rules for production

## Phase 13: Production Preparation

- [ ] Review security rules
- [ ] Test on actual devices
- [ ] Configure app signing (Android)
- [ ] Setup CI/CD if needed
- [ ] Enable analytics
- [ ] Setup error monitoring

## Common Issues Log

Use this section to track any issues encountered:

| Issue | Date | Status | Solution |
|-------|------|--------|----------|
|       |      |        |          |

---

## Notes

- **Start Date:** _________________
- **Expected Completion:** _________________
- **Actual Completion:** _________________

### Additional Configuration Notes:

```
[Add your custom notes here]
```

---

## Resources

- [Firebase Console](https://console.firebase.google.com)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- [ANDROID_FIREBASE_SETUP.md](ANDROID_FIREBASE_SETUP.md)
- [EXAMPLES.md](EXAMPLES.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

**Last Updated:** February 17, 2026
**Status:** Ready for Configuration ✅
