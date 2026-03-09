import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import 'local_storage_service.dart';
import 'auth_service.dart';

/// Service untuk manage Notes dengan Streams
class NotesStreamService {
  static final NotesStreamService _instance = NotesStreamService._internal();

  final LocalStorageService _storage = LocalStorageService();
  final AuthService _authService = AuthService();
  static const String _notesKey = 'notes';
  static const String _categoriesKey = 'note_categories';

  // Stream controllers untuk real-time updates
  late StreamController<List<NoteModel>> _allNotesController;
  late StreamController<List<NoteModel>> _pinnedNotesController;
  late StreamController<List<NoteModel>> _archivedNotesController;
  late StreamController<List<NoteCategoryModel>> _categoriesController;
  late StreamController<NoteModel> _singleNoteController;

  factory NotesStreamService() {
    return _instance;
  }

  NotesStreamService._internal();

  /// Initialize service dan streams
  Future<void> init() async {
    await _storage.init();
    _initializeControllers();
    _loadInitialData();
  }

  /// Initialize semua stream controllers
  void _initializeControllers() {
    _allNotesController = StreamController<List<NoteModel>>.broadcast();
    _pinnedNotesController = StreamController<List<NoteModel>>.broadcast();
    _archivedNotesController = StreamController<List<NoteModel>>.broadcast();
    _categoriesController =
        StreamController<List<NoteCategoryModel>>.broadcast();
    _singleNoteController = StreamController<NoteModel>.broadcast();
  }

  /// Load initial data ke streams
  Future<void> _loadInitialData() async {
    try {
      final notes = await _getAllUserNotesFromStorage();
      _allNotesController.add(notes);
      _updatePinnedStream();
      _updateArchivedStream();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  /// Get current user ID
  String? _getCurrentUserId() {
    return _authService.uid;
  }

  /// Verify if user is authenticated
  bool _isUserAuthenticated() {
    return _authService.isAuthenticated;
  }

  /// Get semua notes stream
  Stream<List<NoteModel>> getAllNotesStream() {
    return _allNotesController.stream;
  }

  /// Get pinned notes stream
  Stream<List<NoteModel>> getPinnedNotesStream() {
    return _pinnedNotesController.stream;
  }

  /// Get archived notes stream
  Stream<List<NoteModel>> getArchivedNotesStream() {
    return _archivedNotesController.stream;
  }

  /// Get categories stream
  Stream<List<NoteCategoryModel>> getCategoriesStream() {
    return _categoriesController.stream;
  }

  /// Get single note stream by ID
  Stream<NoteModel?> getSingleNoteStream(String noteId) async* {
    // Initial emit
    final note = await getNoteById(noteId);
    if (note != null) {
      yield note;
    }

    // Listen to all notes changes
    await for (final notes in getAllNotesStream()) {
      final updatedNote = notes.firstWhere(
        (n) => n.id == noteId,
        orElse: () => NoteModel(
          id: noteId,
          title: 'Note not found',
          content: '',
          createdAt: DateTime.now(),
        ),
      );
      yield updatedNote;
    }
  }

  /// Filter notes by category stream
  Stream<List<NoteModel>> getNotesByCategoryStream(String category) async* {
    await for (final notes in getAllNotesStream()) {
      yield notes.where((note) => note.category == category).toList();
    }
  }

  /// Search notes stream
  Stream<List<NoteModel>> searchNotesStream(String query) async* {
    await for (final notes in getAllNotesStream()) {
      if (query.isEmpty) {
        yield notes;
      } else {
        yield notes
            .where(
              (note) =>
                  note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    }
  }

  // ==================== CREATE ====================

  /// Create new note
  Future<bool> createNote(
    String title,
    String content, {
    String? category,
  }) async {
    try {
      // Verify user is authenticated
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      const uuid = Uuid();
      final newNote = NoteModel(
        id: uuid.v4(),
        userId: userId,
        title: title,
        content: content,
        category: category,
        createdAt: DateTime.now(),
      );

      final notes = await _getAllNotesFromStorage();
      notes.add(newNote);

      final success = await _saveNotesToStorage(notes);
      if (success) {
        final userNotes = await _getAllUserNotesFromStorage();
        _allNotesController.add(userNotes);
        _updatePinnedStream();
        _updateArchivedStream();
      }
      return success;
    } catch (e) {
      print('Error creating note: $e');
      return false;
    }
  }

  // ==================== READ ====================

  /// Get note by ID
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User not authenticated');
        return null;
      }

      final notes = await _getAllNotesFromStorage();
      final note = notes.firstWhere(
        (note) => note.id == id,
        orElse: () => NoteModel(
          id: '',
          userId: '',
          title: '',
          content: '',
          createdAt: DateTime.now(),
        ),
      );

      // Verify note belongs to current user
      if (note.userId != userId) {
        print('Unauthorized: Note does not belong to current user');
        return null;
      }

      return note.id.isEmpty ? null : note;
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }

  /// Get all notes (non-stream)
  Future<List<NoteModel>> getAllNotes() async {
    return await _getAllUserNotesFromStorage();
  }

  /// Get pinned notes
  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final notes = await _getAllUserNotesFromStorage();
      return notes.where((note) => note.isPinned && !note.isArchived).toList();
    } catch (e) {
      print('Error getting pinned notes: $e');
      return [];
    }
  }

