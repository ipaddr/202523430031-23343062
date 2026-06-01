# Firebase Backend Setup Guide

## 📋 Overview

Firebase Backend telah dikonfigurasi untuk proyek Flutter Anda dengan dukungan lengkap untuk:
- ✅ Authentication (Firebase Auth)
- ✅ Realtime Database (Cloud Firestore)
- ✅ File Storage (Firebase Storage)
- ✅ Cloud Messaging (Firebase Messaging)
- ✅ Analytics

---

## 🔧 Setup Awal

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Konfigurasi Firebase

#### Untuk Android:

1. **Download `google-services.json`:**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Pilih project Anda
   - Go to Project Settings → Download `google-services.json`
   - Paste ke `android/app/`

2. **Edit `firebase_options.dart`:**
   - Ganti placeholder values dengan konfigurasi dari Firebase Console
   - Ambil dari Project Settings

#### Untuk iOS:

1. **Download `GoogleService-Info.plist`:**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Buka iOS project: `ios/Runner.xcworkspace`
   - Drag file ke Xcode under Runner target

2. **Edit `firebase_options.dart`:**
   - Ganti placeholder values dengan konfigurasi dari Firebase Console

#### Untuk Web:

1. **Copy Firebase Config:**
   - Dari Firebase Console → Project Settings
   - Copy firebaseConfig object
   - Update di `firebase_options.dart`

---

## 📚 Cara Penggunaan

### 1. Authentication Service

```dart
import 'package:app1/services/auth_service.dart';

final authService = AuthService();

// Sign Up
final result = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

if (result.isSuccess) {
  print('Sign up berhasil: ${result.user?.email}');
} else {
  print('Error: ${result.message}');
}

// Login
final loginResult = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await authService.logout();

// Reset Password
await authService.resetPassword(email: 'user@example.com');

// Listen to Auth State Changes
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User logged in: ${user.email}');
  } else {
    print('User logged out');
  }
});
```

### 2. Firestore Service

```dart
import 'package:app1/services/firestore_service.dart';
import 'package:app1/models/models.dart';

final firestoreService = FirestoreService();

// CREATE - Add dokumen
String docId = await firestoreService.addDocument(
  collection: 'posts',
  data: {
    'title': 'Judul Post',
    'content': 'Konten post',
    'authorId': 'user123',
  },
);

// CREATE - Set dengan custom ID
await firestoreService.setDocument(
  collection: 'users',
  docId: 'user123',
  data: {
    'displayName': 'John Doe',
    'email': 'john@example.com',
  },
);

// READ - Get single document
PostModel? post = await firestoreService.getDocument<PostModel>(
  collection: 'posts',
  docId: 'postId123',
  fromJson: (json) => PostModel.fromJson(json),
);

// READ - Get all documents
List<PostModel> posts = await firestoreService.getCollection<PostModel>(
  collection: 'posts',
  fromJson: (json) => PostModel.fromJson(json),
);

// UPDATE - Update document
await firestoreService.updateDocument(
  collection: 'posts',
  docId: 'postId123',
  data: {
    'title': 'Judul baru',
    'content': 'Konten baru',
  },
);

// UPDATE - Increment field
await firestoreService.incrementField(
  collection: 'posts',
  docId: 'postId123',
  fieldName: 'likes',
  value: 1,
);

// UPDATE - Add to array
await firestoreService.addToArray(
  collection: 'posts',
  docId: 'postId123',
  fieldName: 'tags',
  value: 'flutter',
);

// DELETE - Delete document
await firestoreService.deleteDocument(
  collection: 'posts',
  docId: 'postId123',
);

// QUERY - Where clause
List<PostModel> userPosts = await firestoreService.query<PostModel>(
  collection: 'posts',
  field: 'authorId',
  operator: '==',
  value: 'user123',
  fromJson: (json) => PostModel.fromJson(json),
);

// STREAM - Real-time updates (single document)
firestoreService.streamDocument<PostModel>(
  collection: 'posts',
  docId: 'postId123',
  fromJson: (json) => PostModel.fromJson(json),
).listen((post) {
  print('Post updated: ${post?.title}');
});

// STREAM - Real-time updates (collection)
firestoreService.streamCollection<PostModel>(
  collection: 'posts',
  fromJson: (json) => PostModel.fromJson(json),
).listen((posts) {
  print('Posts count: ${posts.length}');
});
```

