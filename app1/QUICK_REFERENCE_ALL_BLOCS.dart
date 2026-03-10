/// QUICK REFERENCE - ALL BLoCs & METHODS
/// ======================================
///
/// Ringkasan cepat semua methods dari NavigationBloc, DialogBloc, dan LoadingBloc

/*

════════════════════════════════════════════════════════════════════════════════
NAVIGATION BLOC - QUICK REFERENCE
════════════════════════════════════════════════════════════════════════════════

Method                                  Usage
─────────────────────────────────────────────────────────────────────────────

navigateTo(context, '/home')
  → Navigate ke route '/home'
  → Syntax: NavigationBloc.navigateTo(context, '/home')
  → Replaces Navigator.push()

pop(context)
  → Kembali ke screen sebelumnya (pop 1 screen)
  → Syntax: NavigationBloc.pop(context)
  → Replaces Navigator.pop()

popUntil(context, '/home')
  → Pop semua screen sampai ketemu '/home'
  → Syntax: NavigationBloc.popUntil(context, '/home')
  → Berguna untuk: kembali ke home setelah logout

popAll(context)
  → Pop semua screens, kembali ke first screen
  → Syntax: NavigationBloc.popAll(context)
  → Berguna untuk: reset app state setelah logout

replace(context, '/home')
  → Ganti current screen dengan '/home' tanpa menambah history
  → Syntax: NavigationBloc.replace(context, '/home')
  → Berguna untuk: login screen → home (ga perlu bisa back)


════════════════════════════════════════════════════════════════════════════════
DIALOG BLOC - QUICK REFERENCE
════════════════════════════════════════════════════════════════════════════════

Method                                  Usage
─────────────────────────────────────────────────────────────────────────────

showConfirmationDialog(context, 
  title: 'Konfirmasi', 
  message: 'Hapus?', 
  onConfirm: () => _delete()
)
  → Show konfirmasi dialog dengan OK & Cancel
  → Syntax: DialogBloc.showConfirmationDialog(...)
  → onConfirm callback dipanggil saat user tap OK

showSuccessDialog(context, 
  title: 'Sukses', 
  message: 'Catatan berhasil disimpan'
)
  → Show success dialog (hanya OK button)
  → Syntax: DialogBloc.showSuccessDialog(...)
  → Biasanya untuk konfirmasi operasi selesai

showErrorDialog(context, 
  title: 'Error', 
  message: 'Gagal menyimpan: ...'
)
  → Show error dialog (hanya OK button)
  → Syntax: DialogBloc.showErrorDialog(...)
  → Biasanya untuk error messages

showInfoDialog(context, 
  title: 'Info', 
  message: 'Total notes: 42'
)
  → Show informasi dialog (hanya OK button)
  → Syntax: DialogBloc.showInfoDialog(...)
  → Untuk menampilkan informasi penting


════════════════════════════════════════════════════════════════════════════════
LOADING BLOC - QUICK REFERENCE
════════════════════════════════════════════════════════════════════════════════

Method                                  Usage
─────────────────────────────────────────────────────────────────────────────

start(context, message: 'Menyimpan...')
  → Show loading overlay dengan message
  → Syntax: LoadingBloc.start(context, message: 'Menyimpan...')
  → Disable UI interaction sampai stop() dipanggil
  → Message opsional (default: 'Loading...')

stop(context)
  → Hide loading overlay
  → Syntax: LoadingBloc.stop(context)
  → Automatic: dialog auto-dismiss, UI enabled kembali
  → WAJIB dipanggil di akhir async operation

showWithMessage(context, 'Proses selesai')
  → Same as start() tapi dengan berbeda message
  → Syntax: LoadingBloc.showWithMessage(context, 'Proses selesai')


════════════════════════════════════════════════════════════════════════════════
LOADING SCREENS - QUICK REFERENCE
════════════════════════════════════════════════════════════════════════════════

Screen                          Usage
─────────────────────────────────────────────────────────────────────────────

SimpleLoadingScreen()
  → Basic spinner + message
  → Minimal, clean design
  → Cocok untuk: simple operations

LinearLoadingScreen()
  → Animated linear progress bar
  → Shows some progression
  → Cocok untuk: download/upload operations

ShimmerLoadingScreen()
  → Shimmer skeleton loading
  → Professional appearance
  → Cocok untuk: data loading dari database

CustomAnimatedLoadingScreen()
  → Rotating spinner dengan custom animation
  → Smooth 2-second rotation
  → Cocok untuk: file operations

DotsLoadingScreen()
  → Animated dots (scale animation)
  → Fun, interactive feel
  → Cocok untuk: user waiting screens

CardLoadingScreen()
  → Skeleton cards (like data structure)
  → Shows what UI structure will be
  → Cocok untuk: list/cards data loading


════════════════════════════════════════════════════════════════════════════════
LOADING WIDGETS - QUICK REFERENCE
════════════════════════════════════════════════════════════════════════════════

Widget                          Usage
─────────────────────────────────────────────────────────────────────────────

LoadingSpinner()
  → Basic circular spinner
  → Reusable di anywhere
  → Cocok untuk: simple loading indicators

LoadingBar()
  → Linear progress bar
  → Animated fill
  → Cocok untuk: show progress (20%, 50%, 80%)

SkeletonItem()
  → Skeleton placeholder (rectangular shimmer)
  → Customizable height
  → Cocok untuk: loading individual items

SkeletonNoteCard()
  → Skeleton of NoteCard (title + content shimmer)
  → Cocok untuk: loading note lists

SkeletonList()
  → List of SkeletonNoteCards
  → itemCount: jumlah skeleton items
  → Cocok untuk: FutureBuilder loading state

LoadingOverlay()
  → Full-screen overlay dengan LoadingSpinner
  → isLoading: true/false untuk show/hide
  → child: widget di belakang overlay
  → Cocok untuk: modal loading over content

ShimmerCard()
  → Card dengan shimmer animation
  → Berguna untuk: showing placeholder cards

LoadingButton()
  → Button yang disable saat loading
  → isLoading: true/false
  → Cocok untuk: form submit buttons

PageLoadingIndicator()
  → Small indicator untuk load-more
  → Cocok untuk: infinite scroll bottom indicator


════════════════════════════════════════════════════════════════════════════════
COMMON PATTERNS - COPY-PASTE READY
════════════════════════════════════════════════════════════════════════════════

PATTERN 1 - Navigation
```dart
NavigationBloc.navigateTo(context, '/home');
```

PATTERN 2 - Confirmation Dialog + Callback
```dart
DialogBloc.showConfirmationDialog(
  context,
  title: 'Konfirmasi',
  message: 'Yakin ingin dihapus?',
  onConfirm: () => _deleteItem(),
);
```

PATTERN 3 - Loading Screen Transition
```dart
NavigationBloc.navigateTo(context, '/create-note');
```

PATTERN 4 - Async Operation dengan Loading Overlay
```dart
void _saveNote() async {
  LoadingBloc.start(context, message: 'Menyimpan...');
  
  try {
    await _notesService.saveNote(_note);
    LoadingBloc.stop(context);
    
    if (mounted) {
      DialogBloc.showSuccessDialog(
        context,
        message: 'Catatan berhasil disimpan',
      );
    }
  } catch (e) {
    LoadingBloc.stop(context);
    
    if (mounted) {
      DialogBloc.showErrorDialog(
        context,
        message: 'Error: \$e',
      );
    }
  }
}
```

PATTERN 5 - FutureBuilder dengan Skeleton Loading
```dart
FutureBuilder<List<NoteModel>>(
  future: _loadNotes(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SkeletonList();
    }
    
    if (snapshot.hasError) {
      return Center(child: Text('Error: \${snapshot.error}'));
    }
    
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (_, i) => NoteCard(snapshot.data![i]),
    );
  },
)
```

PATTERN 6 - LoadingButton di Form
```dart
LoadingButton(
  label: 'Simpan',
  isLoading: _isSaving,
  onPressed: _isSaving ? null : _saveForm,
)
```

PATTERN 7 - LoadingOverlay untuk Modal
```dart
LoadingOverlay(
  isLoading: _isDeleting,
  child: Scaffold(
    body: Column(...),
  ),
)
```

PATTERN 8 - Infinite Scroll Load More
```dart
ListView.builder(
  itemCount: _items.length + (_isLoadingMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == _items.length) {
      return PageLoadingIndicator();
    }
    
    if (index == _items.length - 3) {
      _loadMore();
    }
    
    return ItemCard(_items[index]);
  },
)
```


════════════════════════════════════════════════════════════════════════════════
INTEGRATION CHECKLIST
════════════════════════════════════════════════════════════════════════════════

main.dart setup:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => NavigationBloc()),
    BlocProvider(create: (_) => DialogBloc()),
    BlocProvider(create: (_) => LoadingBloc()),
  ],
  child: MaterialApp(
    home: NavigationListener(
      child: DialogListener(
        child: LoadingListener(
          child: const HomeScreen(),
        ),
      ),
    ),
  ),
)
```


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING QUICK FIXES
════════════════════════════════════════════════════════════════════════════════

Problem: NavigationBloc not found
Fix: Add import 'package:.../navigation_bloc.dart' di file

Problem: Dialog tidak muncul
Fix: Check DialogListener sudah wrap MaterialApp

Problem: Loading overlay tidak hilang
Fix: Pastikan LoadingBloc.stop(context) dipanggil

Problem: Build error: no matching function
Fix: Pastikan parameter names sesuai (title, message, onConfirm, dll)

Problem: Widget rebuild loop
Fix: Move Future calls ke initState() bukan build()

Problem: Memory leak
Fix: Always call dispose() untuk TextEditingController

Problem: Mounted check error
Fix: Add 'if (mounted)' sebelum setState/Navigator/Dialog


════════════════════════════════════════════════════════════════════════════════
QUICK SUMMARY
════════════════════════════════════════════════════════════════════════════════

Navigation:
  navigateTo() → go to screen
  pop() → back 1 screen
  replace() → replace current screen
  popUntil() → back to specific screen

Dialog:
  showConfirmationDialog() → ask yes/no
  showSuccessDialog() → show success
  showErrorDialog() → show error
  showInfoDialog() → show info

Loading:
  start() → show overlay
  stop() → hide overlay
  

Loading UI:
  6 Loading Screens (SimpleLoading, LinearLoading, ShimmerLoading, etc)
  9 Loading Widgets (LoadingButton, SkeletonList, LoadingOverlay, etc)

*/
