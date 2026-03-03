/// Integration Guide for Local Storage CRUD
///
/// Langkah-langkah untuk mengintegrasikan CRUD Local Storage ke dalam aplikasi

// ============ STEP 1: Update pubspec.yaml ============
/*
dependencies:
  flutter:
    sdk: flutter
  
  # ... existing dependencies ...
  
  # Local Storage (already added)
  shared_preferences: ^2.2.2
  uuid: ^4.0.0
*/

// ============ STEP 2: Initialize in main.dart ============
/*
import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  final storage = LocalStorageService();
  await storage.init();
  
  runApp(const MyApp());
}
*/

// ============ STEP 3: Add Route to AppRouter ============
/*
// In config/app_router.dart or routes.dart

import '../screens/local_storage_crud_screen.dart';

class AppRoutes {
  static const String appInit = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String localStorageCrud = '/local-storage-crud'; // Add this
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.appInit:
        return MaterialPageRoute(builder: (_) => const SomeInitScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppRoutes.localStorageCrud:
        return MaterialPageRoute(
          builder: (_) => const LocalStorageCrudScreen(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
*/

// ============ STEP 4: Navigate to CRUD Screen ============
/*
// From any screen, navigate to CRUD demo:

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/local-storage-crud');
  },
  child: const Text('Open Local Storage CRUD'),
)

// Or using MaterialPageRoute:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LocalStorageCrudScreen(),
  ),
)
*/

// ============ STEP 5: Usage in Your Screens ============
/*
// Example: HomeScreen with Local Storage

import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/todo_repository.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _storage = LocalStorageService();
  final TodoRepository _todoRepository = TodoRepository();
  
  List<TodoModel> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTodos();
  }

  Future<void> _loadUserData() async {
    // Load user data from local storage
    String? username = _storage.getString('username');
    int? userId = _storage.getInt('user_id');
    
    print('Username: $username, ID: $userId');
  }

  Future<void> _loadTodos() async {
    final todos = await _todoRepository.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  Future<void> _saveUserData() async {
    await _storage.saveString('username', 'John Doe');
    await _storage.saveInt('user_id', 123);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User data saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Todos: ${_todos.length}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Save User Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/local-storage-crud');
              },
              child: const Text('Open CRUD Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============ STEP 6: File Structure ============
/*
project_root/
├── lib/
│   ├── main.dart                          (Initialize storage)
│   ├── config/
│   │   ├── app_router.dart               (Add CRUD route)
│   │   └── routes.dart
│   ├── models/
│   │   └── todo_model.dart               (NEW)
│   ├── screens/
│   │   ├── home_screen.dart              (Use storage)
│   │   ├── login_screen.dart
│   │   └── local_storage_crud_screen.dart (NEW - Demo)
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── firebase_service.dart
│   │   ├── local_storage_service.dart    (NEW - Core service)
│   │   └── todo_repository.dart          (NEW - Repository pattern)
│   └── widgets/
```
*/

// ============ STEP 7: Complete main.dart Example ============
/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_storage_service.dart';
import 'firebase_options.dart';
import 'config/app_router.dart';
import 'config/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage FIRST
  final storage = LocalStorageService();
  await storage.init();
  print('✓ Local Storage initialized');

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.appInit,
    );
  }
}
*/

// ============ STEP 8: Testing Local Storage ============
/*
// Add this to test if storage is working:

void debugStorageTest() async {
  final storage = LocalStorageService();
  await storage.init();
  
  // Test CRUD
  print('=== Testing Local Storage ===');
  
  // CREATE
  await storage.saveString('test_key', 'test_value');
  print('✓ Created: test_key = test_value');
  
  // READ
  String? value = storage.getString('test_key');
  print('✓ Read: test_key = $value');
  
  // UPDATE
  await storage.updateString('test_key', 'updated_value');
  value = storage.getString('test_key');
  print('✓ Updated: test_key = $value');
  
  // DELETE
  await storage.delete('test_key');
  bool exists = storage.containsKey('test_key');
  print('✓ Deleted: test_key exists = $exists');
  
  print('=== Testing Complete ===');
}

// Call in main():
// debugStorageTest();
*/

// ============ STEP 9: Common Use Cases ============
/*
// Use Case 1: Save user session
class SessionManager {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> saveSession(String token, String userId) async {
    await _storage.saveString('auth_token', token);
    await _storage.saveString('user_id', userId);
    await _storage.saveBool('is_logged_in', true);
  }

  bool isLoggedIn() {
    return _storage.getBool('is_logged_in', defaultValue: false);
  }

  String? getAuthToken() {
    return _storage.getString('auth_token');
  }

  Future<void> logout() async {
    await _storage.deleteMultiple(['auth_token', 'user_id', 'is_logged_in']);
  }
}

// Use Case 2: Cache API responses
class CacheManager {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _storage.saveObject(key, {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic>? getCachedData(String key) {
    return _storage.getObject(key);
  }

  bool isCacheValid(String key, Duration maxAge) {
    var cached = _storage.getObject(key);
    if (cached == null) return false;

    DateTime cachedTime = DateTime.parse(cached['timestamp']);
    return DateTime.now().difference(cachedTime) < maxAge;
  }
}

// Use Case 3: App preferences
class AppPreferences {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> setTheme(String theme) async {
    await _storage.saveString('app_theme', theme);
  }

  String getTheme() {
    return _storage.getString('app_theme', defaultValue: 'light');
  }

  Future<void> setLanguage(String lang) async {
    await _storage.saveString('app_language', lang);
  }

  String getLanguage() {
    return _storage.getString('app_language', defaultValue: 'en');
  }
}

// ============ STEP 10: Troubleshooting ============
/*
Problem: "Bad state: Future already completed"
Solution: Make sure to call storage.init() only once in main()

Problem: "null" values when reading
Solution: Use default values: storage.getString('key', defaultValue: '')

Problem: Data not persisting
Solution: Ensure you're awaiting the operations properly

Problem: JSON serialization error
Solution: Make sure your objects have proper toJson() and fromJson() methods

Problem: Can't access storage in widget
Solution: Create storage instance after init() in main(), use singleton pattern
*/