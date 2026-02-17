# Firebase Backend Setup - Quick Reference

## ✅ Apa Yang Sudah Dikonfigurasi

- ✅ Firebase Core
- ✅ Firebase Authentication
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Messaging
- ✅ Firebase Analytics

## 📦 Struktur Project

```
lib/
├── main.dart                      # Entry point (sudah update)
├── firebase_options.dart          # Config (perlu update)
├── services/
│   ├── firebase_service.dart      # Core service
│   ├── auth_service.dart          # Auth operations
│   └── firestore_service.dart     # Database operations
├── models/
│   └── models.dart                # UserModel, PostModel
└── pages/
    ├── login_page.dart
    ├── home_page.dart
    └── posts_page.dart
```

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase

**Android:**
- Download `google-services.json` dari Firebase Console
- Paste ke `android/app/google-services.json`
- Update `firebase_options.dart`

**iOS:**
- Download `GoogleService-Info.plist` dari Firebase Console
- Drag ke Xcode under Runner target
- Update `firebase_options.dart`

### 3. Update firebase_options.dart

Dikonfigurasi dengan:
```dart
// android, ios, web, macos, windows, linux
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 4. Run!
```bash
flutter run
```

## 💻 Quick Usage

### Authentication
```dart
final authService = AuthService();

// Login
await authService.login(
  email: 'user@example.com',
  password: 'password',
);

// Sign Up
await authService.signUp(
  email: 'user@example.com',
  password: 'password',
  displayName: 'John',
);

// Current User
User? user = authService.currentUser;

// Logout
await authService.logout();
```

### Firestore CRUD
```dart
final db = FirestoreService();

// Create
await db.addDocument(
  collection: 'posts',
  data: {'title': 'Hello', 'likes': 0},
);

// Read
List<PostModel> posts = await db.getCollection<PostModel>(
  collection: 'posts',
  fromJson: (json) => PostModel.fromJson(json),
);

// Update
await db.updateDocument(
  collection: 'posts',
  docId: 'postId',
  data: {'title': 'Updated'},
);

// Delete
await db.deleteDocument(
  collection: 'posts',
  docId: 'postId',
);

// Query
List<PostModel> userPosts = await db.query<PostModel>(
  collection: 'posts',
  field: 'authorId',
  operator: '==',
  value: 'userId',
  fromJson: (json) => PostModel.fromJson(json),
);

// Real-time Stream
db.streamCollection<PostModel>(
  collection: 'posts',
  fromJson: (json) => PostModel.fromJson(json),
).listen((posts) {
  print('Posts: $posts');
});
```

### Firebase Storage
```dart
final firebase = FirebaseService();

// Upload
String url = await firebase.uploadFile(
  path: 'images/photo.jpg',
  filePath: '/local/path/photo.jpg',
);

// Download URL
String url = await firebase.getDownloadUrl(
  path: 'images/photo.jpg',
);

// Delete
await firebase.deleteFile(path: 'images/photo.jpg');
```

## 📚 Documentation Files

- **FIREBASE_SETUP.md** - Setup lengkap & penggunaan
- **ANDROID_FIREBASE_SETUP.md** - Android configuration step-by-step
- **EXAMPLES.md** - Complete working examples

## 🔗 Important Links

- [Firebase Console](https://console.firebase.google.com)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Cloud Firestore Docs](https://firebase.google.com/docs/firestore)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)

## ⚡ Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| google-services.json not found | Paste di `android/app/` |
| Firebase not initialized | Update main.dart dengan Firebase.initializeApp() |
| Import errors | Run `flutter pub get` |
| Build fails | Run `flutter clean` then `flutter pub get` |
| Firestore rules error | Check security rules di Firebase Console |

## 🔐 Default Firestore Rules (Development)

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

⚠️ **Untuk production, gunakan rules yang lebih strict!**

## 📱 Next Steps

1. ✅ Setup Firebase project
2. ✅ Configure android/ios
3. ✅ Update firebase_options.dart
4. ✅ Run flutter pub get
5. ⏳ Test Authentication
6. ⏳ Test Firestore CRUD
7. ⏳ Configure Security Rules
8. ⏳ Deploy to App Stores

## 💡 Tips

- **Singleton pattern** sudah diterapkan di services (hanya 1 instance)
- **Error handling** dengan try-catch di semua method
- **Model classes** untuk type safety
- **Streams** untuk real-time updates
- **Timestamps** otomatis ditambah
- **Pagination** support untuk large collections

## 🎯 Common Use Cases

### User Profile Page dengan Real-time Sync
```dart
StreamBuilder<UserModel?>(
  stream: firestoreService.streamDocument<UserModel>(
    collection: 'users',
    docId: userId,
    fromJson: (json) => UserModel.fromJson(json),
  ),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final user = snapshot.data!;
      return Text(user.displayName ?? 'Anonymous');
    }
    return CircularProgressIndicator();
  },
)
```

### Like Button
```dart
ElevatedButton(
  onPressed: () async {
    await firestoreService.incrementField(
      collection: 'posts',
      docId: postId,
      fieldName: 'likes',
      value: 1,
    );
  },
  child: Icon(Icons.favorite),
)
```

### Search Users
```dart
List<UserModel> results = await firestoreService.query<UserModel>(
  collection: 'users',
  field: 'displayName',
  operator: '==',
  value: searchQuery,
  fromJson: (json) => UserModel.fromJson(json),
);
```

---

**Happy Coding! 🎉**
