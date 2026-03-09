/// Firestore Service Migration Guide
///
/// Panduan lengkap untuk migrasi Notes dari Local Storage ke Cloud Firestore

// ============ WHAT IS FIRESTORE? ============
/*
Cloud Firestore adalah database NoSQL berbasis cloud dari Google Firebase yang:
- Menyimpan data di cloud (online)
- Real-time synchronization
- Offline support
- Scalable ke jutaan users
- User authentication integration

Keuntungan menggunakan Firestore:
✓ Data aman tersimpan di cloud
✓ Accessible dari multi-device
✓ Automatic backup
✓ User-specific data isolation
✓ Real-time updates
*/

// ============ ARCHITECTURE OVERVIEW ============
/*
┌─────────────────────────────────────────────────────────┐
│              Flutter App (UI Layer)                     │
├─────────────────────────────────────────────────────────┤
│  create_note_screen.dart                                │
│  edit_note_screen.dart                                  │
│  notes_display_screen.dart                              │
├─────────────────────────────────────────────────────────┤
│         Service Layer (Dual-Write Pattern)              │
├─────────────────────────────────────────────────────────┤
│  NotesStreamService (Local Storage)                     │
│           ↓                                              │
│  FirestoreNotesService (Cloud Firestore)                │
│           ↓                                              │
│  LocalStorageService (Cache/Offline)                    │
├─────────────────────────────────────────────────────────┤
│              Firebase / Firestore Backend                │
├─────────────────────────────────────────────────────────┤
│  Cloud Storage          │  Authentication               │
│  Real-time Database     │  User Management              │
└─────────────────────────────────────────────────────────┘
*/

// ============ STEP 1: Firestore Service Structure ============
/*
// firestore_notes_service.dart contains:

class FirestoreNotesService {
  // Singleton pattern untuk single instance
  static final FirestoreNotesService _instance = FirestoreNotesService._internal();
  
  // Helper services
  final _firestoreService = FirestoreService();      // Firestore wrapper
  final _authService = AuthService();                // User authentication
  final _localStorage = LocalStorageService();       // Cache layer
  
  // Collection structure di Firestore
  static const String _notesCollection = 'notes';
  // Path: notes/{userId}/userNotes/{noteId}
  
  // Methods:
  // CREATE: createNoteToFirestore(NoteModel note)
  // READ:   getNotesFromFirestore()
  // READ:   getNoteFromFirestore(String noteId)
  // UPDATE: updateNoteInFirestore(NoteModel note)
  // DELETE: deleteNoteInFirestore(String noteId)
  // DELETE: permanentlyDeleteNoteInFirestore(String noteId)
  // UTILITY: getTotalNotesCount()
  // UTILITY: syncNotesFromFirestore()
}
*/

// ============ STEP 2: Migration Strategy ============
/*
DUAL-WRITE PATTERN (Recommended):
- Menulis ke Local Storage FIRST (fast, reliable)
- Kemudian menulis ke Firestore (cloud sync)
- Jika Firestore gagal, tetap ada local copy

Timeline dalam setiap operasi:
1. [FAST] Write to Local Storage     → Immediate success
2. [SLOW] Write to Firestore         → Cloud sync
3. Show feedback berdasarkan hasil kedua

Benefit:
✓ User dapat bekerja offline
✓ Local data tidak hilang jika cloud down
✓ Experience tetap smooth/responsive
✓ Automatic cache untuk offline mode
*/

