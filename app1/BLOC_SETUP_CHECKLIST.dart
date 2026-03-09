/// BLoC Implementation Checklist & Next Steps
///
/// Lengkapi semua checkbox untuk transformasi lengkap ke BLoC pattern

// ============ PREREQUISITES ✅ ============
/*
☐ Created: lib/blocs/auth_event.dart (auth_event.dart)
  - AuthCheckRequested
  - LoginRequested
  - RegisterRequested
  - LogoutRequested
  - UpdateProfileRequested
  - ResetPasswordRequested

☐ Created: lib/blocs/auth_state.dart (auth_state.dart)
  - AuthInitial
  - AuthLoading
  - AuthSuccess (with userId, email, name, photoUrl)
  - AuthUnauthenticated
  - AuthError (with message and errorCode)
  - ProfileUpdateSuccess
  - ResetPasswordEmailSent

☐ Created: lib/blocs/auth_bloc.dart (auth_bloc.dart)
  - Full event handlers implemented
  - Firebase error handling
  - Firestore user profile creation/update
  - Helper methods

☐ Updated: pubspec.yaml
  - flutter_bloc: ^8.1.0
  - bloc: ^8.1.0
  - equatable: ^2.0.5

☐ Created: Documentation files
  - BLOC_PATTERN_GUIDE.dart
  - BLOC_INTEGRATION_GUIDE.dart
  - QUICK_REFERENCE_BLOC.dart
  - BLOC_TROUBLESHOOTING_GUIDE.dart
  - BLOC_SETUP_CHECKLIST.dart (this file)
*/

// ============ STEP 1: Run flutter pub get ============
/*
$ cd d:\SEMESTER 6\Mobile Programing Lanjut\202523430031-23343062\app1
$ flutter pub get

Ini akan download dan install flutter_bloc, bloc, equatable packages
*/

// ============ STEP 2: Create BLoC file structure ============
/*
lib/
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart          ✅ Already created
│   │   ├── auth_event.dart         ✅ Already created
│   │   └── auth_state.dart         ✅ Already created
│   └── note/  (untuk nanti)
│       ├── note_bloc.dart
│       ├── note_event.dart
│       └── note_state.dart
├── screens/
│   ├── login_screen.dart           ← Need to update
│   ├── register_screen.dart        ← Need to update
│   └── home_screen.dart            ← Need to update
├── services/
│   ├── auth_service.dart           ✅ Existing
│   ├── notes_stream_service.dart   ✅ Existing
│   └── firestore_notes_service.dart ✅ Existing
└── main.dart                        ← Need to update

Current status: 3/5 key files updated required
*/

// ============ STEP 3: Update main.dart ============
/*
TODO:
1. Import BLoC packages
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'blocs/auth/auth_bloc.dart';
   import 'blocs/auth/auth_event.dart';

2. Create AuthBloc in main()
   final authBloc = AuthBloc(authService: AuthService());
   authBloc.add(const AuthCheckRequested());

3. Provide BLoC via BlocProvider
   BlocProvider<AuthBloc>.value(
     value: authBloc,
     child: MyApp(),
   )

4. Create AuthWrapper untuk routing
   - If AuthSuccess -> HomeScreen
   - If AuthLoading -> LoadingScreen
   - Else -> LoginScreen

PRIORITY: HIGH - Do this second (after pub get)
*/

// ============ STEP 4: Update LoginScreen ============
/*
TODO:
1. Import BLoC packages
   import 'package:flutter_bloc/flutter_bloc.dart';
   import '../blocs/auth/auth_bloc.dart';
   import '../blocs/auth/auth_event.dart';
   import '../blocs/auth/auth_state.dart';

2. Remove AuthService direct usage
   - Delete: final authService = AuthService();
   - Delete: final result = await authService.login(...);

3. Replace with BLoC
   context.read<AuthBloc>().add(
     LoginRequested(
       email: email,
       password: password,
     ),
   );

4. Add BlocListener for errors
   BlocListener<AuthBloc, AuthState>(
     listener: (context, state) {
       if (state is AuthError) {
         // Show error snackbar
       }
     },
   )

5. Add BlocBuilder for loading state
   BlocBuilder<AuthBloc, AuthState>(
     builder: (context, state) {
       return isLoading
           ? CircularProgressIndicator()
           : LoginButton();
     },
   )

PRIORITY: HIGH - Do this third
*/

// ============ STEP 5: Update RegisterScreen ============
/*
TODO:
1. Import BLoC packages (same as LoginScreen)

2. Replace AuthService with BLoC
   context.read<AuthBloc>().add(
     RegisterRequested(
       email: email,
       password: password,
       name: name,
     ),
   );

3. Add BlocListener & BlocBuilder (same pattern as LoginScreen)

4. Handle registration success
   - Navigate to home or show confirmation

PRIORITY: HIGH - Do this fourth
*/

