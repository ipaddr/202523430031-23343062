/*
# NOTES READ VIEW INTEGRATION GUIDE

Step-by-step guide untuk mengintegrasikan NotesReadView ke dalam aplikasi Anda

## ARCHITECTURE

Sebelum integrasi, pahami positioning NotesReadView:

┌─────────────────────────────────────────────────────────┐
│                     HOME SCREEN                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Create Notes]  ←→  [Read All Notes]  ←→  [Settings]  │
│  (NotesStream)       (NotesReadView)       (Settings)  │
│     Screen           Screen                Screen      │
│                                                         │
│  Purpose:            Purpose:              Purpose:    │
│  - Create notes      - Browse notes        - Config    │
│  - Quick manage      - Search & sort       - About     │
│  - Tabs view         - Rich filtering      - Logout    │
│                      - Detail preview                  │
└─────────────────────────────────────────────────────────┘


## STEP 1: Copy File

Copy `notes_read_view.dart` ke folder `lib/screens/`

Direktori struktur:
  lib/
  ├── screens/
  │   ├── home_screen.dart
  │   ├── notes_stream_screen.dart    ← Create & Manage
  │   ├── notes_read_view.dart         ← NEW: Read & Browse
  │   └── settings_screen.dart
  └── services/
      └── notes_stream_service.dart


## STEP 2: Update main.dart

Tambahkan initialization:

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notes_stream_service.dart';

late NotesStreamService notesStreamService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize NotesStreamService
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
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
```


## STEP 3: Update HomeScreen

Add buttons untuk navigate ke NotesReadView:

```dart
import 'package:flutter/material.dart';
import 'notes_read_view.dart';
import 'notes_stream_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_note),
              title: const Text('Create Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesStreamScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Read All Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesReadView(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_note),
              label: const Text('Create Notes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesStreamScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.notes),
              label: const Text('Read All Notes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesReadView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```


## STEP 4: Configure go_router (Optional - if using go_router)

Jika menggunakan go_router untuk routing:

```dart
// lib/config/app_router.dart

import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/notes_stream_screen.dart';
import '../screens/notes_read_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'create-notes',
          name: 'createNotes',
          builder: (context, state) => const NotesStreamScreen(),
        ),
        GoRoute(
          path: 'read-notes',
          name: 'readNotes',
          builder: (context, state) => const NotesReadView(),
        ),
      ],
    ),
  ],
);
```

Use in main.dart:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Notes App',
      routerConfig: router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
```

Navigate with go_router:

```dart
// Open NotesReadView
context.go('/read-notes');

// Or named route
context.goNamed('readNotes');
```


## STEP 5: Add TabBar Navigation (Optional)

Untuk bottom tab bar navigation:

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const NotesStreamScreen(),
    const NotesReadView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_note),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Read',
          ),
        ],
      ),
    );
  }
}
```


## STEP 6: Shared AppBar (Optional - if needed)

Jika ingin shared AppBar logic:

```dart
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> appBarActions;
  final PreferredSizeWidget? appBar;

  const AppScaffold({
    required this.title,
    required this.body,
    this.appBarActions = const [],
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? AppBar(
        title: Text(title),
        actions: appBarActions,
      ),
      body: body,
    );
  }
}

// Usage di NotesReadView
return AppScaffold(
  title: 'All Notes',
  body: Column(...),
);
```


## STEP 7: Pass Service Instance (Optional)

Jika ingin pass service instance dari parent:

```dart
class NotesReadView extends StatefulWidget {
  final NotesStreamService? notesService;

  const NotesReadView({
    Key? key,
    this.notesService,
  }) : super(key: key);

  @override
  State<NotesReadView> createState() => _NotesReadViewState();
}

class _NotesReadViewState extends State<NotesReadView> {
  late NotesStreamService _notesService;

  @override
  void initState() {
    super.initState();
    _notesService = widget.notesService ?? NotesStreamService();
    _initializeService();
  }

  // ... rest of code
}

// Usage:
// Option 1: Dengan passed service
NotesReadView(notesService: notesStreamService)

// Option 2: Tanpa service (create new)
const NotesReadView()
```


## STEP 8: Testing Integration

Test checklist:

```dart
// 1. File structure correct
✓ lib/screens/notes_read_view.dart exists
✓ Imports resolve correctly

// 2. Navigation working
✓ Can push to NotesReadView from HomeScreen
✓ Back button returns to previous screen
✓ Drawer navigation works

// 3. Functionality working
✓ Notes display in list view
✓ Can switch to grid view
✓ Search works
✓ Category filter appears
✓ Sort menu works
✓ Pin filter works
✓ Tap note opens detail dialog
✓ Detail dialog actions (pin/archive/delete) work
✓ Changes reflect immediately

// 4. No errors
✓ No red screen on errors
✓ Hot reload works
✓ No console errors
```


## STEP 9: Customize Styling (Optional)

```dart
// In NotesReadView, modify colors:

// Category badge
backgroundColor: Colors.blue[100],

// Pin icon
color: Colors.orange,

// Pinned filter active
color: _showOnlyPinned ? Colors.orange : Colors.grey,

// Empty state icon
color: Colors.grey[400],

// Card styling
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  // ...
)
```


## STEP 10: Advanced Features (Future)

Enhance dengan:

```dart
// Multi-select
bool _multiSelectMode = false;
List<String> _selectedNoteIds = [];

// Bulk operations
Future<void> _deleteSelected() async {
  for (var id in _selectedNoteIds) {
    await _notesService.deleteNote(id);
  }
}

// Export
Future<void> _exportNotes() async {
  // Export selected or all notes
}

// Share
Future<void> _shareNote(NoteModel note) async {
  // Share via system share dialog
}

// Favorites
Future<void> _toggleFavorite(String noteId) async {
  // Toggle favorite status
}
```


## COMPLETE INTEGRATION EXAMPLE

Full working example:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notes_stream_service.dart';

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
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// home_screen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.add_note),
              title: const Text('Create Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesStreamScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Read All Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotesReadView(),
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
            ElevatedButton.icon(
              icon: const Icon(Icons.add_note),
              label: const Text('Create Note'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotesStreamScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.notes),
              label: const Text('Read All Notes'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotesReadView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```


## TROUBLESHOOTING

Issue: "NotesReadView not found"
Fix: Ensure file copied to lib/screens/notes_read_view.dart
Fix: Check import path is correct

Issue: "NotesStreamService not initialized"
Fix: Ensure init() called in main.dart
Fix: Await the init() call

Issue: "No notes showing in NotesReadView"
Fix: Create notes in NotesStreamScreen first
Fix: Check NotesStreamService initialized
Fix: Verify getAllNotesStream() working

Issue: "Search not working"
Fix: Check _searchQuery state updating
Fix: Verify _filterNotes() logic

Issue: "Memory leak warnings"
Fix: Ensure dispose() called
Fix: Check TextEditingController disposed
Fix: Close all StreamControllers

Issue: "Navigation not working"
Fix: Verify routes configured correctly
Fix: Check Navigator.push() context
Fix: Ensure screens imported


## FILE SUMMARY

Files created/modified:

lib/screens/notes_read_view.dart
  → Main reading screen
  → 400+ lines
  → All features included

lib/screens/home_screen.dart (modified)
  → Add navigation to NotesReadView
  → Add drawer menu items
  → Add buttons

lib/main.dart (modified)
  → Initialize NotesStreamService
  → Dispose in MyApp.dispose()

lib/config/app_router.dart (optional)
  → Add go_router routes if using go_router


## DEPLOYMENT CHECKLIST

- [ ] Copy notes_read_view.dart to lib/screens/
- [ ] Update main.dart with service init
- [ ] Update home_screen.dart with navigation
- [ ] Test hot reload (no errors)
- [ ] Create test note in NotesStreamScreen
- [ ] Open NotesReadView
- [ ] Verify note appears in list
- [ ] Test all filtering/sorting features
- [ ] Test detail dialog
- [ ] Test pin/archive/delete actions
- [ ] Verify changes reflect immediately
- [ ] Test on device (if possible)
- [ ] Final check for console errors


## SUCCESS METRICS

✅ NotesReadView displays all notes
✅ Search works in real-time
✅ Category filter shows correct categories
✅ Sorting works (3 options)
✅ View mode toggle works (list/grid)
✅ Pin filter works (toggle visibility)
✅ Note detail dialog opens on tap
✅ CRUD actions work from dialog
✅ UI updates immediately after actions
✅ Navigation works smoothly
✅ No errors in console
✅ No memory leaks


## NEXT STEPS

1. Complete integration steps 1-5
2. Run and test NotesReadView
3. Verify all features work
4. Customize styling if needed
5. Add to your app's routing
6. Deploy to test device
7. Add advanced features (multi-select, export, etc.)


## SUPPORT RESOURCES

Documentation:
  - NOTES_READ_VIEW_GUIDE.md (complete guide)
  - This file (integration steps)

Reference:
  - QUICK_REFERENCE_NOTES_READ_VIEW.dart
  - STREAMS_GUIDE.md (stream concepts)

Related Screens:
  - NotesStreamScreen (create & manage)
  - HomeScreen (navigation)

*/
