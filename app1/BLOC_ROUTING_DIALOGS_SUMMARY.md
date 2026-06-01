# Moving to BLoC for Routing and Dialogs - Implementation Summary

## 📋 Apa yang Sudah Dibuat

Implementasi lengkap BLoC pattern untuk mengelola routing dan dialogs di Flutter app dengan struktur yang simple dan mudah dipahami.

---

## 📁 File-File yang Dibuat

### 1. Navigation BLoC Files

- `lib/blocs/navigation_event.dart` - Events untuk navigation
- `lib/blocs/navigation_state.dart` - States untuk navigation
- `lib/blocs/navigation_bloc.dart` - BLoC logic untuk navigation

### 2. Dialog BLoC Files

- `lib/blocs/dialog_event.dart` - Events untuk dialog
- `lib/blocs/dialog_state.dart` - States untuk dialog
- `lib/blocs/dialog_bloc.dart` - BLoC logic untuk dialog

### 3. Listener Widgets

- `lib/widgets/navigation_listener.dart` - Widget untuk mendengarkan navigation state
- `lib/widgets/dialog_listener.dart` - Widget untuk mendengarkan dialog state

### 4. Documentation

- `BLOC_ROUTING_DIALOGS_GUIDE.dart` - Panduan lengkap penggunaan
- `BLOC_ROUTING_DIALOGS_EXAMPLES.dart` - Contoh implementasi di screen

---

## 🎯 Navigation BLoC

**Fungsi:**
Mengelola semua routing/navigasi di aplikasi

**Events yang tersedia:**

1. `NavigateTo` - Navigate ke route baru
2. `NavigationPop` - Pop/back ke screen sebelumnya
3. `PopUntil` - Pop sampai ke route tertentu
4. `PopAndNavigate` - Pop all dan navigate ke route baru
5. `ReplaceRoute` - Replace route saat ini

**Helper Methods:**

```dart
NavigationBloc.navigateTo(context, '/route', arguments: data);
NavigationBloc.pop(context);
NavigationBloc.replace(context, '/route');
NavigationBloc.popAll(context, '/home');
```

---

## 💬 Dialog BLoC

**Fungsi:**
Mengelola semua dialog di aplikasi (success, error, info, confirmation)

**Events yang tersedia:**

1. `ShowConfirmationDialog` - Tampilkan dialog untuk konfirmasi
2. `ShowSuccessDialog` - Tampilkan dialog success
3. `ShowErrorDialog` - Tampilkan dialog error
4. `ShowInfoDialog` - Tampilkan dialog info
5. `CloseDialog` - Close dialog
6. `OnDialogConfirmed` - User click confirm
7. `OnDialogCancelled` - User click cancel

**Dialog Types:**

- ✅ Confirmation Dialog (dengan confirm/cancel buttons)
- 🎉 Success Dialog
- ❌ Error Dialog
- ℹ️ Info Dialog

---

## 🔧 Setup di Main.dart

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => DialogBloc()),
      ],
      child: MaterialApp(
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

---

## 💡 Contoh Penggunaan

### Navigate ke Screen Lain

```dart
NavigationBloc.navigateTo(context, '/notes');
```

### Navigate dengan Arguments

```dart
NavigationBloc.navigateTo(
  context,
  '/edit-note',
  arguments: noteObject,
);
```

### Show Success Dialog

```dart
context.read<DialogBloc>().add(
  const ShowSuccessDialog(
    title: 'Berhasil',
    message: 'Catatan berhasil disimpan',
  ),
);
```

### Show Confirmation Dialog

```dart
context.read<DialogBloc>().add(
  const ShowConfirmationDialog(
    title: 'Konfirmasi',
    message: 'Apakah yakin ingin menghapus?',
    confirmLabel: 'Hapus',
    cancelLabel: 'Batal',
  ),
);
```

### Listen untuk Dialog Result

```dart
BlocListener<DialogBloc, DialogState>(
  listener: (context, state) {
    if (state is DialogConfirmed) {
      // User klik confirm
    } else if (state is DialogCancelled) {
      // User klik cancel
    }
  },
  child: YourWidget(),
);
```

---

## ✅ Keuntungan Menggunakan BLoC Pattern

1. **Centralized Control** - Semua routing dan dialog dikelola dari satu tempat
2. **Testable** - Mudah untuk unit testing tanpa perlu context
3. **Reusable** - BLoC bisa digunakan di mana saja dalam app
4. **Clean Architecture** - Separation of concerns antara UI dan logic
5. **State Management** - Better management terhadap dialog state
6. **Type Safe** - Strong typing untuk route arguments

---

## 📊 Struktur Flow

```
User Action
    ↓
Screen emit BLoC Event
    ↓
BLoC process Event
    ↓
BLoC emit new State
    ↓
Listener mendengarkan State
    ↓
Listener execute action (navigate, show dialog)
    ↓
UI Update
```

---

## 🚀 Next Steps

1. **Update main.dart** - Setup BLoCs dan Listeners
2. **Update screens** - Ganti Navigator.push dengan NavigationBloc
3. **Replace showDialog** - Ganti showDialog dengan DialogBloc
4. **Add routing constants** - Buat file untuk route names
5. **Test the flow** - Testing navigation dan dialog

---

## 📝 File Location Guide

```
lib/
├── blocs/
│   ├── navigation_event.dart      ← Navigation events
│   ├── navigation_state.dart      ← Navigation states
│   ├── navigation_bloc.dart       ← Navigation BLoC
│   ├── dialog_event.dart          ← Dialog events
│   ├── dialog_state.dart          ← Dialog states
│   └── dialog_bloc.dart           ← Dialog BLoC
├── widgets/
│   ├── navigation_listener.dart   ← Navigation listener
│   └── dialog_listener.dart       ← Dialog listener
└── main.dart                      ← Setup BLoCs

root/
├── BLOC_ROUTING_DIALOGS_GUIDE.dart      ← Full guide
└── BLOC_ROUTING_DIALOGS_EXAMPLES.dart   ← Examples
```

---

## 📚 Dokumentasi Lengkap

Untuk dokumentasi lebih detail, buka:

- `BLOC_ROUTING_DIALOGS_GUIDE.dart` - Panduan lengkap dengan tips & best practices
- `BLOC_ROUTING_DIALOGS_EXAMPLES.dart` - Contoh implementasi real dari berbagai skenario

---

## ⚡ Quick Reference

| Task          | Code                                                                |
| ------------- | ------------------------------------------------------------------- |
| Navigate      | `NavigationBloc.navigateTo(context, '/route')`                      |
| Pop           | `NavigationBloc.pop(context)`                                       |
| Show Success  | `context.read<DialogBloc>().add(const ShowSuccessDialog(...))`      |
| Show Error    | `context.read<DialogBloc>().add(const ShowErrorDialog(...))`        |
| Show Confirm  | `context.read<DialogBloc>().add(const ShowConfirmationDialog(...))` |
| Listen Dialog | `BlocListener<DialogBloc, DialogState>(listener: ...)`              |

---

**Status:** ✅ Implementasi selesai dan ready to use!
