/// Sharing Notes Feature Guide
///
/// Panduan lengkap untuk implementasi sharing notes dengan user lain

// ============ WHAT IS NOTE SHARING? ============
/*
Fitur sharing memungkinkan user untuk:
- Share catatan dengan user lain
- Mengatur permission (view only atau edit)
- Melihat siapa saja yang punya akses ke catatan
- Revoke sharing kapan saja
- Mengubah permission sharing

Manfaat:
✓ Kolaborasi antar user
✓ Share informasi penting
✓ Control penuh terhadap akses
✓ User tracking (siapa share dengan siapa)
*/

// ============ ARCHITECTURE ============
/*
┌───────────────────────────────────────────┐
│        Share Note Dialog (UI)              │
│  - Share form input                        │
│  - Permission selector                     │
│  - List of shared users                    │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│    NoteSharingService (Business Logic)      │
│  - shareNoteWithUser()                      │
│  - unshareNoteWithUser()                    │
│  - getSharedWithUsers()                     │
│  - getSharedNotesForMe()                    │
│  - updateSharePermission()                  │
│  - checkNotePermission()                    │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│     Firestore Database                      │
│  - note_shares collection                   │
│  - users collection                         │
└───────────────────────────────────────────┘
*/

// ============ FIRESTORE DATA STRUCTURE ============
/*
Collections:

1. note_shares collection:
   {
     noteId_userId: {
       "noteId": "note123",
       "sharedBy": "user1_id",
       "sharedWith": "user2_id",
       "permission": "view" | "edit",
       "sharedAt": Timestamp,
       "updatedAt": Timestamp,
       "status": "active" | "revoked"
     }
   }

2. users collection:
   {
     user_id: {
       "id": "user_id",
       "email": "user@example.com",
       "name": "User Name",
       "createdAt": Timestamp
     }
   }

Example:
notes/
├── note_shares/
│   ├── note123_user2
│   │   ├── noteId: "note123"
│   │   ├── sharedBy: "user1"
│   │   ├── sharedWith: "user2"
│   │   ├── permission: "view"
│   │   └── sharedAt: 2024-03-10 10:30:00
│   │
│   └── note456_user3
│       ├── noteId: "note456"
│       ├── sharedBy: "user1"
│       ├── sharedWith: "user3"
│       ├── permission: "edit"
│       └── sharedAt: 2024-03-10 11:00:00
│
└── users/
    ├── user1
    │   ├── id: "user1"
    │   ├── email: "user1@example.com"
    │   ├── name: "User One"
    │   └── createdAt: 2024-01-01
    │
    └── user2
        ├── id: "user2"
        ├── email: "user2@example.com"
        ├── name: "User Two"
        └── createdAt: 2024-01-05
*/

// ============ STEP 1: NoteSharingService Methods ============
/*
// CREATE - Share catatan dengan user lain
Future<bool> shareNoteWithUser({
  required String noteId,
  required String recipientEmail,
  String permission = 'view',
}) async
- Cari user berdasarkan email
- Buat record sharing di Firestore
- Set permission ('view' atau 'edit')
- Return true jika berhasil

// UNSHARE - Batalkan sharing
Future<bool> unshareNoteWithUser({
  required String noteId,
  required String recipientId,
}) async
- Verify ownership
- Delete share record dari Firestore
- Return true jika berhasil

// READ - Ambil list user yang note di-share
Future<List<Map<String, dynamic>>> getSharedWithUsers(String noteId) async
- Query note_shares collection
- Filter by noteId dan sharedBy
- Get user info dari users collection
- Return list of shared users

// READ - Ambil notes yang di-share ke current user
Future<List<Map<String, dynamic>>> getSharedNotesForMe() async
- Query note_shares collection
- Filter by sharedWith (current user)
- Return list of shared notes

// UPDATE - Ubah permission sharing
Future<bool> updateSharePermission({
  required String noteId,
  required String recipientId,
  required String newPermission,
}) async
- Verify ownership
- Update permission field
- Return true jika berhasil

// CHECK - Verify permission note
Future<String?> checkNotePermission(String noteId) async
- Check jika current user bisa access note
- Return permission level atau null
*/

