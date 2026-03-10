/// BLoC ARCHITECTURE OVERVIEW
/// ==========================
///
/// Gambaran komprehensif dari seluruh BLoC architecture untuk Notes App

/*

════════════════════════════════════════════════════════════════════════════════
ARCHITECTURE DIAGRAM
════════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                              MyApp                                           │
│                         (Material App)                                       │
│                                                                               │
│  MultiBlocProvider [NavigationBloc, DialogBloc, LoadingBloc]                 │
│         │                                                                     │
│         ├── NavigationListener                                               │
│         │   └── DialogListener                                               │
│         │       └── LoadingListener                                          │
│         │           └── Home Screen                                          │
│         │                                                                     │
│         └── All Screens (receive BLoC via context)                           │
└─────────────────────────────────────────────────────────────────────────────┘


════════════════════════════════════════════════════════════════════════════════
DATA FLOW - NAVIGATION SYSTEM
════════════════════════════════════════════════════════════════════════════════

USER ACTION (Tap Button)
    │
    └─> NavigationBloc.navigateTo(context, '/home')
            │
            └─> NavigationEvent (NavigateTo('/home'))
                    │
                    └─> NavigationBloc.mapEventToState()
                            │
                            └─> NavigationState (NavigationChanged('/home'))
                                    │
                                    └─> NavigationListener (BlocListener)
                                            │
                                            └─> Navigator.pushNamed('/home')
                                                    │
                                                    └─> Screen Changes


════════════════════════════════════════════════════════════════════════════════
DATA FLOW - DIALOG SYSTEM
════════════════════════════════════════════════════════════════════════════════

USER ACTION (Tap Delete)
    │
    └─> DialogBloc.showConfirmationDialog(context, ...)
            │
            └─> DialogEvent (ShowConfirmationDialog)
                    │
                    └─> DialogBloc.mapEventToState()
                            │
                            └─> DialogState (ConfirmationDialogState)
                                    │
                                    └─> DialogListener (BlocBuilder)
                                            │
                                            └─> showDialog(AlertDialog)
                                                    │
                                    ┌───────────────┴───────────────┐
                                    │                               │
                        User Taps OK           User Taps Cancel
                            │                       │
            DialogBloc.add(OnDialogConfirmed)   (dismiss dialog)
                            │
                    DialogEvent (OnDialogConfirmed)
                            │
                    DialogState (DialogConfirmed)
                            │
                    DialogListener (trigger callback)
                            │
                    Execute _deleteNote()


════════════════════════════════════════════════════════════════════════════════
DATA FLOW - LOADING SYSTEM
════════════════════════════════════════════════════════════════════════════════

ASYNC OPERATION START
    │
    └─> LoadingBloc.start(context, message: 'Saving...')
            │
            └─> LoadingEvent (StartLoading/ShowLoadingWithMessage)
                    │
                    └─> LoadingBloc.mapEventToState()
                            │
                            └─> LoadingState (LoadingInProgress)
                                    │
                                    └─> LoadingListener (BlocBuilder)
                                            │
                                            └─> Show LoadingOverlay
                                                    │
                                        [User sees loading overlay]


ASYNC OPERATION FINISH
    │
    └─> LoadingBloc.stop(context)
            │
            └─> LoadingEvent (StopLoading)
                    │
                    └─> LoadingBloc.mapEventToState()
                            │
                            └─> LoadingState (LoadingCompleted)
                                    │
                                    └─> LoadingListener (BlocBuilder)
                                            │
                                            └─> Hide LoadingOverlay
                                                    │
                                        [Loading disappears]


════════════════════════════════════════════════════════════════════════════════
COMPONENT STRUCTURE
════════════════════════════════════════════════════════════════════════════════

NAVIGATION BLoC:
  ├── Event (navigation_event.dart)
  │   ├── NavigateTo(routeName)
  │   ├── NavigationPop()
  │   ├── PopUntil(routeName)
  │   ├── PopAndNavigate(routeName)
  │   └── ReplaceRoute(routeName)
  │
  ├── State (navigation_state.dart)
  │   ├── NavigationInitial()
  │   ├── NavigationChanged(routeName)
  │   ├── NavigationPopped()
  │   ├── NavigationPoppedUntil(routeName)
  │   └── NavigationReplaced(routeName)
  │
  ├── BLoC (navigation_bloc.dart)
  │   ├── navigateTo(context, route)
  │   ├── pop(context)
  │   ├── replace(context, route)
  │   ├── popAll(context)
  │   └── popUntil(context, route)
  │
  └── Listener (navigation_listener.dart)
      └── BlocListener → Navigator actions


DIALOG BLoC:
  ├── Event (dialog_event.dart)
  │   ├── ShowConfirmationDialog(...)
  │   ├── ShowSuccessDialog(...)
  │   ├── ShowErrorDialog(...)
  │   ├── ShowInfoDialog(...)
  │   ├── OnDialogConfirmed()
  │   └── OnDialogCancelled()
  │
  ├── State (dialog_state.dart)
  │   ├── DialogInitial()
  │   ├── ConfirmationDialogState(...)
  │   ├── SuccessDialogState(...)
  │   ├── ErrorDialogState(...)
  │   ├── InfoDialogState(...)
  │   ├── DialogConfirmed()
  │   └── DialogCancelled()
  │
  ├── BLoC (dialog_bloc.dart)
  │   ├── showConfirmationDialog(...)
  │   ├── showSuccessDialog(...)
  │   ├── showErrorDialog(...)
  │   └── showInfoDialog(...)
  │
  └── Listener (dialog_listener.dart)
      └── BlocBuilder → Show appropriate dialog


LOADING BLoC:
  ├── Event (loading_event.dart)
  │   ├── StartLoading()
  │   ├── StopLoading()
  │   └── ShowLoadingWithMessage(message)
  │
  ├── State (loading_state.dart)
  │   ├── LoadingInitial()
  │   ├── LoadingInProgress(message?)
  │   └── LoadingCompleted()
  │
  ├── BLoC (loading_bloc.dart)
  │   ├── start(context, message?)
  │   ├── stop(context)
  │   └── showWithMessage(context, message)
  │
  └── Listener (loading_listener.dart)
      └── BlocBuilder → Show/hide overlay


LOADING SCREENS (loading_screens.dart):
  ├── SimpleLoadingScreen
  ├── LinearLoadingScreen
  ├── ShimmerLoadingScreen
  ├── CustomAnimatedLoadingScreen
  ├── DotsLoadingScreen
  └── CardLoadingScreen


LOADING WIDGETS (loading_widgets.dart):
  ├── LoadingSpinner
  ├── LoadingBar
  ├── SkeletonItem
  ├── SkeletonNoteCard
  ├── SkeletonList
  ├── LoadingOverlay
  ├── ShimmerCard
  ├── LoadingButton
  └── PageLoadingIndicator


════════════════════════════════════════════════════════════════════════════════
COMPLETE SEQUENCE DIAGRAM - Full User Journey
════════════════════════════════════════════════════════════════════════════════

USER OPENS APP:
  1. main() initializes Firebase
  2. MultiBlockProvider wraps app with 3 BLoCs
  3. NavigationListener wraps app → listens to NavigationBloc
  4. DialogListener wraps app → listens to DialogBloc
  5. LoadingListener wraps app → listens to LoadingBloc
  6. LoginScreen displayed


USER LOGS IN:
  1. User fills email & password
  2. User taps Login button
  3. LoadingBloc.start(context) → overlay appears
  4. FirebaseAuth.signInWithEmailAndPassword() called
  5. On success:
     - LoadingBloc.stop(context) → overlay disappears
     - NavigationBloc.navigateTo(context, '/home') → Navigate to HomeScreen
  6. On error:
     - LoadingBloc.stop(context) → overlay disappears
     - DialogBloc.showErrorDialog() → Error dialog appears
     - User taps OK → DialogListener triggers callback


USER OPENS NOTES LIST:
  1. HomeScreen builds and calls _loadNotes()
  2. FutureBuilder starts waiting for Firestore query
  3. SkeletonList shows as placeholder
  4. Once Firestore returns data, SkeletonList replaced with actual NoteCards


USER CREATES NEW NOTE:
  1. User taps "New Note" button
  2. NavigationBloc.navigateTo(context, '/create-note')
  3. CreateNoteScreen appears
  4. User fills form and taps Save
  5. LoadingBloc.start(context, 'Menyimpan...') → overlay appears
  6. Firestore.collection('notes').add() called
  7. On success:
     - LoadingBloc.stop(context) → overlay disappears
     - DialogBloc.showSuccessDialog('Catatan berhasil disimpan')
     - After dialog OK → NavigationBloc.navigateTo(context, '/home')
  8. On error:
     - LoadingBloc.stop(context)
     - DialogBloc.showErrorDialog('Error: ...')


USER DELETES NOTE:
  1. User taps delete icon on NoteCard
  2. DialogBloc.showConfirmationDialog('Hapus catatan ini?')
  3. ConfirmationDialog appears
  4. If user taps OK:
     - DialogBloc.add(OnDialogConfirmed())
     - DialogListener triggers callback
     - LoadingBloc.start(context, 'Menghapus...')
     - Firestore.collection('notes').doc(id).delete()
     - On success:
       - LoadingBloc.stop(context)
       - DialogBloc.showSuccessDialog('Catatan berhasil dihapus')
       - HomeScreen refetches notes list
     - On error:
       - LoadingBloc.stop(context)
       - DialogBloc.showErrorDialog('Error: ...')
  5. If user taps Cancel:
     - DialogListener triggers callback (do nothing)
     - Dialog dismisses


════════════════════════════════════════════════════════════════════════════════
INTERACTION MATRIX
════════════════════════════════════════════════════════════════════════════════

┌──────────────┬──────────────┬──────────────┬──────────────┐
│ Navigation   │  Dialog      │  Loading     │  Result      │
├──────────────┼──────────────┼──────────────┼──────────────┤
│ navigateTo   │              │              │ User moves   │
│              │              │              │ to new route │
├──────────────┼──────────────┼──────────────┼──────────────┤
│ navigateTo   │ confirm()    │              │ User sees    │
│              │              │              │ dialog, then │
│              │              │              │ navigates    │
├──────────────┼──────────────┼──────────────┼──────────────┤
│              │ error()      │              │ Error shown  │
├──────────────┼──────────────┼──────────────┼──────────────┤
│              │              │ start()      │ Overlay      │
│              │              │              │ shows        │
├──────────────┼──────────────┼──────────────┼──────────────┤
│              │              │ start()      │ Disable UI,  │
│              │              │ then         │ do work,     │
│              │              │ stop()       │ overlay      │
│              │              │              │ disappears   │
├──────────────┼──────────────┼──────────────┼──────────────┤
│              │ success()    │ stop()       │ UI enabled,  │
│              │              │              │ success      │
│              │              │              │ dialog shown │
└──────────────┴──────────────┴──────────────┴──────────────┘


════════════════════════════════════════════════════════════════════════════════
BEST PRACTICES
════════════════════════════════════════════════════════════════════════════════

✅ DO:

1. Always wrap async operations with LoadingBloc.start() and .stop()
2. Always check 'if (mounted)' before showing dialogs/snackbars
3. Use NavigationBloc for all screen transitions
4. Use DialogBloc for all user confirmations
5. Keep LoadingListener at highest level in widget tree
6. Provide meaningful messages in LoadingBloc.start(context, message)
7. Use SkeletonList/SkeletonNoteCard for data loading placeholders
8. Disable form inputs while saving (set enabled: !_isSaving)
9. Call LoadingBloc.stop() in both try/catch blocks
10. Test all three BLoCs before deploying


❌ DON'T:

1. Don't use Navigator.push instead of NavigationBloc.navigateTo
2. Don't use showDialog instead of DialogBloc.showConfirmationDialog
3. Don't forget to call LoadingBloc.stop() after operation
4. Don't show multiple overlays simultaneously
5. Don't make uncontrolled async calls without LoadingBloc
6. Don't forget mounted checks in async callbacks
7. Don't nest Dialogs too deeply
8. Don't use LinearLoadingScreen for quick operations (<1 second)
9. Don't forget to dispose TextEditingControllers
10. Don't call get_errors if project has syntax errors


════════════════════════════════════════════════════════════════════════════════
PERFORMANCE CONSIDERATIONS
════════════════════════════════════════════════════════════════════════════════

1. LoadingBloc.stop() automatically removes overlay after completion
2. All listener widgets use BlocBuilder for efficient rebuilds
3. SkeletonList shows content as it loads (incremental rendering)
4. NavigationBloc uses routes instead of pushing screens (memory efficient)
5. DialogBloc uses single overlay instead of multiple dialogs


════════════════════════════════════════════════════════════════════════════════
TESTING CHECKLIST
════════════════════════════════════════════════════════════════════════════════

Integration tests to verify:

[] Navigate between screens works
[] Dialog appears when expected
[] Dialog callbacks trigger correct actions
[] Loading overlay appears/disappears correctly
[] Can't interact with UI during loading
[] Errors show appropriate error dialogs
[] Success operations show success dialogs
[] Memory is cleaned up after operations
[] No memory leaks with repeated navigation
[] Performance acceptable with large data


════════════════════════════════════════════════════════════════════════════════
DEPLOYMENT CHECKLIST
════════════════════════════════════════════════════════════════════════════════

Before releasing to production:

[] All three BLoCs integrated in main.dart
[] All listeners properly wrapped around app
[] No errors in 'flutter analyze'
[] All screens use BLoC for navigation/dialogs/loading
[] LoadingBloc properly manages all async operations
[] Error handling covers all Firebase exceptions
[] User-facing error messages are clear and helpful
[] Loading overlays have appropriate messages
[] No hardcoded English text (all translated)
[] Tests run successfully
[] Performance benchmarks acceptable

*/