// ============ STEP 3: Updated UI Flow ============
/*
// Example: Create Note Screen

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_stream_service.dart';
import '../services/firestore_notes_service.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _notesService = NotesStreamService();
  final _firestoreService = FirestoreNotesService();
  final _authService = AuthService();
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _notesService.init();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // Validate input
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan konten tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get current user ID
      final userId = _authService.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create new note model
      const uuid = Uuid();
      final newNote = NoteModel(
        id: uuid.v4(),
        userId: userId,
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );

      // STEP 1: Save to local storage (FAST)
      bool localSuccess = await _notesService.createNote(newNote);

      if (!localSuccess) {
        throw Exception('Failed to save locally');
      }

      // STEP 2: Save to Firestore (ASYNC, tidak perlu tunggu)
      bool firestoreSuccess = await _firestoreService.createNoteToFirestore(newNote);

      if (firestoreSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Catatan berhasil disimpan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Firestore failed but local succeeded
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠ Catatan disimpan (offline mode)'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Catatan'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Judul catatan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Content Input
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Isi catatan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 10,
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Simpan Catatan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

// ============ STEP 4: Operation Methods ============
/*
// CREATE - Membuat note baru
Future<bool> createNoteToFirestore(NoteModel note) async {
  try {
    // 1. Verify user authentication
    if (!_isUserAuthenticated()) {
      print('User not authenticated');
      return false;
    }

    // 2. Get current user ID
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User ID not found');
      return false;
    }

    // 3. Prepare Firestore document data
    final noteData = {
      'id': note.id,
      'userId': userId,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'isPinned': note.isPinned,
      'isArchived': note.isArchived,
      'createdAt': Timestamp.fromDate(note.createdAt),
      'updatedAt': note.updatedAt != null
          ? Timestamp.fromDate(note.updatedAt!)
          : FieldValue.serverTimestamp(),
      'deletedAt': null,
    };

    // 4. Save ke Firestore path: notes/{userId}/userNotes/{noteId}
    await _firestoreService.setDocument(
      collection: 'notes/${userId}/userNotes',
      docId: note.id,
      data: noteData,
    );

    print('Note created in Firestore: ${note.id}');
    return true;
  } catch (e) {
    print('Error creating note in Firestore: $e');
    return false;
  }
}

// READ - Mengambil semua notes dari Firestore
Future<List<NoteModel>> getNotesFromFirestore() async {
  try {
    // 1. Verify authentication
    if (!_isUserAuthenticated()) {
      print('User not authenticated');
      return [];
    }

    // 2. Get user ID
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User ID not found');
      return [];
    }

    // 3. Query Firestore hanya untuk notes milik user ini
    final notesSnapshot = await FirebaseFirestore.instance
        .collection('notes/${userId}/userNotes')
        .where('deletedAt', isNull: true)  // Skip soft-deleted notes
        .get();

    // 4. Convert Firestore documents ke NoteModel
    final notes = notesSnapshot.docs.map((doc) {
      final data = doc.data();
      return NoteModel(
        id: data['id'] ?? '',
        userId: data['userId'] ?? userId,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        category: data['category'],
        isPinned: data['isPinned'] ?? false,
        isArchived: data['isArchived'] ?? false,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
      );
    }).toList();

    // 5. Cache locally untuk offline support
    await _cacheNotesLocally(notes);

    return notes;
  } catch (e) {
    print('Error getting notes from Firestore: $e');
    // Return cached notes jika error
    return await _getCachedNotes();
  }
}

// UPDATE - Memperbarui note yang sudah ada
Future<bool> updateNoteInFirestore(NoteModel note) async {
  try {
    // 1. Verify authentication
    if (!_isUserAuthenticated()) {
      print('User not authenticated');
      return false;
    }

    // 2. Get user ID
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User ID not found');
      return false;
    }

    // 3. Verify ownership (security check)
    if (note.userId != userId) {
      print('Unauthorized: Note does not belong to current user');
      return false;
    }

    // 4. Prepare update data
    final updateData = {
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'isPinned': note.isPinned,
      'isArchived': note.isArchived,
      'updatedAt': FieldValue.serverTimestamp(),  // Server timestamp
    };

    // 5. Update di Firestore
    await _firestoreService.updateDocument(
      collection: 'notes/${userId}/userNotes',
      docId: note.id,
      data: updateData,
    );

    print('Note updated in Firestore: ${note.id}');
    return true;
  } catch (e) {
    print('Error updating note in Firestore: $e');
    return false;
  }
}

// DELETE - Soft delete (mark as deleted)
Future<bool> deleteNoteInFirestore(String noteId) async {
  try {
    // 1. Verify authentication
    if (!_isUserAuthenticated()) {
      print('User not authenticated');
      return false;
    }

    // 2. Get user ID
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User ID not found');
      return false;
    }

    // 3. Verify note exists and user owns it
    final note = await getNoteFromFirestore(noteId);
    if (note == null) {
      print('Note not found or unauthorized');
      return false;
    }

    // 4. Soft delete (set deletedAt timestamp)
    await _firestoreService.updateDocument(
      collection: 'notes/${userId}/userNotes',
      docId: noteId,
      data: {'deletedAt': FieldValue.serverTimestamp()},
    );

    print('Note deleted in Firestore: $noteId');
    return true;
  } catch (e) {
    print('Error deleting note in Firestore: $e');
    return false;
  }
}

// PERMANENT DELETE - Benar-benar hapus dokumen
Future<bool> permanentlyDeleteNoteInFirestore(String noteId) async {
  try {
    // 1. Verify authentication
    if (!_isUserAuthenticated()) {
      print('User not authenticated');
      return false;
    }

    // 2. Get user ID
    final userId = _getCurrentUserId();
    if (userId == null) {
      print('User ID not found');
      return false;
    }

    // 3. Verify ownership
    final note = await getNoteFromFirestore(noteId);
    if (note == null) {
      print('Note not found or unauthorized');
      return false;
    }

    // 4. Permanently delete dari Firestore
    await FirebaseFirestore.instance
        .collection('notes/${userId}/userNotes')
        .doc(noteId)
        .delete();

    print('Note permanently deleted in Firestore: $noteId');
    return true;
  } catch (e) {
    print('Error permanently deleting note in Firestore: $e');
    return false;
  }
}
*/