// ============ STEP 2: ShareNoteDialog UI ============
/*
// Usage di notes_display_screen.dart atau edit_note_screen.dart:

import 'share_note_dialog.dart';

// Buka dialog sharing:
showDialog(
  context: context,
  builder: (context) => ShareNoteDialog(
    noteId: note.id,
    noteTitle: note.title,
  ),
);

// Biasanya di tombol share / menu:
IconButton(
  icon: const Icon(Icons.share_outlined),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => ShareNoteDialog(
        noteId: widget.note.id,
        noteTitle: widget.note.title,
      ),
    );
  },
)

Dialog akan menampilkan:
1. Form input email pengguna yang akan di-share
2. Permission selector (View / Edit)
3. Tombol Share
4. List user yang sudah di-share
5. Option untuk ubah permission
6. Option untuk revoke sharing
*/

// ============ STEP 3: Integration into UI ============
/*
// Example: Add Share Button to NotesDisplayScreen

import 'share_note_dialog.dart';

// Di _NoteCard widget:
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.share_outlined, color: Colors.blue),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ShareNoteDialog(
            noteId: widget.note.id,
            noteTitle: widget.note.title,
          ),
        );
      },
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    IconButton(
      icon: const Icon(
        Icons.edit_outlined,
        color: Colors.deepPurple,
      ),
      onPressed: _showEditDialog,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: _showDeleteConfirmation,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
  ],
)

// Example: Add Share Button to EditNoteScreen

AppBar(
  title: const Text('Edit Catatan'),
  backgroundColor: Colors.deepPurple,
  actions: [
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ShareNoteDialog(
            noteId: widget.note.id,
            noteTitle: widget.note.title,
          ),
        );
      },
    ),
  ],
)
*/

// ============ STEP 4: Permission Types ============
/*
VIEW ONLY:
- User dapat melihat catatan
- User tidak bisa edit catatan
- User tidak bisa delete catatan
- Read-only access

Permission level: 'view'

EDIT:
- User dapat melihat catatan
- User dapat edit catatan
- User dapat delete catatan dari sharenya
- Tidak bisa bagikan ulang

Permission level: 'edit'

NOTE: Only note owner dapat revoke sharing
      Owner adalah yang create note pertama kali
*/

// ============ STEP 5: User Model Update ============
/*
// users collection structure di Firestore:

{
  "id": "firebase_auth_uid",
  "email": "user@example.com",
  "name": "User Full Name",
  "photoUrl": "https://...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}

// Ini perlu di-create saat user pertama kali login
// Bisa di-handle di AuthService atau di main.dart

Future<void> createUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'id': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'Unknown',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}
*/

// ============ STEP 6: Using Shared Notes ============
/*
// Display notes yang di-share ke current user:

Future<void> _loadSharedNotes() async {
  final sharingService = NoteSharingService();
  final sharedData = await sharingService.getSharedNotesForMe();
  
  for (var share in sharedData) {
    final noteId = share['noteId'];
    final permission = share['permission'];
    print('Shared note: $noteId with $permission access');
    
    // Get note details dari FirestoreNotesService
    final note = await _firestoreService.getNoteFromFirestore(noteId);
    // Show in UI
  }
}

// Check permission sebelum allow edit:

Future<bool> canEditNote(String noteId) async {
  final sharingService = NoteSharingService();
  final permission = await sharingService.checkNotePermission(noteId);
  return permission == 'edit';
}

// Use dalam edit screen:
bool canEdit = await canEditNote(noteId);
if (!canEdit) {
  // Show warning atau disable edit
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Anda hanya bisa view catatan ini'),
      backgroundColor: Colors.orange,
    ),
  );
}
*/

// ============ STEP 7: Security Considerations ============
/*
SECURITY RULES (Firestore):

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Note shares - only owner can create/delete/update
    match /note_shares/{shareId} {
      allow read: if request.auth.uid == resource.data.sharedBy 
                  || request.auth.uid == resource.data.sharedWith;
      allow create: if request.auth.uid == request.resource.data.sharedBy;
      allow update: if request.auth.uid == resource.data.sharedBy;
      allow delete: if request.auth.uid == resource.data.sharedBy;
    }
    
    // Users - anyone can read, only self can update
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }
  }
}

DO:
✓ Always verify ownership sebelum revoke
✓ Only owner bisa ubah permission
✓ Check permission sebelum edit
✓ Validate email saat share
✓ Handle case ketika user tidak found

DON'T:
✗ Jangan share tanpa permission check
✗ Jangan allow user edit note milik orang lain tanpa permission
✗ Jangan trust client-side permission check only
✗ Jangan hardcode user IDs
*/

