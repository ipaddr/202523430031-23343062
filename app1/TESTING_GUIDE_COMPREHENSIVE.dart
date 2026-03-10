/// TESTING GUIDE - COMPREHENSIVE
/// =============================
///
/// Panduan testing untuk memastikan semua fitur berfungsi dengan baik

/*

════════════════════════════════════════════════════════════════════════════════
UNIT 1 - AUTHENTICATION TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 1.1 - User Registration
  Steps:
    1. Buka app
    2. Tap Registration button
    3. Isi email: test@gmail.com
    4. Isi password: Test123!@#
    5. Tap Register button
  Expected:
    ✅ Loading overlay muncul
    ✅ Success dialog muncul
    ✅ Auto navigate ke LoginScreen

TEST 1.2 - User Login dengan credentials benar
  Steps:
    1. Di LoginScreen, isi email: test@gmail.com
    2. Isi password: Test123!@#
    3. Tap Login button
  Expected:
    ✅ Loading overlay muncul
    ✅ Success dialog muncul
    ✅ Navigate ke HomeScreen

TEST 1.3 - User Login dengan password salah
  Steps:
    1. Isi email: test@gmail.com
    2. Isi password: WrongPassword123
    3. Tap Login button
  Expected:
    ✅ Loading overlay muncul
    ✅ Error dialog muncul
    ✅ Error message: "Incorrect password"
    ✅ Stay di LoginScreen

TEST 1.4 - User Login dengan email tidak ada
  Steps:
    1. Isi email: notexist@gmail.com
    2. Isi password: AnyPassword123
    3. Tap Login button
  Expected:
    ✅ Loading overlay muncul
    ✅ Error dialog muncul
    ✅ Error message: "User not found"
    ✅ Stay di LoginScreen

TEST 1.5 - Login Attempt dengan empty fields
  Steps:
    1. Leave email & password empty
    2. Tap Login button
  Expected:
    ✅ Validation error muncul
    ✅ Error message: "Email tidak boleh kosong"
    ✅ No API call made

TEST 1.6 - User Logout
  Steps:
    1. Di HomeScreen, tap Logout button
    2. Confirmation dialog muncul
    3. Tap Yes to confirm
  Expected:
    ✅ Loading overlay muncul
    ✅ Navigate back ke LoginScreen
    ✅ All user data cleared


════════════════════════════════════════════════════════════════════════════════
UNIT 2 - CREATE NOTE TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 2.1 - Create note dengan data lengkap
  Steps:
    1. Di HomeScreen, tap "Create New Note" button
    2. Isi Judul: "Test Note 1"
    3. Isi Content: "This is a test note content"
    4. Tap "Simpan Catatan" button
  Expected:
    ✅ Loading overlay muncul dengan message "Menyimpan catatan..."
    ✅ Success dialog muncul
    ✅ Auto navigate back ke HomeScreen
    ✅ Note muncul di list

TEST 2.2 - Create note dengan judul kosong
  Steps:
    1. Di CreateNoteScreen, leave Judul empty
    2. Isi Content: "Some content"
    3. Tap "Simpan Catatan" button
  Expected:
    ✅ Error dialog muncul
    ✅ Error message: "Judul tidak boleh kosong!"
    ✅ Stay di CreateNoteScreen

TEST 2.3 - Create note dengan content kosong (tapi judul ada)
  Steps:
    1. Isi Judul: "Title Only"
    2. Leave Content empty
    3. Tap "Simpan Catatan" button
  Expected:
    ✅ Loading overlay muncul
    ✅ Success dialog muncul (content boleh kosong)
    ✅ Navigate back
    ✅ Note disimpan dengan content kosong

TEST 2.4 - Cancel create note
  Steps:
    1. Di CreateNoteScreen, isi beberapa data
    2. Tap "Batal" button
  Expected:
    ✅ Navigate back ke HomeScreen
    ✅ Tidak ada data yang disimpan

TEST 2.5 - Create note saat offline
  Steps:
    1. Turn off WiFi/Mobile data
    2. Buat note dengan data lengkap
    3. Tap "Simpan Catatan"
  Expected:
    ✅ Loading overlay muncul
    ✅ Error dialog muncul (network error)
    ✅ Error message clear
    ✅ Stay di CreateNoteScreen (bisa retry)


════════════════════════════════════════════════════════════════════════════════
UNIT 3 - READ NOTES TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 3.1 - Load notes list
  Steps:
    1. Di HomeScreen, tunggu sampai notes load
  Expected:
    ✅ Skeleton loading muncul saat loading
    ✅ Skeleton replaced with actual notes
    ✅ All notes dari database ditampilkan
    ✅ Notes sorted by created date (newest first)

TEST 3.2 - Notes list kosong
  Steps:
    1. User dengan notes kosong masuk app
  Expected:
    ✅ Empty state muncul
    ✅ Message: "Belum ada catatan"
    ✅ Button: "Create Note" visible

TEST 3.3 - Scroll notes list
  Steps:
    1. Scroll up/down di notes list
  Expected:
    ✅ Notes scroll smoothly
    ✅ No lag atau jank
    ✅ Loading indicator visible saat scroll (jika load-more)

TEST 3.4 - Refresh notes list
  Steps:
    1. Pull to refresh di notes list
  Expected:
    ✅ Refresh indicator muncul
    ✅ Skeleton loading muncul
    ✅ List updated dengan data terbaru


════════════════════════════════════════════════════════════════════════════════
UNIT 4 - EDIT NOTE TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 4.1 - Edit note dengan data baru
  Steps:
    1. Tap existing note
    2. Tap Edit button
    3. Change title: "Updated Title"
    4. Change content: "Updated content"
    5. Tap "Simpan Perubahan"
  Expected:
    ✅ Loading overlay muncul
    ✅ Success dialog muncul
    ✅ Navigate back
    ✅ Note di list updated dengan data baru
    ✅ Verified di database (Firestore)

TEST 4.2 - Edit note - clear judul
  Steps:
    1. Open edit screen
    2. Clear judul field (make empty)
    3. Tap "Simpan Perubahan"
  Expected:
    ✅ Error dialog muncul
    ✅ Error message: "Judul tidak boleh kosong"
    ✅ Stay di EditScreen

TEST 4.3 - Cancel edit note
  Steps:
    1. Open edit screen
    2. Make some changes
    3. Tap "Batal" button
  Expected:
    ✅ Navigate back
    ✅ Changes NOT saved
    ✅ Original data unchanged

TEST 4.4 - Edit note saat offline
  Steps:
    1. Turn off internet
    2. Open existing note
    3. Make changes
    4. Save
  Expected:
    ✅ Loading overlay muncul
    ✅ Error dialog: network error
    ✅ Data tetap di device (local)
    ✅ Can retry when online


════════════════════════════════════════════════════════════════════════════════
UNIT 5 - DELETE NOTE TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 5.1 - Delete note dengan confirmation
  Steps:
    1. Open note
    2. Tap Delete icon
    3. Confirmation dialog muncul
    4. Tap "Ya" (confirm)
  Expected:
    ✅ Loading overlay muncul
    ✅ Success dialog muncul
    ✅ Navigate back ke list
    ✅ Note removed dari list
    ✅ Note removed dari database

TEST 5.2 - Delete note - cancel confirmation
  Steps:
    1. Open note
    2. Tap Delete icon
    3. Confirmation dialog muncul
    4. Tap "Tidak" (cancel)
  Expected:
    ✅ Dialog close
    ✅ Note NOT deleted
    ✅ Stay di edit screen

TEST 5.3 - Delete note saat offline
  Steps:
    1. Turn off internet
    2. Open note
    3. Tap delete
    4. Confirm delete
  Expected:
    ✅ Loading overlay muncul
    ✅ Error dialog: network error
    ✅ Note NOT deleted


════════════════════════════════════════════════════════════════════════════════
UNIT 6 - SEARCH & FILTER TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 6.1 - Search note by title
  Steps:
    1. Di notes list, tap search bar
    2. Type: "Test" (partial title)
    3. Watch results update
  Expected:
    ✅ Results filtered in real-time
    ✅ Only notes dengan "Test" di title ditampilkan
    ✅ Notes count updated

TEST 6.2 - Search note by content
  Steps:
    1. Tap search bar
    2. Type: "specific keyword" dari content
  Expected:
    ✅ Notes dengan keyword ditampilkan
    ✅ Real-time filter working

TEST 6.3 - Search dengan no results
  Steps:
    1. Tap search bar
    2. Type: "xyznonexistent"
  Expected:
    ✅ Empty state muncul
    ✅ Message: "Catatan tidak ditemukan"
    ✅ Search bar still active untuk retry

TEST 6.4 - Clear search
  Steps:
    1. Search something
    2. Clear search bar
  Expected:
    ✅ All notes ditampilkan kembali


════════════════════════════════════════════════════════════════════════════════
UNIT 7 - NAVIGATION TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 7.1 - Navigate LoginScreen → RegisterScreen
  Expected:
    ✅ Screen transition smooth
    ✅ Back button works

TEST 7.2 - Navigate LoginScreen → HomeScreen
  Steps:
    1. Login successful
  Expected:
    ✅ Smooth transition
    ✅ No back button ke LoginScreen (or pop)

TEST 7.3 - Navigate HomeScreen → CreateNoteScreen
  Steps:
    1. Tap "Create Note" button
  Expected:
    ✅ Screen appear correctly
    ✅ Back button works

TEST 7.4 - Navigate HomeScreen → EditNoteScreen
  Steps:
    1. Tap note from list
  Expected:
    ✅ EditNoteScreen appear dengan note data
    ✅ Pre-filled fields

TEST 7.5 - Back button dari CreateNoteScreen
  Steps:
    1. Open CreateNoteScreen
    2. Tap system back button atau back button
  Expected:
    ✅ Navigate back ke HomeScreen
    ✅ No state preserved (form reset)

TEST 7.6 - Multiple navigate & back
  Steps:
    1. HomeScreen → Create Note
    2. Back to HomeScreen
    3. Tap Note → EditScreen
    4. Back to HomeScreen
  Expected:
    ✅ All transitions smooth
    ✅ No crashes
    ✅ No duplicate screens di history


════════════════════════════════════════════════════════════════════════════════
UNIT 8 - LOADING STATES TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 8.1 - Loading overlay di save operation
  Steps:
    1. Create/edit note
    2. Tap save button
    3. Observe overlay muncul
  Expected:
    ✅ Overlay with spinner muncul
    ✅ Message: "Menyimpan catatan..."
    ✅ UI disabled (can't interact)

TEST 8.2 - Loading overlay disappear after success
  Steps:
    1. Save note
    2. Wait for completion
  Expected:
    ✅ Overlay auto-dismiss
    ✅ Success dialog appear
    ✅ UI re-enabled

TEST 8.3 - Loading overlay disappear after error
  Steps:
    1. Save note while offline
  Expected:
    ✅ Overlay disappear
    ✅ Error dialog appear
    ✅ Can retry

TEST 8.4 - Skeleton loading di notes list
  Steps:
    1. Open HomeScreen
    2. Notes loading
  Expected:
    ✅ Skeleton items appear
    ✅ Skeleton count = itemCount
    ✅ Skeleton replaced with real data


════════════════════════════════════════════════════════════════════════════════
UNIT 9 - DIALOG TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 9.1 - Error dialog display
  Steps:
    1. Try login dengan wrong password
  Expected:
    ✅ Dialog appear with error icon
    ✅ Error message displayed
    ✅ OK button visible
    ✅ Dialog dismissable

TEST 9.2 - Success dialog display
  Steps:
    1. Create note successfully
  Expected:
    ✅ Dialog appear with success icon
    ✅ Message: "Berhasil"
    ✅ OK button functional

TEST 9.3 - Confirmation dialog display
  Steps:
    1. Try delete note
  Expected:
    ✅ Dialog appear with message
    ✅ 2 buttons: Yes & No
    ✅ Both buttons functional

TEST 9.4 - Dialog dismiss on back
  Steps:
    1. Tap back button saat dialog open
  Expected:
    ✅ Dialog dismiss
    ✅ OK (tidak execute action)


════════════════════════════════════════════════════════════════════════════════
UNIT 10 - EDGE CASES & ERROR HANDLING
════════════════════════════════════════════════════════════════════════════════

TEST 10.1 - App minimize saat loading
  Steps:
    1. Save note
    2. Loading overlay muncul
    3. Minimize app (home button)
    4. Resume app
  Expected:
    ✅ No crash
    ✅ Loading state preserved atau reset gracefully
    ✅ Can retry operation

TEST 10.2 - Network change during operation
  Steps:
    1. Start save operation
    2. Turn off WiFi saat in progress
  Expected:
    ✅ Eventually error detected
    ✅ Error dialog muncul
    ✅ Can retry when online

TEST 10.3 - Rapid button clicks
  Steps:
    1. Click save button multiple times rapidly
  Expected:
    ✅ Only one request sent
    ✅ Button disabled saat loading
    ✅ No duplicate saves

TEST 10.4 - Very long text input
  Steps:
    1. Create note dengan 10000+ character content
    2. Save
  Expected:
    ✅ Save successfully
    ✅ Loaded correctly
    ✅ Display correctly (scroll if needed)

TEST 10.5 - Special characters in text
  Steps:
    1. Note dengan emoji, special chars: "Test 🎉 @#$%^&*()"
    2. Save & load
  Expected:
    ✅ Characters preserved correctly
    ✅ Display correctly


════════════════════════════════════════════════════════════════════════════════
UNIT 11 - PERFORMANCE TESTING
════════════════════════════════════════════════════════════════════════════════

TEST 11.1 - App startup time
  Steps:
    1. Close app completely
    2. Start app
    3. Measure time until main screen visible
  Expected:
    ✅ < 3 seconds

TEST 11.2 - Notes list load time
  Steps:
    1. Login
    2. Measure time until notes visible
  Expected:
    ✅ < 2 seconds (dengan 100+ notes)

TEST 11.3 - Navigation smoothness
  Steps:
    1. Navigate between screens
    2. Check FPS (with Performance overlay)
  Expected:
    ✅ 60 FPS maintained
    ✅ No jank atau drops

TEST 11.4 - Memory usage
  Steps:
    1. Open DevTools
    2. Check memory tab
    3. Navigate & go back multiple times
  Expected:
    ✅ Memory increase minimal
    ✅ Memory decrease when dispose
    ✅ No memory leak


════════════════════════════════════════════════════════════════════════════════
TESTING COMMANDS & TOOLS
════════════════════════════════════════════════════════════════════════════════

Run app:
  flutter run

Run dengan profile (check performance):
  flutter run --profile

Open DevTools:
  flutter pub global activate devtools
  flutter pub global run devtools

Check analyze:
  flutter analyze

Run tests (jika ada):
  flutter test

Build APK:
  flutter build apk --release

View logs:
  flutter logs


════════════════════════════════════════════════════════════════════════════════
TEST RESULT REPORTING FORMAT
════════════════════════════════════════════════════════════════════════════════

Test Case: [TEST NUMBER - TEST NAME]
Platform: [Android/iOS]
Device: [Device name & OS version]

Steps Executed:
1. ...
2. ...

Expected Result:
✅ ...
✅ ...

Actual Result:
✅ ...
✅ ...

Status: [PASS/FAIL]

Notes: [Any observations]


════════════════════════════════════════════════════════════════════════════════
AUTOMATION TEST EXAMPLE
════════════════════════════════════════════════════════════════════════════════

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app1/main.dart';

void main() {
  group('Authentication Tests', () {
    testWidgets('User can login with correct credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Enter email
      await tester.enterText(find.byType(TextField).first, 'test@gmail.com');
      
      // Enter password
      await tester.enterText(find.byType(TextField).at(1), 'Password123');
      
      // Tap login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verify success
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

*/