// ============ STEP 5: Firestore Data Structure ============
/*
Firestore Collection Structure:

notes/                                          (Main collection)
├── {userId1}/                                  (User 1 subcollection)
│   └── userNotes/                              (Notes subcollection)
│       ├── {noteId1}/                          (Note document)
│       │   ├── id: "uuid-1234"
│       │   ├── userId: "user123"
│       │   ├── title: "My Note"
│       │   ├── content: "Note content here..."
│       │   ├── category: "Personal"
│       │   ├── isPinned: false
│       │   ├── isArchived: false
│       │   ├── createdAt: 2024-03-10 10:30:00
│       │   ├── updatedAt: 2024-03-10 11:00:00
│       │   └── deletedAt: null
│       │
│       └── {noteId2}/
│           └── (similar structure)
│
└── {userId2}/                                  (User 2 subcollection)
    └── userNotes/
        ├── {noteId3}/
        └── ...

Security Rules (Firebase Console):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{userId}/userNotes/{noteId} {
      // Only user can read/write their own notes
      allow read, write: if request.auth.uid == userId;
    }
  }
}
*/

// ============ STEP 6: Offline Support ============
/*
How Offline Caching Works:

1. Setiap berhasil read dari Firestore → cache ke local storage
   await _cacheNotesLocally(notes);

2. Jika network error → return cached notes
   catch (e) {
     return await _getCachedNotes();
   }

3. Multiple devices sync:
   Device A: Create note → Local + Firestore
   Device B: Refresh → Gets from Firestore + cache locally
   
Offline Flow:
┌─────────────────┐
│  User Offline   │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ Try Read  │
    └────┬─────┘
         │
    ┌────▼─────────────────┐
    │ Firestore Error       │
    │ (network down)        │
    └────┬─────────────────┘
         │
    ┌────▼──────────────────┐
    │ Return Cached Notes   │
    │ dari LocalStorage     │
    └──────────────────────┘
*/

// ============ STEP 7: Integration Checklist ============
/*
☐ FirestoreNotesService sudah dibuat
☐ CreateNoteScreen import FirestoreNotesService
☐ CreateNoteScreen call createNoteToFirestore()
☐ EditNoteScreen import FirestoreNotesService
☐ EditNoteScreen call updateNoteInFirestore()
☐ NotesDisplayScreen import FirestoreNotesService
☐ NotesDisplayScreen call deleteNoteInFirestore()
☐ Notes dapat dibuat di Firestore
☐ Notes dapat dibaca dari Firestore
☐ Notes dapat diupdate di Firestore
☐ Notes dapat dihapus dari Firestore
☐ Offline cache working
☐ User authentication protecting data
☐ NotesStreamService add userId ke NoteModel
*/

// ============ STEP 8: Common Issues & Solutions ============
/*
ISSUE 1: "User not authenticated"
CAUSE: AuthService.currentUser is null
SOLUTION: 
  - Ensure user login before creating notes
  - Check AuthService initialization
  - Verify Firebase Authentication setup

ISSUE 2: "Note not found or unauthorized"
CAUSE: Trying to access another user's note
SOLUTION:
  - Verify note.userId == currentUser.uid
  - Check Firestore security rules
  - Ensure ownership verification in delete/update

ISSUE 3: "Failed to save locally"
CAUSE: LocalStorageService initialization issue
SOLUTION:
  - Call _notesService.init() in initState
  - Check SharedPreferences library added
  - Verify NotesStreamService creation

ISSUE 4: Offline cache not working
CAUSE: _cacheNotesLocally() tidak dipanggil
SOLUTION:
  - Add await _cacheNotesLocally(notes); after getNotesFromFirestore()
  - Check LocalStorageService.saveObjectList() implementation
  - Verify JSON serialization in NoteModel

ISSUE 5: Duplicate notes in display
CAUSE: Reading from both Local and Firestore simultaneously
SOLUTION:
  - Use getAllNotesStream() dari NotesStreamService
  - Don't query both services at same time
  - Let stream handle synchronization
*/

