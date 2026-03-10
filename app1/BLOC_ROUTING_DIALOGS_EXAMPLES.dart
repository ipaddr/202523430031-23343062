/// EXAMPLE IMPLEMENTATION - Main App Setup
/// =======================================
///
/// Contoh cara set up dan integrate NavigationBloc dan DialogBloc ke dalam app

// Import BLoCs (uncomment when implementing)
// import 'lib/blocs/navigation_bloc.dart';
// import 'lib/blocs/dialog_bloc.dart';

// Import Listeners (uncomment when implementing)
// import 'lib/widgets/navigation_listener.dart';
// import 'lib/widgets/dialog_listener.dart';

// Import Router (uncomment when implementing)
// import 'lib/config/app_router.dart';

/*

CONTOH SETUP - main.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Navigation BLoC
        BlocProvider(
          create: (_) => NavigationBloc(),
        ),
        
        // Dialog BLoC
        BlocProvider(
          create: (_) => DialogBloc(),
        ),
        
        // Auth BLoC
        // BlocProvider(
        //   create: (_) => AuthBloc(authService: AuthService()),
        // ),
        
        // Lainnya...
      ],
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        
        // Wrap app dengan listeners
        home: NavigationListener(
          child: DialogListener(
            child: const HomeScreen(),
          ),
        ),
        
        // Route generator
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

ATAU jika menggunakan named routes:

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => DialogBloc()),
      ],
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: NavigationListener(
          child: DialogListener(
            child: const HomeScreen(),
          ),
        ),
        routes: {
          '/': (_) => const HomeScreen(),
          '/notes': (_) => const NotesDisplayScreen(),
          '/create-note': (_) => const CreateNoteScreen(),
          '/edit-note': (_) => const EditNoteScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}


══════════════════════════════════════════════════════════════════════════════
CONTOH PENGGUNAAN DI SCREEN
══════════════════════════════════════════════════════════════════════════════

CONTOH 1 - NAVIGATE KE SCREEN LAIN

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate menggunakan BLoC
                NavigationBloc.navigateTo(context, '/notes');
              },
              child: const Text('Lihat Catatan'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationBloc.navigateTo(context, '/create-note');
              },
              child: const Text('Buat Catatan Baru'),
            ),
          ],
        ),
      ),
    );
  }
}


CONTOH 2 - NAVIGATE DENGAN ARGUMENTS

class NotesDisplayScreen extends StatelessWidget {
  const NotesDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () {
              // Navigate dengan argument (note object)
              NavigationBloc.navigateTo(
                context,
                '/edit-note',
                arguments: note,
              );
            },
          );
        },
      ),
    );
  }
}


CONTOH 3 - HANDLE ARGUMENTS DI SCREEN TUJUAN

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({
    required this.note,
    super.key,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

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

  void _saveNote() async {
    try {
      // Save logic...

      // Show success dialog
      if (mounted) {
        context.read<DialogBloc>().add(
          const ShowSuccessDialog(
            title: 'Berhasil',
            message: 'Catatan berhasil diperbarui',
          ),
        );

        // Delay sebentar, kemudian pop
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          NavigationBloc.pop(context, result: 'success');
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<DialogBloc>().add(
          ShowErrorDialog(
            title: 'Error',
            message: 'Gagal menyimpan: \${e.toString()}',
          ),
        );
      }
    }
  }

  void _deleteNote() {
    // Show confirmation dialog
    context.read<DialogBloc>().add(
      const ShowConfirmationDialog(
        title: 'Konfirmasi Hapus',
        message: 'Apakah Anda yakin ingin menghapus catatan ini?',
        confirmLabel: 'Hapus',
        cancelLabel: 'Batal',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: BlocListener<DialogBloc, DialogState>(
        listener: (context, state) {
          if (state is DialogConfirmed) {
            // User confirmed delete
            _performDelete();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
    );
  }

  void _performDelete() {
    // Delete logic...
  }
}


CONTOH 4 - POP DENGAN RESULT

// Di screen yang di-navigate:
void _onSuccess() {
  NavigationBloc.pop(context, result: 'note_created');
}

// Di screen yang navigate:
void _navigateToCreate() async {
  NavigationBloc.navigateTo(context, '/create-note');
  
  // Atau jika ingin menangkap result:
  // final result = await Navigator.pushNamed(
  //   context,
  //   '/create-note',
  // );
  // if (result == 'note_created') {
  //   // Refresh notes list
  // }
}


CONTOH 5 - DIALOG DENGAN BlocListener

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) {
      context.read<DialogBloc>().add(
        const ShowErrorDialog(
          title: 'Validasi Error',
          message: 'Judul catatan tidak boleh kosong',
        ),
      );
      return;
    }

    // Save successful
    context.read<DialogBloc>().add(
      const ShowSuccessDialog(
        title: 'Berhasil',
        message: 'Catatan baru berhasil dibuat',
      ),
    );
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
            // Handle konfirmasi
          } else if (state is DialogClosed) {
            // Dialog sudah ditutup
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              ElevatedButton(
                onPressed: _saveNote,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
