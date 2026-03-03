# Working with Streams in Notes Service

## Overview

Documentation lengkap untuk implementasi Streams dalam Notes Service menggunakan Dart/Flutter.

Streams memungkinkan real-time data updates tanpa perlu manual refresh. Setiap perubahan nota langsung diterpancarkan ke UI melalui StreamController.

---

## Konsep Dasar Streams

### Apa itu Stream?

Stream adalah asynchronous sequence of data. Mirip seperti pipe yang terus mengalirkan data dari sumber ke tujuan.

```
Data Source → Stream → Listener
```

### StreamController

StreamController adalah object yang mengontrol stream. Kita bisa:

- `add()` - menambah data ke stream
- `addError()` - menambah error
- `close()` - menutup stream

### Broadcast Stream

Stream yang bisa memiliki multiple listeners. Semua listener akan menerima event yang sama.

```dart
final controller = StreamController<List<NoteModel>>.broadcast();
```

---

## File Structure

```
lib/
├── models/
│   └── note_model.dart              (NoteModel & NoteCategoryModel)
├── screens/
│   └── notes_stream_screen.dart     (Demo UI)
└── services/
    └── notes_stream_service.dart    (Core service dengan streams)
```

---

## Stream Types dalam NotesStreamService

### 1. **getAllNotesStream()**

Mengemit list semua notes setiap ada perubahan.

```dart
Stream<List<NoteModel>> getAllNotesStream()
```

**Usage:**

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      List<NoteModel> notes = snapshot.data!;
      // Build UI
    }
  },
)
```

### 2. **getPinnedNotesStream()**

Stream untuk notes yang di-pin.

```dart
Stream<List<NoteModel>> getPinnedNotesStream()
```

### 3. **getArchivedNotesStream()**

Stream untuk archived notes.

```dart
Stream<List<NoteModel>> getArchivedNotesStream()
```

### 4. **getSingleNoteStream(String noteId)**

Stream untuk single note yang terus diupdate.

```dart
Stream<NoteModel?> getSingleNoteStream(String noteId)
// Yields individual note updates
```

### 5. **getNotesByCategoryStream(String category)**

Real-time stream filtered by category.

```dart
Stream<List<NoteModel>> getNotesByCategoryStream(String category)
```

### 6. **searchNotesStream(String query)**

Real-time search results.

```dart
Stream<List<NoteModel>> searchNotesStream(String query)
// As user types, results update automatically
```

### 7. **getCategoriesStream()**

Stream untuk list categories.

```dart
Stream<List<NoteCategoryModel>> getCategoriesStream()
```

---

## Usage Examples

### Initialize Service

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notesService = NotesStreamService();
  await notesService.init();

  runApp(const MyApp());
}
```

### Listen to All Notes

```dart
final notesService = NotesStreamService();

// Method 1: Using StreamBuilder (recommended for UI)
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    List<NoteModel> notes = snapshot.data ?? [];

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(note: notes[index]);
      },
    );
  },
)

// Method 2: Using async stream listener
notesService.getAllNotesStream().listen((notes) {
  print('Notes updated: ${notes.length}');
});
```

### Create a Note

```dart
final notesService = NotesStreamService();

bool success = await notesService.createNote(
  'My Note Title',
  'This is the content of my note',
  category: 'Personal',
);

if (success) {
  // UI akan automatically update karena stream
  print('Note created and UI updated automatically');
}
```

### Real-Time Search

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.searchNotesStream(searchQuery),
  builder: (context, snapshot) {
    final searchResults = snapshot.data ?? [];
    // Update search results in real-time as user types
  },
)
```

### Listen to Pinned Notes

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getPinnedNotesStream(),
  builder: (context, snapshot) {
    final pinnedNotes = snapshot.data ?? [];
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return PinnedNoteCard(note: pinnedNotes[index]);
            },
            childCount: pinnedNotes.length,
          ),
        ),
      ],
    );
  },
)
```

### Watch Single Note Updates

```dart
StreamBuilder<NoteModel?>(
  stream: notesService.getSingleNoteStream(noteId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final note = snapshot.data!;
      return NoteDetailView(note: note);
    }
  },
)
```

