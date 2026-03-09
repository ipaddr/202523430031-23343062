import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'local_storage_service.dart';

/// Service untuk manage Notes di Cloud Firestore
class FirestoreNotesService {
  static final FirestoreNotesService _instance =
      FirestoreNotesService._internal();

  factory FirestoreNotesService() {
    return _instance;
  }

  FirestoreNotesService._internal();

  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _localStorage = LocalStorageService();

  static const String _notesCollection = 'notes';
  static const String _cachedNotesKey = 'firestore_notes_cache';

  /// Get current user ID
  String? _getCurrentUserId() {
    return _authService.uid;
  }

  /// Verify if user is authenticated
  bool _isUserAuthenticated() {
    return _authService.isAuthenticated;
  }

  // ==================== CREATE ====================

  /// Create note di Firestore
  Future<bool> createNoteToFirestore(NoteModel note) async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      // Prepare data untuk Firestore
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

      // Simpan ke Firestore dengan user ID sebagai parent
      await _firestoreService.setDocument(
        collection: '$_notesCollection/${userId}/userNotes',
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

  // ==================== READ ====================

  /// Get semua notes dari Firestore untuk current user
  Future<List<NoteModel>> getNotesFromFirestore() async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return [];
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return [];
      }

      final notesSnapshot = await FirebaseFirestore.instance
          .collection('$_notesCollection/$userId/userNotes')
          .where('deletedAt', isNull: true)
          .get();

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

      // Cache locally
      await _cacheNotesLocally(notes);

      return notes;
    } catch (e) {
      print('Error getting notes from Firestore: $e');
      // Return cached notes if error
      return await _getCachedNotes();
    }
  }

  /// Get note by ID dari Firestore
  Future<NoteModel?> getNoteFromFirestore(String noteId) async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return null;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return null;
      }

      final noteDoc = await FirebaseFirestore.instance
          .collection('$_notesCollection/$userId/userNotes')
          .doc(noteId)
          .get();

      if (!noteDoc.exists) {
        print('Note not found');
        return null;
      }

      final data = noteDoc.data() as Map<String, dynamic>;

      // Verify ownership
      if (data['userId'] != userId) {
        print('Unauthorized: Note does not belong to current user');
        return null;
      }

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
    } catch (e) {
      print('Error getting note from Firestore: $e');
      return null;
    }
  }

  // ==================== UPDATE ====================

  /// Update note di Firestore
  Future<bool> updateNoteInFirestore(NoteModel note) async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      // Verify ownership
      if (note.userId != userId) {
        print('Unauthorized: Note does not belong to current user');
        return false;
      }

      final updateData = {
        'title': note.title,
        'content': note.content,
        'category': note.category,
        'isPinned': note.isPinned,
        'isArchived': note.isArchived,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.updateDocument(
        collection: '$_notesCollection/$userId/userNotes',
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

  // ==================== DELETE ====================

  /// Soft delete note (mark as deleted)
  Future<bool> deleteNoteInFirestore(String noteId) async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      // Verify note exists and belongs to user
      final note = await getNoteFromFirestore(noteId);
      if (note == null) {
        print('Note not found or unauthorized');
        return false;
      }

      // Soft delete
      await _firestoreService.updateDocument(
        collection: '$_notesCollection/$userId/userNotes',
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

  /// Permanently delete note
  Future<bool> permanentlyDeleteNoteInFirestore(String noteId) async {
    try {
      // Verify user authentication
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      // Verify note exists and belongs to user
      final note = await getNoteFromFirestore(noteId);
      if (note == null) {
        print('Note not found or unauthorized');
        return false;
      }

      // Permanently delete
      await FirebaseFirestore.instance
          .collection('$_notesCollection/$userId/userNotes')
          .doc(noteId)
          .delete();

      print('Note permanently deleted in Firestore: $noteId');
      return true;
    } catch (e) {
      print('Error permanently deleting note in Firestore: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Cache notes locally for offline support
  Future<void> _cacheNotesLocally(List<NoteModel> notes) async {
    try {
      await _localStorage.init();
      final jsonList = notes.map((note) => note.toJson()).toList();
      await _localStorage.saveObjectList(_cachedNotesKey, jsonList);
    } catch (e) {
      print('Error caching notes locally: $e');
    }
  }

  /// Get cached notes dari local storage
  Future<List<NoteModel>> _getCachedNotes() async {
    try {
      await _localStorage.init();
      final jsonList = _localStorage.getObjectList(_cachedNotesKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting cached notes: $e');
      return [];
    }
  }

  /// Get total notes count di Firestore
  Future<int> getTotalNotesCount() async {
    try {
      if (!_isUserAuthenticated()) {
        return 0;
      }

      final userId = _getCurrentUserId();
      if (userId == null) return 0;

      final snapshot = await FirebaseFirestore.instance
          .collection('$_notesCollection/$userId/userNotes')
          .where('deletedAt', isNull: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting notes count: $e');
      return 0;
    }
  }

  /// Sync notes: Get from Firestore and cache locally
  Future<void> syncNotesFromFirestore() async {
    try {
      print('Syncing notes from Firestore...');
      await getNotesFromFirestore();
      print('Notes synced successfully');
    } catch (e) {
      print('Error syncing notes: $e');
    }
  }
}
