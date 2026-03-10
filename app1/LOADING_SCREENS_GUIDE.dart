/// LOADING SCREENS GUIDE
/// ====================
///
/// Panduan lengkap untuk menggunakan berbagai jenis loading screens

/*

══════════════════════════════════════════════════════════════════════════════
OVERVIEW - Jenis-Jenis Loading Screens
══════════════════════════════════════════════════════════════════════════════

Ada 2 kategori loading screens:

1. FULL SCREEN LOADING
   - SimpleLoadingScreen
   - LinearLoadingScreen
   - ShimmerLoadingScreen
   - CustomAnimatedLoadingScreen
   - DotsLoadingScreen
   - CardLoadingScreen

2. LOADING WIDGETS (untuk di dalam screen lain)
   - LoadingSpinner
   - LoadingBar
   - SkeletonItem
   - SkeletonNoteCard
   - SkeletonList
   - LoadingOverlay
   - ShimmerCard
   - LoadingButton
   - PageLoadingIndicator


══════════════════════════════════════════════════════════════════════════════
SETUP - Add LoadingBloc
══════════════════════════════════════════════════════════════════════════════

Di main.dart:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => NavigationBloc()),
    BlocProvider(create: (_) => DialogBloc()),
    BlocProvider(create: (_) => LoadingBloc()),  // Add ini
  ],
  child: MaterialApp(
    home: LoadingListener(  // Wrap dengan LoadingListener
      child: NavigationListener(
        child: DialogListener(
          child: const HomeScreen(),
        ),
      ),
    ),
  ),
)
```


══════════════════════════════════════════════════════════════════════════════
USAGE - Cara Menggunakan
══════════════════════════════════════════════════════════════════════════════

### 1. FULL SCREEN LOADING - Simple Spinner

```dart
// Navigate ke full screen loading
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const SimpleLoadingScreen(
      message: 'Memuat catatan...',
    ),
  ),
);

// Atau jika sudah selesai, pop screen
Navigator.pop(context);
```

### 2. FULL SCREEN LOADING - Linear Progress

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const LinearLoadingScreen(
      message: 'Menyimpan catatan...',
    ),
  ),
);
```

### 3. FULL SCREEN LOADING - Shimmer (Skeleton)

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const ShimmerLoadingScreen(
      title: 'Catatan Saya',
    ),
  ),
);
```

### 4. FULL SCREEN LOADING - Custom Animated

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CustomAnimatedLoadingScreen(
      message: 'Memuat...',
    ),
  ),
);
```

### 5. FULL SCREEN LOADING - Dots Animation

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const DotsLoadingScreen(
      message: 'Tunggu sebentar...',
    ),
  ),
);
```

### 6. FULL SCREEN LOADING - Card Style

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CardLoadingScreen(
      title: 'Proses Penyimpanan',
      subtitle: 'Jangan tutup aplikasi',
    ),
  ),
);
```


══════════════════════════════════════════════════════════════════════════════
LOADING WIDGETS - Embedded di Screen Lain
══════════════════════════════════════════════════════════════════════════════

### 1. LoadingSpinner - Simple Spinner Widget

```dart
// Gunakan saat loading content di tengah screen
if (isLoading) {
  const LoadingSpinner(
    message: 'Memuat data...',
    size: 50,
  );
} else {
  // Content
}
```

### 2. LoadingBar - Linear Progress Bar

```dart
const LoadingBar(
  label: 'Menyimpan...',
  valueColor: Colors.blue,
)
```

### 3. SkeletonItem - Individual Skeleton

```dart
// Untuk placeholder single item
SkeletonItem(
  width: 200,
  height: 20,
  borderRadius: 8,
)
```

### 4. SkeletonNoteCard - Skeleton Note Card

```dart
// Untuk placeholder note saat loading list
SkeletonNoteCard()
```

### 5. SkeletonList - Multiple Skeleton Items

```dart
// Untuk loading list of items
if (isLoading) {
  SkeletonList(
    itemCount: 5,
    itemHeight: 80,
  );
} else {
  ListView.builder(...)
}
```

### 6. LoadingOverlay - Overlay di atas content

```dart
// Loading overlay di atas content
LoadingOverlay(
  isLoading: isLoading,
  message: isSaving ? 'Menyimpan...' : null,
  child: YourContent(),
)
```

### 7. ShimmerCard - Animated Skeleton Card

```dart
// Animated skeleton untuk loading
ShimmerCard(
  height: 80,
  borderRadius: 8,
)
```

### 8. LoadingButton - Button dengan Loading State

```dart
// Button yang bisa show loading
LoadingButton(
  label: 'Simpan',
  isLoading: isSaving,
  onPressed: isSaving ? null : () => _saveNote(),
)
```

### 9. PageLoadingIndicator - Load More Indicator

```dart
// Untuk bottom of list saat load more
ListView.builder(
  itemCount: notes.length + (isLoadingMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == notes.length) {
      return PageLoadingIndicator();
    }
    return NoteCard(notes[index]);
  },
)
```


══════════════════════════════════════════════════════════════════════════════
LOADING BLOC - Manage Global Loading State
══════════════════════════════════════════════════════════════════════════════

Setup di main.dart:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => LoadingBloc()),
  ],
  child: MaterialApp(
    home: LoadingListener(
      child: HomeScreen(),
    ),
  ),
)
```

Gunakan di screen:

```dart
// Start loading
LoadingBloc.start(context, message: 'Menyimpan...');

// Stop loading
LoadingBloc.stop(context);

// Show loading dengan message
LoadingBloc.showWithMessage(context, 'Processing...');
```

Contoh di method:

```dart
void _saveNote() async {
  try {
    LoadingBloc.start(context, message: 'Menyimpan catatan...');
    
    await _notesService.saveNote(note);
    
    LoadingBloc.stop(context);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil disimpan')),
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


══════════════════════════════════════════════════════════════════════════════
CONTOH IMPLEMENTASI - Create Note Screen
══════════════════════════════════════════════════════════════════════════════

```dart
class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

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

    try {
      setState(() => _isSaving = true);
      LoadingBloc.start(context, message: 'Menyimpan catatan...');

      final note = NoteModel(
        id: DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
      );

      await Future.delayed(const Duration(seconds: 1)); // Simulate save
      
      LoadingBloc.stop(context);
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      LoadingBloc.stop(context);
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
      appBar: AppBar(
        title: const Text('Buat Catatan'),
      ),
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
              minLines: 8,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Konten',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Option 1: Menggunakan LoadingButton
            LoadingButton(
              label: 'Simpan',
              isLoading: _isSaving,
              onPressed: _saveNote,
            ),
            
            // Option 2: Manual dengan conditional
            // if (_isSaving)
            //   const CircularProgressIndicator()
            // else
            //   ElevatedButton(
            //     onPressed: _saveNote,
            //     child: const Text('Simpan'),
            //   ),
          ],
        ),
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
CONTOH - Loading List dengan Skeleton
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
    _notesFuture = _loadNotes();
  }

  Future<List<NoteModel>> _loadNotes() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    return [
      NoteModel(id: '1', title: 'Note 1', content: 'Content 1', createdAt: DateTime.now()),
      NoteModel(id: '2', title: 'Note 2', content: 'Content 2', createdAt: DateTime.now()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
      ),
      body: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          // Loading state - show skeleton
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonList(
              itemCount: 5,
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: \${snapshot.error}'),
            );
          }

          // Success state
          if (snapshot.hasData) {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(notes[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```


══════════════════════════════════════════════════════════════════════════════
TIPS DAN BEST PRACTICES
══════════════════════════════════════════════════════════════════════════════

✅ DO:
- Gunakan skeleton/shimmer untuk list loading (lebih baik UX)
- Show loading message untuk operasi lama
- Disable inputs saat loading (prevent duplicate action)
- Stop loading jika terjadi error
- Use LoadingButton untuk button dengan loading state

❌ DON'T:
- Jangan show full screen loading untuk operasi sepele
- Jangan lupa stop loading setelah done
- Jangan block semua UI saat loading (rasa tidak responsif)
- Jangan show generic "Loading..." (give more context)
- Jangan make loading animation terlalu distracting


══════════════════════════════════════════════════════════════════════════════
COMPARISON - Kapan Menggunakan Apa
══════════════════════════════════════════════════════════════════════════════

Kasus Usage:

1. Loading Full Screen
   ├─ SimpleLoadingScreen: Operasi sederhana, quick loading
   ├─ LinearLoadingScreen: Operasi dengan progress known
   ├─ ShimmerLoadingScreen: List/grid dengan banyak items
   └─ CustomAnimatedLoadingScreen: Loading untuk kesan fancy

2. Loading Widget
   ├─ LoadingSpinner: Center content loading (optional)
   ├─ SkeletonList: List yang belum loaded
   ├─ LoadingOverlay: Modal loading di atas content
   └─ LoadingButton: Button state management

3. Global Loading (via BLoC)
   ├─ Long running operations
   ├─ Background syncing
   └─ Cross-screen loading

*/