### Filter by Category with Stream

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getNotesByCategoryStream('Work'),
  builder: (context, snapshot) {
    final workNotes = snapshot.data ?? [];
    // Display notes in 'Work' category
  },
)
```

---

## Stream Operations

### 1. Update Note

```dart
await notesService.updateNoteContent(noteId, 'Updated content');
// Stream automatically emits updated list
```

### 2. Toggle Pin

```dart
await notesService.togglePinStatus(noteId);
// pinnedNotesStream updates automatically
```

### 3. Archive Note

```dart
await notesService.toggleArchiveStatus(noteId);
// archivedNotesStream updates automatically
```

### 4. Delete Note (soft delete)

```dart
await notesService.deleteNote(noteId);
// Stream removes note from getAllNotesStream
```

---

## Advanced Stream Patterns

### 1. Combine Multiple Streams

```dart
StreamBuilder<List<NoteModel>>(
  stream: Rx.combineLatest2(
    notesService.getPinnedNotesStream(),
    notesService.searchNotesStream(query),
    (pinned, searched) => [...pinned, ...searched],
  ),
  builder: (context, snapshot) {
    // Combine pinned and searched results
  },
)
```

### 2. Stream Transformation

```dart
notesService.getAllNotesStream()
  .map((notes) => notes.where((n) => !n.isArchived).toList())
  .listen((activeNotes) {
    print('${activeNotes.length} active notes');
  });
```

### 3. Filter Stream

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream()
    .map((notes) => notes.where((n) => n.isPinned).toList())
    .asBroadcastStream(),
  builder: (context, snapshot) {
    // Only pinned notes
  },
)
```

### 4. Debounce Search

```dart
final searchController = TextEditingController();
final debouncedSearch = searchController.text;

// In UI
TextField(
  onChanged: (query) {
    // Debounce search to avoid too many stream emissions
    // Use package:rxdart for DebouncedSearch
  },
)
```

---

## Best Practices

### 1. **Always Initialize**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notesService = NotesStreamService();
  await notesService.init();  // Important!
  runApp(const MyApp());
}
```

### 2. **Always Dispose**

```dart
@override
void dispose() {
  notesService.dispose();  // Close all stream controllers
  super.dispose();
}
```

### 3. **Use Broadcast Streams**

```dart
// All streams in NotesStreamService use .broadcast()
// This allows multiple listeners
```

### 4. **Handle Errors**

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return ErrorWidget(error: snapshot.error);
    }
    // ...
  },
)
```

### 5. **Check Connection State**

```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return LoadingWidget();
}
```

---

## Troubleshooting

### Issue: Stream not updating UI

**Solution:**

- Ensure `init()` was called
- Check that StreamController is using `.broadcast()`
- Verify state management or UI rebuild

### Issue: Memory leaks

**Solution:**

- Always call `.dispose()` in State.dispose()
- Don't forget to close StreamControllers

### Issue: Multiple data emissions

**Solution:**

- This is normal behavior, StreamBuilder will rebuild for each emission
- Use `.debounce()` for expensive operations

### Issue: Initial data not showing

**Solution:**

```dart
StreamBuilder<List<NoteModel>>(
  initialData: [], // Provide initial data
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    // ...
  },
)
```

---

## Performance Optimization

### 1. Use `FutureBuilder` + Stream Hybrid

```dart
// Get initial data from Future, then listen to Stream
FutureBuilder<List<NoteModel>>(
  future: notesService.getAllNotes(),
  builder: (context, futureSnapshot) {
    if (futureSnapshot.hasData) {
      return StreamBuilder<List<NoteModel>>(
        initialData: futureSnapshot.data,
        stream: notesService.getAllNotesStream(),
        builder: (context, streamSnapshot) {
          // Stream for real-time updates
        },
      );
    }
  },
)
```

### 2. Update Individual Items instead of List

```dart
// Instead of emitting entire list, update single item
notesService.updateNote(updatedNote);
// Only UI subscribed to that note's stream will rebuild
```

### 3. Use `const` Widgets

```dart
const NoteCard(note: note);  // Won't rebuild unnecessarily
```

---

## Migration Guide

### From Manual Refresh to Streams

**Before (Manual refresh):**

```dart
Future<void> _loadNotes() async {
  final notes = await notesService.getAllNotes();
  setState(() {
    _notes = notes;
  });
}

@override
void initState() {
  super.initState();
  _loadNotes();  // Manual load
}
```

**After (Streams):**

```dart
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    final notes = snapshot.data ?? [];
    // Automatic updates!
  },
)
```

---

## Testing Streams

```dart
void main() {
  group('NotesStreamService Tests', () {
    test('getAllNotesStream emits notes', () async {
      final notesService = NotesStreamService();
      await notesService.init();

      final stream = notesService.getAllNotesStream();

      await notesService.createNote('Test', 'Content');

      expect(
        stream,
        emits(isA<List<NoteModel>>()),
      );
    });
  });
}
```

---

## References

- [Dart Streams Documentation](https://dart.dev/tutorials/language/streams)
- [Flutter StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [RxDart for advanced streaming](https://pub.dev/packages/rxdart)