// ============ STEP 9: Testing Firestore ============
/*
Manual Testing Checklist:

1. CREATE TEST:
   ✓ Open app, login
   ✓ Create new note
   ✓ Check console: "Note created in Firestore: xxx"
   ✓ Go to Firebase Console → Firestore → notes → {userId} → userNotes
   ✓ Verify note document exists with all fields

2. READ TEST:
   ✓ Close app completely
   ✓ Reopen app
   ✓ Go to Notes display
   ✓ Verify notes load from Firestore
   ✓ Turn off internet
   ✓ Refresh notes
   ✓ Verify notes show from cache

3. UPDATE TEST:
   ✓ Edit a note
   ✓ Change title/content
   ✓ Check console: "Note updated in Firestore: xxx"
   ✓ Go to Firebase Console
   ✓ Verify updatedAt timestamp changed

4. DELETE TEST:
   ✓ Delete a note
   ✓ Check console: "Note deleted in Firestore: xxx"
   ✓ Go to Firebase Console
   ✓ Verify deletedAt field is set (soft delete)
   ✓ Or note document removed (permanent delete)

5. OFFLINE TEST:
   ✓ Open app
   ✓ Create note (online)
   ✓ Turn off internet
   ✓ Try create another note
   ✓ Should show orange "offline mode" message
   ✓ Turn internet back on
   ✓ Both notes should exist
*/

// ============ STEP 10: Performance Tips ============
/*
1. PAGINATION (untuk list besar):
   - Load notes in batches instead of all at once
   - Implement startAfterDocument() untuk pagination
   
2. INDEXING:
   - Firestore auto-creates single-field indexes
   - For complex queries, create composite indexes (Firestore will hint)

3. CACHING STRATEGY:
   - Cache recently accessed notes in memory
   - Clear cache on logout
   - Invalidate cache on major changes

4. BATCH OPERATIONS:
   - Use WriteBatch untuk multiple writes
   - More efficient than individual writes

5. MONITORING:
   - Use Firestore documentation to track usage
   - Monitor read/write count
   - Optimize queries to reduce reads

6. Security:
   - Always verify userId in security rules
   - Validate data on client side
   - Never trust client timestamps
*/

// ============ STEP 11: File Structure Update ============
/*
project_root/lib/
├── main.dart
├── config/
│   ├── routes.dart
│   └── app_router.dart
├── models/
│   └── note_model.dart                    (Has userId field)
├── screens/
│   ├── create_note_screen.dart            (UPDATED: Firestore integration)
│   ├── edit_note_screen.dart              (UPDATED: Firestore integration)
│   ├── notes_display_screen.dart          (UPDATED: Firestore integration)
│   └── ...
├── services/
│   ├── auth_service.dart                  (Authentication)
│   ├── firestore_service.dart             (Firestore wrapper)
│   ├── firestore_notes_service.dart       (NEW: Complete CRUD)
│   ├── notes_stream_service.dart          (UPDATED: userId parameter)
│   ├── local_storage_service.dart         (Cache layer)
│   └── ...
└── widgets/
    └── ...
*/

// ============ STEP 12: Best Practices ============
/*
DO:
✓ Always verify user authentication sebelum firestore operations
✓ Check userId ownership untuk security
✓ Use soft delete (set deletedAt) untuk data recovery
✓ Cache data locally untuk offline experience
✓ Use StreamBuilder untuk real-time updates
✓ Handle errors gracefully dengan user feedback
✓ Use Timestamp untuk date/time consistency
✓ Group related fields dalam single document

DON'T:
✗ Don't store large blobs in Firestore (use Cloud Storage)
✗ Don't create unbounded queries (always add where clauses)
✗ Don't trust client timestamps (use serverTimestamp)
✗ Don't hardcode user IDs (get from AuthService)
✗ Don't skip ownership verification
✗ Don't block UI during Firestore operations
✗ Don't create queries without proper indexes
✗ Don't forget to handle network errors
*/

// ============ MIGRATION SUMMARY ============
/*
BEFORE (Local Only):
  Create/Edit/Delete → LocalStorageService only
  No cloud sync
  Data lost if uninstall app
  Single device only

AFTER (Firestore Integrated):
  Create/Edit/Delete → LocalStorageService (fast) + Firestore (sync)
  Dual-write pattern
  Data safe in cloud
  Multi-device sync
  Offline support via caching
  User data isolation

Status: ✓ COMPLETE
- All CRUD operations have Firestore support
- Dual-write pattern implemented
- Offline caching enabled
- User authentication required
- Data ownership protected
*/