  /// Get archived notes
  Future<List<NoteModel>> getArchivedNotes() async {
    try {
      final notes = await _getAllUserNotesFromStorage();
      return notes.where((note) => note.isArchived).toList();
    } catch (e) {
      print('Error getting archived notes: $e');
      return [];
    }
  }

  /// Get notes by category
  Future<List<NoteModel>> getNotesByCategory(String category) async {
    try {
      final notes = await _getAllUserNotesFromStorage();
      return notes.where((note) => note.category == category).toList();
    } catch (e) {
      print('Error getting notes by category: $e');
      return [];
    }
  }

  /// Search notes
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final notes = await _getAllUserNotesFromStorage();
      return notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching notes: $e');
      return [];
    }
  }

  // ==================== UPDATE ====================

  /// Update note
  Future<bool> updateNote(NoteModel updatedNote) async {
    try {
      // Verify user is authenticated
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      // Verify note belongs to current user
      if (updatedNote.userId != userId) {
        print('Unauthorized: Note does not belong to current user');
        return false;
      }

      final notes = await _getAllNotesFromStorage();
      int index = notes.indexWhere((note) => note.id == updatedNote.id);

      if (index == -1) {
        print('Note not found');
        return false;
      }

      final noteWithTimestamp = updatedNote.copyWith(updatedAt: DateTime.now());
      notes[index] = noteWithTimestamp;

      final success = await _saveNotesToStorage(notes);
      if (success) {
        final userNotes = await _getAllUserNotesFromStorage();
        _allNotesController.add(userNotes);
        _updatePinnedStream();
        _updateArchivedStream();
      }
      return success;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  /// Update note content
  Future<bool> updateNoteContent(String id, String newContent) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(content: newContent);
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error updating note content: $e');
      return false;
    }
  }

  /// Update note title
  Future<bool> updateNoteTitle(String id, String newTitle) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(title: newTitle);
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error updating note title: $e');
      return false;
    }
  }

  /// Toggle pin status
  Future<bool> togglePinStatus(String id) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(isPinned: !note.isPinned);
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error toggling pin status: $e');
      return false;
    }
  }

  /// Toggle archive status
  Future<bool> toggleArchiveStatus(String id) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(
        isArchived: !note.isArchived,
        isPinned: note.isArchived
            ? note.isPinned
            : false, // unpin when archiving
      );
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error toggling archive status: $e');
      return false;
    }
  }

  /// Update note category
  Future<bool> updateNoteCategory(String id, String? newCategory) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(category: newCategory);
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error updating note category: $e');
      return false;
    }
  }

  // ==================== DELETE ====================

  /// Delete note (soft delete)
  Future<bool> deleteNote(String id) async {
    try {
      final note = await getNoteById(id);
      if (note == null) return false;

      final updatedNote = note.copyWith(deletedAt: DateTime.now());
      return await updateNote(updatedNote);
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  /// Permanently delete note
  Future<bool> permanentlyDeleteNote(String id) async {
    try {
      // Verify user is authenticated
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final notes = await _getAllNotesFromStorage();
      final noteIndex = notes.indexWhere((note) => note.id == id);

      if (noteIndex == -1) {
        print('Note not found');
        return false;
      }

      // Verify note belongs to current user
      if (notes[noteIndex].userId != userId) {
        print('Unauthorized: Note does not belong to current user');
        return false;
      }

      notes.removeAt(noteIndex);

      if (notes.isEmpty) {
        return await _storage.delete(_notesKey);
      }

      final success = await _saveNotesToStorage(notes);
      if (success) {
        final userNotes = await _getAllUserNotesFromStorage();
        _allNotesController.add(userNotes);
        _updatePinnedStream();
        _updateArchivedStream();
      }
      return success;
    } catch (e) {
      print('Error permanently deleting note: $e');
      return false;
    }
  }

  /// Delete multiple notes
  Future<bool> deleteMultipleNotes(List<String> ids) async {
    try {
      // Verify user is authenticated
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final notes = await _getAllNotesFromStorage();
      for (final id in ids) {
        final idx = notes.indexWhere((note) => note.id == id);
        if (idx != -1) {
          // Verify note belongs to current user
          if (notes[idx].userId == userId) {
            notes[idx] = notes[idx].copyWith(deletedAt: DateTime.now());
          }
        }
      }

      final success = await _saveNotesToStorage(notes);
      if (success) {
        final userNotes = await _getAllUserNotesFromStorage();
        _allNotesController.add(userNotes);
        _updatePinnedStream();
        _updateArchivedStream();
      }
      return success;
    } catch (e) {
      print('Error deleting multiple notes: $e');
      return false;
    }
  }

  /// Delete all notes for current user
  Future<bool> deleteAllNotes() async {
    try {
      // Verify user is authenticated
      if (!_isUserAuthenticated()) {
        print('User not authenticated');
        return false;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final notes = await _getAllNotesFromStorage();
      // Only delete notes belonging to current user
      notes.removeWhere((note) => note.userId == userId);

      if (notes.isEmpty) {
        return await _storage.delete(_notesKey);
      }

      return await _saveNotesToStorage(notes);
    } catch (e) {
      print('Error deleting all notes: $e');
      return false;
    }
  }

  // ==================== CATEGORIES ====================

  /// Add category
  Future<bool> addCategory(String name, String color) async {
    try {
      const uuid = Uuid();
      final newCategory = NoteCategoryModel(
        id: uuid.v4(),
        name: name,
        color: color,
      );

      final categories = await _getCategoriesFromStorage();
      categories.add(newCategory);

      final success = await _saveCategoryToStorage(categories);
      if (success) {
        _categoriesController.add(categories);
      }
      return success;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final categories = await _getCategoriesFromStorage();
      categories.removeWhere((cat) => cat.id == categoryId);

      final success = await _saveCategoryToStorage(categories);
      if (success) {
        _categoriesController.add(categories);
      }
      return success;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Get total note count
  Future<int> getTotalNoteCount() async {
    try {
      final notes = await _getAllNotesFromStorage();
      return notes.where((note) => note.deletedAt == null).length;
    } catch (e) {
      print('Error getting total note count: $e');
      return 0;
    }
  }

  /// Export notes as JSON
  Future<List<Map<String, dynamic>>> exportNotes() async {
    try {
      final notes = await _getAllNotesFromStorage();
      return notes.map((note) => note.toJson()).toList();
    } catch (e) {
      print('Error exporting notes: $e');
      return [];
    }
  }

  /// Dispose streams
  void dispose() {
    _allNotesController.close();
    _pinnedNotesController.close();
    _archivedNotesController.close();
    _categoriesController.close();
    _singleNoteController.close();
  }

  // ==================== PRIVATE METHODS ====================

  /// Get all notes from storage
  Future<List<NoteModel>> _getAllNotesFromStorage() async {
    try {
      final jsonList = _storage.getObjectList(_notesKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting notes from storage: $e');
      return [];
    }
  }

  /// Get all notes untuk current user dari storage
  Future<List<NoteModel>> _getAllUserNotesFromStorage() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        return [];
      }

      final allNotes = await _getAllNotesFromStorage();
      return allNotes.where((note) => note.userId == userId).toList();
    } catch (e) {
      print('Error getting user notes from storage: $e');
      return [];
    }
  }

  /// Save notes ke storage
  Future<bool> _saveNotesToStorage(List<NoteModel> notes) async {
    try {
      final jsonList = notes.map((note) => note.toJson()).toList();
      return await _storage.saveObjectList(_notesKey, jsonList);
    } catch (e) {
      print('Error saving notes to storage: $e');
      return false;
    }
  }

  /// Get categories dari storage
  Future<List<NoteCategoryModel>> _getCategoriesFromStorage() async {
    try {
      final jsonList = _storage.getObjectList(_categoriesKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((json) => NoteCategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting categories from storage: $e');
      return [];
    }
  }

  /// Save categories ke storage
  Future<bool> _saveCategoryToStorage(
    List<NoteCategoryModel> categories,
  ) async {
    try {
      final jsonList = categories.map((cat) => cat.toJson()).toList();
      return await _storage.saveObjectList(_categoriesKey, jsonList);
    } catch (e) {
      print('Error saving categories to storage: $e');
      return false;
    }
  }

  /// Update pinned stream
  Future<void> _updatePinnedStream() async {
    try {
      final pinnedNotes = await getPinnedNotes();
      _pinnedNotesController.add(pinnedNotes);
    } catch (e) {
      print('Error updating pinned stream: $e');
    }
  }

  /// Update archived stream
  Future<void> _updateArchivedStream() async {
    try {
      final archivedNotes = await getArchivedNotes();
      _archivedNotesController.add(archivedNotes);
    } catch (e) {
      print('Error updating archived stream: $e');
    }
  }
}