### 3. Firestore dalam Widgets

```dart
import 'package:flutter/material.dart';
import 'package:app1/services/firestore_service.dart';
import 'package:app1/models/models.dart';

class PostsPage extends StatelessWidget {
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: firestoreService.streamCollection<PostModel>(
        collection: 'posts',
        fromJson: (json) => PostModel.fromJson(json),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(child: Text('Tidak ada post'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.content),
            );
          },
        );
      },
    );
  }
}
```

### 4. Firebase Storage

```dart
import 'package:app1/services/firebase_service.dart';

final firebaseService = FirebaseService();

// Upload file
String downloadUrl = await firebaseService.uploadFile(
  path: 'post_images/image.jpg',
  filePath: '/local/path/to/image.jpg',
);

// Get download URL
String url = await firebaseService.getDownloadUrl(
  path: 'post_images/image.jpg',
);

// Delete file
await firebaseService.deleteFile(
  path: 'post_images/image.jpg',
);
```

---

## 📁 File Structure

```
lib/
├── main.dart                 # Entry point dengan Firebase init
├── firebase_options.dart    # Firebase configuration
├── services/
│   ├── firebase_service.dart     # Core Firebase service
│   ├── auth_service.dart         # Authentication wrapper
│   └── firestore_service.dart    # Firestore wrapper
├── models/
│   └── models.dart           # Data models (UserModel, PostModel, dll)
└── ...
```

---

## 🔐 Firebase Security Rules

### Firestore Rules (Development - Testing Only)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes (ONLY FOR DEVELOPMENT)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Firestore Rules (Production - Recommended)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - user hanya bisa read/write profile mereka sendiri
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
    }

    // Posts collection - siapa saja bisa baca, hanya owner yang bisa edit
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }
  }
}
```

---

## ⚙️ Advanced Features

### 1. Batch Operations

```dart
final firebaseService = FirebaseService();

await firebaseService.batchWrite((batch) {
  batch.set(
    FirebaseFirestore.instance.collection('posts').doc('doc1'),
    {'title': 'Post 1'},
  );
  batch.set(
    FirebaseFirestore.instance.collection('posts').doc('doc2'),
    {'title': 'Post 2'},
  );
});
```

### 2. Transactions

```dart
await firebaseService.transaction<void>((transaction) async {
  final doc1 = await transaction.get(
    FirebaseFirestore.instance.collection('posts').doc('postId1'),
  );
  final count = doc1.get('likes') ?? 0;

  transaction.update(
    FirebaseFirestore.instance.collection('posts').doc('postId1'),
    {'likes': count + 1},
  );
});
```

---

## 🐛 Troubleshooting

### Build Error pada Android

```bash
# Clear dependencies
flutter clean
flutter pub get

# Rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Not Initialized

Pastikan `firebase_options.dart` sudah dikonfigurasi dengan benar dan `main()` sudah diupdate dengan Firebase initialization.

### Import Errors

Pastikan semua files di `lib/services/` dan `lib/models/` sudah ada sebelum import.

---

## 📚 Dokumentasi Resmi

- [Firebase Console](https://console.firebase.google.com)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Storage](https://firebase.google.com/docs/storage)

---

## ✅ Next Steps

1. Setup Firebase project di console
2. Download dan configure `google-services.json` (Android)
3. Download dan configure `GoogleService-Info.plist` (iOS)
4. Update `firebase_options.dart` dengan konfigurasi Anda
5. Run `flutter pub get`
6. Test dengan hot reload
7. Configure Firestore Security Rules sesuai kebutuhan

---

**Happy coding! 🚀**