// ============ STEP 6: Update HomeScreen / NotesDisplayScreen ============
/*
TODO:
1. Add logout button handler
   void _handleLogout() {
     context.read<AuthBloc>().add(const LogoutRequested());
   }

2. Add BlocListener untuk logout
   BlocListener<AuthBloc, AuthState>(
     listener: (context, state) {
       if (state is AuthUnauthenticated) {
         // Navigate to login
       }
     },
   )

3. Get current user info dari BLoC
   final state = context.read<AuthBloc>().state;
   if (state is AuthSuccess) {
     final userId = state.userId;
     final email = state.email;
   }

PRIORITY: MEDIUM - Do this fifth
*/

// ============ STEP 7: Add BLoC Observer (Optional but Useful) ============
/*
TODO:
1. Create lib/config/bloc_observer.dart
   import 'package:bloc/bloc.dart';

   class SimpleBlocObserver extends BlocObserver {
     @override
     void onEvent(Bloc bloc, Object? event) {
       super.onEvent(bloc, event);
       print('Event: $event');
     }

     @override
     void onChange(BlocBase bloc, Change change) {
       super.onChange(bloc, change);
       print('Change: ${change.currentState} -> ${change.nextState}');
     }

     @override
     void onTransition(Bloc bloc, Transition transition) {
       super.onTransition(bloc, transition);
       print('Transition: $transition');
     }

     @override
     void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
       super.onError(bloc, error, stackTrace);
       print('Error: $error');
     }
   }

2. Setup di main.dart
   void main() {
     Bloc.observer = SimpleBlocObserver();
     runApp(...);
   }

PRIORITY: LOW - Nice to have for debugging
*/

// ============ STEP 8: Write Tests ============
/*
TODO:
1. Create test/auth_bloc_test.dart
   import 'package:bloc_test/bloc_test.dart';
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     group('AuthBloc', () {
       late AuthBloc authBloc;

       setUp(() {
         authBloc = AuthBloc(authService: AuthService());
       });

       tearDown(() {
         authBloc.close();
       });

       test('initial state is AuthInitial', () {
         expect(authBloc.state, AuthInitial());
       });

       blocTest<AuthBloc, AuthState>(
         'emits [AuthLoading, AuthSuccess] when login successful',
         build: () => authBloc,
         act: (bloc) => bloc.add(
           LoginRequested(
             email: 'test@test.com',
             password: 'password123',
           ),
         ),
         expect: () => [
           AuthLoading(),
           isA<AuthSuccess>(),
         ],
       );
     });
   }

2. Add dev dependency
   flutter_test (already in pubspec.yaml)
   bloctest: ^9.1.0

3. Run tests
   flutter test

PRIORITY: MEDIUM - Do this after integration complete
*/

// ============ PHASE 1: Critical Updates (Do First) ============
/*
1. ☐ Run: flutter pub get
   Duration: ~2 minutes
   Importance: CRITICAL

2. ☐ Update main.dart with BLoC setup
   Duration: ~10 minutes
   Importance: CRITICAL
   Files: main.dart

3. ☐ Update LoginScreen
   Duration: ~15 minutes
   Importance: CRITICAL
   Files: screens/login_screen.dart

4. ☐ Update RegisterScreen
   Duration: ~15 minutes
   Importance: CRITICAL
   Files: screens/register_screen.dart

5. ☐ Test login/register flows
   Duration: ~10 minutes
   Importance: CRITICAL

TOTAL PHASE 1 TIME: ~50 minutes
*/

// ============ PHASE 2: Integration & Testing (Do Second) ============
/*
6. ☐ Update HomeScreen / NotesDisplayScreen
   Duration: ~10 minutes
   Importance: HIGH
   Files: screens/home_screen.dart, screens/notes_display_screen.dart

7. ☐ Update NotesDisplayScreen features (share, edit, delete)
   Duration: ~10 minutes
   Importance: HIGH

8. ☐ Add BLoC Observer
   Duration: ~5 minutes
   Importance: MEDIUM

9. ☐ Write auth_bloc_test.dart
   Duration: ~20 minutes
   Importance: MEDIUM

10. ☐ Run all tests & debug
    Duration: ~15 minutes
    Importance: CRITICAL

TOTAL PHASE 2 TIME: ~60 minutes
*/

// ============ PHASE 3: Expansion (Do Third) ============
/*
11. ☐ Create NoteBloc for note CRUD
    Duration: ~30 minutes
    Importance: MEDIUM

12. ☐ Integrate NoteBloc into screens
    Duration: ~20 minutes
    Importance: MEDIUM

13. ☐ Write note_bloc_test.dart
    Duration: ~20 minutes
    Importance: LOW

14. ☐ Full app testing
    Duration: ~20 minutes
    Importance: HIGH

15. ☐ Deploy to device
    Duration: ~10 minutes
    Importance: HIGH

TOTAL PHASE 3 TIME: ~100 minutes

TOTAL ALL PHASES: ~210 minutes (~3.5 hours)
*/

