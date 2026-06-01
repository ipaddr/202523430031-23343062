/*
# STREAMS INTEGRATION GUIDE

Panduan lengkap untuk mengintegrasikan NotesStreamService dan NotesStreamScreen 
ke dalam aplikasi Flutter Anda.

## STEP 1: Verify Dependencies

Pastikan pubspec.yaml sudah memiliki:
- shared_preferences: ^2.2.2
- uuid: ^4.0.0

## STEP 2: Initialize Service in main.dart

Contoh implementasi:

```dart
import 'package:flutter/material.dart';
import 'services/notes_stream_service.dart';
import 'config/app_router.dart';

late NotesStreamService notesStreamService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize NotesStreamService
  notesStreamService = NotesStreamService();
  await notesStreamService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      // or gunakan router dengan go_router package
    );
  }
}
```

## STEP 3: Add Route (jika menggunakan go_router)

Edit lib/config/app_router.dart:

```dart
import 'package:go_router/go_router.dart';
import 'package:app1/screens/notes_stream_screen.dart';
import 'package:app1/main.dart' show notesStreamService;

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/notes-stream',
      name: 'notesStream',
      builder: (context, state) => NotesStreamScreen(
        notesService: notesStreamService,
      ),
    ),
    // Routes lainnya...
  ],
);
```

## STEP 4: Add to Navigation

Di HomeScreen atau menu navigation:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Notes Stream Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesStreamScreen(
                      notesService: notesStreamService,
                    ),
                  ),
                );
                // or dengan go_router:
                // context.go('/notes-stream');
              },
              child: const Text('Open Notes Stream'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## STEP 5: Update pubspec.yaml (Optional - untuk Testing)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  
  # Optional untuk advanced stream testing
  rxdart: ^0.27.0
```

## STEP 6: Test Integration

File: test/notes_stream_integration_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app1/services/notes_stream_service.dart';

void main() {
  group('NotesStreamService Integration', () {
    late NotesStreamService notesService;

    setUp(() async {
      notesService = NotesStreamService();
      await notesService.init();
    });

    tearDown(() async {
      await notesService.dispose();
    });

    test('Service initializes without error', () async {
      expect(notesService, isNotNull);
    });

    test('createNote emits to stream', () async {
      final stream = notesService.getAllNotesStream();
      
      await notesService.createNote('Test Note', 'Content');
      
      expect(
        stream,
        emits(isA<List>()),
      );
    });

    test('Multiple streams work independently', () async {
      final allStream = notesService.getAllNotesStream();
      final pinnedStream = notesService.getPinnedNotesStream();
      
      await notesService.createNote('Test', 'Content');
      await notesService.togglePinStatus('test-id');
      
      // Both streams should emit
      expect(allStream, emits(isA<List>()));
      expect(pinnedStream, emits(isA<List>()));
    });
  });
}
```

## STEP 7: Update App Widget (if needed)

```dart
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Dispose NotesStreamService when app closes
    notesStreamService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
```

## STEP 8: Error Handling (Optional Enhancement)

```dart
class NotesStreamScreen extends StatefulWidget {
  final NotesStreamService notesService;

  const NotesStreamScreen({
    Key? key,
    required this.notesService,
  }) : super(key: key);

  @override
  State<NotesStreamScreen> createState() => _NotesStreamScreenState();
}

class _NotesStreamScreenState extends State<NotesStreamScreen> {
  @override
  void initState() {
    super.initState();
    _initializeWithErrorHandling();
  }

  Future<void> _initializeWithErrorHandling() async {
    try {
      // Additional initialization if needed
      print('NotesStreamScreen initialized');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ... rest of the class
}
```

## STEP 9: Dependency Injection (Advanced)

Gunakan GetIt untuk global service management:

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  final notesService = NotesStreamService();
  notesService.init();
  getIt.registerSingleton<NotesStreamService>(notesService);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

// Usage di screens:
class MyScreen extends StatelessWidget {
  final notesService = getIt<NotesStreamService>();
  // ...
}
```

## STEP 10: Add to Drawer Navigation (Optional)

```dart
Drawer(
  child: ListView(
    children: [
      const DrawerHeader(
        child: Text('Menu'),
      ),
      ListTile(
        title: const Text('Home'),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        title: const Text('Notes Stream'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotesStreamScreen(
                notesService: notesStreamService,
              ),
            ),
          );
        },
      ),
    ],
  ),
)
```

## TROUBLESHOOTING

1. **"NotesStreamService not initialized" error**
   - Pastikan init() dipanggil di main.dart
   - Verify await adalah di tempat yang tepat

2. **UI tidak update setelah create/update note**
   - Check bahwa StreamBuilder subscribed ke stream yang tepat
   - Verify stream emissions in service methods
   
3. **Memory leak warnings**
   - Ensure dispose() called di State.dispose()
   - Check that controller.close() dipanggil di service

4. **Stream showing old data**
   - Add initialData parameter ke StreamBuilder
   - Use .asBroadcastStream() jika diperlukan

## COMPLETE EXAMPLE - Flutter App with Navigation

```dart
import 'package:flutter/material.dart';
import 'package:app1/screens/notes_stream_screen.dart';
import 'package:app1/screens/local_storage_crud_screen.dart';
import 'package:app1/services/notes_stream_service.dart';

late NotesStreamService notesStreamService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  notesStreamService = NotesStreamService();
  await notesStreamService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    notesStreamService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes & Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage & Streams Demo'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu Utama'),
            ),
            ListTile(
              title: const Text('Todos (Local Storage CRUD)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocalStorageCrudScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Notes (Streams)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesStreamScreen(
                      notesService: notesStreamService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocalStorageCrudScreen(),
                  ),
                );
              },
              child: const Text('Local Storage (Todos)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesStreamScreen(
                      notesService: notesStreamService,
                    ),
                  ),
                );
              },
              child: const Text('Streams (Notes)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## NEXT STEPS

1. Copy NotesStreamScreen, NoteModel, NotesStreamService ke project Anda
2. Follow steps 1-10 di atas
3. Run flutter pub get
4. Test aplikasi dengan hot reload
5. Verify bahwa notes stream updates real-time

## FEATURE IDEAS

- Add note categories/tags
- Search dengan debounce
- Backup/Restore notes
- Share notes functionality
- Note encryption
- Rich text editor integration
- Note reminders/notifications
- Dark mode support
- Offline sync dengan cloud firestore

*/
