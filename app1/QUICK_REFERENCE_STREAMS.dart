/*
# QUICK REFERENCE - STREAMS

Cheat sheet untuk streaming operations di NotesStreamService

## INITIALIZATION

// In main.dart
NotesStreamService notesService = NotesStreamService();
await notesService.init();

// In dispose
notesService.dispose();


## STREAM GETTERS

Stream<List<NoteModel>> getAllNotesStream()
Stream<List<NoteModel>> getPinnedNotesStream()
Stream<List<NoteModel>> getArchivedNotesStream()
Stream<List<NoteModel>> getNotesByCategoryStream(String category)
Stream<List<NoteModel>> searchNotesStream(String query)
Stream<NoteModel?> getSingleNoteStream(String noteId)
Stream<List<NoteCategoryModel>> getCategoriesStream()


## BASIC OPERATIONS

// Create note
await notesService.createNote(title, content, category: 'Work');

// Update note
await notesService.updateNote(updatedNoteModel);
await notesService.updateNoteTitle(noteId, 'New Title');
await notesService.updateNoteContent(noteId, 'New Content');
await notesService.updateNoteCategory(noteId, 'Personal');

// Toggle pin
await notesService.togglePinStatus(noteId);

// Toggle archive
await notesService.toggleArchiveStatus(noteId);

// Delete (soft)
await notesService.deleteNote(noteId);

// Delete (permanent)
await notesService.permanentlyDeleteNote(noteId);

// Category management
await notesService.addCategory('Work', Color(0xFF1E88E5));
await notesService.deleteCategory(categoryId);


## UI PATTERNS

// Pattern 1: Basic StreamBuilder
StreamBuilder<List<NoteModel>>(
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return Text('Error');
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    List<NoteModel> notes = snapshot.data!;
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, i) => NoteCard(note: notes[i]),
    );
  },
)

// Pattern 2: With initial data
StreamBuilder<List<NoteModel>>(
  initialData: const [],
  stream: notesService.getAllNotesStream(),
  builder: (context, snapshot) {
    final notes = snapshot.data ?? [];
    return Text('${notes.length} notes');
  },
)

// Pattern 3: Connection state check
if (snapshot.connectionState == ConnectionState.waiting) {
  return const CircularProgressIndicator();
}

// Pattern 4: With error handling
if (snapshot.hasError) {
  return Column(
    children: [
      const Icon(Icons.error),
      Text(snapshot.error.toString()),
    ],
  );
}

// Pattern 5: Dynamic stream selection
_getStreamForTab() {
  switch (_selectedTab) {
    case 0: return notesService.getAllNotesStream();
    case 1: return notesService.getPinnedNotesStream();
    case 2: return notesService.getArchivedNotesStream();
    default: return notesService.getAllNotesStream();
  }
}

// Pattern 6: Async listen
notesService.getAllNotesStream().listen((notes) {
  print('Notes: ${notes.length}');
});

// Pattern 7: With map transformation
notesService.getAllNotesStream()
  .map((notes) => notes.where((n) => !n.isArchived).toList())
  .listen((activeNotes) => print(activeNotes));


## SEARCH PATTERN

TextField(
  onChanged: (query) {
    setState(() => _searchQuery = query);
  },
)

StreamBuilder<List<NoteModel>>(
  stream: notesService.searchNotesStream(_searchQuery),
  builder: (context, snapshot) {
    final results = snapshot.data ?? [];
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) => NoteCard(note: results[i]),
    );
  },
)


## FILTER PATTERN

// By category
StreamBuilder<List<NoteModel>>(
  stream: notesService.getNotesByCategoryStream('Work'),
  builder: (context, snapshot) {
    final workNotes = snapshot.data ?? [];
  },
)

// Pinned only
StreamBuilder<List<NoteModel>>(
  stream: notesService.getPinnedNotesStream(),
  builder: (context, snapshot) {
    final pinned = snapshot.data ?? [];
  },
)

// Archived only
StreamBuilder<List<NoteModel>>(
  stream: notesService.getArchivedNotesStream(),
  builder: (context, snapshot) {
    final archived = snapshot.data ?? [];
  },
)


## CRUD WITH FEEDBACK

// Create with snackbar
Future<void> _createNote(String title, String content) async {
  bool success = await _notesService.createNote(title, content);
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Note created' : 'Failed to create'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Delete with confirmation
Future<void> _deleteNote(String noteId) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Note?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _notesService.deleteNote(noteId);
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

// Toggle with instant UI feedback
Future<void> _togglePin(String noteId) async {
  await _notesService.togglePinStatus(noteId);
  // Stream updates UI automatically
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pin status updated')),
    );
  }
}


## ADVANCED PATTERNS

// Pattern 1: Combine multiple streams
// Requires: rxdart package
// Rx.combineLatest2(
//   notesService.getAllNotesStream(),
//   notesService.getCategoriesStream(),
//   (notes, categories) => MapEntry(notes, categories),
// )

// Pattern 2: Stream transformation
notesService.getAllNotesStream()
  .map((notes) => notes.length)
  .distinct()
  .listen((count) => print('Total: $count'));

// Pattern 3: Error recovery
notesService.getAllNotesStream()
  .handleError((error) {
    print('Error: $error');
    return <NoteModel>[];
  })
  .listen((notes) => print(notes));

// Pattern 4: Skip initial emission
notesService.getAllNotesStream()
  .skip(1)
  .listen((notes) => print('Updated notes: $notes'));

// Pattern 5: Take only first n emissions
notesService.getAllNotesStream()
  .take(1)
  .listen((notes) => print('First emission: $notes'));


## MODEL OPERATIONS

// Create model
NoteModel note = NoteModel(
  id: '123',
  title: 'Sample',
  content: 'Content here',
  category: 'Work',
  isPinned: false,
  isArchived: false,
  createdAt: DateTime.now(),
);

// Copy with changes
NoteModel updated = note.copyWith(
  title: 'New Title',
  isPinned: true,
);

// Serialize
Map<String, dynamic> json = note.toJson();

// Deserialize
NoteModel fromJson = NoteModel.fromJson(json);

// Category model
NoteCategoryModel category = NoteCategoryModel(
  id: 'cat-1',
  name: 'Work',
  color: Colors.blue,
  noteCount: 5,
);


## ERROR HANDLING

try {
  await notesService.createNote(title, content);
  print('Success');
} catch (e) {
  print('Error: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}


## DISPOSAL CHECKLIST

// In State.dispose():
✓ notesService.dispose()  // Closes all StreamControllers
✓ _titleController.dispose()  // Dispose TextFields
✓ _contentController.dispose()
✓ super.dispose()

// In MyApp.dispose() (if StatefulWidget):
✓ notesStreamService.dispose()

// Never forget!
// ✗ Don't leave streams open - memory leak
// ✗ Don't use service after dispose()
// ✗ Don't mix sync and async without await


## TESTING

test('Stream emits notes', () async {
  final service = NotesStreamService();
  await service.init();
  
  final stream = service.getAllNotesStream();
  
  service.createNote('Test', 'Content');
  
  expect(stream, emits(isA<List<NoteModel>>()));
  
  await service.dispose();
});


## COMMON ISSUES

Issue: "Stream already closed"
Fix: Don't call dispose() twice

Issue: "Building with data before init()"
Fix: Await init() in main.dart

Issue: "Memory leak" warning
Fix: Call dispose() in State.dispose()

Issue: "No data in StreamBuilder"
Fix: Add initialData: [] parameter

Issue: "Stream not updating UI"
Fix: Verify StreamBuilder stream parameter is connected correctly


## QUICK CHECKLIST

Init:
✓ Call NotesStreamService() constructor
✓ Call init() method
✓ Store instance or use singleton

Create StreamBuilder:
✓ Use stream: parameter
✓ Use builder: (context, snapshot)
✓ Check snapshot.hasData
✓ Add initialData if needed

CRUD:
✓ Create note → createNote()
✓ Update note → updateNote()
✓ Delete note → deleteNote() or permanentlyDeleteNote()
✓ UI updates automatically via stream

Cleanup:
✓ Call dispose() in State.dispose()
✓ Close all controllers
✓ Free resources


## PERFORMANCE TIPS

1. Use const constructors for widgets
2. Use StreamBuilder only where needed
3. Filter at stream level, not UI level
4. Use .where() and .map() for transformations
5. Avoid rebuilding entire list, update individual items
6. Use initialData to show cached data immediately
7. Debounce search queries
8. Unsubscribe from streams when not visible

*/
