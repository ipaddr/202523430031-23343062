import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Firestore Service untuk menangani operasi database Firestore
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final _firebaseService = FirebaseService();

  // ============ CREATE OPERATIONS ============

  /// Tambah dokumen baru ke collection
  Future<String> addDocument<T>({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _firebaseService.addDocument(
        collection: collection,
        data: {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Set dokumen dengan custom ID
  Future<void> setDocument<T>({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      final payload = merge
          ? data
          : {
              ...data,
              'createdAt': FieldValue.serverTimestamp(),
            };
      await _firebaseService.setDocument(
        collection: collection,
        docId: docId,
        data: payload,
        merge: merge,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ READ OPERATIONS ============

  /// Ambil single document
  Future<T?> getDocument<T>({
    required String collection,
    required String docId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final doc = await _firebaseService.getDocument(
        collection: collection,
        docId: docId,
      );
      if (doc.exists) {
        return fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Ambil semua dokumen dari collection
  Future<List<T>> getCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final snapshot = await _firebaseService.getCollection(
        collection: collection,
      );
      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ UPDATE OPERATIONS ============

  /// Update dokumen
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firebaseService.updateDocument(
        collection: collection,
        docId: docId,
        data: {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Increment field
  Future<void> incrementField({
    required String collection,
    required String docId,
    required String fieldName,
    required num value,
  }) async {
    try {
      await updateDocument(
        collection: collection,
        docId: docId,
        data: {
          fieldName: FieldValue.increment(value),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add to array
  Future<void> addToArray({
    required String collection,
    required String docId,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      await updateDocument(
        collection: collection,
        docId: docId,
        data: {
          fieldName: FieldValue.arrayUnion([value]),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove from array
  Future<void> removeFromArray({
    required String collection,
    required String docId,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      await updateDocument(
        collection: collection,
        docId: docId,
        data: {
          fieldName: FieldValue.arrayRemove([value]),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ DELETE OPERATIONS ============

  /// Hapus dokumen
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firebaseService.deleteDocument(
        collection: collection,
        docId: docId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============ QUERY OPERATIONS ============

  /// Query dengan kondisi
  Future<List<T>> query<T>({
    required String collection,
    required String field,
    required String operator,
    required dynamic value,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final snapshot = await _firebaseService.query(
        collection: collection,
        field: field,
        operator: operator,
        value: value,
      );
      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ STREAM OPERATIONS ============

  /// Real-time stream dari collection
  Stream<List<T>> streamCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _firebaseService.streamCollection(collection: collection).map(
          (snapshot) => snapshot.docs
              .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  /// Real-time stream dari single document
  Stream<T?> streamDocument<T>({
    required String collection,
    required String docId,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _firebaseService.streamDocument(
      collection: collection,
      docId: docId,
    ).map((doc) {
      if (doc.exists) {
        return fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ============ PAGINATION ============

  /// Get paginated documents
  Future<QuerySnapshot> getPaginatedDocuments({
    required String collection,
    required int pageSize,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firebaseService.firestore.collection(collection);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return await query.limit(pageSize).get();
    } catch (e) {
      rethrow;
    }
  }
}
