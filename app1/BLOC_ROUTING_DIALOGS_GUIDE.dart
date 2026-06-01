/// MOVING TO BLOC FOR ROUTING AND DIALOGS
/// ======================================
///
/// Panduan untuk menggunakan BLoC pattern untuk manage routing dan dialogs

/*

══════════════════════════════════════════════════════════════════════════════
OVERVIEW - Mengapa menggunakan BLoC untuk Routing dan Dialogs?
══════════════════════════════════════════════════════════════════════════════

Keuntungan:
1. Centralized routing logic
2. Mudah testing (tidak perlu context)
3. Reusable di berbagai tempat
4. Better state management
5. Clean separation of concerns

Struktur:
- NavigationBloc: Handle semua navigasi/routing
- DialogBloc: Handle semua dialogs
- NavigationListener: Mendengarkan NavigationBloc
- DialogListener: Mendengarkan DialogBloc


══════════════════════════════════════════════════════════════════════════════
SETUP - Integrasi dengan App
══════════════════════════════════════════════════════════════════════════════

1. Update main.dart:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => DialogBloc()),
        // BLoC lainnya...
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: NavigationListener(
          child: DialogListener(
            child: const HomeScreen(),
          ),
        ),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
```

2. File structure yang diperlukan:
   - lib/blocs/navigation_bloc.dart
   - lib/blocs/navigation_event.dart
   - lib/blocs/navigation_state.dart
   - lib/blocs/dialog_bloc.dart
   - lib/blocs/dialog_event.dart
   - lib/blocs/dialog_state.dart
   - lib/widgets/navigation_listener.dart
   - lib/widgets/dialog_listener.dart


══════════════════════════════════════════════════════════════════════════════
USAGE - Cara Menggunakan
══════════════════════════════════════════════════════════════════════════════

### 1. NAVIGATE KE ROUTE BARU

// Option 1: Menggunakan NavigationBloc.navigateTo (recommended)
NavigationBloc.navigateTo(
  context,
  '/edit-note',
  arguments: note,
);

// Option 2: Emit event langsung
context.read<NavigationBloc>().add(
  NavigateTo(
    routeName: '/edit-note',
    arguments: note,
  ),
);

// Option 3: Standard Flutter navigation (masih bisa digunakan)
Navigator.pushNamed(context, '/edit-note', arguments: note);


### 2. POP/BACK

// Option 1: Menggunakan helper method
NavigationBloc.pop(context);

// Option 2: Standard Flutter
Navigator.pop(context);


### 3. REPLACE ROUTE

// Replace route saat ini dengan route baru
NavigationBloc.replace(
  context,
  '/dashboard',
);


### 4. POP ALL SCREENS

// Pop semua screen sampai ke route tertentu
NavigationBloc.popAll(context, '/dashboard');


### 5. SHOW DIALOGS

// Success Dialog
context.read<DialogBloc>().add(
  const ShowSuccessDialog(
    title: 'Berhasil',
    message: 'Catatan berhasil disimpan',
  ),
);

// Error Dialog
context.read<DialogBloc>().add(
  const ShowErrorDialog(
    title: 'Error',
    message: 'Terjadi kesalahan saat menyimpan',
  ),
);

// Info Dialog
context.read<DialogBloc>().add(
  const ShowInfoDialog(
    title: 'Informasi',
    message: 'Catatan Anda kosong',
  ),
);

// Confirmation Dialog
context.read<DialogBloc>().add(
  const ShowConfirmationDialog(
    title: 'Konfirmasi',
    message: 'Apakah Anda yakin ingin menghapus?',
    confirmLabel: 'Hapus',
    cancelLabel: 'Batal',
  ),
);


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
      // Show error dialog
      context.read<DialogBloc>().add(
        const ShowErrorDialog(
          title: 'Error',
          message: 'Judul tidak boleh kosong',
        ),
      );
      return;
    }

    try {
      // Save note...
      
      // Show success dialog
      context.read<DialogBloc>().add(
        const ShowSuccessDialog(
          title: 'Berhasil',
          message: 'Catatan berhasil disimpan',
        ),
      );

      // Delay sebentar, kemudian navigate back
      await Future.delayed(const Duration(seconds: 1));
      NavigationBloc.pop(context);
    } catch (e) {
      context.read<DialogBloc>().add(
        ShowErrorDialog(
          title: 'Error',
          message: 'Gagal menyimpan: \${e.toString()}',
        ),
      );
    }
  }

  void _deleteNote(String noteId) async {
    // Show confirmation dialog
    context.read<DialogBloc>().add(
      const ShowConfirmationDialog(
        title: 'Konfirmasi Hapus',
        message: 'Apakah yakin ingin menghapus catatan ini?',
        confirmLabel: 'Hapus',
        cancelLabel: 'Batal',
      ),
    );

    // Listen untuk confirmation result
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Catatan'),
      ),
      body: BlocListener<DialogBloc, DialogState>(
        listener: (context, state) {
          if (state is DialogConfirmed) {
            // User confirm delete
            _performDelete();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  minLines: 10,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Konten',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _performDelete() {
    // Delete logic here
  }
}
```


══════════════════════════════════════════════════════════════════════════════
TIPS DAN BEST PRACTICES
══════════════════════════════════════════════════════════════════════════════

✅ DO:
- Gunakan helper methods (NavigationBloc.navigateTo) untuk kemudahan
- Listen ke DialogBloc state untuk handle user actions
- Keep navigation logic centralized
- Use strong typing untuk route arguments

❌ DON'T:
- Jangan mix BLoC navigation dengan Navigator.push
- Jangan emit navigation state tanpa real action
- Jangan hardcode route names (gunakan constants)
- Jangan lupa dispose controllers


══════════════════════════════════════════════════════════════════════════════
TESTING GUIDE
══════════════════════════════════════════════════════════════════════════════

Test NavigationBloc:

```dart
void main() {
  group('NavigationBloc', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    test('emit NavigationChanged when NavigateTo is added', () {
      expect(
        navigationBloc.stream,
        emits(
          NavigationChanged(
            routeName: '/notes',
            arguments: null,
          ),
        ),
      );

      navigationBloc.add(
        const NavigateTo(routeName: '/notes'),
      );
    });
  });
}
```

Test DialogBloc:

```dart
void main() {
  group('DialogBloc', () {
    late DialogBloc dialogBloc;

    setUp(() {
      dialogBloc = DialogBloc();
    });

    tearDown(() {
      dialogBloc.close();
    });

    test('emit SuccessDialogState when ShowSuccessDialog is added', () {
      expect(
        dialogBloc.stream,
        emits(
          SuccessDialogState(
            title: 'Success',
            message: 'Operation successful',
          ),
        ),
      );

      dialogBloc.add(
        const ShowSuccessDialog(
          title: 'Success',
          message: 'Operation successful',
        ),
      );
    });
  });
}
```


══════════════════════════════════════════════════════════════════════════════
MIGRATION FROM NAVIGATOR.PUSH TO BLOC
══════════════════════════════════════════════════════════════════════════════

BEFORE (Standard Flutter):
```dart
Navigator.pushNamed(context, '/edit-note', arguments: note);
```

AFTER (Using BLoC):
```dart
NavigationBloc.navigateTo(context, '/edit-note', arguments: note);
```


BEFORE (Standard Flutter):
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Success'),
    content: const Text('Note saved'),
    actions: [TextButton(...)],
  ),
);
```

AFTER (Using BLoC):
```dart
context.read<DialogBloc>().add(
  const ShowSuccessDialog(
    title: 'Success',
    message: 'Note saved',
  ),
);
```


══════════════════════════════════════════════════════════════════════════════
SUMMARY
══════════════════════════════════════════════════════════════════════════════

BLoC for Routing & Dialogs memberikan:
✓ Centralized control
✓ Better testability
✓ Cleaner code
✓ Better separation of concerns
✓ Reusable across app

Mulai gunakan dan rasakan perbedaannya!

*/
