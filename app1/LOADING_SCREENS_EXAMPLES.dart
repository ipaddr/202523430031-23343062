/// LOADING SCREENS EXAMPLES
/// ======================
///
/// Contoh implementasi praktis dari berbagai loading screen scenarios

/*

══════════════════════════════════════════════════════════════════════════════
EXAMPLE 1 - SimpleLoadingScreen
══════════════════════════════════════════════════════════════════════════════

```dart
// Di main screen saat loading catatan
if (isLoading) {
  return const SimpleLoadingScreen(message: 'Memuat catatan...');
} else {
  return NotesListView(notes: notes);
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 2 - Navigate ke Loading Screen, Lalu Pop
══════════════════════════════════════════════════════════════════════════════

```dart
class NotesDisplayScreen extends StatefulWidget {
  const NotesDisplayScreen({super.key});

  @override
  State<NotesDisplayScreen> createState() => _NotesDisplayScreenState();
}

class _NotesDisplayScreenState extends State<NotesDisplayScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    // Navigate to loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SimpleLoadingScreen(
          message: 'Memuat catatan...',
        ),
      ),
    );

    try {
      // Do loading operation
      await Future.delayed(const Duration(seconds: 2));
      
      // Pop loading screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Pop loading screen even on error
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: ListView.builder(...),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 3 - Loading dengan SkeletonList (Better UX)
══════════════════════════════════════════════════════════════════════════════

```dart
class NotesDisplayScreen extends StatefulWidget {
  const NotesDisplayScreen({super.key});

  @override
  State<NotesDisplayScreen> createState() => _NotesDisplayScreenState();
}

class _NotesDisplayScreenState extends State<NotesDisplayScreen> {
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _loadNotesFromFirebase();
  }

  Future<List<NoteModel>> _loadNotesFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('userId', isEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat catatan: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Saya')),
      body: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          // Loading - show skeleton
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonList();
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: \${snapshot.error}'),
            );
          }

          // Success
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return SkeletonNoteCard(); // or NoteCard(notes[index])
              },
            );
          }

          // Empty
          return const Center(
            child: Text('Tidak ada catatan'),
          );
        },
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 4 - LoadingButton untuk Save Operation
══════════════════════════════════════════════════════════════════════════════

```dart
class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final note = NoteModel(
        id: DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(note.id)
          .set(note.toMap());

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                hintText: 'Judul',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              enabled: !_isSaving,
              minLines: 10,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Konten',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Loading button
            LoadingButton(
              label: 'Simpan',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveNote,
            ),
          ],
        ),
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 5 - LoadingOverlay untuk Modal Operations
══════════════════════════════════════════════════════════════════════════════

```dart
class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({required this.note, super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _deleteNote() async {
    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.note.id)
          .delete();

      setState(() => _isDeleting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isDeleting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteNote,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isDeleting,
        message: 'Menghapus catatan...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                enabled: !_isDeleting,
                decoration: const InputDecoration(
                  hintText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                enabled: !_isDeleting,
                minLines: 10,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Konten',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 6 - Load More dengan PageLoadingIndicator
══════════════════════════════════════════════════════════════════════════════

```dart
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final List<NoteModel> _notes = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialNotes();
  }

  Future<void> _loadInitialNotes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .limit(10)
          .get();

      setState(() {
        _notes.addAll(
          snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)),
        );
      });
    } catch (e) {
      print('Error loading initial notes: \$e');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final lastNote = _notes.last;
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .startAfter([lastNote.createdAt])
          .limit(10)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _notes.addAll(
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)),
          );
        });
      }
    } catch (e) {
      print('Error loading more notes: \$e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: ListView.builder(
        itemCount: _notes.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at bottom
          if (index == _notes.length) {
            return PageLoadingIndicator();
          }

          // Load more when reaching near end
          if (index == _notes.length - 3 && !_isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadMore();
            });
          }

          return NoteCard(_notes[index]);
        },
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
EXAMPLE 7 - Global Loading with LoadingBloc
══════════════════════════════════════════════════════════════════════════════

Setup main.dart:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoadingBloc()),
      ],
      child: MaterialApp(
        home: LoadingListener(
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
```

Usage di screen:

```dart
void _syncAllNotes() async {
  try {
    LoadingBloc.start(context, message: 'Melakukan sinkronisasi...');

    // Do sync operation
    await _notesService.syncAllNotes();

    LoadingBloc.stop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sinkronisasi berhasil')),
      );
    }
  } catch (e) {
    LoadingBloc.stop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')),
      );
    }
  }
}
```

*/
