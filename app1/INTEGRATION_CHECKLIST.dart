/// INTEGRATION CHECKLIST
/// ====================
///
/// Checklist lengkap untuk mengintegrasikan Navigation BLoC, Dialog BLoC,
/// dan Loading BLoC ke dalam aplikasi Flutter

/*

════════════════════════════════════════════════════════════════════════════════
STEP 1 - Pastikan Semua File Sudah Ada
════════════════════════════════════════════════════════════════════════════════

Cek di lib/blocs/ folder:
✅ navigation_event.dart
✅ navigation_state.dart
✅ navigation_bloc.dart

✅ dialog_event.dart
✅ dialog_state.dart
✅ dialog_bloc.dart

✅ loading_event.dart
✅ loading_state.dart
✅ loading_bloc.dart

Cek di lib/widgets/ folder:
✅ navigation_listener.dart
✅ dialog_listener.dart
✅ loading_listener.dart
✅ loading_screens.dart
✅ loading_widgets.dart


════════════════════════════════════════════════════════════════════════════════
STEP 2 - Update pubspec.yaml
════════════════════════════════════════════════════════════════════════════════

Pastikan dependencies ini sudah ada:

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  equatable: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  firebase_core: ^2.0.0

Dev komentar bagian yang tidak perlu:
dev_dependencies:
  flutter_test:
    sdk: flutter


════════════════════════════════════════════════════════════════════════════════
STEP 3 - Update main.dart (PENTING!)
════════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/navigation/navigation_bloc.dart';
import 'blocs/dialog/dialog_bloc.dart';
import 'blocs/loading/loading_bloc.dart';
import 'widgets/navigation_listener.dart';
import 'widgets/dialog_listener.dart';
import 'widgets/loading_listener.dart';
import 'screens/login_screen.dart'; // atau screen awal kalian
import 'config/app_router.dart'; // jika ada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        BlocProvider(create: (_) => LoadingBloc()),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: NavigationListener(
          child: DialogListener(
            child: LoadingListener(
              child: const LoginScreen(), // atau screen awal kalian
            ),
          ),
        ),
        // Jika menggunakan routes dengan AppRouter:
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}


════════════════════════════════════════════════════════════════════════════════
STEP 4 - Update AppRouter (jika ada AppRouter)
════════════════════════════════════════════════════════════════════════════════

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case '/create-note':
        return MaterialPageRoute(
          builder: (_) => const CreateNoteScreen(),
        );

      case '/edit-note':
        final noteId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditNoteScreen(noteId: noteId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}


════════════════════════════════════════════════════════════════════════════════
STEP 5 - Gunakan NavigationBloc di Screens
════════════════════════════════════════════════════════════════════════════════

SEBELUM (tanpa BLoC):
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
```

SESUDAH (dengan BLoC):
```dart
NavigationBloc.navigateTo(context, '/home');
```


════════════════════════════════════════════════════════════════════════════════
STEP 6 - Gunakan DialogBloc di Screens
════════════════════════════════════════════════════════════════════════════════

SEBELUM (tanpa BLoC):
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Konfirmasi'),
    content: const Text('Apakah Anda yakin?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hapus')),
    ],
  ),
);
```

SESUDAH (dengan BLoC):
```dart
DialogBloc.showConfirmationDialog(
  context,
  title: 'Konfirmasi',
  message: 'Apakah Anda yakin?',
  onConfirm: () => _deleteNote(),
);
```


════════════════════════════════════════════════════════════════════════════════
STEP 7 - Gunakan LoadingBloc di Screens
════════════════════════════════════════════════════════════════════════════════

```dart
void _saveNote() async {
  try {
    // Show loading overlay
    LoadingBloc.start(context, message: 'Menyimpan catatan...');

    // Do operation
    await _notesService.saveNote(_note);

    // Hide loading overlay
    LoadingBloc.stop(context);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan')),
      );
    }
  } catch (e) {
    // Hide loading overlay
    LoadingBloc.stop(context);

    // Show error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')),
      );
    }
  }
}
```


════════════════════════════════════════════════════════════════════════════════
STEP 8 - Testing
════════════════════════════════════════════════════════════════════════════════

Cek apakah semua berfungsi:

1. ✅ App bisa launch tanpa error
2. ✅ Navigation bekerja (tekan tombol, pindah screen)
3. ✅ Dialog muncul (tekan tombol delete, dialog confirm muncul)
4. ✅ Loading overlay muncul saat save/delete
5. ✅ Semua listener bekerja (navigation_listener, dialog_listener, loading_listener)


════════════════════════════════════════════════════════════════════════════════
STEP 9 - File Struktur yang Diharapkan (Struktur Lengkap)
════════════════════════════════════════════════════════════════════════════════

lib/
├── main.dart (UPDATED dengan MultiBlocProvider & Listeners)
├── firebase_options.dart
├── config/
│   └── app_router.dart (optional, untuk routing)
├── blocs/
│   ├── navigation/
│   │   ├── navigation_event.dart
│   │   ├── navigation_state.dart
│   │   └── navigation_bloc.dart
│   ├── dialog/
│   │   ├── dialog_event.dart
│   │   ├── dialog_state.dart
│   │   └── dialog_bloc.dart
│   └── loading/
│       ├── loading_event.dart
│       ├── loading_state.dart
│       └── loading_bloc.dart
├── widgets/
│   ├── navigation_listener.dart
│   ├── dialog_listener.dart
│   ├── loading_listener.dart
│   ├── loading_screens.dart (SimpleLoadingScreen, dll)
│   └── loading_widgets.dart (LoadingButton, SkeletonList, dll)
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── create_note_screen.dart
│   ├── edit_note_screen.dart
│   └── details_screen.dart
├── models/
│   └── note_model.dart
├── services/
│   ├── auth_service.dart
│   ├── notes_service.dart
│   └── firestore_service.dart
└── exceptions/
    └── auth_exceptions.dart


════════════════════════════════════════════════════════════════════════════════
STEP 10 - Troubleshooting
════════════════════════════════════════════════════════════════════════════════

Problem: "NavigationBloc tidak ditemukan"
Solusi: 
- Pastikan import statement sudah ada di main.dart
- Pastikan MultiBlocProvider sudah include BlocProvider(create: (_) => NavigationBloc())
- Jalankan `flutter pub get`

Problem: Dialog tidak muncul saat DialogBloc.showConfirmationDialog dipanggil
Solusi:
- Pastikan DialogListener sudah wrap MaterialApp
- Pastikan DialogBloc sudah di MultiBlocProvider
- Cek apakah ada BlocListener yang mendengarkan DialogState

Problem: Loading overlay tidak muncul
Solusi:
- Pastikan LoadingListener sudah wrap MaterialApp (paling dalam)
- Pastikan LoadingBloc sudah di MultiBlocProvider
- Cek context apakah sudah ada BlocProvider di atasnya

Problem: "The following assertion was thrown during performLayout: RenderFlex children have non-zero flex but incoming height constraints are unbounded"
Solusi:
- Jangan wrap widget dengan Column/Row tanpa memberi height constraints
- Gunakan Expanded untuk children yang perlu flexible


════════════════════════════════════════════════════════════════════════════════
STEP 11 - Contoh Implementasi Lengkap
════════════════════════════════════════════════════════════════════════════════

EXAMPLE - LoginScreen dengan All 3 BLoCs:

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);

    try {
      // Show loading overlay
      LoadingBloc.start(context, message: 'Melakukan login...');

      // Login operation
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Hide loading overlay
      LoadingBloc.stop(context);

      if (userCredential.user != null) {
        // Navigate to home
        NavigationBloc.navigateTo(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      LoadingBloc.stop(context);

      if (mounted) {
        // Show error dialog
        DialogBloc.showErrorDialog(
          context,
          title: 'Login Gagal',
          message: e.message ?? 'Error tidak diketahui',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            LoadingButton(
              label: 'Login',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _login,
            ),
          ],
        ),
      ),
    );
  }
}
```


════════════════════════════════════════════════════════════════════════════════
STEP 12 - Verification Checklist
════════════════════════════════════════════════════════════════════════════════

Sebelum mengedeploy atau mengirim ke pengguna, pastikan:

[] main.dart sudah updated dengan MultiBlocProvider
[] Semua import statement sudah ada di main.dart
[] NavigationListener, DialogListener, LoadingListener sudah wrap app
[] Semua file BLoC sudah ada (event, state, bloc)
[] Semua listener files sudah ada
[] All loading screen dan widgets files sudah ada
[] flutter pub get sudah dijalankan
[] flutter clean sudah dijalankan
[] Tidak ada errors di project
[] NavigationBloc.navigateTo() bekerja (tes saat berpindah screen)
[] DialogBloc.showConfirmationDialog() bekerja (tes saat delete)
[] LoadingBloc.start() dan .stop() bekerja (tes saat save)
[] Tidak ada memory leaks (check dengan flutter devtools)
[] Performance acceptable (no janky animations)


════════════════════════════════════════════════════════════════════════════════
NEXT STEPS
════════════════════════════════════════════════════════════════════════════════

Setelah semua terintegrasikan:

1. Update semua screens untuk menggunakan BLoC patterns (NavigationBloc untuk navigate,
   DialogBloc untuk dialogs, LoadingBloc untuk loading overlays)

2. Create unit tests untuk setiap BLoC (navigation_bloc_test.dart, dll)

3. Create integration tests untuk user flows

4. Optimize performance jika ada bottlenecks

5. Add more features seperti:
   - Snackbar BLoC untuk global notifications
   - Theme BLoC untuk dark/light mode
   - LanguageBloc untuk multi-language support

*/