// ============ COMMONLY FORGOTTEN ============
/*
☐ Import Equatable for all event/state classes
☐ Override get props for all Equatable classes
☐ Handle ALL FirebaseAuthException codes
☐ Emit AuthLoading before async operations
☐ Close BLoC in tests
☐ Use BlocListener for side effects (not in BLoC)
☐ Use BlocBuilder for UI state only
☐ Add const to event/state constructors
☐ Update pubspec.yaml BEFORE importing
☐ Test on actual device (not just emulator)
*/

// ============ VERIFICATION CHECKLIST ============
/*
After completing all steps, verify:

Login Feature:
☐ User can login with email/password
☐ Error shown for invalid credentials
☐ Loading indicator shown while logging in
☐ Successfully navigates to home
☐ User info (email, name) displayed in home

Register Feature:
☐ User can create new account
☐ Validation for weak password
☐ Error for duplicate email
☐ Loading indicator shown
☐ Auto-login after registration
☐ User data saved to Firestore

Logout Feature:
☐ Logout button visible in home
☐ Clicking logout returns to login
☐ User data cleared
☐ Cannot access home without login

State Persistence:
☐ App reopened remember login status
☐ AuthCheckRequested called on app start
☐ User auto-logged back in if still authenticated

Error Handling:
☐ Network errors handled gracefully
☐ Firebase errors mapped to user messages
☐ UI doesn't crash on unexpected errors
☐ Error messages clear and helpful

BLoC Lifecycle:
☐ BLoC created once in main.dart
☐ BLoC events properly dispatched
☐ States properly emitted
☐ No memory leaks
☐ Tests pass without warnings
*/

// ============ ROLLBACK PLAN ============
/*
If something breaks during migration:

1. Revert to service-based approach
   - Remove imports for auth_bloc, auth_event, auth_state
   - Use AuthService directly in screens
   - Roll back screens to original setState version

2. Identify breaking change
   - Check BLoC event/state definitions
   - Verify Firebase error handling
   - Check imports and dependencies

3. Fix & redeploy
   - Update files
   - Run flutter clean
   - Run flutter pub get
   - Test again

Important: Keep git commits frequent so you can revert if needed
*/

// ============ EXPECTED BEHAVIOR ============
/*
Before BLoC:
User taps Login -> setState call -> AuthService.login() -> manage state manually

After BLoC:
User taps Login -> dispatch LoginRequested -> BLoC handles event -> emit state -> Widget rebuilds

Benefits:
✅ Separation of concern (business logic in BLoC, UI in Widget)
✅ Reusable logic (same BLoC across different screens)
✅ Testable (easy to mock BLoC, test event handlers)
✅ Scalable (easy to add more features)
✅ Maintainable (clear event flows and state transitions)
✅ Debuggable (BlocObserver shows all state changes)
*/

// ============ NEXT FEATURES ============
/*
Setelah Auth BLoC done, buat untuk:

1. NoteBloc
   - Events: CreateNoteRequested, UpdateNoteRequested, DeleteNoteRequested,
              SearchNotesRequested, FetchNotesRequested
   - States: NoteLoading, NoteSuccess, NoteError, NoteDeleted

2. ShareBloc
   - Events: ShareNoteRequested, UnshareNoteRequested, FetchSharedNotesRequested
   - States: ShareLoading, ShareSuccess, ShareError

3. ProfileBloc
   - Events: FetchProfileRequested, UpdateProfileRequested
   - States: ProfileLoading, ProfileSuccess, ProfileError

Apply same pattern, dokumentasi akan memudahkan!
*/

// ============ RESOURCES ============
/*
Official Flutter BLoC Documentation:
https://bloclibrary.dev/

Flutter BLoC YouTube Tutorial:
https://www.youtube.com/watch?v=jM3-R9ONknk&list=PLprI2stzMcSgfqLJXjVmrtm2KLODqodKu

BLocTest Package:
https://pub.dev/packages/bloc_test

Equatable Package:
https://pub.dev/packages/equatable

Firebase Auth with BLoC:
https://firebase.flutter.dev/docs/auth/start

This Workspace Files Created:
- lib/blocs/auth_event.dart
- lib/blocs/auth_state.dart
- lib/blocs/auth_bloc.dart
- BLOC_PATTERN_GUIDE.dart
- BLOC_INTEGRATION_GUIDE.dart
- QUICK_REFERENCE_BLOC.dart
- BLOC_TROUBLESHOOTING_GUIDE.dart
- BLOC_SETUP_CHECKLIST.dart (this file)
*/
