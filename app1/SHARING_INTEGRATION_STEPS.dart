/// Quick Integration Guide - Adding Share Button to Existing Screens
///
/// Langkah-langkah untuk mengintegrasikan sharing ke notes display dan edit screen

// ============ STEP 1: Update NotesDisplayScreen ============
/*
Add these imports at the top:
- import '../screens/share_note_dialog.dart';

Update _NoteCard widget:

class _NoteCard extends StatefulWidget {
  final NoteModel note;
  final NotesStreamService notesService;

  const _NoteCard({required this.note, required this.notesService});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

In _NoteCardState, update the action buttons row:

Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    // SHARE BUTTON (NEW)
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
    
    // EDIT BUTTON (existing)
    IconButton(
      icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple),
      onPressed: _showEditDialog,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    
    // DELETE BUTTON (existing)
    IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: _showDeleteConfirmation,
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
  ],
)
*/

// ============ STEP 2: Update EditNoteScreen ============
/*
Add this import at the top:
- import '../screens/share_note_dialog.dart';

In the AppBar, add actions:

AppBar(
  title: const Text('Edit Catatan'),
  backgroundColor: Colors.deepPurple,
  actions: [
    // SHARE ACTION (NEW)
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

// ============ STEP 3: Create Users Collection Setup ============
/*
In AuthService atau main.dart, add function:

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _createUserProfile(User user) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'id': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}

Call this di AuthService after login:

Future<bool> login(String email, String password) async {
  try {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Create/update user profile
    if (credential.user != null) {
      await _createUserProfile(credential.user!);
    }
    
    return true;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}
*/

// ============ STEP 4: Firestore Security Rules ============
/*
Update security rules di Firebase Console:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Existing rules untuk notes
    match /notes/{userId}/userNotes/{noteId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    // NEW: Sharing rules
    match /note_shares/{shareId} {
      allow read: if request.auth.uid == resource.data.sharedBy 
                  || request.auth.uid == resource.data.sharedWith;
      allow create: if request.auth.uid == request.resource.data.sharedBy;
      allow update: if request.auth.uid == resource.data.sharedBy;
      allow delete: if request.auth.uid == resource.data.sharedBy;
    }
    
    // NEW: Users collection
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
*/

// ============ STEP 5: File Structure ============
/*
After adding sharing, project structure:

lib/
├── services/
│   ├── auth_service.dart                          (UPDATE: add createUserProfile)
│   ├── firestore_notes_service.dart               (NO CHANGE)
│   ├── notes_stream_service.dart                  (NO CHANGE)
│   ├── note_sharing_service.dart                  (NEW)
│   ├── local_storage_service.dart                 (NO CHANGE)
│   └── ...
├── screens/
│   ├── create_note_screen.dart                    (NO CHANGE)
│   ├── edit_note_screen.dart                      (UPDATE: Add share button)
│   ├── notes_display_screen.dart                  (UPDATE: Add share button)
│   ├── share_note_dialog.dart                     (NEW)
│   └── ...
└── models/
    └── note_model.dart                            (NO CHANGE)
*/

// ============ STEP 6: Complete Code Example ============
/*
// notes_display_screen.dart - Updated _NoteCard

import 'share_note_dialog.dart';

class _NoteCardState extends State<_NoteCard> {
  bool _isDeleting = false;
  final _firestoreService = FirestoreNotesService();
  final _authService = AuthService();

  Future<void> _showEditDialog() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: widget.note),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => ShareNoteDialog(
        noteId: widget.note.id,
        noteTitle: widget.note.title,
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Hapus Catatan?'),
          content: const Text('Catatan yang dihapus tidak dapat dipulihkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isDeleting ? null : _deleteNote,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: _isDeleting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote() async {
    setState(() => _isDeleting = true);

    try {
      bool localSuccess = await widget.notesService.deleteNote(widget.note.id);
      bool firestoreSuccess = 
          await _firestoreService.deleteNoteInFirestore(widget.note.id);

      if (localSuccess && firestoreSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil dihapus'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (localSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan dihapus (offline)'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SHARE BUTTON (NEW)
                    IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.blue,
                      ),
                      onPressed: _showShareDialog,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    // EDIT BUTTON
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
                    // DELETE BUTTON
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: _showDeleteConfirmation,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content Preview
            Text(
              widget.note.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Footer: Category and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.note.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.note.category!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Text(
                  '${widget.note.createdAt.day}/${widget.note.createdAt.month}/${widget.note.createdAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============ STEP 7: Testing Checklist ============
/*
☐ NoteSharingService created
☐ ShareNoteDialog created
☐ Share button added to NotesDisplayScreen
☐ Share button added to EditNoteScreen
☐ users collection security rules added
☐ note_shares collection security rules added
☐ Create user profile di first login
☐ Can share note dengan valid email
☐ Can see list of shared users
☐ Can change permission (view → edit)
☐ Can revoke sharing
☐ Shared note appears untuk recipient user
☐ Recipients dapat view shared notes
☐ Edit permission works correctly
☐ Can't edit note jika permission is 'view'
☐ Error handling works
☐ UI looks simple dan student-like
*/

// ============ NEXT STEPS ============
/*
Setelah sharing selesai:

Option 1: Display shared notes dalam main notes list
- Gabungkan notes milik user sendiri + shared notes
- Add indicator yang menunjukkan note adalah shared

Option 2: Separate "Shared with Me" tab
- Tab baru di notes screen
- Show only shared notes
- Filter by permission level

Option 3: Notifications
- Notify user saat note di-share
- Show in notification panel
- Quick access ke shared note

Option 4: Collaboration features
- Real-time collaborative editing
- Comments on shared notes
- Activity history
*/