// ============ STEP 8: Common Issues ============
/*
ISSUE 1: "User with email not found"
CAUSE: Email tidak ada di users collection
SOLUTION:
- Ensure user punya profile di users collection
- Create user profile saat first login
- Verify email spelling

ISSUE 2: "Only note owner can revoke sharing"
CAUSE: Non-owner coba revoke sharing
SOLUTION:
- Only show delete button untuk note owner
- Verify ownership di service

ISSUE 3: "Permission access denied"
CAUSE: Firestore security rules reject
SOLUTION:
- Check Firestore security rules
- Verify user authentication
- Ensure user ID match

ISSUE 4: Shared note not appearing
CAUSE: getSharedNotesForMe() tidak return data
SOLUTION:
- Verify note share record created
- Check current user ID
- Verify sharedWith field match
*/

// ============ STEP 9: Testing Sharing ============
/*
Manual Testing:

1. CREATE SHARE:
   ✓ Open app as User A
   ✓ Open a note
   ✓ Tap Share button
   ✓ Input User B's email
   ✓ Set permission to 'view'
   ✓ Tap Share button
   ✓ See confirmation message

2. VERIFY SHARE:
   ✓ Open Firebase Console
   ✓ Go to note_shares collection
   ✓ See share record created
   ✓ Verify sharedBy = User A id
   ✓ Verify sharedWith = User B id
   ✓ Verify permission = 'view'

3. VIEW SHARED NOTE (User B):
   ✓ Logout atau switch account to User B
   ✓ Refresh notes
   ✓ See shared note appear
   ✓ Try to edit (should be disabled)
   ✓ See "View only" indicator

4. UPDATE PERMISSION (User A):
   ✓ Go back to Share dialog
   ✓ Tap "View" badge untuk User B
   ✓ Permission change to 'edit'
   ✓ Verify User B bisa edit sekarang

5. REVOKE SHARE (User A):
   ✓ Tap X button untuk User B
   ✓ See confirmation
   ✓ Go to Firestore Console
   ✓ Verify share record deleted
   ✓ Switch to User B
   ✓ Shared note should disappear
*/

// ============ STEP 10: Future Enhancements ============
/*
Possible improvements:

1. BATCH SHARE:
   - Share satu note ke multiple users sekaligus
   - Import user list dari CSV

2. SHARE NOTIFICATIONS:
   - Notify user saat di-share catatan
   - Push notification untuk new shares

3. ACTIVITY LOG:
   - Track siapa edit apa dan kapan
   - Version history untuk shared notes

4. EXPIRING SHARES:
   - Set expiration date untuk sharing
   - Auto revoke share setelah date

5. SHARE TEMPLATES:
   - Save sharing preference
   - Quick share to frequent contacts

6. SHARE ANALYTICS:
   - See who viewed / edited shared notes
   - Last accessed time
   - Collaboration metrics

7. ADVANCED PERMISSIONS:
   - Comment only (no edit)
   - View history (no current)
   - Custom permissions

8. OFFLINE SHARING:
   - Queue shares ketika offline
   - Sync saat connection restored
*/

// ============ SUMMARY ============
/*
NoteSharingService Features:
✓ Share catatan dengan user lain
✓ Set permission (view / edit)
✓ List user yang sudah di-share
✓ Get shared notes untuk current user
✓ Update permission
✓ Check permission access
✓ Revoke sharing

ShareNoteDialog UI:
✓ Simple share form
✓ Permission selector
✓ List of shared users
✓ Change permission button
✓ Revoke share button
✓ Loading states
✓ Error handling

Integration Points:
✓ NotesDisplayScreen - Add share button
✓ EditNoteScreen - Add share button
✓ Create user profile di first login
✓ Firestore security rules
✓ Permission checks untuk edit operations

Security:
✓ Only owner can revoke/update permission
✓ Only shared user dapat access
✓ Permission verification sebelum edit
✓ Email validation
✓ Ownership checks
*/
